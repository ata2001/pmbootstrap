import pmb.chroot


def create_zip(args, suffix):
    """
    Create android recovery compatible installer zip.
    """
    zip_root = "/usr/share/postmarketos-android-recovery-installer/"
    rootfs = "/mnt/rootfs_" + args.device

    # Install recovery installer package in buildroot
    pmb.chroot.apk.install(args,
                           ["postmarketos-android-recovery-installer"],
                           suffix)

    # Create config file for the recovery installer
    with open(args.work + "/chroot_" + suffix + "/tmp/install_options",
              "w") as install_options:
        install_options.write(
            "\n".join(['DEVICE="{}"'.format(args.device),
                       'FLASH_BOOTIMG="{}"'.format(
                           str(args.recovery_flash_bootimg).lower()),
                       'INSTALL_PARTITION="{}"'.format(
                           args.recovery_install_partition),
                       'CIPHER="{}"'.format(args.cipher),
                       'FDE="{}"'.format(
                           str(args.full_disk_encryption).lower())]))

    commands = [
        # Move config file from /tmp/ to zip root
        ["mv", "/tmp/install_options", "install_options"],
        # Copy boot.img to zip root
        ["cp", rootfs + "/boot/boot.img-" + args.device, "boot.img"],
        # Create tar archive of the rootfs
        ["tar", "-pczf", "rootfs.tar.gz", "--exclude", "./home/user/*",
         "-C", rootfs, "."],
        ["build-recovery-zip"]]
    for command in commands:
        pmb.chroot.root(args, command, suffix, working_dir=zip_root)
