#!/system/bin/sh

TIMEOUT=30

ui_print() {
  echo "$1"
}

print_banner() {
  ui_print "╭───────────────────────────────────────╮"
  ui_print "│  $1"
  ui_print "╰───────────────────────────────────────╯"
}

print_section() {
  ui_print ""
  ui_print "────────────────────────────────────────"
  ui_print "$1"
  ui_print "────────────────────────────────────────"
  ui_print ""
}

choose_option() {
  local prompt="$1"
  local default="$2"
  ui_print ""
  print_banner "$prompt"
  ui_print "🔼 = Yes | 🔽 = No  (Default: $default)"
  ui_print "Waiting up to ${TIMEOUT}s…"
  while :; do
    event=$(timeout "$TIMEOUT" getevent -qlc 1 2>/dev/null)
    code=$?
    if [ "$code" -eq 124 ] || [ "$code" -eq 143 ]; then
      [ "$default" = "Yes" ] && return 0 || return 1
    fi
    echo "$event" | grep -q "KEY_VOLUMEUP.*DOWN"   && return 0
    echo "$event" | grep -q "KEY_VOLUMEDOWN.*DOWN" && return 1
  done
}

get_cat_value() {
  local cat="$1"
  case "$cat" in
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
  local cat="$1"
  local val="$2"
  case "$cat" in
    ADS) v_ads="$val" ;;
    TRACKING) v_tracking="$val" ;;
    ANALYTICS) v_analytics="$val" ;;
    REPORTING) v_reporting="$val" ;;
    BACKGROUND) v_background="$val" ;;
    UPDATE) v_update="$val" ;;
    LOCATION) v_location="$val" ;;
    GEOFENCE) v_geofence="$val" ;;
    NEARBY) v_nearby="$val" ;;
    CAST) v_cast="$val" ;;
    DISCOVERY) v_discovery="$val" ;;
    SYNC) v_sync="$val" ;;
    CLOUD) v_cloud="$val" ;;
    AUTH) v_auth="$val" ;;
    WALLET) v_wallet="$val" ;;
    PAYMENT) v_payment="$val" ;;
    WEAR) v_wear="$val" ;;
    FITNESS) v_fitness="$val" ;;
  esac
}

print_section "Service Categories"
ui_print "Volume Up = YES | Volume Down = NO"
ui_print ""

v_ads=0; v_tracking=0; v_analytics=0; v_reporting=0; v_background=0; v_update=0
v_location=1; v_geofence=1; v_nearby=1; v_cast=1; v_discovery=1; v_sync=1
v_cloud=1; v_auth=1; v_wallet=1; v_payment=1; v_wear=1; v_fitness=1

GMS_CATEGORIES="ADS TRACKING ANALYTICS REPORTING BACKGROUND UPDATE LOCATION GEOFENCE NEARBY CAST DISCOVERY SYNC CLOUD AUTH WALLET PAYMENT WEAR FITNESS"

for cat in $GMS_CATEGORIES; do
  case "$cat" in
    ADS|TRACKING) emoji="🛑" ;;
    ANALYTICS|REPORTING) emoji="📊" ;;
    BACKGROUND|UPDATE) emoji="🔄" ;;
    LOCATION|GEOFENCE) emoji="📍" ;;
    NEARBY|CAST|DISCOVERY) emoji="📡" ;;
    SYNC|CLOUD|AUTH) emoji="☁️" ;;
    WALLET|PAYMENT) emoji="💰" ;;
    WEAR|FITNESS) emoji="⌚️" ;;
  esac
  
  current_value=$(get_cat_value "$cat")
  default="Yes"
  [ "$current_value" = "1" ] && default="No"
  
  choose_option "$emoji Disable $cat services?" "$default"
  set_cat_value "$cat" "$?"
done

print_section "📝 Summary"
for cat in $GMS_CATEGORIES; do
  value=$(get_cat_value "$cat")
  ui_print "$(printf '%-10s' "$cat"): $([ "$value" -eq 0 ] && echo Yes || echo No)"
done
ui_print ""
choose_option "Proceed?" "Yes"
[ $? -ne 0 ] && { ui_print "Cancelled."; exit 1; }

choose_option "📝 Generate shell script for these preferences?" "No"
GENERATE_SCRIPT=$?

print_section "⚙️ Disabling Services"

COUNTER=0
GMSLIST="$MODPATH/gmslist.txt"

if [ ! -f "$GMSLIST" ]; then
  ui_print "Error: gmslist.txt not found!"
  exit 1
fi

if [ "$GENERATE_SCRIPT" -eq 0 ]; then
  SCRIPT_DIR="/sdcard/GMS-Sakura"
  SCRIPT_FILE="$SCRIPT_DIR/GMS-Sakura.sh"
  
  mkdir -p "$SCRIPT_DIR"
  
  cat > "$SCRIPT_FILE" << 'EOF'
#!/system/bin/sh
a="su -c"

clear
echo "================================"
echo "      GMS Sakura🌸"
echo "================================"
echo ""
echo "1. Disable services"
echo "2. Enable services"
echo "3. Exit"
echo ""
echo -n "Choose option (1-3): "
read choice

case $choice in
  1) b="disable" ;;
  2) b="enable" ;;
  3) echo "Exiting..."; exit 0 ;;
  *) echo "Invalid option!"; exit 1 ;;
esac

EOF

fi

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
    
    if [ "$GENERATE_SCRIPT" -eq 0 ]; then
      echo "\$a pm \$b $SERVICE" >> "$SCRIPT_FILE"
    fi
  fi
done < "$GMSLIST"

if [ "$GENERATE_SCRIPT" -eq 0 ]; then
  ui_print "📝 Script saved to:"
  ui_print "$SCRIPT_FILE"
fi

print_section "✅ Complete"
ui_print "Disabled $COUNTER services"
ui_print "GMS optimized!"
