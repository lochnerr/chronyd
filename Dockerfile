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
#  * /srv/chronyd - directory for configuration and data files.
#  * /ntp_signd - samba signing socket directory.
#
# Exposed ports:
#  * 123 - Network Time Protocol
#  * 323 - chrony daemon command port
#
# Linux capabilities required:
#  * SYS_TIME - Set system clock

EXPOSE 123/tcp
EXPOSE 323/tcp

# Add packages.
RUN apk add --update --no-cache chrony

# Copy the unit test script.
COPY bin/run-sut.sh /usr/local/bin

# Copy the assets to the container directory.
COPY assets/* /srv/chronyd/

RUN mkdir -p /srv/chronyd/log \
  # Save the original config file.
 && mv /etc/chrony/chrony.conf /etc/chrony/chrony-orig.conf \
  # Generate a key for chronyd.
 && chronyc keygen 1 MD5 160 > /srv/chronyd/chrony.keys \
  # Fix the ownership for the container directory.
 && chown -R chrony:chrony /srv/chronyd \
  # Create link to config.
 && ln -sf /srv/chronyd/chrony.conf /etc/chrony/chrony.conf \
  # Create link to keys.
 && ln -sf /srv/chronyd/chrony.keys /etc/chrony/chrony.keys \
  # Create link for driftfile.
 && rm -f /var/lib/chrony/chrony.drift \
 && ln -sf /srv/chronyd/chrony.drift /var/lib/chrony/chrony.drift \
  # Create link to adjtime file.
 && ln -sf /srv/chronyd/adjtime /etc/adjtime \
  # Create signing directory.
 && mkdir -p /ntp_signd \
  # Create link to signing directory.
 && mkdir -p /var/lib/samba/ntp_signd \
 && ln -sf /ntp_signd /var/lib/samba/ntp_signd

# Declare the volumes after setting up their content to preserve ownership.
VOLUME [ "/srv/chronyd", "/ntp_signd" ]

# Run the daemon in the foreground.
CMD ["/usr/sbin/chronyd", "-d", "-f", "/etc/chrony/chrony.conf"]

