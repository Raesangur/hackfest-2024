#!/bin/sh

MONITORED_DIR="/home/${FTP_USER}"
LOG_FILE="/var/log/monitor.log"
ERROR_LOG_FILE="/var/log/monitor_error.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE 2>&1
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $ERROR_LOG_FILE 2>&1
}

extract_label() {
    local img_file="$1"
    local label=$(blkid -o value -s LABEL "$img_file" 2>>$ERROR_LOG_FILE)
    echo "$label"
}

extract_fs_type() {
    local img_file="$1"
    local fs_type=$(file -s "$img_file" 2>>$ERROR_LOG_FILE | grep -ioE '(ext[2-4]|fat|ntfs|xfs|btrfs|hfs|iso9660)')
    echo "$fs_type"
}

log "Starting monitor script"
log "Monitoring directory: $MONITORED_DIR"

log "Directory contents before inotifywait:"
ls -l $MONITORED_DIR >> $LOG_FILE 2>&1

inotifywait -m -e create --format "%w%f" $MONITORED_DIR 2>>$ERROR_LOG_FILE | while read FILE
do
    log "Detected new file: $FILE"
    sleep 5
    if [[ $FILE == *.img ]]; then
        log "Processing image file: $FILE"
        DEVNAME=$(extract_label "$FILE")
        ID_FS_TYPE=$(extract_fs_type "$FILE")
        
        if [ -z "$DEVNAME" ]; then
            log "Error: Could not extract label from $FILE"
            continue
        fi
        
        if [ -z "$ID_FS_TYPE" ]; then
            log "Error: Could not determine filesystem type from $FILE"
            continue
        fi
        
        log "Extracted DEVNAME: $DEVNAME, ID_FS_TYPE: $ID_FS_TYPE"
        
        ACTION="add"
        DEVTYPE="partition"
        
        DEVNAME="$DEVNAME" ACTION="$ACTION" ID_FS_TYPE="$ID_FS_TYPE" DEVTYPE="$DEVTYPE" /usr/local/bin/mount.sh "$FILE" >> $LOG_FILE 2>&1
    fi
done
