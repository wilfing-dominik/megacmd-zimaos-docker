FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Tools needed to add MEGA's repo and check for updates
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    cron

# Add MEGA's official signed apt repository
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://mega.nz/linux/repo/Debian_12/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/mega.nz.gpg
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/mega.nz.gpg] https://mega.nz/linux/repo/Debian_12/ ./" \
    > /etc/apt/sources.list.d/mega.nz.list

# Install MEGAcmd from that repo
RUN apt-get update
RUN apt-get install -y --no-install-recommends megacmd

# The megacmd package installs its OWN copy of this repo entry during
# install (pointing at its own keyring, meganz-archive-keyring.gpg).
# Our bootstrap entry above was only needed to get the first install done --
# remove it now so future "apt-get update" calls don't see two conflicting
# entries for the same repo URL with different Signed-By keyrings.
RUN rm -f /etc/apt/sources.list.d/mega.nz.list /etc/apt/keyrings/mega.nz.gpg

RUN rm -rf /var/lib/apt/lists/*

# Runtime startup logic lives in its own file -- see entrypoint.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# /root/.megaCmd -> login session persists here
# /data          -> your HDD, mounted from the host via compose
VOLUME ["/root/.megaCmd", "/data"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
