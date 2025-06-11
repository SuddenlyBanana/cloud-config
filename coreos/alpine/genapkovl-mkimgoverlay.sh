#!/bin/sh -e

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	echo "usage: $0 hostname"
	exit 1
fi

cleanup() {
	rm -rf "$tmp"
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

overlay="$tmp"/overlay
mkdir -pv "$overlay"

# mkdir -p "$tmp"/etc/apk
# makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
# alpine-base
# podman
# EOF

mkdir -pv "$overlay"/etc/init.d
makefile root:root 0755 "$overlay"/etc/init.d/bootstrap <<EOF
#!/sbin/openrc-run

description="bootstrapping script"
name="bootstrap"

command="/usr/local/bin/bootstrap"
command_background=true
pidfile="/run/${RC_SVCNAME}.pid"
EOF

rc_add bootstrap default

mkdir -pv "$overlay"/usr/local/bin
mv $BUILD_DIR/bootstrap "$overlay"/usr/local/bin

mkdir -pv "$overlay"/reprovision
mv $BUILD_DIR/coreos-image.qcow2.gz "$overlay"/reprovision
mv $BUILD_DIR/coreos-image.qcow2.gz.sig "$overlay"/reprovision
mv $BUILD_DIR/coreos-installer.tar  "$overlay"/reprovision
mv $BUILD_DIR/ucore-ignition.ign  "$overlay"/reprovision
chmod -R 777 "$overlay"/reprovision

tar -cvC "$overlay" --no-recursion $( find "$overlay" | sed "s|"$overlay"/||" | sort | xargs ) | gzip -9n > $HOSTNAME.apkovl.tar.gz