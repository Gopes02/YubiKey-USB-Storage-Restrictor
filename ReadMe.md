# YubiKey USB Storage Restrictor

This project provides a shell script for macOS that requires a Yubikey to be inserted for external USB storage devices to be used on Mac. 

> **Disclaimer:**  
> This script only affects external USB storage devices, for example flash drives, external hard drives. Other USB devices, like keyboards and mice, remain unaffected. Use this tool at your own risk, unmounting disks in use can lead to data loss. Test  before deploying.

## Yubikey paring 

1. Install Yubikey Manager 
    Download from [Yubico’s website](https://www.yubico.com/support/download/yubikey-manager/).

2. Open Yubikey Manager, insert Yubikey. 

3. Click **Applications**, then click **PIV**.

4. Click **Setup for MacOS**, then click **Setup for macOS** button on the bottom right corner, follow the on screen directions 

5. Verify Yubikey is paired correctly with Mac

    ```bash
    system_profiler SPUSBDataType | grep -i "yubikey"
    ```

6. Ready to continue with YubiKey USB Storage Restrictor

## How It Works

1. **Detection:**  
   The script uses the command `ioreg` to search for `"YubiKey OTP+FIDO+CCID"` string in the list of USB devices. If your YubiKey appears differently, edit the detection string in the `is_yubikey_connected` function.

2. **Unmounting:**  
   If the YubiKey is not detected, the script lists USB storage devices using `diskutil list` and forcefully unmounts any device labeled as "External".

3. **Continuous Monitoring:**  
   The script runs in an infinite loop w/ a 5-second delay between check to continuously enforce the rule.

## Installation & Setup

### 1. Place the Script

Move the `check_yubikey.sh` script to `/usr/local/bin/` and set the correct permissions:

```bash
sudo cp check_yubikey.sh /usr/local/bin/
sudo chmod 755 /usr/local/bin/check_yubikey.sh
sudo chown root:wheel /usr/local/bin/check_yubikey.sh
```

### 2. Place the plist file

Move the 'com.yubikey.usbrestrict.plist' file to '/Library/LaunchDaemons/' and set the correct permission:

```bash
sudo chown root:wheel /Library/LaunchDaemons/com.yubikey.usbrestrict.plist
sudo chmod 644 /Library/LaunchDaemons/com.yubikey.usbrestrict.plist
```

### 3. Load the daemon

```bash
sudo launchctl load -w /Library/LaunchDaemons/com.yubikey.usbrestrict.plist
```

## License

This project is released under the [MIT License](LICENSE).