From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Apr 2004 22:21:24 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16529.32740.542390.195200@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Apart from small SN2 fixes, there is a tiny but important fix to
pgtable.h.  It fixes breakage introduced by the Non-Exec stack patch
which caused the X server to get stuck.  The X server doesn't like it
if it can't turn on execute permission on the loaded modules...

Thanks!

	--david

 arch/ia64/kernel/smp.c                   |    2 ++
 arch/ia64/sn/io/io.c                     |    4 ++++
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c |    5 -----
 arch/ia64/sn/kernel/irq.c                |    6 +++++-
 include/asm-ia64/pgtable.h               |    4 ++--
 include/asm-ia64/sn/sn_sal.h             |    2 +-
 6 files changed, 14 insertions(+), 9 deletions(-)

through these ChangeSets:

<pfg@sgi.com> (04/04/29 1.1607)
   [PATCH] ia64: SN2 fix
   
   Move HW interrupt register init. to the proper place
   and don't force an interrupt if the IRQ is disabled
   or in progress.

<davidm@tiger.hpl.hp.com> (04/04/29 1.1606)
   ia64: Fix Exec-Only stack patch so X can work again.
   
   No pun intended, but X can't work if it can't turn on eXecute-permission
   on the some data pages...

<davidm@tiger.hpl.hp.com> (04/04/26 1.1371.1.539)
   [PATCH] ia64: BUG if smp_call_function is called with interrupts disabled
   
   smp_call_function() may not be called with interrupts disabled.
   Violating this precondition leads to bugs that are hard to reproduce
   and even harder to diagnose.  Thus, catch violations with BUG_ON().

<kaos@sgi.com> (04/04/26 1.1371.1.538)
   [PATCH] ia64: SN_SAL_PRINT_ERROR is reentrant

