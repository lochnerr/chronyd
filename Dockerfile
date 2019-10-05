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
#  * /srv/chrony - directory for configuration and data files.
#  * /srv/ntp_signd - samba signing socket directory.
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
RUN apk add --update --no-cache chrony tini

# Copy the local scripts.
COPY bin/* /usr/local/bin/

# Copy the assets to the container directory.
COPY assets/* /srv/chrony/

RUN true \
  # Save the original config file.
 && mv /etc/chrony/chrony.conf /etc/chrony/chrony-orig.conf \
  # Create log, run and dump directories.
 && mkdir -p /srv/chrony/log \
 && mkdir -p /srv/chrony/run \
 && mkdir -p /srv/chrony/dump \
  # Fix the ownership for the container directory.
 && chown -R chrony:chrony /srv/chrony \
 && chmod 775 /srv/chrony \
 && chmod 770 /srv/chrony/run \
  # Create link to config.
 && ln -sf /srv/chronyd/chrony.conf /etc/chrony/chrony.conf \
  # Make run directory for pidfile.
 && mkdir -p /var/run/chrony \
 && chown root:chrony /var/run/chrony \
  # Create signing directory.
 && mkdir -p /srv/ntp_signd \
 && chown root:chrony /srv/ntp_signd

# Declare the volumes after setting up their content to preserve ownership.
VOLUME [ "/srv/chrony", "/srv/ntp_signd" ]

# Let's use tini.
ENTRYPOINT ["/sbin/tini", "-v", "--"]

# Run the daemon in the foreground.
CMD ["/usr/sbin/chronyd", "-d", "-f", "/srv/chrony/chrony.conf"]

