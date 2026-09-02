#!/bin/bash
set -e

check_for_updates() {
    echo "[megacmd-app] Checking MEGA's repo for updates..."
    if apt-get update -qq; then
        apt-get install -y --only-upgrade megacmd || true
    else
        echo "[megacmd-app] Repo unreachable -- using currently installed version."
    fi
}

setup_machine_id() {
    # mega-sync needs /etc/machine-id to identify this device to MEGA's
    # servers. Minimal Debian images ship it empty, which causes:
    # "Unable to retrieve the ID of current device". We generate one once
    # and store it in the persistent config volume so it survives restarts --
    # a changing device ID would make MEGA treat every restart as a new device.
    local id_store="/root/.megaCmd/machine-id"
    if [ ! -s "$id_store" ]; then
        echo "[megacmd-app] Generating a stable machine-id for sync..."
        cat /proc/sys/kernel/random/uuid | tr -d '-' > "$id_store"
    fi
    cp "$id_store" /etc/machine-id
}

schedule_daily_check() {
    echo "0 4 * * * root apt-get update -qq && apt-get install -y --only-upgrade megacmd >> /var/log/megacmd-update.log 2>&1" \
        > /etc/cron.d/megacmd-update
    chmod 0644 /etc/cron.d/megacmd-update
    cron
}

check_for_updates
setup_machine_id
schedule_daily_check

echo "[megacmd-app] Starting mega-cmd-server..."
exec mega-cmd-server
