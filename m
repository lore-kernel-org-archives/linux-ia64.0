From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 03:57:57 +0000
Subject: RE: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <200601270357.k0R3vwg22742@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use ia64 intrinsic for functions in sn/rw_mmr.h.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

---
Shhh.  Before anyone noticed, here is a new version that replaces
the original patch [5/5]

By the way, for my learning purpose, why does pio_atomic_phys_write_mmrs()
need to turn off psr.ic bit?


diff -Nurp linus-2.6.git/include/asm-ia64/sn/rw_mmr.h linus-2.6.git.new/include/asm-ia64/sn/rw_mmr.h
--- linus-2.6.git/include/asm-ia64/sn/rw_mmr.h	2006-01-25 16:39:25.000000000 -0800
+++ linus-2.6.git.new/include/asm-ia64/sn/rw_mmr.h	2006-01-26 20:51:14.424330324 -0800
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
 
+	flags = ia64_getreg(_IA64_REG_PSR);
+	ia64_rsm(IA64_PSR_I | IA64_PSR_DT);
+	ia64_srlz_d();
+	val = *mmr;
+	ia64_setreg(_IA64_REG_PSR, flags);
+	ia64_srlz_d();
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
+	flags = ia64_getreg(_IA64_REG_PSR);
+	ia64_rsm(IA64_PSR_I | IA64_PSR_DT);
+	ia64_srlz_d();
+	*mmr = val;
+	ia64_setreg(_IA64_REG_PSR, flags);
+ 	ia64_srlz_d();
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
+	flags = ia64_getreg(_IA64_REG_PSR);
+	ia64_rsm(IA64_PSR_DT | IA64_PSR_I | IA64_PSR_IC);
+	ia64_srlz_i();
+	*mmr1 = val1;
+	if (mmr2)
+		*mmr2 = val2;
+	ia64_setreg(_IA64_REG_PSR, flags);
+ 	ia64_srlz_i();
+}
 
 #endif /* _ASM_IA64_SN_RW_MMR_H */


