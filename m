From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 08 Mar 2001 00:41:25 +0000
Subject: [Linux-ia64] TurboLinux Beta3 for IA64 available
Message-Id: <marc-linux-ia64-105590693005263@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

TurboLinux Frontier IA-64 Beta 3 (2001-03-07)
--------------------------------------------------------------------------------

This is the third beta release of TurboLinux Frontier IA-64.
The distribution is available for download at the TurboLinux ftp site:

    ftp://ftp.turbolinux.com/pub/ia64/TLF-ia64-Beta3.iso
    ftp://ftp.turbolinux.com/pub/ia64/TLF-ia64-Beta3-nox.iso
    ftp://ftp.turbolinux.com/pub/ia64/Beta3/{RPMS,SRPMS}

The first URL points to the ISO 9660 image which you can burn on a CD-ROM.
This will give you a bootable CD from which to install the TurboLinux
IA-64 distribution on your system.  This image contains a graphical
installer which is used to install the contents of the CD.

The second ISO image contains a script-based installer which can be used
if you have problems starting the X server during the install process.  
You can also use this disk as a "rescue disk".

The third URL gives the locations of the binary and source RPMs.
Updated RPMs for this release will be available at:

    ftp://ftp.turbolinux.com/pub/ia64/Beta3/updates

IMPORTANT:  The C-library and tool-chain in this release contain ABI changes
that are not backward compatible with previous TurboLinux IA-64 releases
that were based on glibc 2.1.  

If you are using this release, we highly recommend that you subscribe
to our ia64-dist mailing list.  All TurboLinux ia64 related questions
should be directed there.  For instructions on how to subscribe,
please visit:

    http://www.turbolinux.com/mailman/listinfo/ia64-dist


WHAT'S NEW
=====

* The kernel is 2.4.1 + 01/31 IA-64 patch.  The default SMP and UP
  kernels were compiled with workarounds for B- and C-stepping processors only.
  There is no support for A stepping processors.  Also, the VHPT is disabled
  by default.

* The kernel now contains the new kernel debugger code from Keith Owens.

* Latest version of the gnupro toolchain (2.96-ia64-000717, snapshot 1117)
  with all recent patches applied.

* Updated version of gdb and strace.

* Updated XFree 4.0.2.  This version is known to work on the following 
  cards:

Working cards
-------------
(PCI) VGA compatible controller: ATI Technologies Inc Rage XL (rev 39)
(AGP) VGA compatible controller: ATI Technologies Inc Rage 128 PF (rev 0)
(PCI) VGA compatible controller: ATI Technologies Inc 3D Rage IIC 215IIC [Mach64GT IIC] (rev 58)
(AGP) VGA compatible controller: 3Dfx Interactive, Inc. Voodoo 3 (rev 1)
(PCI) VGA compatible controller: ATI Technologies Inc Rage 128 RE (rev 0)
(AGP) VGA compatible controller: S3 Inc. Savage 4 (rev 2)
(AGP) VGA compatible controller: Matrox Graphics, Inc. MGA G200 AGP (rev 3)
(PCI) VGA compatible controller: ATI Technologies Inc Rage 128 RK (rev 0)
(AGP) Nvidia Quadro
(AGP) VGA compatible controller: Matrox Graphics, Inc. MGA G400 AGP (rev4) *

* X starts using 99.9% of CPU after displaying Gnome welcome screen.
  Using Option "noaccel" allows the server to start.

Other cards may also work, but haven't been explicitly tested.
The installer will currently only recognize the above cards.  If you have
a different card, you will have to manually select it during the X
configuration.

RECOMMENDED BIOS VERSIONS
============
1) Workstations (BigSur)
   This release has been tested with BIOS 89B and 99.

2) Servers (Lion)
   We recommend that you upgrade to BIOS version 71.


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

2) The integrated EEPRO network adapter in Lion systems currently suffers
   from the following issues:

 - If you have more than 1GB of RAM, networking will fail almost immediately
   after you start using it.  To get around this, pass mem24MB as an
   argument to lilo.

 - Transferring certain files from an NFS server to the Lion will cause NFS
   to hang.  The rest of the networking subsystem will continue to operate
   normally.  This is being looked into by Intel.  In the mean time, either
   don't transfer the problem files via NFS, or install an alternate network
   adapter.

3) Due to some unresolved issues with the current tool-chain, the following
   packages are not available in this release:

   * ispell


Complete installation instructions can be found in the README file.

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

