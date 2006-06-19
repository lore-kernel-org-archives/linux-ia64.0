From: Horms <horms@verge.net.au>
Date: Mon, 19 Jun 2006 08:24:45 +0000
Subject: Re: [PATCH 2/2] ia64, kexec: make use of shared mmu-related marcos
Message-Id: <20060619082443.GB15635@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a follow up patch which makes use of newly shared mmu-related marcos.

Signed-off-by: Horms <horms@verge.net.au>

 arch/ia64/kernel/smp.c   |    4 ++--
 include/asm-ia64/kexec.h |    4 ----
 2 files changed, 2 insertions(+), 6 deletions(-)

05aab9d7851bae8cafc152bea91678aa668b1d7d
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 6337278..81baf67 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -104,8 +104,8 @@ kexec_stop_this_cpu (void *func)
 
 	/* Disable VHPT */
 	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
-	pta = POW2(61) - POW2(vmlpt_bits);
-	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
+	pta = POW2(61) - POW2(vmlpt_bits(impl_va_bits));
+	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits(impl_va_bits) << 2) | 0);
 
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
