From: Bill Nottingham <notting@redhat.com>
Date: Mon, 28 Aug 2000 22:10:04 +0000
Subject: [Linux-ia64] New Red Hat Linux Development Release available
Message-Id: <marc-linux-ia64-105590678205395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The third development release of Red Hat Linux for IA-64 is
now available. The main new feature of this release is
kickstart support in the installer.

You can get it at:
	ftp://ftp.rehdat.com/pub/redhat/ia64/
	
ISO images are available.

The README is attached below.

Bill

--

Red Hat Linux Development Release for IA-64
-------------------------------------------

Table of Contents:
	1. Notes
	2. How to install
	3. Changes from the previous release
	4. Compatibility Notes
	5. Known Bugs

1. Notes

Welcome to the third Red Hat Linux Development Release for IA-64.

This is an early snapshot of Red Hat Linux for the IA-64. Not
everything may be working fully yet; remember, if it breaks,
you get to keep both pieces.

There is a mailing list to discuss the IA-64 release. To
subscribe, send mail to ia64-list-request@redhat.com with

subscribe

in the subject line. You can leave the body empty.

2. How to install

Upgrades from previous Red Hat Linux IA-64 Development Releases
are *not* supported.

To do a CD-ROM install, simply insert the CD-ROM; at the EFI
prompt, switch to the CD-ROM filesystem, and run 'eli'. (If
you have filesystems with eli installed on them, you may need
to unmap the aliases (by running 'map -d fs0', for example)
for it to run ELI off the CD.

To do an NFS install, take the boot image (images/boot.img on theCD),
and dd/cat it onto an LS-120 disk. Boot the resulting disk in
EFI; you should not need to pass parameters. If you do, to start the
install you need to pass:
  <kernel image> root=/dev/hda2 ro text

Use the install like a normal Red Hat Linux install. Choose
'Custom Install', and then partition your disks. Be sure to make
a small DOS primary partition (i.e., a partition between 1-4), to 
be used for eli. This partition needs to be mounted on /boot/efi.

For reboot, remove the CD-ROM (and LS-120, if you used it.)

You should then be able to boot from your boot partition by
simply running 'eli'. 

3. General caveats/changes from previous releases:

If you have a Lion (and possibly BigSurs, too), you need to
go into the Qlogic BIOS setup and make sure that 
 ' Enable > 4GB support ' is enabled, even if you don't have
4GB of memory. Otherwise, the kernel won't be able to talk
to anything on the Qlogic controller (the failure method
will be it complaining about being unable to read the
partitions on the SCSI drives.)

Kickstart should work OK; please let us know if it doesn't.

Anything in anaconda that tries to access the floppy will be
looking on the first partition of a partitioned LS-120.
(i.e., /dev/hda1, /dev/hdb1, etc.).In other words, putting
ks.cfg on the boot disk should work fine, and you should be
able to write tracebacks to the boot disk.

You should be able to specify a hostname now on CD-ROM installs
without crashing the installer.

ELI now supports adding of command line arguments to images, for
example:

 eli linux ks=floppy
 
will simply append 'ks=floppy' to whatever arguments you have
for the image labeled 'linux'. Basically, just like LILO.
However, you still cannot pass the 'initrd' parameter on
the command line in ELI; it needs to be in the config file.

You can now install in foreign languages if you so desire.

Testing X configuration in the install still does not
work. Also, there are still occasional reports
of 'everything' installs dying with a sig11 after the last
package, but it's not 100% reproducible.

4. Compatibility Notes

Programs from the previous (May or June) Red Hat Linux IA-64
Development Releases should run on this release; compatibility
is not guaranteed, though.

However, programs built on both this and previous release
will not run on future releases. Similarly, programs built
on future releases will not run on this release.




