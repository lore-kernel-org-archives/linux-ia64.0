From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 19 Feb 2004 10:44:46 +0000
Subject: [PATCH] MCA recovery from memory read error caused by application
Message-Id: <0HTB004BEV6M3H@fjmail506.fjmail.jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

I make a prototype of MCA handler that prevent system from down when
memory read error caused by application. (I think this recovery is still
incomplete since maybe some todo things remain here.)

This patch is against 2.6.2 with Keith's recent 9 patches (6 mca.c cleanups,
1 for irq_safe passing, 1 correct MCA recovery test, and last 1 remove
ia64_mca_check_errors). Fortunately, you can apply this patch to vanilla 2.6.3.

Overview of this patch is:

- Add new files: mca_recovery.c and mca_recovery.h
   To help your understanding, I collect most of new codes into these files.
   They could be arrange in mca.* after some possible clean ups.

- Make index of SAL error record
   ia64_log_make_slidx() collects and lists pointers to access each source
   (record header, section header) in SAL error record. This index makes it
   easier to look up data in the SAL record, and easier to write recovery
   codes. In the same way, ia64_log_make_peidx() make a index of processor
   error section that include notably important bits.

- Try to recover from memory read error
   If SAL record indicates a read error, and if offending process of memory
   read is in user mode, MCA handler kills the process.
   (Besides, I'm considering the isolation of erroneous/poisoned pages, but
   it is not implemented yet.)

- Other trivial fix:
  - Fix a comment typo in mca.c (get the CMC error... -> get the CPE error...)

Welcome your feedback.


Thanks,

H.Seto

diff -Nur linux-2.6.2-keith1-9.orig/arch/ia64/kernel/Makefile linux-2.6.2-recovery_mca/arch/ia64/kernel/Makefile
--- linux-2.6.2-keith1-9.orig/arch/ia64/kernel/Makefile	2004-02-13 19:30:17.000000000 +0900
+++ linux-2.6.2-recovery_mca/arch/ia64/kernel/Makefile	2004-02-13 13:52:55.000000000 +0900
@@ -12,7 +12,7 @@
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
-obj-$(CONFIG_IA64_MCA)		+= mca.o mca_asm.o
+obj-$(CONFIG_IA64_MCA)		+= mca.o mca_recovery.o mca_asm.o
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
diff -Nur linux-2.6.2-keith1-9.orig/arch/ia64/kernel/mca.c linux-2.6.2-recovery_mca/arch/ia64/kernel/mca.c
--- linux-2.6.2-keith1-9.orig/arch/ia64/kernel/mca.c	2004-02-13 19:30:17.000000000 +0900
+++ linux-2.6.2-recovery_mca/arch/ia64/kernel/mca.c	2004-02-16 20:02:50.000000000 +0900
@@ -101,6 +101,10 @@
 extern void			ia64_monarch_init_handler (void);
 extern void			ia64_slave_init_handler (void);
 
+/* In mca_recovery.c */
+extern int 			ia64_mca_try_to_recover(void *);
+extern void			ia64_mca_init_for_recovery(void); /* Initialize section pointer list pool */
+
 static ia64_mc_info_t		ia64_mc_info;
 
 extern struct hw_interrupt_type	irq_type_iosapic_level;
@@ -142,16 +146,16 @@
 	spinlock_t	isl_lock;
 	int		isl_index;
 	unsigned long	isl_count;
-	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
+	void		*isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
 } ia64_state_log_t;
 
 static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
 
 #define IA64_LOG_ALLOCATE(it, size) \
 	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
-		(ia64_err_rec_t *)alloc_bootmem(size); \
+		alloc_bootmem(size); \
 	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
-		(ia64_err_rec_t *)alloc_bootmem(size);}
+		alloc_bootmem(size);}
 #define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
 #define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
 #define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
@@ -278,7 +282,7 @@
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
 
-	/* Get the CMC error record and log it */
+	/* Get the CPE error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
 	return IRQ_HANDLED;
 }
@@ -750,12 +754,12 @@
  *	return state which can be used by the OS_MCA dispatch code
  *	just before going back to SAL.
  *
- *  Inputs  :   None
+ *  Inputs  :   os_status (e.g. IA64_MCA_CORRECTED, IA64_MCA_COLD_BOOT etc.)
  *  Outputs :   None
  */
 
 static void
-ia64_return_to_sal_check(int recover)
+ia64_return_to_sal_check(int os_status)
 {
 
 	/* Copy over some relevant stuff from the sal_to_os_mca_handoff
@@ -767,10 +771,7 @@
 	ia64_os_to_sal_handoff_state.imots_sal_check_ra  		ia64_sal_to_os_handoff_state.imsto_sal_check_ra;
 
-	if (recover)
-		ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_CORRECTED;
-	else
-		ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_COLD_BOOT;
+	ia64_os_to_sal_handoff_state.imots_os_status = os_status;
 
 	/* Default = tell SAL to return to same context */
 	ia64_os_to_sal_handoff_state.imots_context = IA64_MCA_SAME_CONTEXT;
@@ -799,21 +800,24 @@
 void
 ia64_mca_ucmc_handler(void)
 {
-	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
-		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover = psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
+	int os_status;
 
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
 	/*
+	 * Try to recover from MCA
+	 */
+	os_status = ia64_mca_try_to_recover(IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA));
+
+	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
 	 *  loop.
 	 */
 	ia64_mca_wakeup_all();
 
 	/* Return to SAL */
-	ia64_return_to_sal_check(recover);
+	ia64_return_to_sal_check(os_status);
 }
 
 static DECLARE_WORK(cmc_disable_work, ia64_mca_cmc_vector_disable_keventd, NULL);
@@ -1269,6 +1273,7 @@
 	ia64_log_init(SAL_INFO_TYPE_INIT);
 	ia64_log_init(SAL_INFO_TYPE_CMC);
 	ia64_log_init(SAL_INFO_TYPE_CPE);
+	ia64_mca_init_for_recovery();
 
 	printk(KERN_INFO "MCA related initialization done\n");
 }
diff -Nur linux-2.6.2-keith1-9.orig/arch/ia64/kernel/mca_recovery.c linux-2.6.2-recovery_mca/arch/ia64/kernel/mca_recovery.c
--- linux-2.6.2-keith1-9.orig/arch/ia64/kernel/mca_recovery.c	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.2-recovery_mca/arch/ia64/kernel/mca_recovery.c	2004-02-16 20:16:26.000000000 +0900
@@ -0,0 +1,524 @@
+/*
+ File:	mca_recovery.c
+ * Purpose:	Generic MCA handling layer
+ */
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/kallsyms.h>
+#include <linux/smp_lock.h>
+#include <linux/bootmem.h>
+#include <linux/acpi.h>
+#include <linux/timer.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/smp.h>
+#include <linux/workqueue.h>
+
+#include <asm/delay.h>
+#include <asm/machvec.h>
+#include <asm/page.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+#include <asm/sal.h>
+#include <asm/mca.h>
+
+#include <asm/irq.h>
+#include <asm/hw_irq.h>
+
+#include "mca_recovery.h"
+
+typedef enum {
+	RECOVERY_ON_PROCESSING	   = IA64_MCA_CORRECTED + 1,
+	RECOVERY_OK 		   = IA64_MCA_CORRECTED,
+	RECOVERY_NG_THEN_COLD_BOOT = IA64_MCA_COLD_BOOT,
+	RECOVERY_NG_THEN_WARM_BOOT = IA64_MCA_WARM_BOOT,
+	RECOVERY_NG_THEN_HALT 	   = IA64_MCA_COLD_BOOT,
+} os_recovery_state_t;
+
+typedef enum {
+	MCA_IS_LOCAL  = 0,
+	MCA_IS_GLOBAL = 1
+} mca_type_t;
+
+/*
+ *  This pool keeps pointers to the section part of SAL error record
+ */
+static struct {
+	slidx_list_t *buffer; /* section pointer list pool */
+	int	     cur_idx; /* Current index of section pointer list pool */
+	int	     max_idx; /* Maximum index of section pointer list pool */
+} slidx_pool;
+
+#define IA64_LOG_INDEX_INIT_PTR(p) \
+        { INIT_LIST_HEAD(&((p)->proc_err)); \
+          INIT_LIST_HEAD(&((p)->mem_dev_err)); \
+          INIT_LIST_HEAD(&((p)->sel_dev_err)); \
+          INIT_LIST_HEAD(&((p)->pci_bus_err)); \
+          INIT_LIST_HEAD(&((p)->smbios_dev_err)); \
+          INIT_LIST_HEAD(&((p)->pci_comp_err)); \
+          INIT_LIST_HEAD(&((p)->plat_specific_err)); \
+          INIT_LIST_HEAD(&((p)->host_ctlr_err)); \
+          INIT_LIST_HEAD(&((p)->plat_bus_err)); \
+          INIT_LIST_HEAD(&((p)->unsupported)); }
+#define IA64_LOG_INDEX_ADD_SECT_PTR(sect, ptr) \
+        { slidx_list_t *hl = &slidx_pool.buffer[slidx_pool.cur_idx]; \
+          hl->hdr = ptr; \
+          list_add(&hl->list, &(sect)); \
+          slidx_pool.cur_idx = (slidx_pool.cur_idx + 1)%slidx_pool.max_idx; }
+
+/*
+ * ia64_mca_make_peidx
+ *
+ *  Make index of processor error section
+ *
+ *  Inputs      : slpi  (pointer to record of processor error section)
+ *  In/Outputs	: peidx (pointer to index of processor error section)
+ *  Outputs     : None
+ */
+
+static void 
+ia64_mca_make_peidx(sal_log_processor_info_t *slpi, peidx_table_t *peidx)
+{
+	/* 
+	 * calculate the start address of
+	 *   "struct cpuid_info" and "sal_processor_static_info_t".
+	 */
+	u64 total_check_num = slpi->valid.num_cache_check
+				+ slpi->valid.num_tlb_check
+				+ slpi->valid.num_bus_check
+				+ slpi->valid.num_reg_file_check
+				+ slpi->valid.num_ms_check;
+	u64 head_size =	sizeof(sal_log_mod_error_info_t) * total_check_num;
+	u64 mid_size  = slpi->valid.cpuid_info * sizeof(struct sal_cpuid_info);
+
+	peidx_head(peidx)   = slpi;
+	peidx_mid(peidx)    = (struct sal_cpuid_info *)
+		(slpi->valid.cpuid_info ? ((char*)slpi + head_size) : NULL);
+	peidx_bottom(peidx) = (sal_processor_static_info_t *)
+		(slpi->valid.psi_static_struct ?
+			((char*)slpi + head_size + mid_size) : NULL);
+}
+
+/*
+ * ia64_mca_make_slidx
+ *
+ *  Make index of SAL error record 
+ *
+ *  Inputs	:  buffer (pointer to SAL error record)
+ *  In/Outputs	:  slidx  (pointer to index of SAL error record)
+ *  Outputs	:  platform error status
+ */
+
+static int 
+ia64_mca_make_slidx(void *buffer, slidx_table_t *slidx)
+{
+	int platform_err = 0;
+	int record_len = ((sal_log_record_header_t*)buffer)->len;
+	u32 ercd_pos;
+	int sects;
+	sal_log_section_hdr_t *sp;
+
+	/*
+	 * Initialize index referring current record
+	 */
+	IA64_LOG_INDEX_INIT_PTR(slidx);
+
+	/*
+	 * Extract a Record Header
+	 */
+	slidx->header = buffer;
+
+	/*
+	 * Extract each section records
+	 * (arranged from "int ia64_log_platform_info_print()")
+	 */
+	if (!slidx_pool.buffer) /* no space */
+		return platform_err;
+	for (ercd_pos = sizeof(sal_log_record_header_t), sects = 0;
+		ercd_pos < record_len; ercd_pos += sp->len, sects++) {
+		sp = (sal_log_section_hdr_t *)((char*)buffer + ercd_pos);
+		if (!efi_guidcmp(sp->guid, SAL_PROC_DEV_ERR_SECT_GUID)) {
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->proc_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->mem_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->sel_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->pci_bus_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->smbios_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->pci_comp_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->plat_specific_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->host_ctlr_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_BUS_ERR_SECT_GUID)) {
+			platform_err = 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->plat_bus_err, sp);
+		} else {
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->unsupported, sp);
+		}
+	}
+	slidx->n_sections = sects;
+
+	return platform_err;
+}
+
+/*
+ * ia64_mca_init_for_recovery
+ *
+ *  Initialize pool of section pointer lists for SAL record index
+ *
+ *  Inputs : None
+ *  Outputs: None
+ */
+void 
+ia64_mca_init_for_recovery(void)
+{
+	int i;
+	/* SAL info type or SAL record max size */
+	int temp[] = { SAL_INFO_TYPE_MCA, SAL_INFO_TYPE_INIT,
+			SAL_INFO_TYPE_CMC, SAL_INFO_TYPE_CPE };
+	int rec_max_size;  /* Maximum size of SAL error records */
+	int sect_min_size; /* Minimum size of SAL error sections */
+	/* minimum size table of each section */
+	static int sal_log_sect_min_sizes[] = { 
+		sizeof(sal_log_processor_info_t) + sizeof(sal_processor_static_info_t),
+		sizeof(sal_log_mem_dev_err_info_t),
+		sizeof(sal_log_sel_dev_err_info_t),
+		sizeof(sal_log_pci_bus_err_info_t),
+		sizeof(sal_log_smbios_dev_err_info_t),
+		sizeof(sal_log_pci_comp_err_info_t),
+		sizeof(sal_log_plat_specific_err_info_t),
+		sizeof(sal_log_host_ctlr_err_info_t),
+		sizeof(sal_log_plat_bus_err_info_t),
+	};
+
+	/*
+	 * Initialize a handling set of slidx_pool:
+	 *   1. Pick up the max size of SAL error records
+	 *   2. Pick up the min size of SAL error sections
+	 *   3. Allocate the pool as enough to 2 SAL records
+	 *     (now we can estimate the maxinum of section in a record.)
+	 */
+
+	/* - 1 - */
+	for (i = 0; i < sizeof temp/sizeof(int); i++)
+		temp[i] = ia64_sal_get_state_info_size(temp[i]);
+	rec_max_size = temp[0];
+	for (i = 1; i < sizeof temp/sizeof(int); i++)
+		if (rec_max_size < temp[i])
+			rec_max_size = temp[i];
+
+	/* - 2 - */
+	sect_min_size = sal_log_sect_min_sizes[0];
+	for (i = 1; i < sizeof sal_log_sect_min_sizes/sizeof(size_t); i++)
+		if (sect_min_size > sal_log_sect_min_sizes[i])
+			sect_min_size = sal_log_sect_min_sizes[i];
+
+	/* - 3 - */
+	slidx_pool.max_idx = (rec_max_size/sect_min_size) * 2 + 1;
+	slidx_pool.buffer = (slidx_list_t *) alloc_bootmem(slidx_pool.max_idx * sizeof(slidx_list_t));
+}
+
+
+/*****************************************************************************
+ * Recovery functions                                                        *
+ *****************************************************************************/
+
+/*
+ * is_mca_global
+ *
+ *	Check whether this MCA is global or not.
+ *
+ *  Inputs	: peidx (pointer of index of processor error section)
+ *		: pbci	(pointer to pal_bus_check_info_t)
+ *  Outputs	: is_global (whether MCA is global or not)
+ */
+
+static mca_type_t
+is_mca_global(peidx_table_t *peidx, pal_bus_check_info_t *pbci)
+{
+	pal_processor_state_info_t *psp = (pal_processor_state_info_t*)peidx_psp(peidx);
+	extern ia64_mca_sal_to_os_state_t ia64_sal_to_os_handoff_state;
+	enum {
+		SAL_RENDEZ_UNSUCCESSFUL = -1,
+		SAL_RENDEZ_NOT_REQUIRED = 0,
+		SAL_RENDEZ_SUCCESSFUL_INT = 1,
+		SAL_RENDEZ_SUCCESSFUL_INT_WITH_INIT = 2
+	};
+
+	/* 
+	 * PAL can request a rendezvous, if the MCA has a global scope.
+	 * If "rz_always" flag is set, SAL requests MCA rendezvous 
+	 * in spite of global MCA.
+	 * Therefore it is local MCA when rendezvous has not been requested.
+	 * Failed to rendezvous, the system must be down.
+	 */
+	switch (ia64_sal_to_os_handoff_state.imsto_rendez_state) {
+	case SAL_RENDEZ_NOT_REQUIRED:
+		return MCA_IS_LOCAL;
+	case SAL_RENDEZ_UNSUCCESSFUL:
+		return MCA_IS_GLOBAL;
+	case SAL_RENDEZ_SUCCESSFUL_INT:
+	case SAL_RENDEZ_SUCCESSFUL_INT_WITH_INIT:
+	default:
+		break;
+	}
+
+	/*
+	 * If One or more Cache/TLB/Reg_File/Uarch_Check is here,
+	 * it would be a local MCA. (i.e. processor internal error)
+	 */
+	if (psp->tc || psp->cc || psp->rc || psp->uc)
+		return MCA_IS_LOCAL;
+
+	/*
+	 * Bus_Check structure with Bus_Check.ib (internal bus error) flag set
+	 * would be a global MCA. (e.g. a system bus address parity error)
+	 */
+	if (!pbci || pbci->ib)
+		return MCA_IS_GLOBAL;
+
+	/*
+	 * Bus_Check structure with Bus_Check.eb (external bus error) flag set
+	 * could be either a local MCA or a global MCA.
+	 * Referring Bus_Check.bsi (bus error status information) ...
+	 *   1)   Local MCA
+	 *   2,3) Global MCA
+	 *   *)   Undefined ... maybe Global MCA (FIX ME)
+	 */
+	if (pbci->eb)
+		switch (pbci->bsi) {
+			case 1:
+				return MCA_IS_LOCAL;
+			case 2:
+			case 3:
+				return MCA_IS_GLOBAL;
+		}
+
+	return MCA_IS_GLOBAL;
+}
+
+/*
+ * recover_from_processor_error
+ *
+ *  Later we try to recover when below all conditions are satisfied.
+ *   1. Only one processor error section is exist.
+ *   2. BUS_CHECK is exist and the others are not exist.(Except TLB_CHECK)
+ *   3. The entry of BUS_CHECK_INFO is 1.
+ *   4. "External bus error" flag is set and the others are not set.
+ *
+ *  Inputs	: slidx (pointer to index of SAL error record)
+ *		: peidx (pointer to index of processor error section)
+ *		: pbci  (pointer to pal bus check info)
+ *  Outputs	: status (recovered or not)
+ */
+
+static int
+recover_from_processor_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bus_check_info_t *pbci)
+{
+	pal_processor_state_info_t *psp = (pal_processor_state_info_t*)peidx_psp(peidx);
+
+	/*
+	 * Did we correct the error?
+	 * When TLB error has occured, we have already fixed TLB error.
+	 */
+	if (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc)) 
+		return RECOVERY_OK;
+
+	/* 
+	 * We cannot recover errors with other than bus_check.
+	 */
+	if (psp->cc || psp->rc || psp->uc) 
+		return RECOVERY_NG_THEN_COLD_BOOT;
+
+	/*
+	 * If there is no bus error, record is weird but we need not to recover.
+	 */
+	if (psp->bc = 0 || pbci = NULL)
+		return RECOVERY_OK;
+
+	/*
+	 * Sorry, we cannot handle so many.
+	 */
+	if (peidx_bus_check_num(peidx) > 1)
+		return RECOVERY_NG_THEN_COLD_BOOT;
+	/*
+	 * Well, here is only one bus error.
+	 */
+	if (pbci->ib || pbci->cc)
+		return RECOVERY_NG_THEN_COLD_BOOT;
+	if (pbci->eb && pbci->bsi != 1)
+		return RECOVERY_NG_THEN_COLD_BOOT;
+
+	/*
+	 * This is a local MCA and estimated as recoverble external bus error.
+	 * (e.g. a load from poisoned memory)
+	 */
+	return RECOVERY_ON_PROCESSING;
+}
+
+/*
+ * recover_from_read_error
+ *
+ *  Here we try to recover the errors which type are "read"s.
+ *  (full line read, partial read, I/O space read)
+ *
+ *  Inputs	: slidx (pointer of index of SAL error record)
+ *		  peidx (pointer of index of processor error section)
+ *		  pbci  (pointer of pal_bus_check_info)
+ *  Outputs	: os recovery status
+ */
+static int
+recover_from_read_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bus_check_info_t *pbci)
+{
+	struct task_struct *tsk;
+
+	/* Is target address valid? */
+	if (!pbci->tv)
+		return RECOVERY_NG_THEN_COLD_BOOT;
+
+	/*
+	 * cpu read or memory-mapped io read
+	 *
+	 *    offending process  affected process  OS MCA do
+	 *     kernel mode        kernel mode       down system
+	 *     kernel mode        user   mode       kill the process
+	 *     user   mode        kernel mode       kill the process
+	 *     user   mode        user   mode       kill the process
+	 */
+	/*
+	 *  Check the privilege level of interrupted context
+	 */
+	if (((struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr))->cpl = 3) {
+		/* 
+		 * terminate affected process
+		 */
+		tsk = (struct task_struct *)peidx_minstate_area(peidx)->pmsa_gr[13];
+		force_sig(SIGKILL, tsk);
+
+		return RECOVERY_OK;
+	} else if (pbci->pv && pbci->pl = 3) { /* user mode process generates MCA */
+		/*
+		 * terminate offending process
+		 */
+		tsk = (struct task_struct *)peidx_minstate_area(peidx)->pmsa_gr[13];
+		force_sig(SIGKILL, tsk);
+
+		return RECOVERY_OK;
+	}
+
+	return RECOVERY_NG_THEN_COLD_BOOT;
+}
+
+/*
+ * recover_from_platform_error
+ *
+ *  Recover from platform error.
+ *  Now, we deal with read errors only.
+ *
+ *  Inputs	: slidx (pointer of index of SAL error record)
+ *		: peidx (pointer of index of processor error section)
+ *		: pbci  (pointer of pal bus check info)
+ *  Outputs	: status (recovered or not)
+ */
+
+static int
+recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bus_check_info_t *pbci)
+{
+	os_recovery_state_t status = RECOVERY_NG_THEN_COLD_BOOT;
+	pal_processor_state_info_t *psp = (pal_processor_state_info_t*)peidx_psp(peidx);
+
+	if (psp->bc && psp->co && psp->ci && pbci->eb && pbci->bsi = 1) {
+		switch(pbci->type) {
+		case 1: /* partial read */
+		case 3: /* full line(cpu) read */
+		case 9: /* I/O space read */
+			status = recover_from_read_error(slidx, peidx, pbci);
+			break;
+		case 0: /* unknown */
+		case 2: /* partial write */
+		case 4: /* full line write */
+		case 5: /* implicit or explicit write-back operation */
+		case 6: /* snoop probe */
+		case 7: /* incoming or outgoing ptc.g */
+		case 8: /* write coalescing transactions */
+		case 10: /* I/O space write */
+		case 11: /* inter-processor interrupt message(IPI) */
+		case 12: /* interrupt acknowledge or external task priority cycle */
+		default:
+			break;
+		}
+	}
+
+	return status;
+}
+
+/*
+ * ia64_mca_try_to_recover
+ *
+ *  Try to recover from MCA
+ *
+ * Inputs	: rec 	    (pointer to a SAL error record)
+ * Outputs	: os_status (os to sal state: recovered or not)
+ */
+
+int
+ia64_mca_try_to_recover(void *rec)
+{
+	int os_status = IA64_MCA_COLD_BOOT; /* default: os uncorrected */
+	int platform_err;
+	int n_proc_err;
+	slidx_table_t slidx;
+	peidx_table_t peidx;
+	pal_bus_check_info_t pbci;
+
+	/* Make index of SAL error record */
+	platform_err = ia64_mca_make_slidx(rec, &slidx);
+
+	/* Count processor error sections */
+	n_proc_err = slidx_count(&slidx, proc_err);
+
+	 /* Now, OS can recover when there is one processor error section */
+	if (n_proc_err > 1)
+		return IA64_MCA_COLD_BOOT;
+	else if (n_proc_err = 0) {
+		/* Weird SAL record ... We need not to recover */
+		os_status = IA64_MCA_CORRECTED;
+
+		return os_status;
+	}
+
+	/* Make index of processor error section */
+	ia64_mca_make_peidx((sal_log_processor_info_t*)slidx_first_entry(&slidx.proc_err)->hdr, &peidx);
+
+	/* Extract Processor BUS_CHECK[0] */
+	*((u64*)&pbci) = peidx_check_info(&peidx, bus_check, 0);
+
+	/* Check whether MCA is global or not */
+	if (is_mca_global(&peidx, &pbci))
+		return os_status;
+
+	/* Try to recover a processor error */
+	if ((os_status = recover_from_processor_error(&slidx, &peidx, &pbci)) != RECOVERY_ON_PROCESSING)
+		return os_status;
+
+	/* Try to recover a platform error */
+	if (platform_err)
+		os_status = recover_from_platform_error(&slidx, &peidx, &pbci);
+
+	return os_status;
+}
diff -Nur linux-2.6.2-keith1-9.orig/arch/ia64/kernel/mca_recovery.h linux-2.6.2-recovery_mca/arch/ia64/kernel/mca_recovery.h
--- linux-2.6.2-keith1-9.orig/arch/ia64/kernel/mca_recovery.h	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.2-recovery_mca/arch/ia64/kernel/mca_recovery.h	2004-02-16 20:02:32.000000000 +0900
@@ -0,0 +1,111 @@
+/*
+ * File:	mca_recovery.h
+ * Purpose:	Define helpers for Generic MCA handling
+ */
+
+/* 
+ * Processor error section: 
+ * 
+ *  +-sal_log_processor_info_t *info-------------+
+ *  | sal_log_section_hdr_t header;              |
+ *  | ...                                        |
+ *  | sal_log_mod_error_info_t info[0];          |
+ *  +-+----------------+-------------------------+
+ *    | CACHE_CHECK    |  ^ num_cache_check v
+ *    +----------------+
+ *    | TLB_CHECK      |  ^ num_tlb_check v
+ *    +----------------+
+ *    | BUS_CHECK      |  ^ num_bus_check v
+ *    +----------------+
+ *    | REG_FILE_CHECK |  ^ num_reg_file_check v
+ *    +----------------+
+ *    | MS_CHECK       |  ^ num_ms_check v
+ *  +-struct cpuid_info *id----------------------+
+ *  | regs[5];                                   |
+ *  | reserved;                                  |
+ *  +-sal_processor_static_info_t *regs----------+
+ *  | valid;                                     |
+ *  | ...                                        |
+ *  | fr[128];                                   |
+ *  +--------------------------------------------+
+ */
+
+/* peidx: index of processor error section */
+typedef struct peidx_table {
+	sal_log_processor_info_t        *info;
+	struct sal_cpuid_info           *id;
+	sal_processor_static_info_t     *regs;
+} peidx_table_t;
+
+#define peidx_head(p)   (((p)->info))
+#define peidx_mid(p)    (((p)->id))
+#define peidx_bottom(p) (((p)->regs))
+
+#define peidx_psp(p)           (&(peidx_head(p)->proc_state_parameter))
+#define peidx_field_valid(p)   (&(peidx_head(p)->valid))
+#define peidx_minstate_area(p) (&(peidx_bottom(p)->min_state_area))
+
+#define peidx_cache_check_num(p)    (peidx_head(p)->valid.num_cache_check)
+#define peidx_tlb_check_num(p)      (peidx_head(p)->valid.num_tlb_check)
+#define peidx_bus_check_num(p)      (peidx_head(p)->valid.num_bus_check)
+#define peidx_reg_file_check_num(p) (peidx_head(p)->valid.num_reg_file_check)
+#define peidx_ms_check_num(p)       (peidx_head(p)->valid.num_ms_check)
+
+#define peidx_cache_check_idx(p, n)    (n)
+#define peidx_tlb_check_idx(p, n)      (peidx_cache_check_idx(p, peidx_cache_check_num(p)) + n)
+#define peidx_bus_check_idx(p, n)      (peidx_tlb_check_idx(p, peidx_tlb_check_num(p)) + n)
+#define peidx_reg_file_check_idx(p, n) (peidx_bus_check_idx(p, peidx_bus_check_num(p)) + n)
+#define peidx_ms_check_idx(p, n)       (peidx_reg_file_check_idx(p, peidx_reg_file_check_num(p)) + n)
+
+#define peidx_mod_error_info(p, name, n) \
+({	int __idx = peidx_##name##_idx(p, n); \
+	sal_log_mod_error_info_t *__ret = NULL; \
+	if (peidx_##name##_num(p) <= n) \
+		__ret = &(peidx_head(p)->info[__idx]); \
+	__ret; })
+
+#define peidx_cache_check(p, n)    peidx_mod_error_info(p, cache_check, n)
+#define peidx_tlb_check(p, n)      peidx_mod_error_info(p, tlb_check, n)
+#define peidx_bus_check(p, n)      peidx_mod_error_info(p, bus_check, n)
+#define peidx_reg_file_check(p, n) peidx_mod_error_info(p, reg_file_check, n)
+#define peidx_ms_check(p, n)       peidx_mod_error_info(p, ms_check, n)
+
+#define peidx_check_info(proc, name, n) \
+({ \
+	sal_log_mod_error_info_t *__info = peidx_mod_error_info(proc, name, n);\
+	u64 __temp = __info && __info->valid.check_info \
+		? __info->check_info : 0; \
+	__temp; })
+
+/* slidx: index of SAL log error record */
+
+typedef struct slidx_list {
+        struct list_head list;
+        sal_log_section_hdr_t *hdr;
+} slidx_list_t;
+
+typedef struct slidx_table {
+        sal_log_record_header_t *header;
+        int n_sections;			/* # of section headers */
+        struct list_head proc_err;
+        struct list_head mem_dev_err;
+        struct list_head sel_dev_err;
+        struct list_head pci_bus_err;
+        struct list_head smbios_dev_err;
+        struct list_head pci_comp_err;
+        struct list_head plat_specific_err;
+        struct list_head host_ctlr_err;
+        struct list_head plat_bus_err;
+        struct list_head unsupported;	/* list of unsupported sections */
+} slidx_table_t;
+
+#define slidx_foreach_entry(pos, head) \
+	list_for_each_entry(pos, head, list)
+#define slidx_first_entry(head) \
+	(((head)->next != (head)) ? list_entry((head)->next, typeof(slidx_list_t), list) : NULL)
+#define slidx_count(slidx, sec) \
+({	int __count = 0; \
+	slidx_list_t *__pos; \
+	slidx_foreach_entry(__pos, &((slidx)->sec)) { __count++; }\
+	__count; })
+

