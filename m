From: Matt_Domsch@Dell.com
Date: Thu, 02 May 2002 16:31:46 +0000
Subject: [Linux-ia64] efibootmgr 0.4.0 released
Message-Id: <marc-linux-ia64-105590701905545@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've released efibootmgr 0.4.0 final.
It can be downloaded from http://domsch.com/linux/ia64/efibootmgr/
   efibootmgr-0.4.0.tar.gz
   efibootmgr-0.4.0.tar.gz.sign

Changes since version 0.3.4:
- Added some printfs to compare_gpts().
- Make sure partition number arg is in the GPT disk.
- Added a few more _FILE_OFFSET_BITS defines where needed
- Added syncs to make tarball target so NFS is current and CVS dirs get
deleted before the tarball is made.
- Added a few __leXX_to_cpu() calls in code currently commented out in gpt.c
- conversion to GPT code in post-2.4.18 and post-2.5.7 kernels.
- added manpage contributed by dannf@fc.hp.com - needs a run through
docbook2man yet...
- BLKGETSIZE64 is fixed in 2.4.18-pre8 and 2.5.4-pre3.  Wait a bit longer
before using though.
- added list_for_each_safe() routine.  It's needed in the boot
var deletion routine, though it was already breaking out once found.
- changed struct list_head to list_t
- Changed PROC_DIR_EFI to PROC_DIR_EFI_VARS
- write_variable() now searches /proc/efi/vars for a variable that's not
  the one being written.  The EFI 1.1 sample implementation changed the
  name of the "victim" being written to (was Efi-xxxxx, now EFI-xxxxx), so
  previous versions of efibootmgr don't work with the new firmware.  This
  should fix that up.
- Added test for valid PMBR, similar to parted and the kernel.
- Added test for returning size of block device as a u64.
- Added test for returning sector size as int, and use that.
- Changed GPT struct and member names to be more Linux-like.
- added -g option to force disk with invalid PMBR to be treated as GPT
anyhow.


This release is known to work on newer firmwares which do not have an
"Efi-(guid)" EFI Variable, which previous versions relied upon, and is the
primary reason for this release.  I recommend this release for all
distributions.

Feedback and patches appreciated.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001!

