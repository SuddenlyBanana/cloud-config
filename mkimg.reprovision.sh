profile_reprovision() {
        profile_base
        image_ext="tar.gz"
        arch="x86_64"
        output_format="targz"
        apks="$apks podman"
        apkovl="genapkovl-mkimgoverlay.sh"
}