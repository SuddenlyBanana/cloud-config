profile_reprovision() {
        profile_standard
        image_ext="tar.gz"
        output_format="rootfs"
        apkovl="aports/scripts/genapkovl-mkimgoverlay.sh"
        apks="\$apks podman"
}