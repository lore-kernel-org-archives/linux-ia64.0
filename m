From: Horms <horms@verge.net.au>
Date: Wed, 21 Jun 2006 06:27:29 +0000
Subject: [PATCH] ia64, kexec: make use of ia64_disable_vhpt()
Message-Id: <20060621062727.GA21347@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 21, 2006 at 01:16:06PM +1000, Ian Wienand wrote:
> Kexec wants a way to enable and disable the VHPT, and it seems quite
> straight forward to abstract it.  I think the reduced ia64_mmu_init is
> an improvement.

Here is a patch that makes use of that. Thanks.

-- 
Horms                                           http://www.vergenet.net/~horms/

ia64, kexec: make use of ia64_disable_vhpt()

Have kexec make use of ia64_disable_vhpt() which Ian Wienand recently
proposed and posted a patch for.

http://permalink.gmane.org/gmane.linux.ports.ia64/14425

This removes some duplicated macros in include/asm-ia64/kexec.h, and avoids
arch/ia64/kernel/smp.c needing to know anything about vhpt. It replaces
a cleanup patches that I posted the other day.

http://permalink.gmane.org/gmane.linux.ports.ia64/14406
http://permalink.gmane.org/gmane.linux.ports.ia64/14407

Signed-off-by: Horms <horms@verge.net.au>
---
 arch/ia64/kernel/smp.c   |    7 ++-----
 include/asm-ia64/kexec.h |    4 ----
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 6337278..5277fdc 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -93,7 +93,7 @@ #ifdef CONFIG_KEXEC
 void
 kexec_stop_this_cpu (void *func)
 {
-	unsigned long pta, impl_va_bits, pal_base;
+	unsigned long pal_base;
 
 	/*
 	 * Remove this CPU by putting it into fake SAL rendezvous
@@ -102,10 +102,7 @@ kexec_stop_this_cpu (void *func)
 	max_xtp();
 	ia64_eoi();
 
-	/* Disable VHPT */
-	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
-	pta = POW2(61) - POW2(vmlpt_bits);
-	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
+	ia64_disable_vhpt();
 
 	local_irq_disable();
 	pal_base = __get_cpu_var(ia64_mca_pal_base);
diff --git a/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
index d45c03f..e6dbe1d 100644
--- a/include/asm-ia64/kexec.h
+++ b/include/asm-ia64/kexec.h
@@ -16,10 +16,6 @@ #define KEXEC_ARCH KEXEC_ARCH_IA_64
 
 #define MAX_NOTE_BYTES 1024
 
-#define pte_bits	3
-#define vmlpt_bits	(impl_va_bits - PAGE_SHIFT + pte_bits)
-#define POW2(n)		(1ULL << (n))
-
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
 const extern unsigned int relocate_new_kernel_size;
 volatile extern long kexec_rendez;
-- 
1.4.0.gd281

