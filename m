From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 23 Nov 2000 07:32:55 +0000
Subject: [Linux-ia64] TurboLinux IA-64 Beta 2 (2000-11-23) Available for download
Message-Id: <marc-linux-ia64-105590678205769@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

TurboLinux Frontier IA-64 Beta 2 (2000-11-23)
--------------------------------------------------------------------------------

This is the second beta release of TurboLinux Frontier IA-64.
The distribution is available for download at the TurboLinux ftp site:

    ftp://ftp.turbolinux.com/pub/ia64/TLF-ia64-1120.iso
    ftp://ftp.turbolinux.com/pub/ia64/TLF-ia64-1120-nox.iso
    ftp://ftp.turbolinux.com/pub/ia64/1120/{RPMS,SRPMS}

The first URL points to the ISO 9660 image which you can burn on a CD-ROM.
This will give you a bootable CD from which to install the TurboLinux
IA-64 distribution on your system.  This image contains a graphical
installer which is used to install the contents of the CD.

The second ISO image contains a script-based installer which can be used
if you have problems starting the X server during the install process.  
You can also use this disk as a "rescue disk".

The third URL gives the locations of the binary and source RPMs.
Updated RPMs for this release will be available at:

    ftp://ftp.turbolinux.com/pub/ia64/1120/updates

IMPORTANT:  The C-library and tool-chain in this release contain ABI changes
that are not backward compatible with previous TurboLinux IA-64 releases. 
As a result, there is no option to upgrade existing systems.

Complete installation instructions can be found in the README file.

If you are using this release, we highly recommend that you subscribe
to our ia64-dist mailing list.  All TurboLinux ia64 related questions
should be directed there.  For instructions on how to subscribe,
please visit:

    http://www.turbolinux.com/mailman/listinfo/ia64-dist


WHAT'S NEW
=====

* The kernel is 2.4.0-test10 + 11/15 IA-64 patch.  The default SMP and UP
  kernels were compiled with workarounds for B- and C-stepping processors only.
  We have provided a special kernel with A2 and A3 workarounds (in addition
  to B- and C-stepping) to help with the installation.  There is no support
  for A1 stepping;  A[23]-stepping support will be dropped in the next release.

* GLIBC 2.2.  All packages now link against the latest version of the C library.

* Latest version of the gnupro toolchain (2.96-ia64-000717, snapshot 1117).

* Updated version of the Gnome environment.

* RPM 4.0.

* SGI Pro64 compiler is installed by default.  the binaries will run
  under IA-32 emulation mode.  The compiler hasn't been extensively tested.


RECOMMENDED BIOS VERSIONS
============
1) Workstations (BigSur)
   If you have a B1/B2-stepping processors you should upgrade your BigSurs
   to BIOS 84; if you're still on Ax stepping upgrade to BIOS 80.
   If you are running BIOS 60/70 the PS/2 keyboard will not work with
   the new kernel; you can complete the installation by plugging in a
   USB keyboard.

   The new BIOSes on BigSur will leave the network interface in a misconfigured
   tate if you let them boot off the network.  When the system boots you should
   select EFI Shell manually, i.e. don't let the system network boot first and
   then fall back into the EFI shell.

2) Servers (Lion)
   We recommend that you upgrade to BIOS version 64.  (If the system reboots
   correctly you're already running it).  Note that there are two versions
   of BIOS 64 -- one for the Lion SDVs and another for the OEM systems.
   Before you upgrade BIOS you should really open your system first and
   verify what legacy I/O card you have in your box.  If it says "OEM LEGACY"
   you have an OEM system -- use BIOS 1064.


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
   both the Rage 128 (PCI and AGP) and Rage XL.  This version of XFree is
   known to work with the following cards:

      * Rage XL (rev 39)
      * Rage 128 RK (rev 0) (This is the built in video on Lions)
      * Rage 128 PF (rev 0)
      * 3D Rage IIC 215IIC [Mach64 GT IIC] (rev 58)
      * Rage 128 RE 

   This is a Development version of X, however, and it may not always work 
   reliably even on the above cards.

   The installer will currently only recognize the above cards.  If you have
   a different card, you will have to use the text based installer.

   Before choosing which installer to use (graphical/text) it is recommended
   that you check your video card model.  This is easily done by issuing the
   following command:

      grep VGA /proc/pci

4) If you press the back button while partitioning your hard disk, you may end
   up with your partitions listed twice.  This does not effect the actual 
   partitioning operation.  With this version of the installer, it is best not
   to use the back buttons.

5) Due to some unresolved issues with the current tool-chain, the following
   packages are not available in this release:

      * guile
      * gnome-games (requires guile)
      * ispell
      * mars-nwe

6) The current kernel has some issues when running on systems with large
   amounts of memory installed.  You may see the symptoms when you try
   to transfer large files over NFS -- if the system hangs or dies with
   a kernel panic you should boot the kernel with mem24m as a temporary
   workaround. These symptoms have been observed on Lion systems only.

7) SMP kernels on Lion systems will cause processes to occasionally segfault.
   The same SMP kernel has been stable on BigSur systems.

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.
mmadore@turbolinux.com

