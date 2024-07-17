# Checking for installation environment
# Abort TWRP installation with error message when user tries to install this module in TWRP

if [ $BOOTMODE = false ]; then
	ui_print "- Installing through TWRP Not supported"
	ui_print "- Install this module via APatch/KernelSU/Magisk Manager"
	abort "- Aborting installation !!"
fi
api_level_arch_detect


# Process Monitor Tool (PMT) variables
PMT_MODULE_PATH="/data/adb/modules/magisk_proc_monitor"
PMTURL=https://github.com/HuskyDG/magisk_proc_monitor/releases/latest
PMT_VERSION="$(grep_prop versionCode "$PMT_MODULE_PATH/module.prop")"

# Check Process Monitor Tool
[ ! -d "$PMT_MODULE_PATH" ] && {
	ui_print "- Process monitor tool is not installed"
	ui_print "  Please install it from $PMTURL"
	am start -a android.intent.action.VIEW -d "$PMTURL" &>/dev/null
	abort "- Aborting installation !!"
}

if [ "$PMT_VERSION" -lt 10 ]; then
	ui_print "! Process Monitor Tool v2.3 or above is required"
	am start -a android.intent.action.VIEW -d "$PMTURL" &>/dev/null
	abort "- Aborting installation !!"
fi

if [ -f "$PMT_MODULE_PATH/disable" ] || [ -f "$PMT_MODULE_PATH/remove" ]; then
	ui_print "! Process Monitor Tool is either be removed or disabled."
	abort "- Aborting installation !!"
fi


# APK variables
APPNAME="YouTube"
PKGNAME="$(grep_prop package "$MODPATH/module.prop")"
STOCKAPPVER=$(dumpsys package $PKGNAME | grep versionName | cut -d= -f 2 | sed -n '1p')
RVAPPVER="$(grep_prop version "$MODPATH/module.prop")"
URL="https://www.apkmirror.com/apk/google-inc/youtube/youtube-$(echo -n "$RVAPPVER" | tr "." "-")-release/"

if [ ! -d "/proc/1/root/data/data/$PKGNAME" ]
then
	ui_print "- $APPNAME app is not installed"
	am start -a android.intent.action.VIEW -d "$URL" &>/dev/null
	abort "- Aborting installation !!"
fi

if [ "$STOCKAPPVER" != "$RVAPPVER" ]
then
	ui_print "- Installed $APPNAME version = $STOCKAPPVER"
	ui_print "- $APPNAME Revanced version = $RVAPPVER"
	ui_print "- App Version Mismatch !!"
	am start -a android.intent.action.VIEW -d "$URL" &>/dev/null
	abort "- Aborting installation !!"
fi

# Disable battery optimization for YouTube ReVanced
sleep 1
ui_print "- Disable Battery Optimization for YouTube ReVanced"
dumpsys deviceidle whitelist +$PKGNAME > /dev/null 2>&1

ui_print "- Install Successful !!"
