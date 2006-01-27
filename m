From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 01:37:43 +0000
Subject: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <200601270137.k0R1big21236@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use ia64 intrinsic for functions in sn/rw_mmr.h.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/sn/rw_mmr.h.orig	2006-01-26 18:27:42.750607692 -0800
+++ ./include/asm-ia64/sn/rw_mmr.h	2006-01-26 18:33:46.337517301 -0800
@@ -25,50 +25,43 @@
 extern inline long
 pio_phys_read_mmr(volatile long *mmr) 
 {
-	long val;
-        asm volatile
-            ("mov r2=psr;;"
-             "rsm psr.i | psr.dt;;"
-             "srlz.i;;"
-             "ld8.acq %0=[%1];;"
-             "mov psr.l=r2;;"
-             "srlz.i;;"
-             : "=r"(val)
-             : "r"(mmr)
-	     : "r2");
-        return val;
-}
-
+	long val, flags;
 
+	local_irq_save(flags);
+	ia64_rsm(IA64_PSR_DT);
+	ia64_srlz_d();
+	val = *mmr;
+	ia64_ssm(IA64_PSR_DT);
+	local_irq_restore(flags);
+	return val;
+}
 
 extern inline void
 pio_phys_write_mmr(volatile long *mmr, long val) 
 {
-        asm volatile
-            ("mov r2=psr;;"
-             "rsm psr.i | psr.dt;;"
-             "srlz.i;;"
-             "st8.rel [%0]=%1;;"
-             "mov psr.l=r2;;"
-             "srlz.i;;"
-	     :: "r"(mmr), "r"(val)
-             : "r2", "memory");
-}            
+	unsigned long flags;
+
+	local_irq_save(flags);
+	ia64_rsm(IA64_PSR_DT);
+	ia64_srlz_d();
+	*mmr = val;
+	ia64_ssm(IA64_PSR_DT);
+	local_irq_restore(flags);
+}
 
 extern inline void
 pio_atomic_phys_write_mmrs(volatile long *mmr1, long val1, volatile long *mmr2, long val2) 
 {
-        asm volatile
-            ("mov r2=psr;;"
-             "rsm psr.i | psr.dt | psr.ic;;"
-	     "cmp.ne p9,p0=%2,r0;"
-             "srlz.i;;"
-             "st8.rel [%0]=%1;"
-             "(p9) st8.rel [%2]=%3;;"
-             "mov psr.l=r2;;"
-             "srlz.i;;"
-	     :: "r"(mmr1), "r"(val1), "r"(mmr2), "r"(val2)
-             : "p9", "r2", "memory");
-}            
+	unsigned long flags;
+
+	local_irq_save(flags);
+	ia64_rsm(IA64_PSR_DT);
+	ia64_srlz_d();
+	*mmr1 = val1;
+	if (mmr2)
+		*mmr2 = val2;
+	ia64_ssm(IA64_PSR_DT);
+	local_irq_restore(flags);
+}
 
 #endif /* _ASM_IA64_SN_RW_MMR_H */


