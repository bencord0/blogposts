Recently, I've been working on ways to create OpenStack ready cloud images. While I do have acess to a local instance of OpenStack, sometimes it becomes necessary to test the images on a local machine to fine tune the boot process.

The minimum necessary files needed to boot a cloud image are the `meta-data` and `user-data` files.

meta-data

    instance-id: iid-gentoo
    local-hostname: gentoo

user-data

    #cloud-config
    ssh_authorized_keys:
      - ssh-ed25519 AAAA...

For more examples about what you can include in a cloud-config file, see the [documentation](http://cloudinit.readthedocs.org/en/latest/topics/examples.html).

Finally, pack these two files into a FAT32 filesystem.

    $ truncate -s 2M cloudconfig.img
    $ /usr/sbin/mkfs.vfat -n cidata cloudconfig.img
    $ mcopy -oi cloudconfig.img user-data meta-data ::

To test it out, you can download one of my Gentoo OpenStack images.

    $ wget https://dl.condi.me/gentoo-systemd/latest/gentoo-systemd.qcow2
    $ qemu-img resize gentoo-systemd.qcow2 50G
    $ qemu-system-x86_64 \
    -enable-kvm \
    -drive file=gentoo-systemd.qcow2,if=virtio,format=qcow2 \
    -drive file=cloudconfig.img,if=virtio,format=raw \
    -net nic -net user,hostfwd=tcp::2222-:22 \
    -nographic


In a new shell, login over ssh.

    $ ssh gentoo@localhost -p 2222 \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

