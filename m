From: Bruno Vidal <bruno_vidal@hp.com>
Date: Tue, 13 May 2003 07:02:48 +0000
Subject: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705751@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Hi all.
I've already wrote a dump modules driver for linux-parisc.
This module goal is to create a memory image on a swap area, and
at reboot time to save it to disk with all kernel modules, in
order to analyze it after by "support" people with tools like
gdb/p4. The problem while dumping is that the dump modules
cannot trust anymore the system, so dumping means: no interruption,
no disk driver, no buffer, nothing. The solution is to use low level
call. For parisc I use the IODC calls, for ia64 I think I'll
use the EFI calls. My questions:
-do you think it is a "good" and realistic solution.
-because I think "yes", does exist somewhere an example of
reading/writing with EFI call on disk using BLOCK IO. I've already
looked in elilo, but it seems that it use FS access.

	Thanks.

-- 
	Vidal Bruno, (770-4271)
         SSD-HA Team, HP-UX & LINUX Support
	bruno_vidal@admin.france.hp.com


