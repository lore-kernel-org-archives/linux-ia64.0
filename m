From: Bill Nottingham <notting@redhat.com>
Date: Tue, 10 Jul 2001 14:44:13 +0000
Subject: [Linux-ia64] Red Hat Linux 7.1 for Itanium now available - Release Notes
Message-Id: <marc-linux-ia64-105590693005836@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005835@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005835@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Red Hat Linux/Itanium 7.1 Release Notes
-----------------------------------------------

This document describes features that are new to Red Hat Linux/Itanium, but
may not have been available prior to our documentation being finalized.
For the very latest information, please read the RELEASE-NOTES file on the
Red Hat Linux CD #1.

Last-Minute Changes
-------------------

     o Boot loader Change -- Red Hat Linux/Itanium uses the ELILO boot
       loader.  Older, prerelease evaluation Itanium systems shipped with
       an older boot loader (known as ELI).  These systems must be upgraded
       to use ELILO before installing Red Hat Linux/Itanium.

       If you have used ELI, please note that the change to ELILO affects
       the boot loader configuration file names:

         - ELI used eli.cfg
         - ELILO uses elilo.conf

    o Partitioning -- Red Hat Linux/Itanium supports EFI GUID Partition
      Tables. These partition tables are created by default on unpartitioned
      disks by Disk Druid, and can be edited with parted. fdisk does
      not currently support EFI GPT partitioning. Note that Disk Druid
      only supports 64 partitions per disk for EFI GPT partitioning; any
      partition table entries greater than 64 will be REMOVED if Disk
      Druid is used.

    o Automatic Partitioning -- Red Hat Linux/Itanium only supports
      automatic partitioning for Server installs. Note that choosing
      automatic partitioning will erase ALL existing partitions, destroying
      ALL data on ALL disks.

    o Firmware revisions on prototype hardware -- If you intend to run Red
      Hat Linux/Itanium on prototype Itanium hardware, please be sure that
      your hardware is using the latest revision firmware.  Contact your
      system's vendor if you require a firmware update.  Note that
      non-prototype Itanium systems should already be at the appropriate
      revision.

    o Upgrades from beta versions not supported -- Please note that
      upgrades from a Red Hat Linux beta to a final version of Red Hat
      Linux/Itanium are not officially supported.  Such upgrades may or may
      not work, so please plan on performing a fresh install when moving to
      a final Red Hat Linux release.

    o Reminder regarding NFS, FTP, or HTTP installations -- Because the Red
      Hat Linux Itanium installation program is capable of installing Red
      Hat Linux from multiple CD-ROMs, if you intend to support NFS, FTP,
      or HTTP installations it is no longer possible to simply mount a
      single Red Hat Linux CD-ROM, and install from it.

      Instead, you must copy the RedHat directory from each CD-ROM
      comprising Red Hat Linux Itanium 7.1 onto a disk drive:

        - Insert CD 1
          mount /dev/cdrom /mnt/cdrom
          cp -var /mnt/cdrom/RedHat /location/of/disk/space
          umount /mnt/cdrom

        - Insert CD 2
          mount /dev/cdrom /mnt/cdrom
          cp -var /mnt/cdrom/RedHat /location/of/disk/space
          umount /mnt/cdrom

      You must then make /location/of/disk/space accessible to the
      installation program (for example, exporting it for NFS
      installations):

        - Export /location/of/disk/space


Installation-Related Enhancements and Changes
---------------------------------------------

The Red Hat Linux 7.1 installation program includes a number of new
features.  For more information, please refer to the Official Red Hat Linux
Installation Guide.


    o Swap-related issues -- The 2.4 kernel is more aggressive than the 2.2
      kernel in its use of swap space.  However, as with previous versions
      of the kernel, the optimal sizing of swap space remains dependent on
      the following:

        - The amount of RAM installed
        - The amount of disk space available for swap
        - The applications being run
        - The mix of applications that are run concurrently

      No rule-of-thumb can possibly take all these data points into
      account.  However, we recommend the following swap sizes:

        - Single-user systems with less than 128MB physical RAM: 256MB

        - Single-user systems and low-end servers with more than 128MB
          physical RAM: two times physical RAM (2xRAM)

        - Dedicated servers with more than 512MB physical RAM: highly
          dependent on environment (must be determined on a case-by-case
          basis)

      While it is certainly possible for systems with specific
      configurations and application loads to run with less (or even no)
      swap space, these guidelines attempt to ensure that you will not run
      out of swap.  The old saying certainly applies to swap space:

          "It's better to have it and not need it, than to need
           it and not have it."

    o XFree86 4.0.3 -- The Red Hat Linux 7.1 installation program includes
      improved test screens and better detection of video memory, doing
      more than ever to help you get everything correct with a minimum of
      fuss.

    o Firewall Configuration -- For added security, you can now configure a
      firewall as part of your system installation.  You can choose from
      two levels of security, as well as choosing which common system
      services should be allowed or disallowed by default.

      Please note that both "medium" and "high" firewall settings will
      cause RPC-based services (such as NIS or NFS) to be blocked, and
      thus fail.

    o Hard Drive Installation - ISO images are now required for hard drive
      installations, making it no longer necessary to copy and install the
      entire tree. Instead, simply put the required ISO images in a
      directory.  During the hard drive installation, point the Red Hat
      Linux installation program at that directory.  In addition, since Red
      Hat publishes MD5 checksums for all ISO images, it is now possible to
      ensure that you are using officially-released software by running the
      md5sum program against your ISO images, and comparing the checksums
      against the ones published by Red Hat.

    o Language Selection -- Language selection has been significantly
      re-vamped.  It is now possible to install in one language, but
      specify that the system, after installation, will operate in another
      language.

    o Disk Druid Improvements -- Disk Druid now detects partition table
      inconsistencies, such as partitions that do not end on cylinder
      boundaries.  This can be caused if the geometry of a hard disk drive
      is detected differently than when the drive was originally
      partitioned.  In these cases, we recommend that you use the fdisk
      program to more closely inspect these inconsistencies, or choose to
      skip the drive entirely.

    o Graphical Kickstart Configuration -- Red Hat Linux 7.1 now provides a
      graphical interface for creating kickstart configurations, allowing
      custom, unattended installations to be created with greater ease than
      ever before.

    o Improved Rescue Mode -- Rescue mode now attempts to mount the
      filesystems listed in /etc/fstab (assuming the root filesystem can be
      found).  The filesystems are mounted under /mnt/sysimage.  This
      eliminates a very confusing step for users using rescue-mode for the
      first time.

    o New Authentication Configuration Security Option -- Authentication
      configuration now includes the ability to use Transport Layer
      Security (TLS) when performing lookups.  TLS allows LDAP clients to
      use an encrypted connection when performing authentication.

    o Miscellaneous Installation Program Improvements -- Overall, there are
      many additional tests and checks performed to catch potential
      problems which previously caused tracebacks (installer crashes).
      This should reduce the number of poor out-of-box experiences for
      newer users.

System-Related Enhancements and Changes
---------------------------------------

There are many features new to Red Hat Linux 7.1 that are not part of the
installation process.  Some new features are server-oriented programs,
while others are new applications or desktop environment changes.  This
list will provide a bit more information about what to expect from Red Hat
Linux 7.1 once you are actually using the OS.

    o Upgraded Core System Components -- The following major system
      components have been upgraded in Red Hat Linux 7.1:

        - kernel 2.4.x (with additional fixes)
        - glibc 2.2.3
        - KDE 2.1.1
        - XFree86 4.0.3 with the Xft anti-aliased font render extension
        - GCC 2.96-RH, with many new fixes since the original 7.0 release

    o Improved USB Support -- The 2.4 kernel gives Red Hat Linux 7.1 more
      mature USB support than previous versions of Red Hat Linux.  It
      contains more drivers, and includes support for storage devices such
      as CD-ROMs.  It also supports "hot-pluggable" or removable devices --
      if a supported device is plugged in after booting, the necessary
      drivers will load automatically.

    o Removable media drives automatically added to /etc/fstab -- Red Hat
      Linux 7.1 now includes the ability for users to mount and unmount
      removable media drives.  This is done by the updfstab program (which
      is part of the kudzu boot-time hardware configurator).  It adds and
      removes the necessary entries in /etc/fstab.  Note that each entry
      managed by updfstab contains the new "kudzu" option -- this acts as a
      token indicating that the entry may subsequently be removed; if you
      wish to permanently add such an entry to your fstab, simply remove
      the "kudzu" option.

      Hotpluggable devices are handled through a combination of cardmgr,
      hotplug, updfstab, and pam_console_apply.  When the kernel notifies
      hotplug or cardmgr that a new storage device has been attached to the
      system, updfstab is run to add the new entries to the fstab.  Then,
      updfstab runs pam_console_apply, which uses the rules specified in
      /etc/security/console.perms to give the current console user access
      to the device.

      GNOME users who run magicdev will see device icons appear on their
      desktop automatically.  magicdev regularly checks the timestamp of
      /etc/fstab, and directs gmc to rescan devices when the fstab has
      changed.  If you do not run magicdev, the "Rescan Devices" option on
      the root gmc menu (which appears when you right-click on the desktop)
      performs an equivalent function.

      KDE users will see similar functionality.

    o New and Updated Drivers -- Many drivers are new to Red Hat Linux 7.1,
      or have been upgraded as a result of switching to a 2.4-based kernel.
      Changes include:

        - Updated Adaptec AIC7XXX SCSI driver
        - IEEE1394 (FireWire(tm)) subsystem
        - Adaptec starfire quad ethernet
        - IPv6 support
        - NFS version 3
        - iptables, an improved firewall layer
        - Maestro3 sound
        - Broadcom BCM5700 PCI-X 10/100/1000BASE-T controller
        - IDE UltraDMA/66 and UltraDMA/100 contoller support

    o 3D acceleration under XFree86 4.0.3 -- A wide variety of 3DFX cards
      have been added to the list of cards supporting accelerated 3D
      graphics. In addition, Intel i810, Matrox G200, G400, G450 (NOTE:
      dual-head operation on the G450 is unsupported), and ATI Rage 128
      based cards also support accelerated 3D graphics.  Please note that
      3D acceleration on ATI Radeon cards is not yet supported by XFree86
      4.0.3.

    o New Apache Configuration Tool -- apacheconf:

        - Helps manage virtual hosts in an intelligent fashion
        - Configured via the Alchemist Data Library
 
    o New BIND Configuration Tool -- bindconf:

        - Makes DNS configuration easier
        - Configured via the Alchemist Data Library

    o New Printing Configuration Tool -- printconf:

        - Filters are based on David Parson's magicfilter, the foomatic
          system, and the Linux Printing Database
          (http://linuxprinting.org).
        - Supports over 500 printers
        - Upgrades old systems configured with printtool
        - Configured via the Alchemist Data Library

    o Emacs/XEmacs site-start.d Directories -- Emacs/XEmacs each support a
      site-start.d directory.  Packages can now place emacs .el startup
      files in the appropriate directory, and they will be loaded when the
      editor starts.  This eliminates the need to edit the site-start.el
      file directly.  The directories are:

            /usr/share/emacs/site-lisp/site-start.d
            /usr/lib/xemacs/xemacs-packages/lisp/site-start.d

    o IMAP server changes -- The IMAP server now defaults to using its
      built-in SSL support instead of stunnel's tunneling support.
      Accordingly, the name of the certificate file used by imapd has
      changed from stunnel.pem to imapd.pem.  Users upgrading from previous
      releases of Red Hat Linux will need to rename, copy, or create a
      symbolic link to their existing certificate.

    o Sendmail -- By default, sendmail does not accept network connections
      from any host other than the local computer.  If you want to
      configure sendmail as a server for other clients, please edit
      /etc/mail/sendmail.mc and change DAEMON_OPTIONS to also listen on
      network devices, or comment out this option all together.  You will
      need to regenerate /etc/sendmail.cf by running:

            m4 /etc/mail/sendmail.mc > /etc/sendmail.cf

      Note that you must have the sendmail-cf package installed for this to
      work.

    o Other package highlights:

        - Ogg Vorbis audio encoder/decoder
        - LSB-compliant SGML and XML packages
        - KDE 2.1 and KOffice
        - BIND 9.x with DNSsec support and remote named control
        - SSL support in links, slrn, OpenLDAP, and pine
        - Pine 4.33
        - Quanta HTML editor (on Powertools)
        - Postfix and exim (on Powertools) include SSL/TLS support
        - WINE (on Powertools) can directly execute Windows .exe binaries
          from Linux


    o Deprecated Packages -- the following packages are deprecated, and
      could disappear in a future release:

        - AfterStep
        - Netscape 4.x
        - Qt 1.x
        - KDE v1 compatibility libraries / build environment
        - elm
        - linuxconf
        - ncpfs
        - mars_nwe



Documentation-Related Enhancements and Changes
----------------------------------------------

    o Additional documentation regarding the /etc/sysconfig/vncservers file
      -- Due to time constraints, the following information was not
      available prior to the Red Hat Linux Reference Guide's print date.

      The /etc/sysconfig/vncservers file configures how the Virtual Network
      Computing (VNC) server starts up. VNC is a remote display system
      which allows you to view a desktop environment not only on the
      machine where it is running but across different networks (from a LAN
      to the Internet) and using a wide variety of machine architectures.
  
      It may contain the following:

      VNCSERVERS=<value>, where <value> is set to something like "1:fred",
      to indicate that a VNC server should be started for user fred on
      display :1. User fred must have set a VNC passwd using vncpasswd
      before attempting to connect to the remote VNC server.

      Note that when you use a VNC server, your communication with it is
      unencrypted, and so it should not be used on an untrusted
      network. For specific instructions concerning the use of SSH to
      secure the VNC communication, please read the information found at
      http://www.uk.research.att.com/vnc/sshvnc.html.  To find out more
      about SSH, please refer to the Red Hat Linux Reference and
      Customization Guides.

ia64 7.1

