From: horms@tabatha.lab.ultramonkey.org
Date: Thu, 17 Aug 2006 07:07:24 +0000
Subject: [patch 5/5] kdump: simplify device_shootdown
Message-Id: <20060817071455.591468000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Archived-At: http://permalink.gmane.org/gmane.linux.ports.ia64/14683
>
> On Tue, 2006-08-15 at 09:56, Jay Lan wrote:
> > Bob Montgomery wrote:
> > > On Mon, 2006-08-14 at 14:47 +0800, Zou Nan hai wrote:
> > >
> > >>This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.
> > >
> > >
> 
> > ...
>   Jay,
>         Thanks very much, please try the following updated patch which
> simplify the device_shootdown code.
> 
> 
>   Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Incremental version of the patch posted by Zou Nan hai

Cc: Zou Nan hai <nanhai.zou@intel.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6-ia64/arch/ia64/kernel/crash.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/crash.c	2006-08-17 11:51:44.000000000 +0900
+++ linux-2.6-ia64/arch/ia64/kernel/crash.c	2006-08-17 11:52:06.000000000 +0900
@@ -47,13 +47,9 @@
 	int irq;
 	for (irq = 0; irq < NR_IRQS; irq++) {
 		idesc = irq_desc + irq;
-		if (!idesc || !idesc->action)
-			continue;
-		disable_irq_nosync(irq);
-		idesc->chip->end(irq);
-		idesc->chip->shutdown(irq);
+		if (idesc)
+			kdump_disable_irq(irq);
 	}
-
 #ifdef CONFIG_IA64_HP_ZX1
 	ioc_iova_disable();
 #endif
Index: linux-2.6-ia64/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/iosapic.c	2006-08-17 11:51:44.000000000 +0900
+++ linux-2.6-ia64/arch/ia64/kernel/iosapic.c	2006-08-17 11:52:06.000000000 +0900
@@ -288,6 +288,24 @@
 	/* do nothing... */
 }
 
+#ifdef CONFIG_CRASH_DUMP
+void
+kdump_disable_irq(unsigned int irq)
+{
+	u32 low32;
+	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_rte_info *rte;
+
+	low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
+	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
+			rte_list) {
+			iosapic_write(rte->addr,
+					IOSAPIC_RTE_LOW(rte->rte_index), low32);
+			iosapic_eoi(rte->addr, vec);
+	}
+}
+#endif
+
 static void
 mask_irq (unsigned int irq)
 {
Index: linux-2.6-ia64/include/asm-ia64/kexec.h
=================================--- linux-2.6-ia64.orig/include/asm-ia64/kexec.h	2006-08-17 11:51:45.000000000 +0900
+++ linux-2.6-ia64/include/asm-ia64/kexec.h	2006-08-17 11:52:06.000000000 +0900
@@ -34,5 +34,7 @@
 extern struct resource efi_memmap_res;
 extern struct resource boot_param_res;
 extern void kdump_smp_send_stop(void);
+extern void kdump_disable_irq(unsigned int irq);
 extern void crash_save_this_cpu(void);
+
 #endif /* _ASM_IA64_KEXEC_H */

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

