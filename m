From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 30 Jun 2004 05:09:38 +0000
Subject: Using GDB kills kernel
Message-Id: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



With David's current patch against 2.6.7-BK, attempting to use GDB
causes a firmware assertion failure on my ZX2000.  Looks like it's
causing a SAL call or something.

gdb ./h
(gdb) r
Firmware assertion failed: (((DATA8) addr - salNvm) < NVM_SIZE) ||
(((DATA8) addr - efiNvm) < EFI_NVM_SIZE), file bbsram_new.c line 570 
....


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
