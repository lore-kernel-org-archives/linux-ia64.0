From: Matt_Domsch@Dell.com
Date: Sat, 06 Apr 2002 04:10:44 +0000
Subject: [Linux-ia64] efibootmgr 0.4.0-test6
Message-Id: <marc-linux-ia64-105590701905401@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've done a bit of GPT code cleanup in efibootmgr, prompted by Richard
Hirst's Debian IA-64 work, and have now posted 0.4.0-test6 at 
http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.0-test6.tar.gz

Changelog extracts below since the first of the year.  Functionally the only
new thing is the write_variable() behavior change necessitated by EFI 1.1
having gone and changed the name of the variable I had been using as the
"victim".

- write_variable() now searches /proc/efi/vars for a variable that's not
  the one being written.  The EFI 1.1 sample implementation changed the
  name of the "victim" being written to (was Efi-xxxxx, now EFI-xxxxx), so
  previous versions of efibootmgr don't work with the new firmware.  This
  should fix that up.
- conversion to GPT code in post-2.4.18 and post-2.5.7 kernels.
- added manpage contributed by dannf@fc.hp.com
- BLKGETSIZE64 is fixed in 2.4.18-pre8 and 2.5.4-pre3.  Wait a bit longer
before using though.
- added list_for_each_safe() routine.  It's needed in the boot
var deletion routine, though it was already breaking out once found.
- commented out BLKGETSIZE64 ioctl use for now.  Kernels 2.4.15-2.4.18 and
  2.5.0-2.5.3 don't return the right value.
- added back in read last sector IOCTL hack, but only after read() fails.
- Changed PROC_DIR_EFI to PROC_DIR_EFI_VARS

This works fine on my Itanium workstation with GPT disks and a 2.4.18
kernel.
Barring anything unexpected, I want to tag this as 0.4.0 final in the near
future.

Feedback and patches appreciated.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001! (IDC Mar 2002)

