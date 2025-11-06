#!/system/bin/sh

SKIPUNZIP=1

ui_print() { echo "$1"; }

choose_option() {
  ui_print "$1"
  ui_print "Vol+ = Yes | Vol- = No (Default: $2)"
  START=$(date +%s)
  while [ $(($(date +%s) - START)) -lt 60 ]; do
    KEY=$(getevent -qlc 1)
    echo "$KEY" | grep -q "KEY_VOLUMEUP.*DOWN" && return 0
    echo "$KEY" | grep -q "KEY_VOLUMEDOWN.*DOWN" && return 1
  done
  [ "$2" = "Yes" ] && return 0 || return 1
}

get_cat_value() {
  case "$1" in
    ADS) echo "$v_ads" ;;
    TRACKING) echo "$v_tracking" ;;
    ANALYTICS) echo "$v_analytics" ;;
    REPORTING) echo "$v_reporting" ;;
    BACKGROUND) echo "$v_background" ;;
    UPDATE) echo "$v_update" ;;
    LOCATION) echo "$v_location" ;;
    GEOFENCE) echo "$v_geofence" ;;
    NEARBY) echo "$v_nearby" ;;
    CAST) echo "$v_cast" ;;
    DISCOVERY) echo "$v_discovery" ;;
    SYNC) echo "$v_sync" ;;
    CLOUD) echo "$v_cloud" ;;
    AUTH) echo "$v_auth" ;;
    WALLET) echo "$v_wallet" ;;
    PAYMENT) echo "$v_payment" ;;
    WEAR) echo "$v_wear" ;;
    FITNESS) echo "$v_fitness" ;;
  esac
}

set_cat_value() {
  case "$1" in
    ADS) v_ads="$2" ;;
    TRACKING) v_tracking="$2" ;;
    ANALYTICS) v_analytics="$2" ;;
    REPORTING) v_reporting="$2" ;;
    BACKGROUND) v_background="$2" ;;
    UPDATE) v_update="$2" ;;
    LOCATION) v_location="$2" ;;
    GEOFENCE) v_geofence="$2" ;;
    NEARBY) v_nearby="$2" ;;
    CAST) v_cast="$2" ;;
    DISCOVERY) v_discovery="$2" ;;
    SYNC) v_sync="$2" ;;
    CLOUD) v_cloud="$2" ;;
    AUTH) v_auth="$2" ;;
    WALLET) v_wallet="$2" ;;
    PAYMENT) v_payment="$2" ;;
    WEAR) v_wear="$2" ;;
    FITNESS) v_fitness="$2" ;;
  esac
}

unzip -o "$ZIPFILE" -d "$MODPATH" >&2

GMSLIST="$MODPATH/gmslist.txt"
SCRIPT_FILE="$MODPATH/action.sh"
UNINSTALL_SCRIPT="$MODPATH/uninstall.sh"

[ ! -f "$GMSLIST" ] && { ui_print "Error: gmslist.txt not found!"; exit 1; }

ui_print ""
ui_print "GMS Sakura 🌸"
ui_print ""

v_ads=0; v_tracking=0; v_analytics=0; v_reporting=0; v_background=1; v_update=0
v_location=1; v_geofence=0; v_nearby=0; v_cast=0; v_discovery=0; v_sync=0
v_cloud=0; v_auth=0; v_wallet=0; v_payment=1; v_wear=0; v_fitness=0

GMS_CATEGORIES="ADS TRACKING ANALYTICS REPORTING BACKGROUND UPDATE LOCATION GEOFENCE NEARBY CAST DISCOVERY SYNC CLOUD AUTH WALLET PAYMENT WEAR FITNESS"

for cat in $GMS_CATEGORIES; do
  case "$cat" in
    ADS) emoji="🚫" ;;
    TRACKING) emoji="👁️" ;;
    ANALYTICS) emoji="📈" ;;
    REPORTING) emoji="📝" ;;
    BACKGROUND) emoji="⏱️" ;;
    UPDATE) emoji="🔄" ;;
    LOCATION) emoji="🗺️" ;;
    GEOFENCE) emoji="🔷" ;;
    NEARBY) emoji="📶" ;;
    CAST) emoji="📺" ;;
    DISCOVERY) emoji="🔍" ;;
    SYNC) emoji="🔃" ;;
    CLOUD) emoji="☁️" ;;
    AUTH) emoji="🔐" ;;
    WALLET) emoji="💳" ;;
    PAYMENT) emoji="💰" ;;
    WEAR) emoji="⌚" ;;
    FITNESS) emoji="🏃" ;;
  esac
  
  current_value=$(get_cat_value "$cat")
  default="Yes"
  [ "$current_value" = "1" ] && default="No"
  
  choose_option "$emoji Disable $cat?" "$default"
  set_cat_value "$cat" "$?"
done

ui_print ""
for cat in $GMS_CATEGORIES; do
  value=$(get_cat_value "$cat")
  ui_print "$cat: $([ "$value" -eq 0 ] && echo Disable || echo Keep)"
done

ui_print ""
choose_option "Proceed?" "Yes"
[ $? -ne 0 ] && { ui_print "Cancelled"; rm -rf "$MODPATH"; exit 1; }

ui_print ""
ui_print "Disabling services..."

cat > "$SCRIPT_FILE" << 'EOF'
#!/system/bin/sh
ui_print() { echo "$1"; }
choose_option() {
  ui_print "$1"
  ui_print "Vol+ = $3 | Vol- = $4"
  START=$(date +%s)
  while [ $(($(date +%s) - START)) -lt 60 ]; do
    KEY=$(getevent -qlc 1)
    echo "$KEY" | grep -q "KEY_VOLUMEUP.*DOWN" && return 0
    echo "$KEY" | grep -q "KEY_VOLUMEDOWN.*DOWN" && return 1
  done
  [ "$2" = "$3" ] && return 0 || return 1
}
clear
ui_print "GMS Sakura 🌸"
choose_option "Select Action" "Disable" "Disable" "Enable"
[ $? -eq 0 ] && action="disable" || action="enable"
ui_print "${action}ing..."
COUNTER=0
EOF

cat > "$UNINSTALL_SCRIPT" << 'UNINSTALL_START'
#!/system/bin/sh
until [ -d "/sdcard" ]; do sleep 1; done
echo "GMS Sakura 🌸 Uninstaller"
COUNTER=0
UNINSTALL_START

COUNTER=0

while IFS="|" read -r SERVICE CATEGORY; do
  [ -z "$SERVICE" ] && continue
  echo "$SERVICE" | grep -q "^#" && continue
  
  SHOULD_DISABLE=1
  case "$CATEGORY" in
    ads) SHOULD_DISABLE="$v_ads" ;;
    tracking) SHOULD_DISABLE="$v_tracking" ;;
    analytics) SHOULD_DISABLE="$v_analytics" ;;
    reporting) SHOULD_DISABLE="$v_reporting" ;;
    background) SHOULD_DISABLE="$v_background" ;;
    update) SHOULD_DISABLE="$v_update" ;;
    location) SHOULD_DISABLE="$v_location" ;;
    geofence) SHOULD_DISABLE="$v_geofence" ;;
    nearby) SHOULD_DISABLE="$v_nearby" ;;
    cast) SHOULD_DISABLE="$v_cast" ;;
    discovery) SHOULD_DISABLE="$v_discovery" ;;
    sync) SHOULD_DISABLE="$v_sync" ;;
    cloud) SHOULD_DISABLE="$v_cloud" ;;
    auth) SHOULD_DISABLE="$v_auth" ;;
    wallet) SHOULD_DISABLE="$v_wallet" ;;
    payment) SHOULD_DISABLE="$v_payment" ;;
    wear) SHOULD_DISABLE="$v_wear" ;;
    fitness) SHOULD_DISABLE="$v_fitness" ;;
  esac
  
  if [ "$SHOULD_DISABLE" = "0" ]; then
    pm disable "$SERVICE" >/dev/null 2>&1
    COUNTER=$((COUNTER+1))
    echo "pm \"\$action\" \"$SERVICE\" >/dev/null 2>&1" >> "$SCRIPT_FILE"
    echo "pm enable \"$SERVICE\" >/dev/null 2>&1" >> "$UNINSTALL_SCRIPT"
  fi
done < "$GMSLIST"

cat >> "$SCRIPT_FILE" << EOF

ui_print ""
ui_print "✅ Complete"
if [ "\$action" = "disable" ]; then
  ui_print "Disabled $COUNTER services."
else
  ui_print "Enabled $COUNTER services."
fi
EOF

cat >> "$UNINSTALL_SCRIPT" << 'UNINSTALL_END'
echo "✅ Enabled $COUNTER services"
UNINSTALL_END

chmod 0755 "$SCRIPT_FILE" "$UNINSTALL_SCRIPT"

ui_print ""
ui_print "✅ Disabled $COUNTER services"