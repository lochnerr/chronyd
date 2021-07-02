FROM alpine:latest

LABEL MAINTAINER Richard Lochner, Clone Research Corp. <lochner@clone1.com> \
      org.label-schema.name = "chronyd" \
      org.label-schema.description = "Minimal chronyd container suitable for use with a Samba 4 Active Director Domain Controller." \
      org.label-schema.vendor = "Clone Research Corp" \
      org.label-schema.usage = "https://github.com/lochnerr/chronyd" \
      org.label-schema.url = "https://certbot.eff.org/about/" \
      org.label-schema.vcs-url = "https://github.com/lochnerr/chronyd.git"

# A minimal chronyd (network time server) service that is suitable
# for use with a Samba 4 Active Director Domain Controller.
#
# Volumes:
#  * /etc/chrony - directory for configuration and data files.
#  * /var/lib/chrony - persistent data directory.
#  * /var/lib/samba/ntp_signd - samba signing socket directory.
#
# Exposed ports:
#  * 123 - Network Time Protocol
#  * 323 - chronyc command port.
#
# Linux capabilities required:
#  * SYS_TIME - Set system clock

EXPOSE 123/udp
EXPOSE 323/udp

# Add packages.
RUN apk add --update --no-cache chrony

# Copy the local scripts.
COPY bin/* /usr/local/bin/

# Copy the assets to the container.
COPY assets/adjtime      /usr/share/chrony/
COPY assets/chrony.conf  /usr/share/chrony/
COPY assets/chrony.keys  /usr/share/chrony/

RUN true \
  # Save the original config file.
 && mv /etc/chrony/chrony.conf /etc/chrony/chrony-orig.conf \
  # Create link to default config.
 && ln -s /usr/share/chrony/chrony.conf /etc/chrony/chrony.conf \
  # Create link to default keys.
 && ln -s /usr/share/chrony/chrony.keys /etc/chrony/chrony.keys \
  # Create link to default adjtime.
 && ln -s /usr/share/chrony/adjtime     /etc/chrony/adjtime \
  # Make chrony run directory for socket.
 && mkdir -p /var/run/chrony \
 && chown chrony:chrony /var/run/chrony \
 && chmod 760 /var/run/chrony \
  # Create signing directory.
 && mkdir -p /var/lib/samba/ntp_signd \
 && chown root:chrony /var/lib/samba/ntp_signd

# Declare the volumes after setting up their content to preserve ownership.
VOLUME [ "/etc/chrony", "/var/lib/chrony", "/var/lib/samba/ntp_signd" ]

# Set the container build date.
RUN date > /etc/container-build-date

# Run the daemon in the foreground.
CMD ["chronyd-run"]

