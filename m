From: Jack Steiner <steiner@sgi.com>
Date: Fri, 15 Aug 2003 16:42:59 +0000
Subject: Add ia64_tpa & ia64_imva for 2.4.21
Message-Id: <marc-linux-ia64-106096639130452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Because of the strange memory map on the SGI SN hardware, we need a 
portion of the 2.6 patches from Tony Luck backported into 2.4.21. 

This patche adds the ia64_imva function & a few additional calls to ia64_tpa.

In 2.6, these patches were part of the change to relocate the kernel to
region 5. However, I am NOT proposing making that change!!  I just need the
macros!!



Patch is attach & is based on the 2.4.21 bitkeeper tree.


diff -Naru linux_base/arch/ia64/kernel/setup.c linux/arch/ia64/kernel/setup.c
--- linux_base/arch/ia64/kernel/setup.c	Wed Aug 13 12:09:37 2003
+++ linux/arch/ia64/kernel/setup.c	Thu Aug 14 22:57:52 2003
@@ -305,8 +305,8 @@
 				+ strlen(__va(ia64_boot_param->command_line)) + 1);
 	n++;
 
-	rsvd_region[n].start = KERNEL_START;
-	rsvd_region[n].end   = KERNEL_END;
+	rsvd_region[n].start = ia64_imva(KERNEL_START);
+	rsvd_region[n].end   = ia64_imva(KERNEL_END);
 	n++;
 
 #ifdef CONFIG_BLK_DEV_INITRD
diff -Naru linux_base/arch/ia64/kernel/smpboot.c linux/arch/ia64/kernel/smpboot.c
--- linux_base/arch/ia64/kernel/smpboot.c	Wed Aug 13 12:09:37 2003
+++ linux/arch/ia64/kernel/smpboot.c	Thu Aug 14 18:24:58 2003
@@ -577,7 +577,7 @@
 	/* Tell SAL where to drop the AP's.  */
 	ap_startup = (struct fptr *) start_ap;
 	sal_ret = ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ,
-				       __pa(ap_startup->fp), __pa(ap_startup->gp), 0, 0, 0, 0);
+				      ia64_tpa(ap_startup->fp), ia64_tpa(ap_startup->gp), 0, 0, 0, 0);
 	if (sal_ret < 0) {
 		printk(KERN_ERR "SMP: Can't set SAL AP Boot Rendezvous: %s\n     Forcing UP mode\n",
 		       ia64_sal_strerror(sal_ret));
diff -Naru linux_base/arch/ia64/mm/init.c linux/arch/ia64/mm/init.c
--- linux_base/arch/ia64/mm/init.c	Wed Aug 13 12:09:37 2003
+++ linux/arch/ia64/mm/init.c	Thu Aug 14 22:58:09 2003
@@ -114,8 +114,8 @@
 {
 	unsigned long addr, eaddr;
 
-	addr = (unsigned long) &__init_begin;
-	eaddr = (unsigned long) &__init_end;
+	addr = (unsigned long) ia64_imva(&__init_begin);
+	eaddr = (unsigned long) ia64_imva(&__init_end);
 	for (; addr < eaddr; addr += PAGE_SIZE) {
 		clear_bit(PG_reserved, &virt_to_page((void *)addr)->flags);
 		set_page_count(virt_to_page((void *)addr), 1);
@@ -577,7 +577,7 @@
 		}
 	}
 
-	zero_page_memmap_ptr = virt_to_page(empty_zero_page);
+	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
 
 static int
@@ -646,7 +646,7 @@
 		pgt_cache_water[1] = num_pgt_pages;
 
 	/* install the gate page in the global page table: */
-	put_gate_page(virt_to_page(__start_gate_section), GATE_ADDR);
+	put_gate_page(virt_to_page(ia64_imva(__start_gate_section)), GATE_ADDR);
 
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_gdt_init();
diff -Naru linux_base/arch/ia64/sn/kernel/bte.c linux/arch/ia64/sn/kernel/bte.c
--- linux_base/arch/ia64/sn/kernel/bte.c	Wed Aug 13 12:09:38 2003
+++ linux/arch/ia64/sn/kernel/bte.c	Thu Aug 14 08:08:21 2003
@@ -156,8 +156,8 @@
 
 	/* Set the notification register */
 	BTE_PRINTKV(("IBNA - HUB_S(0x%p, 0x%lx)\n", BTEREG_NOTIF_ADDR,
-		     (TO_PHYS(__tpa(bte->most_rcnt_na)))));
-	HUB_S(BTEREG_NOTIF_ADDR, (TO_PHYS(__tpa(bte->most_rcnt_na))));
+		     (TO_PHYS(ia64_tpa(bte->most_rcnt_na)))));
+	HUB_S(BTEREG_NOTIF_ADDR, (TO_PHYS(ia64_tpa(bte->most_rcnt_na))));
 
 
 	/* Initiate the transfer */
@@ -294,7 +294,7 @@
 				headBteLen += footBteLen;
 			} else if (footBcopyLen > 0) {
 				rv = bte_copy(footBteSource,
-					      __tpa(bteBlock),
+					      ia64_tpa(bteBlock),
 					      footBteLen, mode, NULL);
 				if (rv != BTE_SUCCESS) {
 					return rv;
@@ -344,7 +344,7 @@
 
 	if (headBcopyLen > 0) {
 		rv = bte_copy(headBteSource,
-			      __tpa(bteBlock), headBteLen, mode, NULL);
+			      ia64_tpa(bteBlock), headBteLen, mode, NULL);
 		if (rv != BTE_SUCCESS) {
 			return rv;
 		}
diff -Naru linux_base/include/asm-ia64/processor.h linux/include/asm-ia64/processor.h
--- linux_base/include/asm-ia64/processor.h	Wed Aug 13 12:11:01 2003
+++ linux/include/asm-ia64/processor.h	Fri Aug 15 11:07:54 2003
@@ -959,6 +959,20 @@
 	return result;
 }
 
+/*
+ * Take a mapped kernel address and return the equivalent address
+ * in the region 7 identity mapped virtual area.
+ */
+static inline void *
+ia64_imva (void *addr)
+{
+	void *result;
+	asm ("tpa %0=%1" : "=r"(result) : "r"(addr));
+	return __va(result);
+}
+
+#define __imva(x) ((long)__va(ia64_tpa(x)))
+
 #define ARCH_HAS_PREFETCH
 #define ARCH_HAS_PREFETCHW
 #define ARCH_HAS_SPINLOCK_PREFETCH

-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

