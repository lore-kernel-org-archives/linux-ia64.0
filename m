From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 21 Jun 2004 20:59:39 +0000
Subject: [PATCH] define cpu_logical_id() always
Message-Id: <200406211459.39151.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Define cpu_logical_id() even when !SMP.  I added uses of this in some
iosapic printk's, which broke the UP build.

=== include/asm-ia64/smp.h 1.17 vs edited ==--- 1.17/include/asm-ia64/smp.h	2004-05-14 20:00:12 -06:00
+++ edited/include/asm-ia64/smp.h	2004-06-21 14:44:12 -06:00
@@ -123,5 +123,9 @@
 extern void lock_ipi_calllock(void);
 extern void unlock_ipi_calllock(void);
 
+#else
+
+#define cpu_logical_id(cpuid)		0
+
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
=== include/asm-ia64/sn/sn_cpuid.h 1.8 vs edited ==--- 1.8/include/asm-ia64/sn/sn_cpuid.h	2004-02-03 22:39:51 -07:00
+++ edited/include/asm-ia64/sn/sn_cpuid.h	2004-06-21 14:53:37 -06:00
@@ -84,7 +84,6 @@
  */
 
 #ifndef CONFIG_SMP
-#define cpu_logical_id(cpu)				0
 #define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 #endif
 
