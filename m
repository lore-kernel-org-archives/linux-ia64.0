From: Matt Domsch <Matt_Domsch@dell.com>
Date: Wed, 09 Nov 2005 20:13:02 +0000
Subject: efibootmgr 0.5.3 released
Message-Id: <20051109201302.GA29966@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've released efibootmgr v0.5.2.2 as v0.5.3 with no changes.

http://linux.dell.com/efibootmgr/efibootmgr-0.5.3.tar.gz
http://linux.dell.com/efibootmgr/efibootmgr-0.5.3.tar.gz.sign

* Wed Nov 9 2005 Matt Domsch <Matt_Domsch@dell.com>
- released v0.5.2.2 as v0.5.3, no changes
	
* Thu Aug 11 2005 Matt Domsch <Matt_Domsch@dell.com>
- applied patch from Rogerio Timmers which adds a new option -@ <file>,
  which takes extra variable parameters from <file>, or - from stdin.
  This lets you pass binary (non-unicode, non-ascii) formatted options to
  your bootloader.
- cleaned up Rogerio's patch some.
- moved definition of _FILE_OFFSET_BITSd into Makefile and out of the
  individual .c files.  This fixes a bug reported by Red Flag, where
  variable data was getting incorrectly set with a 32-bit copy of
  efibootmgr on a 32-bit kernel.
- made efi_variable_t.DataSize be an unsigned long to match the kernel.
  This lets a 32-bit copy of efibootmgr run on a 32-bit kernel.  This
  means you've got to have a 32-bit efibootmgr on a 32-bit kernel, and a
  64-bit efibootmgr on a 64-bit kernel, but since efi_status_t is also a
  long, this was really going to be the case anyway.
- valgrind caught the app exiting without freeing some malloc'd
  structures, fix that.
- v0.5.2.2 released for testing	


Thanks,
Matt

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
