#!/bin/sh

MOUNT="/bin/mount"
EXTCD="none"
FILESYSTEM="-t text2,text3,text4,tfat,texfat,tntfs"
LOG_FILE="/var/log/mount.log"

DEVN=${DEVNAME##*/}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE 2>&1
}

check_blacklist() {
    blacklisted_chars=$(echo "$1" | grep -o '[$();|&><`]')
    if [ -n "$blacklisted_chars" ]; then
        log "Error: DEVNAME contains blacklisted characters: $blacklisted_chars"
        exit 1
    fi
}

mount_fs() {
    DEVNAME=$(echo "$DEVNAME" | tr -d '\\')
    check_blacklist "$DEVNAME"
    log "Mounting filesystem: $MOUNT ${FILESYSTEM} $DEVNAME"
    eval "$MOUNT ${FILESYSTEM} $DEVNAME" >> $LOG_FILE 2>&1
}

log "Starting mount script"

if [ "$ACTION" = "add" ] && [ -n "$DEVNAME" ] && [ -n "$ID_FS_TYPE" ] && [ "$DEVTYPE" = "partition" ]; then
   log "Action is add, DEVNAME: $DEVNAME, ID_FS_TYPE: $ID_FS_TYPE, DEVTYPE: $DEVTYPE"
   mount_fs
elif [ "$ACTION" = "add" ] && [ -n "$DEVNAME" ] && [ -n "$ID_FS_TYPE" ] && [ ! -n "$UDISKS_PARTITION_TABLE" ]; then
   partition_num=$(grep "${DEVN}[0-9]" /proc/partitions | wc -l)
   log "Partition number: $partition_num"
   if [ ${partition_num} -eq 0 ] || [ -z "${partition_num}" ]; then
      mount_fs
   fi
fi
