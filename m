From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 30 Aug 2000 07:12:25 +0000
Subject: [Linux-ia64] ANNOUNCE: New TurboLinux IA-64 distribution
Message-Id: <marc-linux-ia64-105590678205418@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

TurboLinux Frontier IA-64 Beta 1 (2000-08-28)
--------------------------------------------------------------------------------

This is the first beta release of TurboLinux Frontier IA-64.
The distribution is available for download at the TurboLinux ftp site:

    ftp://ftp.turbolinux.com/pub/ia64/TLF-ia64-0828.iso
    ftp://ftp.turbolinux.com/pub/ia64/TLF-ia64-0828-nox.iso
    ftp://ftp.turbolinux.com/pub/ia64/0828/{RPMS,SRPMS}

The first URL points to the ISO 9660 image which you can burn on a CD-ROM.
This will give you a bootable CD from which to install the TurboLinux
IA-64 distribution on your system.  This image contains a graphical
installer which is used to install the contents of the CD.  For system
upgrade, please read "SYSTEM UPGRADE INSTRUCTIONS" section below.

The second ISO image contains a script-based installer which can be used
if you have problems starting the X server during the install process.  
You can also use this disk as a "rescue disk".

The third URL gives the locations of the binary and source RPMs.
Updated RPMs will be available at:

    ftp://ftp.turbolinux.com/pub/ia64/0828/updates

If you are using this release, we highly recommend that you subscribe
to our ia64-dist mailing list.  All TurboLinux ia64 related questions
should be directed there.  For instructions on how to subscribe,
please visit:

    http://www.turbolinux.com/mailman/listinfo/ia64-dist


WHAT'S NEW
=====

* Upgraded to the latest kernel (2.4.0-test7 + 000823 patch).
  The toolchain is Cygnus May 1 release (2.9-ia64-000216-final) with
  some additional patches (-mconstant-gp, -mauto-pic, gas unwind fixes).

* Kernel modules fully supported.

* XFree86 4.0.1 installed by default.  We have tested the server
  support for ATI Rage 128 and ATI Rage XL video cards.  If you use
  the graphical installer you should be able to just type `startx'.
  Other cards may work but you will have to play with XF86Config file.

* Netscape is installed by default and runs under IA-32 emulation mode.

* SGI Pro64 compiler is installed by default.  the binaries will run
  under IA-32 emulation mode.  The compiler hasn't been extensively tested.

* Autoboot is enabled by default.  The install process creates startup.nsh
  file which automatically boots Linux after power-up.


KNOWN PROBLEMS
=======

1) IMPORTANT.  The settings for the QLogic SCSI adapter on Lions MUST be 
   changed to support >4GB addressing.  If this is not done, the install will
   fail.  To change the setting, press ALT-Q when the QLogic BIOS screen comes
   up.  Next, select the following menu items:

   Configuration settings
      Host adapter settings
         >4GByte addressing

   Save your changes, and exit from the QLogic configuration program.

   You don't have to enable >4G addressing on BigSur systems.

2) The installer (Both graphical and scripted) can sometimes kernel panic
   in the swapper process.  If this happens, try passing mem24m as an 
   argument to lilo.  This seems to mostly be a problem on Lions.  You might
   have to include this option in the regular boot process.

3) X-Windows.  The release ships with XFree 4.0.1.  Drivers are provided for 
   both the Rage 128 (PCI and AGP) and Rage XL.  Both drivers can sometimes 
   lock the machine hard.  Netscape Communicator in particular seems to trigger
   this problem frequently.  If you have problems using the graphical installer
   there is a non-graphical install ISO image on the ftp site.  Based on our
   testing, you will probably need to use the non-graphical installer on Lions.

4) If you press the back button while partitioning your hard disk, you may end
   up with your partitions listed twice.  This does not effect the actual 
   partitioning operation.  With this version of the installer, it is best not
   to use the back buttons.

5) When the configure services screen launches, it takes a long time 
   (up to 2 minutes) before the list appears.  The system has not crashed.  
   This is a limitation in the current installer, and will be fixed by the
   next release.

6) Xaw3d and traceroute both generate unaligned memory accesses.  This should
   be fixed between now and the next release.


Mike Madore
mmadore@turbolinux.com
Software Engineer
TurboLinux, Inc.


