From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Wed, 12 Dec 2001 03:55:40 +0000
Subject: [Linux-ia64] RE: new GPT and uuid patches
Message-Id: <marc-linux-ia64-105590698805688@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805681@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805681@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> A struct probably would be safer.

Try try again, now as a struct.  :-)
http://domsch.com/linux/ia64/linux-2.4.16-ia64-011128-uuid-20011211-2.patch

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#1 US Linux Server provider with 24% (IDC Sept 2001)
#2 Worldwide Linux Server provider with 17% (IDC Sept 2001)
#3 Unix provider with 18% in the US (Dataquest)!


diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/arch/ia64/kernel/efi.c linux/arch/ia64/kernel/efi.c
--- linux-2.4.16-ia64-011128/arch/ia64/kernel/efi.c	Fri Nov  9 16:26:17 2001
+++ linux/arch/ia64/kernel/efi.c	Tue Dec 11 16:29:43 2001
@@ -24,6 +24,7 @@
 #include <linux/types.h>
 #include <linux/time.h>
 #include <linux/proc_fs.h>
+#include <linux/uuid.h>
 
 #include <asm/efi.h>
 #include <asm/io.h>
@@ -77,7 +78,7 @@ phys_set_wakeup_time (efi_bool_t enabled
 }
 
 static efi_status_t
-phys_get_variable (efi_char16_t *name, efi_guid_t *vendor, u32 *attr,
+phys_get_variable (efi_char16_t *name, uuid_t *vendor, u32 *attr,
 		   unsigned long *data_size, void *data)
 {
 	return efi_call_phys(__va(runtime->get_variable), __pa(name), __pa(vendor), __pa(attr),
@@ -85,14 +86,14 @@ phys_get_variable (efi_char16_t *name, e
 }
 
 static efi_status_t
-phys_get_next_variable (unsigned long *name_size, efi_char16_t *name, efi_guid_t *vendor)
+phys_get_next_variable (unsigned long *name_size, efi_char16_t *name, uuid_t *vendor)
 {
 	return efi_call_phys(__va(runtime->get_next_variable), __pa(name_size), __pa(name),
 			     __pa(vendor));
 }
 
 static efi_status_t
-phys_set_variable (efi_char16_t *name, efi_guid_t *vendor, u32 attr,
+phys_set_variable (efi_char16_t *name, uuid_t *vendor, u32 attr,
 		   unsigned long data_size, void *data)
 {
 	return efi_call_phys(__va(runtime->set_variable), __pa(name), __pa(vendor), attr,
@@ -331,19 +332,19 @@ efi_init (void)
 	       efi.systab->hdr.revision >> 16, efi.systab->hdr.revision & 0xffff, vendor);
 
 	for (i = 0; i < efi.systab->nr_tables; i++) {
-		if (efi_guidcmp(config_tables[i].guid, MPS_TABLE_GUID) = 0) {
+		if (uuidcmp(config_tables[i].guid, MPS_TABLE_GUID) = 0) {
 			efi.mps = __va(config_tables[i].table);
 			printk(" MPS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, ACPI_20_TABLE_GUID) = 0) {
+		} else if (uuidcmp(config_tables[i].guid, ACPI_20_TABLE_GUID) = 0) {
 			efi.acpi20 = __va(config_tables[i].table);
 			printk(" ACPI 2.0=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, ACPI_TABLE_GUID) = 0) {
+		} else if (uuidcmp(config_tables[i].guid, ACPI_TABLE_GUID) = 0) {
 			efi.acpi = __va(config_tables[i].table);
 			printk(" ACPI=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, SMBIOS_TABLE_GUID) = 0) {
+		} else if (uuidcmp(config_tables[i].guid, SMBIOS_TABLE_GUID) = 0) {
 			efi.smbios = __va(config_tables[i].table);
 			printk(" SMBIOS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, SAL_SYSTEM_TABLE_GUID) = 0) {
+		} else if (uuidcmp(config_tables[i].guid, SAL_SYSTEM_TABLE_GUID) = 0) {
 			efi.sal_systab = __va(config_tables[i].table);
 			printk(" SALsystab=0x%lx", config_tables[i].table);
 		}
@@ -483,7 +484,7 @@ efi_get_iobase (void)
 }
 
 static void __exit
-efivars_exit(void)
+efi_exit(void)
 {
 #ifdef CONFIG_PROC_FS
  	remove_proc_entry(efi_dir->name, NULL);
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/arch/ia64/kernel/efivars.c linux/arch/ia64/kernel/efivars.c
--- linux-2.4.16-ia64-011128/arch/ia64/kernel/efivars.c	Fri Nov  9 16:26:17 2001
+++ linux/arch/ia64/kernel/efivars.c	Tue Dec 11 21:24:19 2001
@@ -86,7 +86,7 @@ efivar_write(struct file *file, const ch
 
 typedef struct _efi_variable_t {
 	efi_char16_t  VariableName[1024/sizeof(efi_char16_t)];
-	efi_guid_t    VendorGuid;
+	uuid_t        VendorGuid;
 	unsigned long DataSize;
 	__u8          Data[1024];
 	efi_status_t  Status;
@@ -100,7 +100,7 @@ typedef struct _efivar_entry_t {
 	struct list_head        list;
 } efivar_entry_t;
 
-spinlock_t efivars_lock = SPIN_LOCK_UNLOCKED;
+static spinlock_t efivars_lock = SPIN_LOCK_UNLOCKED;
 static LIST_HEAD(efivar_list);
 static struct proc_dir_entry *efi_vars_dir = NULL;
 
@@ -139,19 +139,6 @@ proc_calc_metrics(char *page, char **sta
 }
 
 
-static void
-uuid_unparse(efi_guid_t *guid, char *out)
-{
-	sprintf(out, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
-		guid->data1, guid->data2, guid->data3,
-		guid->data4[0], guid->data4[1], guid->data4[2], guid->data4[3],
-		guid->data4[4], guid->data4[5], guid->data4[6], guid->data4[7]);
-}
-
-
-
-
-
 /*
  * efivar_create_proc_entry()
  * Requires:
@@ -163,11 +150,11 @@ uuid_unparse(efi_guid_t *guid, char *out
 static int
 efivar_create_proc_entry(unsigned long variable_name_size,
 			 efi_char16_t *variable_name,
-			 efi_guid_t *vendor_guid)
+			 uuid_t       *vendor_guid)
 {
 
-	int i, short_name_size = variable_name_size /
-		sizeof(efi_char16_t) + 38;
+	int i, short_name_size = (variable_name_size / sizeof(efi_char16_t)) +
+                1 + UUID_UNPARSED_SIZE;
 	char *short_name = kmalloc(short_name_size+1,
 				   GFP_KERNEL);
 	efivar_entry_t *new_efivar = kmalloc(sizeof(efivar_entry_t),
@@ -182,7 +169,7 @@ efivar_create_proc_entry(unsigned long v
 
 	memcpy(new_efivar->var.VariableName, variable_name,
 	       variable_name_size);
-	memcpy(&(new_efivar->var.VendorGuid), vendor_guid, sizeof(efi_guid_t));
+	memcpy(&(new_efivar->var.VendorGuid), vendor_guid, sizeof(uuid_t));
 
 	/* Convert Unicode to normal chars (assume top bits are 0),
 	   ala UTF-8 */
@@ -304,7 +291,7 @@ efivar_write(struct file *file, const ch
 		if ( strsize1 = strsize2 &&
 		     !memcmp(&(search_efivar->var.VariableName),
 			     var_data->VariableName, strsize1) &&
-		     !efi_guidcmp(search_efivar->var.VendorGuid,
+		     !uuidcmp(search_efivar->var.VendorGuid,
 				  var_data->VendorGuid)) {
 			found = 1;
 			break;
@@ -355,7 +342,7 @@ efivars_init(void)
 {
 
 	efi_status_t status;
-	efi_guid_t vendor_guid;
+	uuid_t vendor_guid;
 	efi_char16_t *variable_name = kmalloc(1024, GFP_KERNEL);
 	unsigned long variable_name_size = 1024;
 
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/arch/ia64/kernel/mca.c linux/arch/ia64/kernel/mca.c
--- linux-2.4.16-ia64-011128/arch/ia64/kernel/mca.c	Fri Nov  9 16:26:17 2001
+++ linux/arch/ia64/kernel/mca.c	Tue Dec 11 21:13:08 2001
@@ -311,38 +311,6 @@ mca_test(void)
 
 #endif /* #if defined(MCA_TEST) */
 
-
-/*
- *  verify_guid
- *
- *  Compares a test guid to a target guid and returns result.
- *
- *  Inputs
- *      test_guid *     (ptr to guid to be verified)
- *      target_guid *   (ptr to standard guid to be verified against)
- *
- *  Outputs
- *      0               (test verifies against target)
- *      non-zero        (test guid does not verify)
- */
-static int
-verify_guid (efi_guid_t *test, efi_guid_t *target)
-{
-	int     rc;
-
-	if ((rc = memcmp((void *)test, (void *)target, sizeof(efi_guid_t)))) {
-		IA64_MCA_DEBUG("ia64_mca_print: invalid guid = "
-			       "{ %08x, %04x, %04x, { %#02x, %#02x, %#02x, %#02x, "
-			       "%#02x, %#02x, %#02x, %#02x, } } \n ",
-			       test->data1, test->data2, test->data3, test->data4[0],
-			       test->data4[1], test->data4[2], test->data4[3],
-			       test->data4[4], test->data4[5], test->data4[6],
-			       test->data4[7]);
-	}
-
-	return rc;
-}
-
 /*
  * ia64_mca_init
  *
@@ -817,19 +785,16 @@ ia64_init_handler (struct pt_regs *regs)
  *
  *  Print a formatted GUID.
  *
- * Inputs   :   p_guid      (ptr to the GUID)
+ * Inputs   :   guid      (the GUID)
  *              prfunc      (print function)
  * Outputs  :   None
  *
  */
 void
-ia64_log_prt_guid (efi_guid_t *p_guid, prfunc_t prfunc)
+ia64_log_prt_guid (uuid_t *guid, prfunc_t prfunc)
 {
-	printk("GUID = { %08x, %04x, %04x, { %#02x, %#02x, %#02x, %#02x, "
-	       "%#02x, %#02x, %#02x, %#02x, } } \n ", p_guid->data1,
-	       p_guid->data2, p_guid->data3, p_guid->data4[0], p_guid->data4[1],
-	       p_guid->data4[2], p_guid->data4[3], p_guid->data4[4],
-	       p_guid->data4[5], p_guid->data4[6], p_guid->data4[7]);
+	char buffer[UUID_UNPARSED_SIZE];
+	prfunc("GUID = %s", uuid_unparse(guid, buffer));
 }
 
 static void
@@ -1690,6 +1655,9 @@ ia64_log_processor_info_print(sal_log_re
 	sal_log_section_hdr_t       *slsh;
 	int                         n_sects;
 	int                         ercd_pos;
+#ifdef IA64_MCA_DEBUG_INFO
+	char buffer[UUID_UNPARSED_SIZE];
+#endif
 
 	if (!lh)
 		return;
@@ -1716,7 +1684,9 @@ ia64_log_processor_info_print(sal_log_re
 		ia64_log_prt_section_header(slsh, prfunc);
 #endif  // MCA_PRT_XTRA_DATA for test only @FVL
 
-		if (verify_guid((void *)&slsh->guid, (void *)&(SAL_PROC_DEV_ERR_SECT_GUID))) {
+		if (uuidcmp(slsh->guid, (SAL_PROC_DEV_ERR_SECT_GUID))) {
+			IA64_MCA_DEBUG("ia64_mca_print: invalid guid = %s",
+				       uuid_unparse(&slsh->guid, buffer));
 			IA64_MCA_DEBUG("ia64_mca_log_print: unsupported record section\n");
 			continue;
 		}
@@ -1778,7 +1748,7 @@ ia64_log_platform_info_print (sal_log_re
 #ifdef MCA_PRT_XTRA_DATA    // for test only @FVL
 		ia64_log_prt_section_header(slsh, prfunc);
 
-		if (efi_guidcmp(slsh->guid, SAL_PROC_DEV_ERR_SECT_GUID) != 0) {
+		if (uuidcmp(slsh->guid, SAL_PROC_DEV_ERR_SECT_GUID) != 0) {
 			size_t  d_len = slsh->len - sizeof(sal_log_section_hdr_t);
 			char    *p_data = (char *)&((sal_log_mem_dev_err_info_t *)slsh)->valid;
 
@@ -1792,39 +1762,39 @@ ia64_log_platform_info_print (sal_log_re
 		/*
 		 *  Now process CPE error record section
 		 */
-		if (efi_guidcmp(slsh->guid, SAL_PROC_DEV_ERR_SECT_GUID) = 0) {
+		if (uuidcmp(slsh->guid, SAL_PROC_DEV_ERR_SECT_GUID) = 0) {
 			ia64_log_proc_dev_err_info_print((sal_log_processor_info_t *)slsh,
 							 prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform Memory Device Error Info Section\n");
 			ia64_log_mem_dev_err_info_print((sal_log_mem_dev_err_info_t *)slsh,
 							prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform SEL Device Error Info Section\n");
 			ia64_log_sel_dev_err_info_print((sal_log_sel_dev_err_info_t *)slsh,
 							prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform PCI Bus Error Info Section\n");
 			ia64_log_pci_bus_err_info_print((sal_log_pci_bus_err_info_t *)slsh,
 							prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform SMBIOS Device Error Info Section\n");
 			ia64_log_smbios_dev_err_info_print((sal_log_smbios_dev_err_info_t *)slsh,
 							   prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform PCI Component Error Info Section\n");
 			ia64_log_pci_comp_err_info_print((sal_log_pci_comp_err_info_t *)slsh,
 							 prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform Specific Error Info Section\n");
 			ia64_log_plat_specific_err_info_print((sal_log_plat_specific_err_info_t *)
 							      slsh,
 							      prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform Host Controller Error Info Section\n");
 			ia64_log_host_ctlr_err_info_print((sal_log_host_ctlr_err_info_t *)slsh,
 							  prfunc);
-		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_BUS_ERR_SECT_GUID) = 0) {
+		} else if (uuidcmp(slsh->guid, SAL_PLAT_BUS_ERR_SECT_GUID) = 0) {
 			prfunc("+Platform Bus Error Info Section\n");
 			ia64_log_plat_bus_err_info_print((sal_log_plat_bus_err_info_t *)slsh,
 							 prfunc);
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/fs/partitions/efi.c linux/fs/partitions/efi.c
--- linux-2.4.16-ia64-011128/fs/partitions/efi.c	Tue Dec 11 16:43:09 2001
+++ linux/fs/partitions/efi.c	Tue Dec 11 16:51:50 2001
@@ -29,6 +29,9 @@
  * TODO:
  *
  * Changelog:
+ * Tue Dec 11 2001 Matt Domsch <Matt_Domsch@dell.com>
+ * - removed le_efi_guid_to_cpus() - it's all just a blob of char now, no endian conversions.
+ *
  * Thu Dec 6 2001 Matt Domsch <Matt_Domsch@dell.com>
  * - Added compare_gpts().
  * - moved le_efi_guid_to_cpus() back into this file.  GPT is the only
@@ -131,26 +134,6 @@ force_gpt(char *str)
 __setup("gpt", force_gpt);
 
 /**
- * le_efi_guid_to_cpus()
- * @guid
- *
- * Description: modifies @guid in situ
- *
- * This function converts a little endian efi_guid_t to the
- * native cpu representation.  The EFI Spec. declares that all 
- * on-disk structures are stored in little endian format.
- */
-static void
-le_efi_guid_to_cpus(efi_guid_t *guid)
-{
-	le32_to_cpus(guid->data1);
-	le16_to_cpus(guid->data2);
-	le16_to_cpus(guid->data3);
-	/* no need to change the rest. It's already an array of chars */
-	return;
-}
-
-/**
  * efi_crc32() - EFI version of crc32 function
  * @buf: buffer to calculate crc32 of
  * @len - length of buf
@@ -340,8 +323,7 @@ alloc_read_gpt_entries(struct gendisk *h
 	}
 	/* Fixup endianness */
 	for (i = 0; i < gpt->num_partition_entries; i++) {
-		le_efi_guid_to_cpus(&pte[i].partition_type_guid);
-		le_efi_guid_to_cpus(&pte[i].unique_partition_guid);
+                /* Don't touch the GUIDs */
 		le64_to_cpus(pte[i].starting_lba);
 		le64_to_cpus(pte[i].ending_lba);
 		le_part_attributes_to_cpus(&pte[i].attributes);
@@ -391,7 +373,7 @@ alloc_read_gpt_header(struct gendisk *hd
 	le64_to_cpus(gpt->alternate_lba);
 	le64_to_cpus(gpt->first_usable_lba);
 	le64_to_cpus(gpt->last_usable_lba);
-	le_efi_guid_to_cpus(&gpt->disk_guid);
+        /* Don't touch disk_guid */
 	le64_to_cpus(gpt->partition_entry_lba);
 	le32_to_cpus(gpt->num_partition_entries);
 	le32_to_cpus(gpt->sizeof_partition_entry);
@@ -524,7 +506,7 @@ compare_gpts(gpt_header *pgpt, gpt_heade
 		       pgpt->last_usable_lba, agpt->last_usable_lba);
 		error_found++;
 	}
-	if (efi_guidcmp(pgpt->disk_guid, agpt->disk_guid)) {
+	if (uuidcmp(pgpt->disk_guid, agpt->disk_guid)) {
 		printk(KERN_WARNING "GPT:disk_guids don't match.\n");
 		error_found++;
 	}
@@ -707,11 +689,6 @@ add_gpt_partitions(struct gendisk *hd, s
 	gpt_entry *ptes = NULL;
 	u32 i, nummade = 0;
 
-	efi_guid_t unusedGuid = UNUSED_ENTRY_GUID;
-#if CONFIG_BLK_DEV_MD
-	efi_guid_t raidGuid = PARTITION_LINUX_RAID_GUID;
-#endif
-
 	if (!hd || !bdev)
 		return -1;
 
@@ -727,7 +704,7 @@ add_gpt_partitions(struct gendisk *hd, s
 
 	for (i = 0; i < gpt->num_partition_entries &&
 	     nummade < (hd->max_p - 1); i++) {
-		if (!efi_guidcmp(unusedGuid, ptes[i].partition_type_guid))
+		if (!uuidcmp(ptes[i].partition_type_guid, UNUSED_ENTRY_GUID))
 			continue;
 
 		add_gd_partition(hd, nextminor, ptes[i].starting_lba,
@@ -736,7 +713,8 @@ add_gpt_partitions(struct gendisk *hd, s
 
 		/* If there's this is a RAID volume, tell md */
 #if CONFIG_BLK_DEV_MD
-		if (!efi_guidcmp(raidGuid, ptes[i].partition_type_guid)) {
+		if (!uuidcmp(ptes[i].partition_type_guid,
+                             PARTITION_LINUX_RAID_GUID)) {
 			md_autodetect_dev(MKDEV
 					  (MAJOR(to_kdev_t(bdev->bd_dev)),
 					   nextminor));
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/fs/partitions/efi.h linux/fs/partitions/efi.h
--- linux-2.4.16-ia64-011128/fs/partitions/efi.h	Tue Dec 11 16:43:09 2001
+++ linux/fs/partitions/efi.h	Tue Dec 11 17:11:05 2001
@@ -33,6 +33,7 @@
 #include <linux/major.h>
 #include <linux/string.h>
 #include <linux/blk.h>
+#include <linux/uuid.h>
 /*
  * Yes, specifying asm-ia64 is ugly, but this lets it build on
  * other platforms too, until efi.h moves to include/linux.
@@ -49,21 +50,21 @@
 #define GPT_PRIMARY_PARTITION_TABLE_LBA 1
 
 #define UNUSED_ENTRY_GUID    \
-    ((efi_guid_t) { 0x00000000, 0x0000, 0x0000, { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }})
+    ((uuid_t) {{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }})
 #define PARTITION_SYSTEM_GUID \
-((efi_guid_t) { 0xC12A7328, 0xF81F, 0x11d2, { 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B }})
+    ((uuid_t) {{ 0xC1, 0x2A, 0x73, 0x28, 0xF8, 0x1F, 0x11, 0xd2, 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B }})
 #define LEGACY_MBR_PARTITION_GUID \
-    ((efi_guid_t) { 0x024DEE41, 0x33E7, 0x11d3, { 0x9D, 0x69, 0x00, 0x08, 0xC7, 0x81, 0xF3, 0x9F }})
+    ((uuid_t) {{ 0x02, 0x4D, 0xEE, 0x41, 0x33, 0xE7, 0x11, 0xd3, 0x9D, 0x69, 0x00, 0x08, 0xC7, 0x81, 0xF3, 0x9F }})
 #define PARTITION_MSFT_RESERVED_GUID \
-    ((efi_guid_t) { 0xE3C9E316, 0x0B5C, 0x4DB8, { 0x81, 0x7D, 0xF9, 0x2D, 0xF0, 0x02, 0x15, 0xAE }})
+    ((uuid_t) {{ 0xE3, 0xC9, 0xE3, 0x16, 0x0B, 0x5C, 0x4D, 0xB8, 0x81, 0x7D, 0xF9, 0x2D, 0xF0, 0x02, 0x15, 0xAE }})
 #define PARTITION_BASIC_DATA_GUID \
-    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, { 0x87, 0xC0, 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7 }})
+    ((uuid_t) {{ 0xEB, 0xD0, 0xA0, 0xA2, 0xB9, 0xE5, 0x44, 0x33, 0x87, 0xC0, 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7 }})
 #define PARTITION_LINUX_RAID_GUID \
-    ((efi_guid_t) { 0xa19d880f, 0x05fc, 0x4d3b, { 0xa0, 0x06, 0x74, 0x3f, 0x0f, 0x84, 0x91, 0x1e  }})
+    ((uuid_t) {{ 0xa1, 0x9d, 0x88, 0x0f, 0x05, 0xfc, 0x4d, 0x3b, 0xa0, 0x06, 0x74, 0x3f, 0x0f, 0x84, 0x91, 0x1e }})
 #define PARTITION_LINUX_SWAP_GUID \
-    ((efi_guid_t) { 0x0657fd6d, 0xa4ab, 0x43c4, { 0x84, 0xe5, 0x09, 0x33, 0xc8, 0x4b, 0x4f, 0x4f  }})
+    ((uuid_t) {{ 0x06, 0x57, 0xfd, 0x6d, 0xa4, 0xab, 0x43, 0xc4, 0x84, 0xe5, 0x09, 0x33, 0xc8, 0x4b, 0x4f, 0x4f }})
 #define PARTITION_LINUX_LVM_GUID \
-    ((efi_guid_t) { 0xe6d6d379, 0xf507, 0x44c2, { 0xa2, 0x3c, 0x23, 0x8f, 0x2a, 0x3d, 0xf9, 0x28 }})
+    ((uuid_t) {{ 0xe6, 0xd6, 0xd3, 0x79, 0xf5, 0x07, 0x44, 0xc2, 0xa2, 0x3c, 0x23, 0x8f, 0x2a, 0x3d, 0xf9, 0x28 }})
 
 typedef struct _gpt_header {
 	u64 signature;
@@ -75,7 +76,7 @@ typedef struct _gpt_header {
 	u64 alternate_lba;
 	u64 first_usable_lba;
 	u64 last_usable_lba;
-	efi_guid_t disk_guid;
+	uuid_t disk_guid;
 	u64 partition_entry_lba;
 	u32 num_partition_entries;
 	u32 sizeof_partition_entry;
@@ -90,8 +91,8 @@ typedef struct _gpt_entry_attributes {
 } __attribute__ ((packed)) gpt_entry_attributes;
 
 typedef struct _gpt_entry {
-	efi_guid_t partition_type_guid;
-	efi_guid_t unique_partition_guid;
+	uuid_t partition_type_guid;
+	uuid_t unique_partition_guid;
 	u64 starting_lba;
 	u64 ending_lba;
 	gpt_entry_attributes attributes;
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/include/asm-ia64/efi.h linux/include/asm-ia64/efi.h
--- linux-2.4.16-ia64-011128/include/asm-ia64/efi.h	Tue Jul 31 12:30:09 2001
+++ linux/include/asm-ia64/efi.h	Tue Dec 11 17:02:06 2001
@@ -16,6 +16,7 @@
 #include <linux/time.h>
 #include <linux/types.h>
 #include <linux/proc_fs.h>
+#include <linux/uuid.h>
 
 #include <asm/page.h>
 #include <asm/system.h>
@@ -32,13 +33,6 @@ typedef unsigned long efi_status_t;
 typedef u8 efi_bool_t;
 typedef u16 efi_char16_t;		/* UNICODE character */
 
-typedef struct {
-	u32 data1;
-	u16 data2;
-	u16 data3;
-	u8 data4[8];
-} efi_guid_t;
-
 /*
  * Generic EFI table header
  */
@@ -152,11 +146,11 @@ typedef efi_status_t efi_set_time_t (efi
 typedef efi_status_t efi_get_wakeup_time_t (efi_bool_t *enabled, efi_bool_t *pending,
 					    efi_time_t *tm);
 typedef efi_status_t efi_set_wakeup_time_t (efi_bool_t enabled, efi_time_t *tm);
-typedef efi_status_t efi_get_variable_t (efi_char16_t *name, efi_guid_t *vendor, u32 *attr,
+typedef efi_status_t efi_get_variable_t (efi_char16_t *name, uuid_t *vendor, u32 *attr,
 					 unsigned long *data_size, void *data);
 typedef efi_status_t efi_get_next_variable_t (unsigned long *name_size, efi_char16_t *name,
-					      efi_guid_t *vendor);
-typedef efi_status_t efi_set_variable_t (efi_char16_t *name, efi_guid_t *vendor, u32 attr,
+					      uuid_t *vendor);
+typedef efi_status_t efi_set_variable_t (efi_char16_t *name, uuid_t *vendor, u32 attr,
 					 unsigned long data_size, void *data);
 typedef efi_status_t efi_get_next_high_mono_count_t (u64 *count);
 typedef void efi_reset_system_t (int reset_type, efi_status_t status,
@@ -167,22 +161,22 @@ typedef void efi_reset_system_t (int res
  */
 
 #define MPS_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d2f, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
+    ((uuid_t) {{ 0xeb, 0x9d, 0x2d, 0x2f, 0x2d, 0x88, 0x11, 0xd3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
 
 #define ACPI_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d30, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
+    ((uuid_t) {{ 0xeb, 0x9d, 0x2d, 0x30, 0x2d, 0x88, 0x11, 0xd3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
 
 #define ACPI_20_TABLE_GUID    \
-    ((efi_guid_t) { 0x8868e871, 0xe4f1, 0x11d3, { 0xbc, 0x22, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81 }})
+    ((uuid_t) {{ 0x88, 0x68, 0xe8, 0x71, 0xe4, 0xf1, 0x11, 0xd3, 0xbc, 0x22, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81 }})
 
 #define SMBIOS_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d31, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
+    ((uuid_t) {{ 0xeb, 0x9d, 0x2d, 0x31, 0x2d, 0x88, 0x11, 0xd3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
 
 #define SAL_SYSTEM_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d32, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
+    ((uuid_t) {{ 0xeb, 0x9d, 0x2d, 0x32, 0x2d, 0x88, 0x11, 0xd3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x3f, 0xc1, 0x4d }})
 
 typedef struct {
-	efi_guid_t guid;
+	uuid_t guid;
 	u64 table;
 } efi_config_table_t;
 
@@ -227,12 +221,6 @@ extern struct efi {
 	efi_reset_system_t *reset_system;
 } efi;
 
-static inline int
-efi_guidcmp (efi_guid_t left, efi_guid_t right)
-{
-	return memcmp(&left, &right, sizeof (efi_guid_t));
-}
-
 extern void efi_init (void);
 extern void efi_map_pal_code (void);
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/include/asm-ia64/sal.h linux/include/asm-ia64/sal.h
--- linux-2.4.16-ia64-011128/include/asm-ia64/sal.h	Fri Nov  9 16:26:17 2001
+++ linux/include/asm-ia64/sal.h	Tue Dec 11 17:02:15 2001
@@ -233,32 +233,23 @@ enum {
 
 /* SAL Error Record Section GUID Definitions */
 #define SAL_PROC_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf1, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf1, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x00, 0x80, 0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_MEM_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf2, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf2, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x00, 0x80, 0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_SEL_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf3, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf3, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x00, 0x80, 0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_PCI_BUS_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf4, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf4, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x0, 0x80,  0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf5, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf5, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x0, 0x80,  0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_PCI_COMP_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf6, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf6, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x0, 0x80,  0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_SPECIFIC_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf7, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf7, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x0, 0x80,  0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_HOST_CTLR_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf8, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf8, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x0, 0x80,  0xc7, 0x3c, 0x88, 0x81 }})
 #define SAL_PLAT_BUS_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf9, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    ((uuid_t) {{ 0xe4, 0x29, 0xfa, 0xf9, 0x3c, 0xb7, 0x11, 0xd4, 0xbc, 0xa7, 0x0, 0x80,  0xc7, 0x3c, 0x88, 0x81 }})
 
 #define MAX_CACHE_ERRORS			6
 #define MAX_TLB_ERRORS				6
@@ -292,13 +283,13 @@ typedef struct sal_log_record_header
     u16                 severity;       /* Error Severity */
     u32                 len;            /* Length of this error log in bytes */
     sal_log_timestamp_t timestamp;      /* Timestamp */
-    efi_guid_t          platform_guid;  /* Unique OEM Platform ID */
+    uuid_t              platform_guid;  /* Unique OEM Platform ID */
 } sal_log_record_header_t;
 
 /* Definition of log section header structures */
 typedef struct sal_log_sec_header
 {
-    efi_guid_t          guid;       /* Unique Section ID */
+    uuid_t              guid;       /* Unique Section ID */
     sal_log_revision_t  revision;   /* Major and Minor revision of Section */
     u16                 reserved;
     u32                 len;        /* Section length */
@@ -543,7 +534,7 @@ typedef struct sal_log_plat_specific_err
             reserved        : 61;
     } valid;
     u64             err_status;
-    efi_guid_t      guid;
+    uuid_t          guid;
     u8              oem_data[1];      /* platform specific variable length data */
 } sal_log_plat_specific_err_info_t;
 
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/include/asm-ia64/sn/mca.h linux/include/asm-ia64/sn/mca.h
--- linux-2.4.16-ia64-011128/include/asm-ia64/sn/mca.h	Tue Dec 11 16:43:02 2001
+++ linux/include/asm-ia64/sn/mca.h	Tue Dec 11 16:26:09 2001
@@ -82,7 +82,7 @@ sal_log_section_hdr_t header;
 		reserved        : 61;
 	} valid;
 	__uint64_t             err_status;
-	efi_guid_t      guid;
+	uuid_t                 guid;
 	__uint64_t shub_nic;
 	sal_log_shub_state_t    shub_state;
 } sal_log_plat_info_t;
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/include/linux/uuid.h linux/include/linux/uuid.h
--- linux-2.4.16-ia64-011128/include/linux/uuid.h	Wed Dec 31 18:00:00 1969
+++ linux/include/linux/uuid.h	Tue Dec 11 21:12:36 2001
@@ -0,0 +1,60 @@
+#ifndef LINUX_UUID_H
+#define LINUX_UUID_H
+/*
+ * uuid.h
+ *  by Matt Domsch <Matt_Domsch@dell.com>
+ *  Copyright 2001 Dell Computer Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include<linux/types.h>
+#include<linux/string.h>
+
+typedef struct _uuid_t
+{
+        u8 b[16];
+} __attribute__((packed)) uuid_t;
+
+static inline int
+uuidcmp (uuid_t left, uuid_t right)
+{
+	return memcmp(&left, &right, sizeof (uuid_t));
+}
+
+/* This includes the NULL character at the end */
+#define UUID_UNPARSED_SIZE 37
+
+extern char * uuid_unparse(uuid_t *uuid, char *out);
+
+#endif
+/*
+ * Overrides for Emacs so that we follow Linus's tabbing style.
+ * Emacs will notice this stuff at the end of the file and automatically
+ * adjust the settings for this buffer only.  This must remain at the end
+ * of the file.
+ * ---------------------------------------------------------------------------
+ * Local variables:
+ * c-indent-level: 4
+ * c-brace-imaginary-offset: 0
+ * c-brace-offset: -4
+ * c-argdecl-indent: 4
+ * c-label-offset: -4
+ * c-continued-statement-offset: 4
+ * c-continued-brace-offset: 0
+ * indent-tabs-mode: nil
+ * tab-width: 8
+ * End:
+ */
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/lib/Makefile linux/lib/Makefile
--- linux-2.4.16-ia64-011128/lib/Makefile	Tue Dec 11 16:43:03 2001
+++ linux/lib/Makefile	Tue Dec 11 16:26:09 2001
@@ -8,9 +8,9 @@
 
 L_TARGET := lib.a
 
-export-objs := cmdline.o dec_and_lock.o rwsem-spinlock.o rwsem.o
+export-objs := cmdline.o dec_and_lock.o rwsem-spinlock.o rwsem.o uuid.o
 
-obj-y := errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spinlocks.o rbtree.o crc32.o
+obj-y := errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spinlocks.o rbtree.o crc32.o uuid.o
 
 obj-$(CONFIG_RWSEM_GENERIC_SPINLOCK) += rwsem-spinlock.o
 obj-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
diff -burNp --exclude-from=/home/mdomsch/excludes --exclude=offsets.h --exclude=print_offsets linux-2.4.16-ia64-011128/lib/uuid.c linux/lib/uuid.c
--- linux-2.4.16-ia64-011128/lib/uuid.c	Wed Dec 31 18:00:00 1969
+++ linux/lib/uuid.c	Tue Dec 11 16:29:01 2001
@@ -0,0 +1,38 @@
+/*
+ * uuid.c
+ *  by Matt Domsch <Matt_Domsch@dell.com>
+ *  Copyright 2001 Dell Computer Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/uuid.h>
+
+char * uuid_unparse(uuid_t *guid, char *out)
+{
+        if (guid && out)
+                sprintf(out,
+                        "%02x%02x%02x%02x-%02x%02x-%02x%02xx-%02x%02x-%02x%02x%02x%02x%02x%02x",
+                        guid->b[0],  guid->b[1],  guid->b[2],  guid->b[3],
+			guid->b[4],  guid->b[5],  guid->b[6],  guid->b[7],
+			guid->b[8],  guid->b[9],  guid->b[10], guid->b[11],
+			guid->b[12], guid->b[13], guid->b[14], guid->b[15]);
+        return out;
+}
+
+
+EXPORT_SYMBOL(uuid_unparse);





