#!/bin/sh

set -e

# Start vsftpd
vsftpd /etc/vsftpd.conf &

# Run the monitor script in the background
/usr/local/bin/monitor.sh &

# Keep the container running
tail -f /dev/null
