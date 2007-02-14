From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Feb 2007 07:17:47 +0000
Subject: [PATCH] [IA64] kexec: declare ia64_mca_pal_base in mca.h rather than kexec.h
Message-Id: <20070214071745.GA17011@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Kexec adds some code to arch/ia64/kernel/smp.c which needs ia64_mca_pal_base,
  so the kexec patch (actually the kdump patch) declares this
  per-cpu variable in include/asm-ia64/kexec.h.
    
* ia64_mca_pal_base is defined in arch/ia64/kernel/mca.c, so it
  seems to me that it would make a lot more sense to declare it in
  include/asm-ia64/mca.h.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/include/asm-ia64/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2006-12-19 13:08:21.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2006-12-19 13:08:29.000000000 +0900
@@ -22,7 +22,6 @@
         } while(0)
 
 extern struct kimage *ia64_kimage;
-DECLARE_PER_CPU(u64, ia64_mca_pal_base);
 const extern unsigned int relocate_new_kernel_size;
 extern void relocate_new_kernel(unsigned long, unsigned long,
 		struct ia64_boot_param *, unsigned long);
Index: linux-2.6/include/asm-ia64/mca.h
=================================--- linux-2.6.orig/include/asm-ia64/mca.h	2006-12-19 13:08:21.000000000 +0900
+++ linux-2.6/include/asm-ia64/mca.h	2006-12-19 13:08:37.000000000 +0900
@@ -156,6 +156,8 @@
 	int *monarch_cpu;
 };
 
+DECLARE_PER_CPU(u64, ia64_mca_pal_base);
+
 #else	/* __ASSEMBLY__ */
 
 #define IA64_MCA_CORRECTED	0x0	/* Error has been corrected by OS_MCA */
