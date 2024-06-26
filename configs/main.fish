set -lx prefix [ctcontainer]
set -lx ctcontainer_root /opt/ctcontainer
set -lx ctcontainer_share $HOME/ctcontainer_share
set -lx ctcontainer_log_level info
set -lx ctcontainer_backend chroot
set -lx ctcontainer_safety_level 1
set -lx ctcontainer_auto_umount 1
set -lx ctcontainer_x11 xhost
set -lx ctcontainer_source "https://images.linuxcontainers.org"
checkdependence file curl jq sudo
if test -d /etc/centerlinux/conf.d/
else
    sudo mkdir -p /etc/centerlinux/conf.d/
end
if test -e /etc/centerlinux/conf.d/ctcontainer.conf
    set ctcontainer_root (configure ctcontainer_root /etc/centerlinux/conf.d/ctcontainer.conf)
    set ctcontainer_share (configure ctcontainer_share /etc/centerlinux/conf.d/ctcontainer.conf)
    set ctcontainer_log_level (configure log_level /etc/centerlinux/conf.d/ctcontainer.conf)
    set ctcontainer_backend (configure backend /etc/centerlinux/conf.d/ctcontainer.conf)
    set ctcontainer_safety_level (configure safety_level /etc/centerlinux/conf.d/ctcontainer.conf)
    set ctcontainer_auto_umount (configure auto_umount /etc/centerlinux/conf.d/ctcontainer.conf)
    set ctcontainer_x11 (configure x11 /etc/centerlinux/conf.d/ctcontainer.conf)
    set ctcontainer_source (configure source /etc/centerlinux/conf.d/ctcontainer.conf)
else
    ctconfig_init
end
if test -d $ctcontainer_root
else
    logger 4 "root.ctcontainer not found,try to create it under root"
    sudo mkdir -p $ctcontainer_root
end
argparse -i -n $prefix 'r/ctroot=' 's/ctshare=' 'l/ctlog_level=' 'u/ctauto_umount=' 'p/ctsafety_level=' 'b/ctbackend=' 'x/x11=' 'e/source=' -- $argv
if set -q _flag_ctroot
    set ctcontainer_root $_flag_ctroot
end
if set -q _flag_ctshare
    set ctcontainer_share $_flag_ctshare
end
if set -q _flag_ctlog_level
    set ctcontainer_log_level $_flag_ctlog_level
end
if set -q _flag_ctauto_umount
    set ctcontainer_auto_umount $_flag_ctauto_umount
end
if set -q _flag_ctsafety_level
    set ctcontainer_safety_level $_flag_ctsafety_level
end
if set -q _flag_ctbackend
    set ctcontainer_backend $_flag_ctbackend
end
if set -q _flag_x11
    set ctcontainer_x11 $_flag_x11
end
if set -q _flag_source
    set ctcontainer_source $_flag_source
end
if [ "$ctcontainer_log_level" = debug ]
    logger 3 "set root.ctcontainer -> $ctcontainer_root"
    logger 3 "set share.ctcontainer -> $ctcontainer_share"
    logger 3 "set log_level.ctcontainer -> $ctcontainer_log_level"
    logger 3 "set backend.ctcontainer -> $ctcontainer_backend"
    logger 3 "set safety_level.ctcontainer -> $ctcontainer_safety_level"
    logger 3 "set auto_umount.ctcontainer -> $ctcontainer_auto_umount"
    logger 3 "set x11.ctcontainer -> $ctcontainer_x11"
    logger 3 "set source.ctcontainer -> $ctcontainer_source"
end
switch $argv[1]
    case service
        service $argv[2..-1]
    case purge
        purge $argv[2..-1]
    case init
        init $argv[2..-1]
    case import
        import $argv[2..-1]
    case run
        switch $ctcontainer_backend
            case chroot
                chroot_run $argv[2..-1]
            case nspawn
                nspawn_run $argv[2..-1]
            case '*'
                logger 5 "Unknown backend $ctcontainer_backend, abort"
                exit 128
        end
    case load
        set ctload true
        switch $ctcontainer_backend
            case chroot
                chroot_run $argv[2..-1]
            case nspawn
                nspawn_run $argv[2..-1]
            case '*'
                logger 5 "Unknown backend $ctcontainer_backend, abort"
                exit 128
        end
    case list
        list $argv[2..-1]
    case v version
        logger 1 "Anna@build0"
    case install
        install ctcontainer
    case uninstall
        uninstall ctcontainer
    case h help '*'
        help_echo
end
