#!/bin/bash

# Script force-unmounts all external USB storage devices, if YubiKey is not inserted

# Note:
# - Uses the presence of the string "YubiKey OTP+FIDO+CCID" to detect your YubiKey
#	Adjust this string if your device appears differently
# - This script only unmounts external USB storage devices, runs as a LaunchDaemon
#	Run this script with root privileges

# Tested on Intel-based macOS, MacBook Pro 2017.

LOG_FILE="/tmp/yubikey_status.log"

# all the USB devices currently plugged into your computer
# looks through that list to see if there's a YubiKey that supports OTP, FIDO, and CCID
is_yubikey_connected() {
    ioreg -p IOUSB -l | grep -q "YubiKey OTP+FIDO+CCID"
}

# unmount all external USB storage devices.
unmount_external_disks() {
     # lists all disks connected to your Mac
     # filters out the lines that are the disk identifiers
     # prints first word of each line, the disk names
    for disk in $(diskutil list | grep '^/dev/disk' | awk '{print $1}'); do
        # gets detailed info about the current disk
	# finds the line that shows the device's location
	# line split into two parts, part one is before colon and part two is after; takes part two, the location   
	# removes extra spaces around the location string
        location=$(diskutil info "$disk" | grep "Device Location:" | awk -F: '{print $2}' | xargs)
	# location has to be External
        if [ "$location" = "External" ]; then
	    # current date and time
	    # creates message 
	    # prints the message and appends it to a log file 
            echo "$(date): Unmounting $disk because YubiKey is not present." | tee -a "$LOG_FILE"
	    # forcefully and safely unmounts the disk
            diskutil unmountDisk force "$disk"
        fi
    done
}

# endless loop, pauses for 5 seconds before repeating
while true; do
    # yubikey is connected logs message
    if is_yubikey_connected; then
        echo "$(date): YubiKey detected. External USB storage devices remain accessible." | tee -a "$LOG_FILE"
    # yubikey is not connected logs message
    else
        echo "$(date): YubiKey NOT detected. Unmounting external USB storage devices." | tee -a "$LOG_FILE"
        unmount_external_disks
    fi
    sleep 5
done