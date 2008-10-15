From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 15 Oct 2008 03:22:43 +0000
Subject: Re: [PATCH 32/32] ia64/pv_ops: paravirtualized istruction checker.
Message-Id: <20081015032243.GE6061%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1223963507-28056-33-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1223963507-28056-33-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2008 at 02:58:48PM -0700, Luck, Tony wrote:
> > This patch implements a checker to detect instructions which
> > should be paravirtualized instead of direct writing raw instruction.
> > This patch does rough check so that it doesn't fully cover all cases,
> > but it can detects most cases of paravirtualization breakage of hand
> > written assembly codes.
> 
> There are still some "itc.d" instructions in ivt.S (in the #ifndef
> CONFIG_SMP code).  This checker caught them ... but the error messages
> from the build were not as elegant as they might be
> 
>   AS      arch/ia64/kernel/pvchk-ivt.o
> arch/ia64/kernel/ivt.S: Assembler messages:
> arch/ia64/kernel/ivt.S:583: Warning: itc.d should not be used directly.
> arch/ia64/kernel/ivt.S:583: Error: junk at end of line, first unrecognized character is `r'
> arch/ia64/kernel/ivt.S:649: Warning: itc.i should not be used directly.
> arch/ia64/kernel/ivt.S:649: Error: junk at end of line, first unrecognized character is `r'
> arch/ia64/kernel/ivt.S:701: Warning: itc.d should not be used directly.
> arch/ia64/kernel/ivt.S:701: Error: junk at end of line, first unrecognized character is `r'
> make[1]: *** [arch/ia64/kernel/pvchk-ivt.o] Error 1
> make: *** [arch/ia64/kernel] Error 2
> 
> 
> I'll hold off on applying part32/32 until the CONFIG_SMP=n case
> is fixed.
> 
> -Tony
> 

Here is the patch to fix the CONFIG_SMP=n case.
BTW with CONFIG_SMP=n, I got the following error so that
I had to disable kvm.

arch/ia64/kvm/vmm.c: In function 'vmm_spin_unlock':
arch/ia64/kvm/vmm.c:63: error: 'raw_spinlock_t' has no member named 'lock'


From 62a9ea7ff351db545e0dd1f44837b51ca7daa12e Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 15 Oct 2008 11:48:39 +0900
Subject: [PATCH] ia64/pv_ops: fix paraviatualization of ivt.S with CONFIG_SMP=n

When CONFIG_SMP=n, three instruction in ivt.S were missed to paravirtualize.
paravirtualize them.

Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/ivt.S |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 416a952..f675d8e 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -580,7 +580,7 @@ ENTRY(dirty_bit)
 	mov b0=r29				// restore b0
 	;;
 	st8 [r17]=r18				// store back updated PTE
-	itc.d r18				// install updated PTE
+	ITC_D(p0, r18, r16)			// install updated PTE
 #endif
 	mov pr=r31,-1				// restore pr
 	RFI
@@ -646,7 +646,7 @@ ENTRY(iaccess_bit)
 	mov b0=r29				// restore b0
 	;;
 	st8 [r17]=r18				// store back updated PTE
-	itc.i r18				// install updated PTE
+	ITC_I(p0, r18, r16)			// install updated PTE
 #endif /* !CONFIG_SMP */
 	mov pr=r31,-1
 	RFI
@@ -698,7 +698,7 @@ ENTRY(daccess_bit)
 	or r18=_PAGE_A,r18			// set the accessed bit
 	;;
 	st8 [r17]=r18				// store back updated PTE
-	itc.d r18				// install updated PTE
+	ITC_D(p0, r18, r16)			// install updated PTE
 #endif
 	mov b0=r29				// restore b0
 	mov pr=r31,-1
-- 
1.6.0.2


-- 
yamahata
