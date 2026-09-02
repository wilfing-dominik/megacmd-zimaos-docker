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

schedule_daily_check() {
    echo "0 4 * * * root apt-get update -qq && apt-get install -y --only-upgrade megacmd >> /var/log/megacmd-update.log 2>&1" \
        > /etc/cron.d/megacmd-update
    chmod 0644 /etc/cron.d/megacmd-update
    cron
}

check_for_updates
schedule_daily_check

echo "[megacmd-app] Starting mega-cmd-server..."
exec mega-cmd-server
