From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Tue, 22 May 2001 22:31:29 +0000
Subject: [Linux-ia64] Announcing efibootmgr-0.3.2
Message-Id: <marc-linux-ia64-105590693005646@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Announcing efibootmgr-0.3.2, a Linux user-space application which
interacts with the EFI Boot Manager.  It may be downloaded from
http://domsch.com/linux/ia64/efibootmgr-0.3.2.tar.gz.

ChangeLog extract:
* Tue May 22 2001 Matt Domsch <Matt_Domsch@dell.com>
- Applied patch from Andreas Schwab.  remove_from_boot_order() called
  read_boot_order() without checking the return status.
- Changed README to remove os loader args comment
- Changed efi_status_t to be unsigned long (not uint64_t) as per EFI
  spec.  This allows efibootmgr to be recompiled as a 32-bit or 64-bit app
  depending on its running on 32-bit or 64-bit Linux.  Note:  this changes
  the size of the structure returned in /proc/efi/vars to match the kernel
  implementation.  32-bit efibootmgr won't work on 64-bit Linux and vice versa.
- release v0.3.2

I appreciate the feedback (and Andreas' patches!) I've received thus
far.  Please keep up the good work!
-Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux



