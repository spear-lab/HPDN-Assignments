#!/bin/bash
set -e

echo "[*] Starting Open vSwitch..."

mkdir -p /var/run/openvswitch
mkdir -p /etc/openvswitch

SCHEMA=$(find /usr/share/openvswitch -name vswitch.ovsschema | head -n 1)

if [ ! -f "$SCHEMA" ]; then
    echo "[ERROR] Could not find OVS schema"
    exit 1
fi

if [ ! -f /etc/openvswitch/conf.db ]; then
    echo "[*] Creating OVS database"
    ovsdb-tool create /etc/openvswitch/conf.db "$SCHEMA"
fi

ovsdb-server \
    --remote=punix:/var/run/openvswitch/db.sock \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --pidfile --detach

ovs-vswitchd --pidfile --detach

echo "[*] OVS started successfully."


# ---------------------------------------------------------
# Add Mininet mn() override function to bashrc
# ---------------------------------------------------------

MN_FUNC='
mn() {
    sudo /usr/bin/mn --controller=remote,ip=127.0.0.1,port=6633 \
        --switch=ovs,protocols=OpenFlow13 "$@"
}
'

# Install to root and user bashrc (if user exists)
for rc in "/root/.bashrc" "/home/${USERNAME}/.bashrc"; do
    if [ -f "$rc" ]; then
        if ! grep -q "mn()" "$rc"; then
            echo "[*] Adding mn() function to $rc"
            printf "%s\n" "$MN_FUNC" >> "$rc"
        else
            echo "[*] mn() already exists in $rc"
        fi
    fi
done

echo "[*] Entrypoint done. Launching shell..."

exec "$@"
