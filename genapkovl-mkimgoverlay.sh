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

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
podman
EOF

makefile root:root 0755 "$tmp"/etc/init.d/bootstrap <<EOF
#!/sbin/openrc-run

# SPDX-FileCopyrightText: Copyright 2022-2023, macmpi
# SPDX-License-Identifier: MIT

description="boostrappring script"
name="bootstrap"

command="/usr/local/bin/bootstrap"
command_background=true
pidfile="/run/${RC_SVCNAME}.pid"
EOF

rc_add podman boot
rc_add bootstrap boot

mv $TMPDIR/bootstrap "$tmp"/usr/local/bin/bootstrap

mv $TMPDIR/coreos-image.qcow2.gz "$tmp"/reprovision
mv $TMPDIR/coreos-image.qcow2.gz.sig "$tmp"/reprovision
mv $TMPDIR/coreos-installer.tar  "$tmp"/reprovision
mv $TMPDIR/ucore-ignition.ign  "$tmp"/reprovision
chmod -R 777 "$tmp"/reprovision

tar -c -C "$tmp" etc | gzip -9n > $HOSTNAME.apkovl.tar.gz