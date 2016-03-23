You forgot to load xen backend modules. Guest domains will boot, but  
are waiting for the host (dom0) to provide device implementations.

    modprobe xen-netback
    modprobe xen-pciback
    modprobe xen-blkback

And while you're at it,

    modprobe xen-gntdev
    modprobe xen-gntalloc
    modprobe xen-acpi-processor

Also, if you're using systemd,

    cat << EOF > /etc/modules-load.d/xen.conf
    xen-blkback
    xen-netback
    xen-pciback
    xen-gntalloc
    xen-gntdev
    xen-acpi-processor
    tmem
    EOF

