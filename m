From: Matt_Domsch@Dell.com
Date: Thu, 03 Jan 2002 18:20:33 +0000
Subject: [Linux-ia64] efibootmgr 0.4.0-test4
Message-Id: <marc-linux-ia64-105590698805738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've made a newer efibootmgr. ChangeLog below.  Most important change is
that write_variable() no longer has a hard-coded "victim" file in
/proc/efi/vars to open, it now searches the list of files to find one it's
not actively writing.  This is necessary because the EFI 1.1 sample
implementation changed the name of the file we had been using as the
"victim". :-)

Posted to
http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.0-test4.tar.gz.
Feedback welcome.

* Thu Jan 3 2002 Matt Domsch <Matt_Domsch@dell.com>
- added back in read last sector IOCTL hack, but only after read() fails.
- released v0.4.0-test4

* Thu Jan 3 2002 Matt Domsch <Matt_Domsch@dell.com>
- more cleanups
- released v0.4.0-test3

* Wed Jan 2 2002 Matt Domsch <Matt_Domsch@dell.com>
- Changed PROC_DIR_EFI to PROC_DIR_EFI_VARS
- write_variable() now searches /proc/efi/vars for a variable that's not
  the one being written.  The EFI 1.1 sample implementation changed the
  name of the "victim" being written to (was Efi-xxxxx, now EFI-xxxxx), so
  previous versions of efibootmgr don't work with the new firmware.  This
  should fix that up.
- released v0.4.0-test2

* Fri Dec 7 2001 Matt Domsch <Matt_Domsch@dell.com>
- Removed read last sector ioctl hack, it's not needed anymore.  The
  kernel takes care of it for us with a new patch.
- Added test for valid PMBR, similar to parted and the kernel.
- Added test for returning size of block device as a u64.
- Added test for returning sector size as int, and use that.
- Changed GPT struct and member names to be more Linux-like.
- added -g option to force disk with invalid PMBR to be treated as GPT
anyhow.
- released v0.4.0-test1

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
#1 US Linux Server provider with 24.5% (IDC Dec 2001)
#2 Worldwide Linux Server provider with 18.2% (IDC Dec 2001)

