From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 07 Jun 2002 21:54:57 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.18)
Message-Id: <marc-linux-ia64-105590701905654@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 	-- Again with CONFIG_GENERIC, there are problems:
>
> include/asm/machvec.h:83:12: warning: pasting "machvec_hpsim" and "."
> does not give a valid preprocessing token
> include/asm/machvec_init.h:26: initializer element is not constant
> include/asm/machvec_init.h:26: (near initialization for
> `machvec_hpsim.dma_supported') include/asm/machvec_init.h:26:
> `__ia64_mmiob' undeclared here (not in a function)
> include/asm/machvec_init.h:26: initializer element is not constant

I forgot that you had run into these problems too.  If you haven't
alread fixed them, you can try the attached patch which I sent to
David this morning.

Grant also fixed the sba_iommu.c problems, that patch is coming
soon.  Both are required to make the generic kernel build.
-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux Systems Operation R&D
Hewlett-Packard Company


diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/arch/ia64/hp/zx1/hpzx1_machvec.c linux-2.5.18-ia64-020530/arch/ia64/hp/zx1/hpzx1_machvec.c
--- linux-2.5.18-ia64-020530.orig/arch/ia64/hp/zx1/hpzx1_machvec.c	Fri May 24 19:55:24 2002
+++ linux-2.5.18-ia64-020530/arch/ia64/hp/zx1/hpzx1_machvec.c	Thu Jun  6 10:37:14 2002
@@ -1,4 +1,2 @@
 #define MACHVEC_PLATFORM_NAME	hpzx1
 #include <asm/machvec_init.h>
-#define MACHVEC_PLATFORM_NAME	hpzx1
-#include <asm/machvec_init.h>
diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/arch/ia64/lib/io.c linux-2.5.18-ia64-020530/arch/ia64/lib/io.c
--- linux-2.5.18-ia64-020530.orig/arch/ia64/lib/io.c	Fri May 24 19:55:16 2002
+++ linux-2.5.18-ia64-020530/arch/ia64/lib/io.c	Thu Jun  6 11:07:16 2002
@@ -87,6 +87,12 @@
 	__ia64_outl(val, port);
 }
 
+void
+ia64_mmiob (void)
+{
+	__ia64_mmiob();
+}
+
 /* define aliases: */
 
 asm (".global __ia64_inb, __ia64_inw, __ia64_inl");
@@ -98,5 +104,8 @@
 asm ("__ia64_outb = ia64_outb");
 asm ("__ia64_outw = ia64_outw");
 asm ("__ia64_outl = ia64_outl");
+
+asm (".global __ia64_mmiob");
+asm ("__ia64_mmiob = ia64_mmiob");
 
 #endif /* CONFIG_IA64_GENERIC */
diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/include/asm-ia64/machvec.h linux-2.5.18-ia64-020530/include/asm-ia64/machvec.h
--- linux-2.5.18-ia64-020530.orig/include/asm-ia64/machvec.h	Thu Jun  6 10:11:46 2002
+++ linux-2.5.18-ia64-020530/include/asm-ia64/machvec.h	Fri Jun  7 10:49:22 2002
@@ -210,6 +210,7 @@
 extern ia64_mv_pci_dma_sync_single swiotlb_sync_single;
 extern ia64_mv_pci_dma_sync_sg swiotlb_sync_sg;
 extern ia64_mv_pci_dma_address swiotlb_dma_address;
+extern ia64_mv_pci_dma_supported swiotlb_pci_dma_supported;
 
 /*
  * Define default versions so we can extend machvec for new platforms without having
diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/include/asm-ia64/machvec_init.h linux-2.5.18-ia64-020530/include/asm-ia64/machvec_init.h
--- linux-2.5.18-ia64-020530.orig/include/asm-ia64/machvec_init.h	Thu Jun  6 10:22:38 2002
+++ linux-2.5.18-ia64-020530/include/asm-ia64/machvec_init.h	Fri Jun  7 10:49:29 2002
@@ -16,6 +16,7 @@
 extern ia64_mv_outb_t __ia64_outb;
 extern ia64_mv_outw_t __ia64_outw;
 extern ia64_mv_outl_t __ia64_outl;
+extern ia64_mv_mmiob_t __ia64_mmiob;
 
 #define MACHVEC_HELPER(name)									\
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __section__ (".machvec")))	\
diff -u -r -X /home/helgaas/exclude linux-2.5.18-ia64-020530.orig/include/asm-ia64/page.h linux-2.5.18-ia64-020530/include/asm-ia64/page.h
--- linux-2.5.18-ia64-020530.orig/include/asm-ia64/page.h	Thu Jun  6 09:54:16 2002
+++ linux-2.5.18-ia64-020530/include/asm-ia64/page.h	Thu Jun  6 14:35:21 2002
@@ -56,6 +56,18 @@
 	flush_dcache_page(page);		\
 } while (0)
 
+/*
+ * Note: the MAP_NR_*() macro can't use __pa() because MAP_NR_*(X) MUST
+ * map to something >= max_mapnr if X is outside the identity mapped
+ * kernel space.
+ */
+
+/*
+ * The dense variant can be used as long as the size of memory holes isn't
+ * very big.
+ */
+#define MAP_NR_DENSE(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE_SHIFT)
+
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)


