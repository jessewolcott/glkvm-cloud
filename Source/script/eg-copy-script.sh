#!/bin/sh

HOSTNAME="106.55.158.199"
PORT="5912"
TOKEN="12tBwAsxMVDUd6BqbTErBEZbG56sotvw"
WEBRTC_IP="106.55.158.199"
WEBRTC_PORT="3478"
WEBRTC_USERNAME="JK5X5EbZ2DmLdy0ygJeqG6eZCav68BvS"
WEBRTC_PASSWORD="3kUdWh7XJQ3CPcth1cutS86FrDV2tEuP"

TARGET_DIR="/etc/kvmd/user/scripts"
SCRIPT_FILE="$TARGET_DIR/S01selfCloud"
WATCHDOG_SCRIPT="$TARGET_DIR/rtty-loop.sh"

# 1. Create directory
mkdir -p "$TARGET_DIR"

# 2. Write S01selfCloud script
cat <<EOF > "$SCRIPT_FILE"
#!/bin/sh

WATCHDOG_SCRIPT="$WATCHDOG_SCRIPT"

start() {
    if pgrep -f "\$WATCHDOG_SCRIPT" > /dev/null; then
        echo "selfHosted cloud is already started"
        return 0
    fi

    echo "starting self hosted cloud"

    # 写入 TURN 配置
    cat <<TURNCONF > /tmp/turnserver.json
{
    "username": "$WEBRTC_USERNAME",
    "ttl": 864000,
    "password": "$WEBRTC_PASSWORD",
    "uris": [
        "turn:$WEBRTC_IP:$WEBRTC_PORT?transport=udp",
        "turn:$WEBRTC_IP:$WEBRTC_PORT?transport=tcp"
    ]
}
TURNCONF

    device_id=\$(cat /proc/gl-hw-info/device_ddns)
    device_mac=\$(cat /proc/gl-hw-info/device_mac)

    mkdir -p \$(dirname "\$WATCHDOG_SCRIPT")

    cat <<RTTY > "\$WATCHDOG_SCRIPT"
#!/bin/sh
device_id=\$(cat /proc/gl-hw-info/device_ddns)
device_mac=\$(cat /proc/gl-hw-info/device_mac)
while true; do
    if ! pgrep -f "rtty.*-d \$device_mac" > /dev/null; then
        echo "[\$(date)] rtty not running, starting..."
        rtty -sx -T 2 -I "\$device_id" -h $HOSTNAME:$PORT -t $TOKEN -d "\$device_mac" &
    fi
    sleep 5
done
RTTY

    chmod +x "\$WATCHDOG_SCRIPT"
    nohup "\$WATCHDOG_SCRIPT" >> /tmp/rtty.log 2>&1 &
    echo "started selfHosted cloud"
}

stop() {
    echo "stopping selfHosted cloud"
    device_mac=\$(cat /proc/gl-hw-info/device_mac)
    pkill -f "\$WATCHDOG_SCRIPT"
    pkill -f "rtty.*-d \$device_mac"
    echo "stopped selfHosted cloud"
}

restart() {
    stop
    sleep 1
    start
}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart|reload)
        restart
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart}"
        exit 1
esac

exit 0
EOF

# 3. Add execution permissions
chmod +x "$SCRIPT_FILE"

# 4. Execute restart once
"$SCRIPT_FILE" restart
