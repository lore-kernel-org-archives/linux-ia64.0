From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 21 Mar 2002 23:42:55 +0000
Subject: [Linux-ia64] Running ia64 2.4.17 kernel on RedHat 7.2 and problems with LoadModule: "scanpci" what s
Message-Id: <marc-linux-ia64-105590701905318@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 22, 2002 at 08:30:54AM +1100, Keith Owens wrote:
> On Wed, 20 Mar 2002 22:51:32 -0800, 
> Piet/Pete Delaney <piet@sgi.com> wrote:
> >How do I build: 
> >
> >	/boot/module-info-${KERNELRELEASE}
> >	/boot/kernel.h-${KERNELRELEASE}
> 
> Redhat special files, not part of the kernel build.

Any idea what they do?  Perhaps it's involved with my X11R6 problem below...



> 
> >	/boot/initrd-${KERNELRELEASE}
> 
> mkinitrd, if you really insist.  initrd is useful for distributors and
> when you need a binary only module at boot time.  Otherwise initrd is a
> pain in the neck, build boot drivers into the kernel instead.

What does "binary only module at boot time" mean?

I managed to get 2.4.18 to boot and got to multiuser (init level 3) without it 
by linking in the EXT3 driver and starting from scratch with the .config file. 

Rob Gjertsen suggested just doing:

	/sbin/mkinitrd /boot/efi/initrd-2.4.17.img 2.4.17

and putting this info in the new entry in /boot/efi/elilo.conf. Seems like
an idea worth trying. Might make it possible to load modules.


==============================================
				xfree86 Problem
==============================================

I'm not able to go to init level 5 yet. It seems the XFree86 driver
is trying to load a Video Driver and experiences a problem when
loading the scanpci library:
---------------------------------------------------------------------------
XFree86 Version 4.1.0.1 (Red Hat Linux release: 4.1.0-8) / X Window System
(protocol Version 11, revision 0, vendor release 6510)
Release Date: xx August 2001
        If the server is older than 6-12 months, or if your card is
        newer than the above date, look for a newer version before
        reporting problems.  (See http://www.XFree86.Org/FAQ)
Build Operating System: Linux 2.4.9-7.2smp ia64 [ELF]
Build Host: boris.devel.redhat.com

Module Loader present
(=) Log file: "/var/log/XFree86.0.log", Time: Sun Mar 31 13:57:41 2002
(=) Using config file: "/etc/X11/XF86Config-4"
Markers: (--) probed, (**) from config file, (=) default setting,
         (++) from command line, (!!) notice, (II) informational,
         (WW) warning, (EE) error, (NI) not implemented, (??) unknown.
(=) ServerLayout "Anaconda Configured"
(**) |-->Screen "Screen0" (0)
(**) |   |-->Monitor "Monitor0"
(**) |   |-->Device "ATI Rage 128"
(**) |-->Input Device "Mouse0"
(**) |-->Input Device "Keyboard0"
(**) Option "XkbRules" "xfree86"
(**) XKB: rules: "xfree86"
(**) Option "XkbModel" "pc105"
(**) XKB: model: "pc105"
(**) Option "XkbLayout" "us"
(**) XKB: layout: "us"
(=) Keyboard: CustomKeycode disabled
(**) FontPath set to "unix/:7100"
(**) RgbPath set to "/usr/X11R6/lib/X11/rgb"
(=) ModulePath set to "/usr/X11R6/lib/modules"
(--) using VT number 7

(WW) Cannot open APM
(II) Module ABI versions:
        XFree86 ANSI C Emulation: 0.1
        XFree86 Video Driver: 0.4
        XFree86 XInput driver : 0.2
        XFree86 Server Extension : 0.1
        XFree86 Font Renderer : 0.2
(II) Loader running on linux
(II) LoadModule: "bitmap"
(II) Loading /usr/X11R6/lib/modules/fonts/libbitmap.a
(II) Module bitmap: vendor="The XFree86 Project"
        compiled for 4.1.0.1, module version = 1.0.0
        Module class: XFree86 Font Renderer
        ABI class: XFree86 Font Renderer, version 0.2
(II) Loading font Bitmap
(II) LoadModule: "pcidata"
(II) Loading /usr/X11R6/lib/modules/libpcidata.a
(II) Module pcidata: vendor="The XFree86 Project"
        compiled for 4.1.0.1, module version = 0.1.0
        ABI class: XFree86 Video Driver, version 0.4
(II) PCI: PCI scan (all values are in hex)
(II) PCI: 00:00:0: chip 8086,123d card 0000,0000 rev 01 class 08,00,20 hdr 00
(II) PCI: 00:01:0: chip 1002,5245 card 1002,0008 rev 00 class 03,00,00 hdr 00
(II) PCI: 00:03:0: chip 8086,7600 card 0000,0000 rev 01 class 06,01,00 hdr 80
(II) PCI: 00:03:1: chip 8086,7601 card 8086,4253 rev 01 class 01,01,80 hdr 00
(II) PCI: 00:03:2: chip 8086,7602 card 8086,4253 rev 01 class 0c,03,00 hdr 00
(II) PCI: 00:03:3: chip 8086,7603 card 8086,4253 rev 01 class 0c,05,00 hdr 00
.
.
.
(II) PCI: 04:15:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr 80
(II) PCI: 04:16:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr 80
(II) PCI: 04:17:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr 80
(II) PCI: End of PCI scan
(II) LoadModule: "scanpci"
(II) Loading /usr/X11R6/lib/modules/libscanpci.a
(II) Module scanpci: vendor="The XFree86 Project"
        compiled for 4.1.0.1, module version = 0.1.0
        ABI class: XFree86 Video Driver, version 0.4

Fatal server error:
Caught signal 11.  Server aborting


When reporting a problem related to a server crash, please send
the full server output, not just the last messages.
This can be found in the log file "/var/log/XFree86.0.log".
Please report problems to xfree86@xfree86.org.
---------------------------------------------------------------------------
I wonder if the error "(WW) Cannot open APM" is involved. I don't see
a APM module in the kernel.

I searched RedHat's  Linux Support Knowledgebase but didn't find anything.


===================================================

I checked:

	http://www.tux.org/lkml/#s8-8

	It's a bit out of date for ia64:
	------------------------------------
	    mv .config ..
            make mrproper
            mv ../.config .
            make oldconfig
            make dep clean bzImage modules
            # install, boot
	-----------------------------------

	make bzImage isn't supported by the kernel Makefile yet /boot comes with vmlinuz-2.4.9-18 images on RedHat 7.2 for the ia64.

	Last evening I took the make mrproper deletion of the .config file as a hint to start with a fresh .config built from make xconfig 
	and I managed to build a kernel that doesn't need or appear to have any modules.

	I don't really need the X11R6 stuff right now, but it would be nice to get it working eventually.


I had to remove S83iscsi for /etc/rc3.d and /etc/rc5.d; it appears to be module that isn't included in the 2.4.17 kernel that
supports scsi over ethernet. I doubt I need it.

-piet


