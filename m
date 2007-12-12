From: Aron Griffis <aron@hp.com>
Date: Wed, 12 Dec 2007 15:07:48 +0000
Subject: [PATCH 1 of 4] Make efi.c fit in 80 columns
Message-Id: <1161690ae81590dec4e9.1197472068@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

# HG changeset patch
# User Aron Griffis <aron@hp.com>
# Date 1197428035 18000
# Node ID 1161690ae81590dec4e97c52f07cf1798c11a97b
# Parent  3085cb07495e9e6c275c816342b27225d5f6529d
Make efi.c fit in 80 columns

This patch is purely whitespace changes to make the code
fit in 80 columns, plus fix some inconsistent indentation.

Signed-off-by: Aron Griffis <aron@hp.com>

diff -r 3085cb07495e -r 1161690ae815 arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Mon Dec 10 10:18:27 2007 -0800
+++ b/arch/ia64/kernel/efi.c	Tue Dec 11 21:53:55 2007 -0500
@@ -1,7 +1,8 @@
 /*
  * Extensible Firmware Interface
  *
- * Based on Extensible Firmware Interface Specification version 0.9 April 30, 1999
+ * Based on Extensible Firmware Interface Specification version 0.9
+ * April 30, 1999
  *
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
@@ -48,145 +49,157 @@ static unsigned long mem_limit = ~0UL, m
 
 #define efi_call_virt(f, args...)	(*(f))(args)
 
-#define STUB_GET_TIME(prefix, adjust_arg)							  \
-static efi_status_t										  \
-prefix##_get_time (efi_time_t *tm, efi_time_cap_t *tc)						  \
-{												  \
-	struct ia64_fpreg fr[6];								  \
-	efi_time_cap_t *atc = NULL;								  \
-	efi_status_t ret;									  \
-												  \
-	if (tc)											  \
-		atc = adjust_arg(tc);								  \
-	ia64_save_scratch_fpregs(fr);								  \
-	ret = efi_call_##prefix((efi_get_time_t *) __va(runtime->get_time), adjust_arg(tm), atc); \
-	ia64_load_scratch_fpregs(fr);								  \
-	return ret;										  \
+#define STUB_GET_TIME(prefix, adjust_arg)				       \
+static efi_status_t							       \
+prefix##_get_time (efi_time_t *tm, efi_time_cap_t *tc)			       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_time_cap_t *atc = NULL;					       \
+	efi_status_t ret;						       \
+									       \
+	if (tc)								       \
+		atc = adjust_arg(tc);					       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix((efi_get_time_t *) __va(runtime->get_time),    \
+				adjust_arg(tm), atc);			       \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_SET_TIME(prefix, adjust_arg)							\
-static efi_status_t										\
-prefix##_set_time (efi_time_t *tm)								\
-{												\
-	struct ia64_fpreg fr[6];								\
-	efi_status_t ret;									\
-												\
-	ia64_save_scratch_fpregs(fr);								\
-	ret = efi_call_##prefix((efi_set_time_t *) __va(runtime->set_time), adjust_arg(tm));	\
-	ia64_load_scratch_fpregs(fr);								\
-	return ret;										\
+#define STUB_SET_TIME(prefix, adjust_arg)				       \
+static efi_status_t							       \
+prefix##_set_time (efi_time_t *tm)					       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_status_t ret;						       \
+									       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix((efi_set_time_t *) __va(runtime->set_time),    \
+				adjust_arg(tm));			       \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_GET_WAKEUP_TIME(prefix, adjust_arg)						\
-static efi_status_t										\
-prefix##_get_wakeup_time (efi_bool_t *enabled, efi_bool_t *pending, efi_time_t *tm)		\
-{												\
-	struct ia64_fpreg fr[6];								\
-	efi_status_t ret;									\
-												\
-	ia64_save_scratch_fpregs(fr);								\
-	ret = efi_call_##prefix((efi_get_wakeup_time_t *) __va(runtime->get_wakeup_time),	\
-				adjust_arg(enabled), adjust_arg(pending), adjust_arg(tm));	\
-	ia64_load_scratch_fpregs(fr);								\
-	return ret;										\
+#define STUB_GET_WAKEUP_TIME(prefix, adjust_arg)			       \
+static efi_status_t							       \
+prefix##_get_wakeup_time (efi_bool_t *enabled, efi_bool_t *pending,	       \
+			  efi_time_t *tm)				       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_status_t ret;						       \
+									       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix(					       \
+		(efi_get_wakeup_time_t *) __va(runtime->get_wakeup_time),      \
+		adjust_arg(enabled), adjust_arg(pending), adjust_arg(tm));     \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_SET_WAKEUP_TIME(prefix, adjust_arg)						\
-static efi_status_t										\
-prefix##_set_wakeup_time (efi_bool_t enabled, efi_time_t *tm)					\
-{												\
-	struct ia64_fpreg fr[6];								\
-	efi_time_t *atm = NULL;									\
-	efi_status_t ret;									\
-												\
-	if (tm)											\
-		atm = adjust_arg(tm);								\
-	ia64_save_scratch_fpregs(fr);								\
-	ret = efi_call_##prefix((efi_set_wakeup_time_t *) __va(runtime->set_wakeup_time),	\
-				enabled, atm);							\
-	ia64_load_scratch_fpregs(fr);								\
-	return ret;										\
+#define STUB_SET_WAKEUP_TIME(prefix, adjust_arg)			       \
+static efi_status_t							       \
+prefix##_set_wakeup_time (efi_bool_t enabled, efi_time_t *tm)		       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_time_t *atm = NULL;						       \
+	efi_status_t ret;						       \
+									       \
+	if (tm)								       \
+		atm = adjust_arg(tm);					       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix(					       \
+		(efi_set_wakeup_time_t *) __va(runtime->set_wakeup_time),      \
+		enabled, atm);						       \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_GET_VARIABLE(prefix, adjust_arg)						\
-static efi_status_t									\
-prefix##_get_variable (efi_char16_t *name, efi_guid_t *vendor, u32 *attr,		\
-		       unsigned long *data_size, void *data)				\
-{											\
-	struct ia64_fpreg fr[6];							\
-	u32 *aattr = NULL;									\
-	efi_status_t ret;								\
-											\
-	if (attr)									\
-		aattr = adjust_arg(attr);						\
-	ia64_save_scratch_fpregs(fr);							\
-	ret = efi_call_##prefix((efi_get_variable_t *) __va(runtime->get_variable),	\
-				adjust_arg(name), adjust_arg(vendor), aattr,		\
-				adjust_arg(data_size), adjust_arg(data));		\
-	ia64_load_scratch_fpregs(fr);							\
-	return ret;									\
+#define STUB_GET_VARIABLE(prefix, adjust_arg)				       \
+static efi_status_t							       \
+prefix##_get_variable (efi_char16_t *name, efi_guid_t *vendor, u32 *attr,      \
+		       unsigned long *data_size, void *data)		       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	u32 *aattr = NULL;						       \
+	efi_status_t ret;						       \
+									       \
+	if (attr)							       \
+		aattr = adjust_arg(attr);				       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix(					       \
+		(efi_get_variable_t *) __va(runtime->get_variable),	       \
+		adjust_arg(name), adjust_arg(vendor), aattr,		       \
+		adjust_arg(data_size), adjust_arg(data));		       \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_GET_NEXT_VARIABLE(prefix, adjust_arg)						\
-static efi_status_t										\
-prefix##_get_next_variable (unsigned long *name_size, efi_char16_t *name, efi_guid_t *vendor)	\
-{												\
-	struct ia64_fpreg fr[6];								\
-	efi_status_t ret;									\
-												\
-	ia64_save_scratch_fpregs(fr);								\
-	ret = efi_call_##prefix((efi_get_next_variable_t *) __va(runtime->get_next_variable),	\
-				adjust_arg(name_size), adjust_arg(name), adjust_arg(vendor));	\
-	ia64_load_scratch_fpregs(fr);								\
-	return ret;										\
+#define STUB_GET_NEXT_VARIABLE(prefix, adjust_arg)			       \
+static efi_status_t							       \
+prefix##_get_next_variable (unsigned long *name_size, efi_char16_t *name,      \
+			    efi_guid_t *vendor)				       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_status_t ret;						       \
+									       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix(					       \
+		(efi_get_next_variable_t *) __va(runtime->get_next_variable),  \
+		adjust_arg(name_size), adjust_arg(name), adjust_arg(vendor));  \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_SET_VARIABLE(prefix, adjust_arg)						\
-static efi_status_t									\
-prefix##_set_variable (efi_char16_t *name, efi_guid_t *vendor, unsigned long attr,	\
-		       unsigned long data_size, void *data)				\
-{											\
-	struct ia64_fpreg fr[6];							\
-	efi_status_t ret;								\
-											\
-	ia64_save_scratch_fpregs(fr);							\
-	ret = efi_call_##prefix((efi_set_variable_t *) __va(runtime->set_variable),	\
-				adjust_arg(name), adjust_arg(vendor), attr, data_size,	\
-				adjust_arg(data));					\
-	ia64_load_scratch_fpregs(fr);							\
-	return ret;									\
+#define STUB_SET_VARIABLE(prefix, adjust_arg)				       \
+static efi_status_t							       \
+prefix##_set_variable (efi_char16_t *name, efi_guid_t *vendor,		       \
+		       unsigned long attr, unsigned long data_size,	       \
+		       void *data)					       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_status_t ret;						       \
+									       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix(					       \
+		(efi_set_variable_t *) __va(runtime->set_variable),	       \
+		adjust_arg(name), adjust_arg(vendor), attr, data_size,	       \
+		adjust_arg(data));					       \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_GET_NEXT_HIGH_MONO_COUNT(prefix, adjust_arg)					\
-static efi_status_t										\
-prefix##_get_next_high_mono_count (u32 *count)							\
-{												\
-	struct ia64_fpreg fr[6];								\
-	efi_status_t ret;									\
-												\
-	ia64_save_scratch_fpregs(fr);								\
-	ret = efi_call_##prefix((efi_get_next_high_mono_count_t *)				\
-				__va(runtime->get_next_high_mono_count), adjust_arg(count));	\
-	ia64_load_scratch_fpregs(fr);								\
-	return ret;										\
+#define STUB_GET_NEXT_HIGH_MONO_COUNT(prefix, adjust_arg)		       \
+static efi_status_t							       \
+prefix##_get_next_high_mono_count (u32 *count)				       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_status_t ret;						       \
+									       \
+	ia64_save_scratch_fpregs(fr);					       \
+	ret = efi_call_##prefix((efi_get_next_high_mono_count_t *)	       \
+				__va(runtime->get_next_high_mono_count),       \
+				adjust_arg(count));			       \
+	ia64_load_scratch_fpregs(fr);					       \
+	return ret;							       \
 }
 
-#define STUB_RESET_SYSTEM(prefix, adjust_arg)					\
-static void									\
-prefix##_reset_system (int reset_type, efi_status_t status,			\
-		       unsigned long data_size, efi_char16_t *data)		\
-{										\
-	struct ia64_fpreg fr[6];						\
-	efi_char16_t *adata = NULL;						\
-										\
-	if (data)								\
-		adata = adjust_arg(data);					\
-										\
-	ia64_save_scratch_fpregs(fr);						\
-	efi_call_##prefix((efi_reset_system_t *) __va(runtime->reset_system),	\
-			  reset_type, status, data_size, adata);		\
-	/* should not return, but just in case... */				\
-	ia64_load_scratch_fpregs(fr);						\
+#define STUB_RESET_SYSTEM(prefix, adjust_arg)				       \
+static void								       \
+prefix##_reset_system (int reset_type, efi_status_t status,		       \
+		       unsigned long data_size, efi_char16_t *data)	       \
+{									       \
+	struct ia64_fpreg fr[6];					       \
+	efi_char16_t *adata = NULL;					       \
+									       \
+	if (data)							       \
+		adata = adjust_arg(data);				       \
+									       \
+	ia64_save_scratch_fpregs(fr);					       \
+	efi_call_##prefix(						       \
+		(efi_reset_system_t *) __va(runtime->reset_system),	       \
+		reset_type, status, data_size, adata);			       \
+	/* should not return, but just in case... */			       \
+	ia64_load_scratch_fpregs(fr);					       \
 }
 
 #define phys_ptr(arg)	((__typeof__(arg)) ia64_tpa(arg))
@@ -223,7 +236,8 @@ efi_gettimeofday (struct timespec *ts)
 		return;
 	}
 
-	ts->tv_sec = mktime(tm.year, tm.month, tm.day, tm.hour, tm.minute, tm.second);
+	ts->tv_sec = mktime(tm.year, tm.month, tm.day,
+			    tm.hour, tm.minute, tm.second);
 	ts->tv_nsec = tm.nanosecond;
 }
 
@@ -297,8 +311,8 @@ walk (efi_freemem_callback_t callback, v
 }
 
 /*
- * Walks the EFI memory map and calls CALLBACK once for each EFI memory descriptor that
- * has memory that is available for OS use.
+ * Walks the EFI memory map and calls CALLBACK once for each EFI memory
+ * descriptor that has memory that is available for OS use.
  */
 void
 efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
@@ -307,8 +321,8 @@ efi_memmap_walk (efi_freemem_callback_t 
 }
 
 /*
- * Walks the EFI memory map and calls CALLBACK once for each EFI memory descriptor that
- * has memory that is available for uncached allocator.
+ * Walks the EFI memory map and calls CALLBACK once for each EFI memory
+ * descriptor that has memory that is available for uncached allocator.
  */
 void
 efi_memmap_walk_uc (efi_freemem_callback_t callback, void *arg)
@@ -321,7 +335,6 @@ efi_memmap_walk_uc (efi_freemem_callback
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
  */
-
 void *
 efi_get_pal_addr (void)
 {
@@ -341,32 +354,33 @@ efi_get_pal_addr (void)
 			continue;
 
 		if (++pal_code_count > 1) {
-			printk(KERN_ERR "Too many EFI Pal Code memory ranges, dropped @ %lx\n",
-			       md->phys_addr);
+			printk(KERN_ERR "Too many EFI Pal Code memory ranges, "
+			       "dropped @ %lx\n", md->phys_addr);
 			continue;
 		}
 		/*
-		 * The only ITLB entry in region 7 that is used is the one installed by
-		 * __start().  That entry covers a 64MB range.
+		 * The only ITLB entry in region 7 that is used is the one
+		 * installed by __start().  That entry covers a 64MB range.
 		 */
 		mask  = ~((1 << KERNEL_TR_PAGE_SHIFT) - 1);
 		vaddr = PAGE_OFFSET + md->phys_addr;
 
 		/*
-		 * We must check that the PAL mapping won't overlap with the kernel
-		 * mapping.
+		 * We must check that the PAL mapping won't overlap with the
+		 * kernel mapping.
 		 *
-		 * PAL code is guaranteed to be aligned on a power of 2 between 4k and
-		 * 256KB and that only one ITR is needed to map it. This implies that the
-		 * PAL code is always aligned on its size, i.e., the closest matching page
-		 * size supported by the TLB. Therefore PAL code is guaranteed never to
-		 * cross a 64MB unless it is bigger than 64MB (very unlikely!).  So for
-		 * now the following test is enough to determine whether or not we need a
-		 * dedicated ITR for the PAL code.
+		 * PAL code is guaranteed to be aligned on a power of 2 between
+		 * 4k and 256KB and that only one ITR is needed to map it. This
+		 * implies that the PAL code is always aligned on its size,
+		 * i.e., the closest matching page size supported by the TLB.
+		 * Therefore PAL code is guaranteed never to cross a 64MB unless
+		 * it is bigger than 64MB (very unlikely!).  So for now the
+		 * following test is enough to determine whether or not we need
+		 * a dedicated ITR for the PAL code.
 		 */
 		if ((vaddr & mask) = (KERNEL_START & mask)) {
-			printk(KERN_INFO "%s: no need to install ITR for PAL code\n",
-			       __FUNCTION__);
+			printk(KERN_INFO "%s: no need to install ITR for "
+			       "PAL code\n", __FUNCTION__);
 			continue;
 		}
 
@@ -376,10 +390,11 @@ efi_get_pal_addr (void)
 #if EFI_DEBUG
 		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
 
-		printk(KERN_INFO "CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
-			smp_processor_id(), md->phys_addr,
-			md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
-			vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
+		printk(KERN_INFO "CPU %d: mapping PAL code "
+		       "[0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
+		       smp_processor_id(), md->phys_addr,
+		       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 #endif
 		return __va(md->phys_addr);
 	}
@@ -401,7 +416,8 @@ efi_map_pal_code (void)
 	 * Cannot write to CRx with PSR.ic=1
 	 */
 	psr = ia64_clear_ic();
-	ia64_itr(0x1, IA64_TR_PALCODE, GRANULEROUNDDOWN((unsigned long) pal_vaddr),
+	ia64_itr(0x1, IA64_TR_PALCODE,
+		 GRANULEROUNDDOWN((unsigned long) pal_vaddr),
 		 pte_val(pfn_pte(__pa(pal_vaddr) >> PAGE_SHIFT, PAGE_KERNEL)),
 		 IA64_GRANULE_SHIFT);
 	ia64_set_psr(psr);		/* restore psr */
@@ -418,7 +434,10 @@ efi_init (void)
 	char *cp, vendor[100] = "unknown";
 	int i;
 
-	/* it's too early to be able to use the standard kernel command line support... */
+	/*
+	 * it's too early to be able to use the standard kernel command line
+	 * support...
+	 */
 	for (cp = boot_command_line; *cp; ) {
 		if (memcmp(cp, "mem=", 4) = 0) {
 			mem_limit = memparse(cp + 4, &cp);
@@ -434,9 +453,11 @@ efi_init (void)
 		}
 	}
 	if (min_addr != 0UL)
-		printk(KERN_INFO "Ignoring memory below %luMB\n", min_addr >> 20);
+		printk(KERN_INFO "Ignoring memory below %luMB\n",
+		       min_addr >> 20);
 	if (max_addr != ~0UL)
-		printk(KERN_INFO "Ignoring memory above %luMB\n", max_addr >> 20);
+		printk(KERN_INFO "Ignoring memory above %luMB\n",
+		       max_addr >> 20);
 
 	efi.systab = __va(ia64_boot_param->efi_systab);
 
@@ -464,7 +485,8 @@ efi_init (void)
 	}
 
 	printk(KERN_INFO "EFI v%u.%.02u by %s:",
-	       efi.systab->hdr.revision >> 16, efi.systab->hdr.revision & 0xffff, vendor);
+	       efi.systab->hdr.revision >> 16, 
+	       efi.systab->hdr.revision & 0xffff, vendor);
 
 	efi.mps        = EFI_INVALID_TABLE_ADDR;
 	efi.acpi       = EFI_INVALID_TABLE_ADDR;
@@ -476,22 +498,28 @@ efi_init (void)
 	efi.uga        = EFI_INVALID_TABLE_ADDR;
 
 	for (i = 0; i < (int) efi.systab->nr_tables; i++) {
-		if (efi_guidcmp(config_tables[i].guid, MPS_TABLE_GUID) = 0) {
+		if (efi_guidcmp(config_tables[i].guid, 
+				MPS_TABLE_GUID) = 0) {
 			efi.mps = config_tables[i].table;
 			printk(" MPS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, ACPI_20_TABLE_GUID) = 0) {
+		} else if (efi_guidcmp(config_tables[i].guid, 
+				       ACPI_20_TABLE_GUID) = 0) {
 			efi.acpi20 = config_tables[i].table;
 			printk(" ACPI 2.0=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, ACPI_TABLE_GUID) = 0) {
+		} else if (efi_guidcmp(config_tables[i].guid, 
+				       ACPI_TABLE_GUID) = 0) {
 			efi.acpi = config_tables[i].table;
 			printk(" ACPI=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, SMBIOS_TABLE_GUID) = 0) {
+		} else if (efi_guidcmp(config_tables[i].guid, 
+				       SMBIOS_TABLE_GUID) = 0) {
 			efi.smbios = config_tables[i].table;
 			printk(" SMBIOS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, SAL_SYSTEM_TABLE_GUID) = 0) {
+		} else if (efi_guidcmp(config_tables[i].guid, 
+				       SAL_SYSTEM_TABLE_GUID) = 0) {
 			efi.sal_systab = config_tables[i].table;
 			printk(" SALsystab=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) = 0) {
+		} else if (efi_guidcmp(config_tables[i].guid, 
+				       HCDP_TABLE_GUID) = 0) {
 			efi.hcdp = config_tables[i].table;
 			printk(" HCDP=0x%lx", config_tables[i].table);
 		}
@@ -519,11 +547,14 @@ efi_init (void)
 		efi_memory_desc_t *md;
 		void *p;
 
-		for (i = 0, p = efi_map_start; p < efi_map_end; ++i, p += efi_desc_size) {
+		for (i = 0, p = efi_map_start; p < efi_map_end; 
+		     ++i, p += efi_desc_size)
+		{
 			md = p;
-			printk("mem%02u: type=%u, attr=0x%lx, range=[0x%016lx-0x%016lx) (%luMB)\n",
+			printk("mem%02u: type=%u, attr=0x%lx, "
+			       "range=[0x%016lx-0x%016lx) (%luMB)\n",
 			       i, md->type, md->attribute, md->phys_addr,
-			       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+			       md->phys_addr + (md->num_pages<<EFI_PAGE_SHIFT),
 			       md->num_pages >> (20 - EFI_PAGE_SHIFT));
 		}
 	}
@@ -549,8 +580,8 @@ efi_enter_virtual_mode (void)
 		md = p;
 		if (md->attribute & EFI_MEMORY_RUNTIME) {
 			/*
-			 * Some descriptors have multiple bits set, so the order of
-			 * the tests is relevant.
+			 * Some descriptors have multiple bits set, so the
+			 * order of the tests is relevant.
 			 */
 			if (md->attribute & EFI_MEMORY_WB) {
 				md->virt_addr = (u64) __va(md->phys_addr);
@@ -558,21 +589,26 @@ efi_enter_virtual_mode (void)
 				md->virt_addr = (u64) ioremap(md->phys_addr, 0);
 			} else if (md->attribute & EFI_MEMORY_WC) {
 #if 0
-				md->virt_addr = ia64_remap(md->phys_addr, (_PAGE_A | _PAGE_P
-									   | _PAGE_D
-									   | _PAGE_MA_WC
-									   | _PAGE_PL_0
-									   | _PAGE_AR_RW));
+				md->virt_addr = ia64_remap(md->phys_addr,
+							   (_PAGE_A |
+							    _PAGE_P |
+							    _PAGE_D |
+							    _PAGE_MA_WC |
+							    _PAGE_PL_0 |
+							    _PAGE_AR_RW));
 #else
 				printk(KERN_INFO "EFI_MEMORY_WC mapping\n");
 				md->virt_addr = (u64) ioremap(md->phys_addr, 0);
 #endif
 			} else if (md->attribute & EFI_MEMORY_WT) {
 #if 0
-				md->virt_addr = ia64_remap(md->phys_addr, (_PAGE_A | _PAGE_P
-									   | _PAGE_D | _PAGE_MA_WT
-									   | _PAGE_PL_0
-									   | _PAGE_AR_RW));
+				md->virt_addr = ia64_remap(md->phys_addr, 
+							   (_PAGE_A | 
+							    _PAGE_P |
+							    _PAGE_D | 
+							    _PAGE_MA_WT | 
+							    _PAGE_PL_0 | 
+							    _PAGE_AR_RW));
 #else
 				printk(KERN_INFO "EFI_MEMORY_WT mapping\n");
 				md->virt_addr = (u64) ioremap(md->phys_addr, 0);
@@ -583,16 +619,18 @@ efi_enter_virtual_mode (void)
 
 	status = efi_call_phys(__va(runtime->set_virtual_address_map),
 			       ia64_boot_param->efi_memmap_size,
-			       efi_desc_size, ia64_boot_param->efi_memdesc_version,
+			       efi_desc_size, 
+			       ia64_boot_param->efi_memdesc_version,
 			       ia64_boot_param->efi_memmap);
 	if (status != EFI_SUCCESS) {
-		printk(KERN_WARNING "warning: unable to switch EFI into virtual mode "
-		       "(status=%lu)\n", status);
+		printk(KERN_WARNING "warning: unable to switch EFI into "
+		       "virtual mode (status=%lu)\n", status);
 		return;
 	}
 
 	/*
-	 * Now that EFI is in virtual mode, we call the EFI functions more efficiently:
+	 * Now that EFI is in virtual mode, we call the EFI functions more
+	 * efficiently:
 	 */
 	efi.get_time = virt_get_time;
 	efi.set_time = virt_set_time;
@@ -606,8 +644,8 @@ efi_enter_virtual_mode (void)
 }
 
 /*
- * Walk the EFI memory map looking for the I/O port range.  There can only be one entry of
- * this type, other I/O port ranges should be described via ACPI.
+ * Walk the EFI memory map looking for the I/O port range.  There can only be
+ * one entry of this type, other I/O port ranges should be described via ACPI.
  */
 u64
 efi_get_iobase (void)
@@ -655,8 +693,8 @@ efi_memory_descriptor (unsigned long phy
 
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
-
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+		if (phys_addr - md->phys_addr < 
+		    (md->num_pages << EFI_PAGE_SHIFT))
 			 return md;
 	}
 	return NULL;
@@ -678,7 +716,6 @@ efi_memmap_intersects (unsigned long phy
 
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
-
 		if (md->phys_addr < end && efi_md_end(md) > phys_addr)
 			return 1;
 	}
@@ -883,7 +920,7 @@ efi_uart_console_only(void)
 				return 1;
 			uart = 0;
 		}
-		hdr = (struct efi_generic_dev_path *) ((u8 *) hdr + hdr->length);
+		hdr = (struct efi_generic_dev_path *)((u8 *) hdr + hdr->length);
 	}
 	printk(KERN_ERR "Malformed %s value\n", name);
 	return 0;
@@ -921,10 +958,12 @@ find_memmap_space (void)
 		if (!efi_wb(md)) {
 			continue;
 		}
-		if (pmd = NULL || !efi_wb(pmd) || efi_md_end(pmd) != md->phys_addr) {
+		if (pmd = NULL || !efi_wb(pmd) ||
+		    efi_md_end(pmd) != md->phys_addr) {
 			contig_low = GRANULEROUNDUP(md->phys_addr);
 			contig_high = efi_md_end(md);
-			for (q = p + efi_desc_size; q < efi_map_end; q += efi_desc_size) {
+			for (q = p + efi_desc_size; q < efi_map_end;
+			     q += efi_desc_size) {
 				check_md = q;
 				if (!efi_wb(check_md))
 					break;
@@ -988,8 +1027,9 @@ efi_memmap_init(unsigned long *s, unsign
 	for (p = efi_map_start; p < efi_map_end; pmd = md, p += efi_desc_size) {
 		md = p;
 		if (!efi_wb(md)) {
-			if (efi_uc(md) && (md->type = EFI_CONVENTIONAL_MEMORY ||
-				    	   md->type = EFI_BOOT_SERVICES_DATA)) {
+			if (efi_uc(md) &&
+			    (md->type = EFI_CONVENTIONAL_MEMORY ||
+			     md->type = EFI_BOOT_SERVICES_DATA)) {
 				k->attribute = EFI_MEMORY_UC;
 				k->start = md->phys_addr;
 				k->num_pages = md->num_pages;
@@ -997,10 +1037,12 @@ efi_memmap_init(unsigned long *s, unsign
 			}
 			continue;
 		}
-		if (pmd = NULL || !efi_wb(pmd) || efi_md_end(pmd) != md->phys_addr) {
+		if (pmd = NULL || !efi_wb(pmd) || 
+		    efi_md_end(pmd) != md->phys_addr) {
 			contig_low = GRANULEROUNDUP(md->phys_addr);
 			contig_high = efi_md_end(md);
-			for (q = p + efi_desc_size; q < efi_map_end; q += efi_desc_size) {
+			for (q = p + efi_desc_size; q < efi_map_end; 
+			     q += efi_desc_size) {
 				check_md = q;
 				if (!efi_wb(check_md))
 					break;
@@ -1025,13 +1067,17 @@ efi_memmap_init(unsigned long *s, unsign
 		if (md->phys_addr < contig_low) {
 			lim = min(efi_md_end(md), contig_low);
 			if (efi_uc(md)) {
-				if (k > kern_memmap && (k-1)->attribute = EFI_MEMORY_UC &&
+				if (k > kern_memmap && 
+				    (k-1)->attribute = EFI_MEMORY_UC &&
 				    kmd_end(k-1) = md->phys_addr) {
-					(k-1)->num_pages += (lim - md->phys_addr) >> EFI_PAGE_SHIFT;
+					(k-1)->num_pages += 
+						(lim - md->phys_addr) 
+						>> EFI_PAGE_SHIFT;
 				} else {
 					k->attribute = EFI_MEMORY_UC;
 					k->start = md->phys_addr;
-					k->num_pages = (lim - md->phys_addr) >> EFI_PAGE_SHIFT;
+					k->num_pages = (lim - md->phys_addr) 
+						>> EFI_PAGE_SHIFT;
 					k++;
 				}
 			}
@@ -1049,7 +1095,8 @@ efi_memmap_init(unsigned long *s, unsign
 				} else {
 					k->attribute = EFI_MEMORY_UC;
 					k->start = lim;
-					k->num_pages = (efi_md_end(md) - lim) >> EFI_PAGE_SHIFT;
+					k->num_pages = (efi_md_end(md) - lim) 
+						>> EFI_PAGE_SHIFT;
 					k++;
 				}
 			}
@@ -1151,14 +1198,16 @@ efi_initialize_iomem_resources(struct re
 				break;
 		}
 
-		if ((res = kzalloc(sizeof(struct resource), GFP_KERNEL)) = NULL) {
-			printk(KERN_ERR "failed to alocate resource for iomem\n");
+		if ((res = kzalloc(sizeof(struct resource),
+				   GFP_KERNEL)) = NULL) {
+			printk(KERN_ERR 
+			       "failed to alocate resource for iomem\n");
 			return;
 		}
 
 		res->name = name;
 		res->start = md->phys_addr;
-		res->end = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1;
+		res->end = md->phys_addr + (md->num_pages<<EFI_PAGE_SHIFT) - 1;
 		res->flags = flags;
 
 		if (insert_resource(&iomem_resource, res) < 0)
@@ -1187,44 +1236,44 @@ efi_initialize_iomem_resources(struct re
    rsvd_regions are sorted
  */
 unsigned long __init
-kdump_find_rsvd_region (unsigned long size,
-		struct rsvd_region *r, int n)
+kdump_find_rsvd_region (unsigned long size, struct rsvd_region *r, int n)
 {
-  int i;
-  u64 start, end;
-  u64 alignment = 1UL << _PAGE_SIZE_64M;
-  void *efi_map_start, *efi_map_end, *p;
-  efi_memory_desc_t *md;
-  u64 efi_desc_size;
+	int i;
+	u64 start, end;
+	u64 alignment = 1UL << _PAGE_SIZE_64M;
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
 
-  efi_map_start = __va(ia64_boot_param->efi_memmap);
-  efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
-  efi_desc_size = ia64_boot_param->efi_memdesc_size;
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
 
-  for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
-	  md = p;
-	  if (!efi_wb(md))
-		  continue;
-	  start = ALIGN(md->phys_addr, alignment);
-	  end = efi_md_end(md);
-	  for (i = 0; i < n; i++) {
-		if (__pa(r[i].start) >= start && __pa(r[i].end) < end) {
-			if (__pa(r[i].start) > start + size)
-				return start;
-			start = ALIGN(__pa(r[i].end), alignment);
-			if (i < n-1 && __pa(r[i+1].start) < start + size)
-				continue;
-			else
-				break;
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+		if (!efi_wb(md))
+			continue;
+		start = ALIGN(md->phys_addr, alignment);
+		end = efi_md_end(md);
+		for (i = 0; i < n; i++) {
+			if (__pa(r[i].start) >= start && __pa(r[i].end) < end) {
+				if (__pa(r[i].start) > start + size)
+					return start;
+				start = ALIGN(__pa(r[i].end), alignment);
+				if (i < n-1 && 
+				    __pa(r[i+1].start) < start + size)
+					continue;
+				else
+					break;
+			}
 		}
-	  }
-	  if (end > start + size)
-		return start;
-  }
+		if (end > start + size)
+			return start;
+	}
 
-  printk(KERN_WARNING "Cannot reserve 0x%lx byte of memory for crashdump\n",
-	size);
-  return ~0UL;
+	printk(KERN_WARNING 
+	       "Cannot reserve 0x%lx byte of memory for crashdump\n", size);
+	return ~0UL;
 }
 #endif
 


