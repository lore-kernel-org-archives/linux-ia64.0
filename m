From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 21 Nov 2001 00:40:56 +0000
Subject: [Linux-ia64] 2.4.14 Missing asm clobbers
Message-Id: <marc-linux-ia64-105590698805537@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A comment of Linus's on l-k promoted me to check ia64 inline asm for
predicates.  I was surprised to find what look like missing asm
clobbers.  I am not 100% sure that these are errors (gcc clobbers are a
black art ;) so there is no patch.

include/asm-ia64/spinlock.h.

  spin_lock() changes ar.ccv, p7 without a clobber (!NEW_LOCK version).
  read_lock() changes p6 without a clobber.
  write_lock() changes ar.ccv, p7 without a clobber.

arch/ia64/kernel/traps.c

  fp_emulate() does ldf f10, f11 without a clobber.

arch/ia64/kernel/unaligned.c

  invala_gr() and invala_fr() do invala without a "memory" clobber.
  Not sure if it is necessary or not.


