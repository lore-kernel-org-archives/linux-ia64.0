From: Christopher Wedgwood <cw@sgi.com>
Date: Sat, 19 Jul 2003 01:05:13 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105857678422381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 18, 2003 at 10:13:02AM -0600, Bjorn Helgaas wrote:

> But I do prefer the machine vector approach, and there are several
> other machine vectors used only at boot-time, so I don't think
> that's an issue.

I've done this but must say it feels like excessive abstraction and an
overkill approach.

The previous suggestion of mine was smaller and clearer.  Machine
vectors are at some level vague.  The preprocessor kung-foo involved
obscures things considerably (I think anyhow) so I still prefer the
smaller more-obvious approach I originally sent :)


 arch/ia64/kernel/efi.c          |  111 +++++++++++++++++++++++++++++-
 arch/ia64/kernel/setup.c        |    9 --
 arch/ia64/kernel/smpboot.c      |    2
 include/asm-ia64/machvec.h      |    9 ++
 include/asm-ia64/machvec_init.h |    1
 include/asm-ia64/machvec_sn2.h  |    1
 include/linux/efi.h             |    2
 7 files changed, 123 insertions(+), 12 deletions(-)


=== arch/ia64/kernel/efi.c 1.12 vs edited ==--- 1.12/arch/ia64/kernel/efi.c	Fri Mar 14 16:08:01 2003
+++ edited/arch/ia64/kernel/efi.c	Fri Jul 18 14:17:53 2003
@@ -392,9 +398,13 @@
  * Look for the PAL_CODE region reported by EFI and maps it using an
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
+ *
+ * This is called for every CPU in the system (ie. from efi_init for
+ * the boot CPU and from start_secondary() in smpboot.c for all other
+ * CPUs).  This is called using the machine vector mechanics.
  */
-void
-efi_map_pal_code (void)
+void __init
+ia64_generic_PAL_map (void)
 {
 	void *efi_map_start, *efi_map_end, *p;
 	efi_memory_desc_t *md;
@@ -462,6 +472,95 @@
 	}
 }
 
+#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
+/*
+ * This is more-or-less a copy of the original PAL mapping with replicated functionality.
+ * It all repeated here (out of line on the above) for clarity.  Since this is marked __init
+ * code it doesn't hurt that much.  Arguably we should either generalize these two functions
+ * or allow for a platform specific mapping function (a little tricky this early in the boot
+ * but not impossible).
+ *
+ * Please see the genric code for comments if any of this is unclear.
+ *
+ */
+void __init
+sn_PAL_map(void)
+{
+	static u64 pal_start = 0ul, pal_end = 0ul;
+	void *efi_map_start, *efi_map_end, *p;
+	int pg_shift;
+	u64 efi_desc_size;
+	u64 vaddr, mask, psr;
+
+#if EFI_DEBUG
+	printk("SGI: Mapping PAL.\n");
+#endif
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	/* The first time this runs (on the boot processor) we copy the PAL's start and end
+	   addresses because the trim code destroy's the EFI MD */
+	if (!pal_start) {
+		efi_memory_desc_t *md = NULL;
+
+		/* scan the efi memory map to find the PAL_CODE descriptor */
+		for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+			md = (efi_memory_desc_t*)p;
+
+			if (md->type != EFI_PAL_CODE)
+				continue;
+
+			break; /* there's only enough room in this town for one PAL */
+		}
+
+		if (!md)
+			panic(KERN_ERR "SN2: Unable to performace minimalist PAL mapping\n");
+
+		pal_start = md->phys_addr;
+		pal_end = pal_start + (md->num_pages << EFI_PAGE_SHIFT);
+
+		if (pal_end <= pal_start)
+			panic(KERN_ERR "SGI: PAL_CODE MD already hosed\n");
+	}
+
+	/* Find out the smallest page with which we can map the PAL */
+	for (pg_shift = _PAGE_SIZE_64K; pg_shift <= IA64_GRANULE_SHIFT; pg_shift += 2) {
+		/* round the start address down to our test page size */
+		u64 chk_start = pal_start & (~((1ul << pg_shift) - 1));
+
+		/* does the test page size cover the newly aligned size? */
+		if ((1ul << pg_shift) >= (pal_end - chk_start))
+			break;
+	}
+
+	if (pg_shift > IA64_GRANULE_SHIFT)
+		panic(KERN_ERR "SGI: Woah!  PAL code size bigger than a granule!");
+
+	vaddr = (u64)__va(pal_start);
+	mask  = ~((1ul<<pg_shift) - 1);
+
+#if EFI_DEBUG
+	printk("SGI: CPU(%d) pg_shift %d\n", smp_processor_id(), pg_shift);
+	printk("SGI: CPU(%d) actual PAL range phys: 0x%lx-0x%lx\n", smp_processor_id(), pal_start, pal_end);
+	printk("SGI: CPU(%d) PAL mapping from phys:0x%lx-0x%lx to virt:0x%lx-0x%lx\n",
+	       smp_processor_id(),
+	       pal_start & mask, (pal_start & mask) + (1ul<<pg_shift) - 1,
+	       vaddr & mask, (vaddr & mask) + (1ul<<pg_shift) - 1);
+#endif
+
+	psr = ia64_clear_ic();
+	ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask, pte_val(mk_pte_phys((pal_start & mask), PAGE_KERNEL)), pg_shift);
+	ia64_set_psr(psr);
+	ia64_srlz_i();
+
+	printk(KERN_DEBUG "SGI: Mapped PAL for CPU %d\n", smp_processor_id());
+}
+#endif /* CONFIG_IA64_GENERIC or CONFIG_IA64_SGI_SN2 */
+
+/* This is called early for the boot-CPU only...  we are therefore somewhat restricted in
+ * what we can blindly do. */
 void __init
 efi_init (void)
 {
@@ -542,6 +641,11 @@
 	}
 	printk("\n");
 
+#ifdef CONFIG_IA64_GENERIC
+	/* we have efi.acpi20 so we can do this now */
+	machvec_init(acpi_get_sysname());
+#endif
+
 	runtime = __va(efi.systab->runtime);
 	efi.get_time = phys_get_time;
 	efi.set_time = phys_set_time;
@@ -573,7 +677,8 @@
 	}
 #endif
 
-	efi_map_pal_code();
+	platform_PAL_map();
+
 	efi_enter_virtual_mode();
 }
 
=== arch/ia64/kernel/setup.c 1.13 vs edited ==--- 1.13/arch/ia64/kernel/setup.c	Thu May 29 16:19:59 2003
+++ edited/arch/ia64/kernel/setup.c	Fri Jul 18 14:17:53 2003
@@ -300,6 +300,9 @@
 
 	efi_init();
 
+	/* process SAL system table: */
+	ia64_sal_init(efi.sal_systab);
+
 	iomem_resource.end = ~0UL;	/* FIXME probably belongs elsewhere */
 	find_memory();
 
@@ -316,12 +319,6 @@
 	data_resource.end = virt_to_bus(&_edata) - 1;
 #endif
 
-	/* process SAL system table: */
-	ia64_sal_init(efi.sal_systab);
-
-#ifdef CONFIG_IA64_GENERIC
-	machvec_init(acpi_get_sysname());
-#endif
 
 	/*
 	 *  Set `iobase' to the appropriate address in region 6 (uncached access range).
=== arch/ia64/kernel/smpboot.c 1.14 vs edited ==--- 1.14/arch/ia64/kernel/smpboot.c	Fri May  9 07:42:04 2003
+++ edited/arch/ia64/kernel/smpboot.c	Fri Jul 18 12:07:07 2003
@@ -396,7 +396,7 @@
 	extern int cpu_idle (void);
 
 	Dprintk("start_secondary: starting CPU 0x%x\n", hard_smp_processor_id());
-	efi_map_pal_code();
+	platform_PAL_map();
 	cpu_init();
 	smp_callin();
 	Dprintk("CPU %d is set to go.\n", smp_processor_id());
=== include/asm-ia64/machvec.h 1.8 vs edited ==--- 1.8/include/asm-ia64/machvec.h	Thu Oct 31 15:39:07 2002
+++ edited/include/asm-ia64/machvec.h	Fri Jul 18 14:23:48 2003
@@ -63,6 +63,7 @@
 typedef void ia64_mv_outb_t (unsigned char, unsigned long);
 typedef void ia64_mv_outw_t (unsigned short, unsigned long);
 typedef void ia64_mv_outl_t (unsigned int, unsigned long);
+typedef void ia64_mv_PAL_map_t (void);
 
 extern void machvec_noop (void);
 
@@ -113,6 +114,7 @@
 #  define platform_outb		ia64_mv.outb
 #  define platform_outw		ia64_mv.outw
 #  define platform_outl		ia64_mv.outl
+#  define platform_PAL_map	ia64_mv.PAL_map
 # endif
 
 struct ia64_machine_vector {
@@ -148,6 +150,7 @@
 	ia64_mv_outb_t *outb;
 	ia64_mv_outw_t *outw;
 	ia64_mv_outl_t *outl;
+	ia64_mv_PAL_map_t *PAL_map;
 };
 
 #define MACHVEC_INIT(name)			\
@@ -183,7 +186,8 @@
 	platform_inl,				\
 	platform_outb,				\
 	platform_outw,				\
-	platform_outl				\
+	platform_outl,				\
+	platform_PAL_map				\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -300,6 +304,9 @@
 #endif
 #ifndef platform_outl
 # define platform_outl		__ia64_outl
+#endif
+#ifndef platform_PAL_map
+# define platform_PAL_map		ia64_generic_PAL_map
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
=== include/asm-ia64/machvec_init.h 1.3 vs edited ==--- 1.3/include/asm-ia64/machvec_init.h	Mon Jun 23 09:46:56 2003
+++ edited/include/asm-ia64/machvec_init.h	Fri Jul 18 14:23:48 2003
@@ -12,6 +12,7 @@
 extern ia64_mv_outb_t __ia64_outb;
 extern ia64_mv_outw_t __ia64_outw;
 extern ia64_mv_outl_t __ia64_outl;
+extern ia64_mv_PAL_map_t ia64_generic_PAL_map;
 
 #define MACHVEC_HELPER(name)									\
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __section__ (".machvec")))	\
=== include/asm-ia64/machvec_sn2.h 1.6 vs edited ==--- 1.6/include/asm-ia64/machvec_sn2.h	Thu May 29 02:22:05 2003
+++ edited/include/asm-ia64/machvec_sn2.h	Fri Jul 18 12:00:23 2003
@@ -91,5 +91,6 @@
 #define platform_pci_dma_sync_single	sn_pci_dma_sync_single
 #define platform_pci_dma_sync_sg	sn_pci_dma_sync_sg
 #define platform_pci_dma_supported	sn_pci_dma_supported
+#define platform_PAL_map		sn_PAL_map
 
 #endif /* _ASM_IA64_MACHVEC_SN2_H */
=== include/linux/efi.h 1.3 vs edited ==--- 1.3/include/linux/efi.h	Thu Sep 12 11:57:59 2002
+++ edited/include/linux/efi.h	Fri Jul 18 14:23:57 2003
@@ -258,13 +258,13 @@
 }
 
 extern void efi_init (void);
-extern void efi_map_pal_code (void);
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
 extern void efi_gettimeofday (struct timeval *tv);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, if possible */
 extern u64 efi_get_iobase (void);
 extern u32 efi_mem_type (unsigned long phys_addr);
 extern u64 efi_mem_attributes (unsigned long phys_addr);
+extern void ia64_generic_PAL_map (void);
 
 /*
  * Variable Attributes
