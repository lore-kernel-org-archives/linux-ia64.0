From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Fri, 18 May 2001 22:28:53 +0000
Subject: [Linux-ia64] Announcing efibootmgr-0.3.0
Message-Id: <marc-linux-ia64-105590693005625@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Announcing efibootmgr-0.3.0, a Linux user-space application which
interacts with the EFI Boot Manager.  It may be downloaded from
http://domsch.com/linux/ia64/efibootmgr-0.3.0.tar.gz.

This requires the efivars module be loaded, and expects them
to be at /proc/efi/vars/* which is consistent with the kernel
2.4.4 IA-64 patch.  You must be root to run this (as /proc/efi/vars/*
are only read/write root).

Changes since v0.2.0:

* Fri May 18 2001 Matt Domsch <Matt_Domsch@dell.com>
- Padded HARDDRIVE_DEVICE_PATH out to please EFI Boot Manager.
- Incorporated patches from Andreas Schwab
  - replace __u{8,16,32,64} with uint{8,16,32,64}_t
  - use _FILE_OFFSET_BITS
  - fix a segfault
- release v0.3.0

I believe this is functional, would be happy for the various
distributions to include this.  As always, comments and patches (such as
sent by Andreas!) are appreciated.

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux



