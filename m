From: Christopher Wedgwood <cw@sgi.com>
Date: Thu, 17 Jul 2003 01:34:20 +0000
Subject: [PATCH] (2.6.0-test1 bk) SN2 Minimalist PAL mapping
Message-Id: <marc-linux-ia64-105840575616404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

Given then lack of objections to the 2.4.x version of this patch thus
far how do you feel about something like this?

Patch against your linux-ia64-2.5 bk tree.



  --cw



# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1392  -> 1.1393 
#	arch/ia64/kernel/efi.c	1.21    -> 1.22   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/16	cw@tomahawk.engr.sgi.com	1.1393
# On SN2 map MAP using the smallest possible that will work.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Wed Jul 16 18:29:53 2003
+++ b/arch/ia64/kernel/efi.c	Wed Jul 16 18:29:53 2003
@@ -33,11 +33,20 @@
 
 #define EFI_DEBUG	0
 
+#ifdef EFI_DEBUG
+/* make debugging visible */
+#undef KERN_DEBUG
+#define KERN_DEBUG KERN_ERR
+#endif
+
 extern efi_status_t efi_call_phys (void *, ...);
 
 struct efi efi;
 static efi_runtime_services_t *runtime;
 
+/* For some architectures (presently only SN2) we may want to map the PAL differently */
+static void (*alternate_pal_map)(void);
+
 /*
  * efi_dir is allocated here, but the directory isn't created
  * here, as proc_mkdir() doesn't work this early in the bootup
@@ -392,8 +401,12 @@
  * Look for the PAL_CODE region reported by EFI and maps it using an
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
+ *
+ * This is called for every CPU in the system (ie. from efi_init for
+ * the boot CPU and from start_secondary() in smpboot.c for all other
+ * CPUs)
  */
-void
+void __init
 efi_map_pal_code (void)
 {
 	void *efi_map_start, *efi_map_end, *p;
@@ -403,6 +416,11 @@
 	u64 mask, psr;
 	u64 vaddr;
 
+	if (alternate_pal_map) {
+		alternate_pal_map();
+		return;
+	}
+
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
 	efi_desc_size = ia64_boot_param->efi_memdesc_size;
@@ -463,6 +481,93 @@
 	}
 }
 
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
+static void __init
+sgisn_efi_map_pal_code(void)
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
+	ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask, pte_val(pfn_pte((pal_start & mask) >> PAGE_SHIFT, PAGE_KERNEL)), pg_shift);
+	ia64_set_psr(psr);
+	ia64_srlz_i();
+
+	printk(KERN_DEBUG "SGI: Mapped PAL for CPU %d\n", smp_processor_id());
+}
+
+/* This is called early for the boot-CPU only...  we are therefore somewhat restricted in
+ * what we can blindly do. */
 void __init
 efi_init (void)
 {
@@ -573,6 +678,14 @@
 		}
 	}
 #endif
+
+	/* SGI's SN2 (Altix) requires slightly different PAL mapping semantics.  For now we
+	   check if this is the case and do it all out-of-line for clarity (once the code is
+	   merged we can clean this up).  We use a function pointer here because we want
+	   this decision to follow for all other non-boot CPUs where we don't easily have
+	   access to the vendor string (unless we want to be more invasive). */
+	if (!strncmp(vendor, "SGI", 3))
+		alternate_pal_map = sgisn_efi_map_pal_code;
 
 	efi_map_pal_code();
 	efi_enter_virtual_mode();
