From: "Hall, Jenna S" <jenna.s.hall@intel.com>
Date: Tue, 15 Jan 2002 22:35:58 +0000
Subject: RE: [Linux-ia64] latest MCA logging patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C19E15.00A80E00"
Message-Id: <marc-linux-ia64-105590698805841@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805745@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C19E15.00A80E00
Content-Type: text/plain;
	charset="iso-8859-1"

To be on the safe side, I have re-instated the spinlock around SAL runtime
calls.  During MCA handling, however, we will make SAL calls without the
spinlock.  If the SAL version happens not to be re-entrant then it will just
increase the chances of a system crash - which is provided for anyway in the
MCA handler code.

Please let me know if this is acceptable.  Here is the new patch.

Thanks,
Jenna


diff -urN ./linux-2.4.17/arch/ia64/kernel/mca.c
mca/linux-2.4.17/arch/ia64/kernel/mca.c
--- ./linux-2.4.17/arch/ia64/kernel/mca.c	Fri Nov  9 14:26:17 2001
+++ mca/linux-2.4.17/arch/ia64/kernel/mca.c	Thu Jan 10 14:38:50 2002
@@ -3,6 +3,9 @@
  * Purpose:	Generic MCA handling layer
  *
  * Updated for latest kernel
+ * Copyright (C) 2002 Intel
+ * Copyright (C) Jenna Hall (jenna.s.hall@intel.com)
+ *
  * Copyright (C) 2001 Intel
  * Copyright (C) Fred Lewis (frederick.v.lewis@intel.com)
  *
@@ -12,6 +15,11 @@
  * Copyright (C) 1999 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander(vijay@engr.sgi.com)
  *
+ * 02/01/04 J. Hall	Aligned MCA stack to 16 bytes, added platform vs.
CPU
+ *			error flag, set SAL default return values, changed
+ *			error record structure to linked list, added init
call
+ *			to sal_get_state_info_size().
+ *
  * 01/01/03 F. Lewis    Added setup of CMCI and CPEI IRQs, logging of
corrected
  *                      platform errors, completed code for logging of
  *                      corrected & uncorrected machine check errors, and
@@ -27,6 +35,7 @@
 #include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/smp_lock.h>
+#include <linux/bootmem.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -50,18 +59,22 @@
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
 u64				ia64_mca_proc_state_dump[512];
-u64				ia64_mca_stack[1024];
+u64				ia64_mca_stack[1024]
__attribute__((aligned(16)));
 u64				ia64_mca_stackframe[32];
 u64				ia64_mca_bspstore[1024];
 u64				ia64_init_stack[INIT_TASK_SIZE]
__attribute__((aligned(16)));
+u64				ia64_mca_sal_data_area[1356];
+u64				ia64_mca_min_state_save_info;
+u64				ia64_tlb_functional;
+u64				ia64_os_mca_recovery_successful;
 
 static void			ia64_mca_wakeup_ipi_wait(void);
 static void			ia64_mca_wakeup(int cpu);
 static void			ia64_mca_wakeup_all(void);
 static void			ia64_log_init(int);
-extern void		        ia64_monarch_init_handler (void);
-extern void		        ia64_slave_init_handler (void);
-extern struct hw_interrupt_type irq_type_iosapic_level;
+extern void			ia64_monarch_init_handler (void);
+extern void			ia64_slave_init_handler (void);
+extern struct hw_interrupt_type	irq_type_iosapic_level;
 
 static struct irqaction cmci_irqaction = {
 	handler:    ia64_mca_cmc_int_handler,
@@ -95,25 +108,31 @@
  *  memory.
  *
  *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE/INIT)
- *  Outputs :   None
+ *  Outputs :   platform error status
  */
-void
+int
 ia64_mca_log_sal_error_record(int sal_info_type)
 {
+	int platform_err = 0;
+
 	/* Get the MCA error record */
 	if (!ia64_log_get(sal_info_type, (prfunc_t)printk))
-		return;                 // no record retrieved
+		return platform_err;                 // no record retrieved
 
-	/* Log the error record */
-	ia64_log_print(sal_info_type, (prfunc_t)printk);
+	/* TODO:
+	 * 1. analyze error logs to determine recoverability
+	 * 2. perform error recovery procedures, if applicable
+	 * 3. set ia64_os_mca_recovery_successful flag, if applicable
+	 */
 
-	/* Clear the CMC SAL logs now that they have been logged */
+	platform_err = ia64_log_print(sal_info_type, (prfunc_t)printk);
 	ia64_sal_clear_state_info(sal_info_type);
+
+	return platform_err;
 }
 
 /*
- * hack for now, add platform dependent handlers
- * here
+ * platform dependent error handling
  */
 #ifndef PLATFORM_MCA_HANDLERS
 void
@@ -275,8 +294,8 @@
 	cmcv_reg_t	cmcv;
 
 	cmcv.cmcv_regval	= 0;
-	cmcv.cmcv_mask      = 0;        /* Unmask/enable interrupt */
-	cmcv.cmcv_vector    = IA64_CMC_VECTOR;
+	cmcv.cmcv_mask		= 0;        /* Unmask/enable interrupt */
+	cmcv.cmcv_vector	= IA64_CMC_VECTOR;
 	ia64_set_cmcv(cmcv.cmcv_regval);
 
 	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d corrected "
@@ -374,6 +393,9 @@
 
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
+	/* initialize recovery success indicator */
+	ia64_os_mca_recovery_successful = 0;
+
 	/* Clear the Rendez checkin flag for all cpus */
 	for(i = 0 ; i < NR_CPUS; i++)
 		ia64_mc_info.imi_rendez_checkin[i] =
IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
@@ -459,7 +481,7 @@
 
 	/*
 	 *  Configure the CMCI vector and handler. Interrupts for CMC are
-	 *  per-processor, so AP CMC interrupts are setup in smp_callin()
(smp.c).
+	 *  per-processor, so AP CMC interrupts are setup in smp_callin()
(smpboot.c).
 	 */
 	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
 	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP & enable
*/
@@ -498,6 +520,9 @@
 	ia64_log_init(SAL_INFO_TYPE_CMC);
 	ia64_log_init(SAL_INFO_TYPE_CPE);
 
+	/* Zero the min state save info */
+	ia64_mca_min_state_save_info = 0;
+
 #if defined(MCA_TEST)
 	mca_test();
 #endif /* #if defined(MCA_TEST) */
@@ -576,7 +601,7 @@
 	int cpu;
 
 	/* Clear the Rendez checkin flag for all cpus */
-	for(cpu = 0 ; cpu < smp_num_cpus; cpu++)
+	for(cpu = 0; cpu < smp_num_cpus; cpu++)
 		if (ia64_mc_info.imi_rendez_checkin[cpu] ==
IA64_MCA_RENDEZ_CHECKIN_DONE)
 			ia64_mca_wakeup(cpu);
 
@@ -668,6 +693,13 @@
 
 	/* Cold Boot for uncorrectable MCA */
 	ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_COLD_BOOT;
+
+	/* Default = tell SAL to return to same context */
+	ia64_os_to_sal_handoff_state.imots_context = IA64_MCA_SAME_CONTEXT;
+
+	/* Register pointer to new min state values */
+	/* NOTE: need to do something with this during recovery phase */
+	ia64_os_to_sal_handoff_state.imots_new_min_state =
&ia64_mca_min_state_save_info;
 }
 
 /*
@@ -678,10 +710,10 @@
  *	This is the place where the core of OS MCA handling is done.
  *	Right now the logs are extracted and displayed in a well-defined
  *	format. This handler code is supposed to be run only on the
- *	monarch processor. Once the  monarch is done with MCA handling
+ *	monarch processor. Once the monarch is done with MCA handling
  *	further MCA logging is enabled by clearing logs.
  *	Monarch also has the duty of sending wakeup-IPIs to pull the
- *  slave processors out of rendezvous spinloop.
+ *	slave processors out of rendezvous spinloop.
  *
  *  Inputs  :   None
  *  Outputs :   None
@@ -689,20 +721,16 @@
 void
 ia64_mca_ucmc_handler(void)
 {
-#if 0   /* stubbed out @FVL */
-	/*
-	 *  Attempting to log a DBE error Causes "reserved register/field
panic"
-	 *  in printk.
-	 */
+	int platform_err = 0;
 
 	/* Get the MCA error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
-#endif  /* stubbed out @FVL */
+	platform_err = ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
 	/*
 	 *  Do Platform-specific mca error handling if required.
 	 */
-	mca_handler_platform() ;
+	if (platform_err)
+		mca_handler_platform();
 
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
@@ -749,13 +777,16 @@
 {
 	spinlock_t	isl_lock;
 	int		isl_index;
-	ia64_err_rec_t  isl_log[IA64_MAX_LOGS]; /* need space to store
header + error log */
+	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store
header + error log */
 } ia64_state_log_t;
 
 static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
 
-/* Note:  Some of these macros assume IA64_MAX_LOGS is always 2.  Should be
*/
-/* fixed. @FVL
*/
+#define IA64_LOG_ALLOCATE(it, size) \
+	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
+		(ia64_err_rec_t *)alloc_bootmem(size); \
+	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
+		(ia64_err_rec_t *)alloc_bootmem(size);}
 #define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
 #define IA64_LOG_LOCK(it)
spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
 #define IA64_LOG_UNLOCK(it)
spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
@@ -765,13 +796,13 @@
     ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index
 #define IA64_LOG_INDEX_DEC(it) \
     ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index
-#define IA64_LOG_NEXT_BUFFER(it)   (void
*)(&(ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)]))
-#define IA64_LOG_CURR_BUFFER(it)   (void
*)(&(ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
+#define IA64_LOG_NEXT_BUFFER(it)   (void
*)((ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)]))
+#define IA64_LOG_CURR_BUFFER(it)   (void
*)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
 
 /*
  * C portion of the OS INIT handler
  *
- * Called from ia64_<monarch/slave>_init_handler
+ * Called from ia64_monarch_init_handler
  *
  * Inputs: pointer to pt_regs where processor info was saved.
  *
@@ -885,10 +916,18 @@
 void
 ia64_log_init(int sal_info_type)
 {
-	IA64_LOG_LOCK_INIT(sal_info_type);
+	u64	max_size = 0;
+
 	IA64_LOG_NEXT_INDEX(sal_info_type) = 0;
-	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0,
-	       sizeof(ia64_err_rec_t) * IA64_MAX_LOGS);
+	IA64_LOG_LOCK_INIT(sal_info_type);
+
+	// SAL will tell us the maximum size of any error record of this
type
+	max_size = ia64_sal_get_state_info_size(sal_info_type);
+
+	// set up OS data structures to hold error info
+	IA64_LOG_ALLOCATE(sal_info_type, max_size);
+	memset(IA64_LOG_CURR_BUFFER(sal_info_type), 0, max_size);
+	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0, max_size);
 }
 
 /*
@@ -923,8 +962,7 @@
 		return total_len;
 	} else {
 		IA64_LOG_UNLOCK(sal_info_type);
-		prfunc("ia64_log_get: Failed to retrieve SAL error record
type %d\n",
-		       sal_info_type);
+		prfunc("ia64_log_get: No SAL error record available for type
%d\n", sal_info_type);
 		return 0;
 	}
 }
@@ -1268,7 +1306,7 @@
 	}
 
 	if (mdei->valid.oem_data) {
-		ia64_log_prt_oem_data((int)mdei->header.len,
+		platform_mem_dev_err_print((int)mdei->header.len,
 
(int)sizeof(sal_log_mem_dev_err_info_t) - 1,
 				      &(mdei->oem_data[0]), prfunc);
 	}
@@ -1357,7 +1395,7 @@
 		prfunc("\n");
 
 	if (pbei->valid.oem_data) {
-		ia64_log_prt_oem_data((int)pbei->header.len,
+		platform_pci_bus_err_print((int)pbei->header.len,
 
(int)sizeof(sal_log_pci_bus_err_info_t) - 1,
 				      &(pbei->oem_data[0]), prfunc);
 	}
@@ -1456,7 +1494,7 @@
 		}
 	}
 	if (pcei->valid.oem_data) {
-		ia64_log_prt_oem_data((int)pcei->header.len, n_pci_data,
+		platform_pci_comp_err_print((int)pcei->header.len,
n_pci_data,
 				      p_oem_data, prfunc);
 		prfunc("\n");
 	}
@@ -1485,7 +1523,7 @@
 		ia64_log_prt_guid(&psei->guid, prfunc);
 	}
 	if (psei->valid.oem_data) {
-		ia64_log_prt_oem_data((int)psei->header.len,
+		platform_plat_specific_err_print((int)psei->header.len,
 
(int)sizeof(sal_log_plat_specific_err_info_t) - 1,
 				      &(psei->oem_data[0]), prfunc);
 	}
@@ -1519,7 +1557,7 @@
 	if (hcei->valid.bus_spec_data)
 		prfunc(" Bus Specific Data: %#lx", hcei->bus_spec_data);
 	if (hcei->valid.oem_data) {
-		ia64_log_prt_oem_data((int)hcei->header.len,
+		platform_host_ctlr_err_print((int)hcei->header.len,
 
(int)sizeof(sal_log_host_ctlr_err_info_t) - 1,
 				      &(hcei->oem_data[0]), prfunc);
 	}
@@ -1553,7 +1591,7 @@
 	if (pbei->valid.bus_spec_data)
 		prfunc(" Bus Specific Data: %#lx", pbei->bus_spec_data);
 	if (pbei->valid.oem_data) {
-		ia64_log_prt_oem_data((int)pbei->header.len,
+		platform_plat_bus_err_print((int)pbei->header.len,
 
(int)sizeof(sal_log_plat_bus_err_info_t) - 1,
 				      &(pbei->oem_data[0]), prfunc);
 	}
@@ -1745,17 +1783,18 @@
  *  Inputs  :   lh      (Pointer to the sal error record header with format
  *                       specified by the SAL spec).
  *              prfunc  (fn ptr of log output function to use)
- *  Outputs :   None
+ *  Outputs :	platform error status
  */
-void
+int
 ia64_log_platform_info_print (sal_log_record_header_t *lh, prfunc_t prfunc)
 {
-	sal_log_section_hdr_t       *slsh;
-	int                         n_sects;
-	int                         ercd_pos;
+	sal_log_section_hdr_t	*slsh;
+	int			n_sects;
+	int			ercd_pos;
+	int			platform_err = 0;
 
 	if (!lh)
-		return;
+		return platform_err;
 
 #ifdef MCA_PRT_XTRA_DATA    // for test only @FVL
 	ia64_log_prt_record_header(lh, prfunc);
@@ -1765,7 +1804,7 @@
 		IA64_MCA_DEBUG("ia64_mca_log_print: "
 			       "truncated SAL error record. len = %d\n",
 			       lh->len);
-		return;
+		return platform_err;
 	}
 
 	/* Print record header info */
@@ -1796,35 +1835,43 @@
 
ia64_log_proc_dev_err_info_print((sal_log_processor_info_t *)slsh,
 							 prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_MEM_DEV_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform Memory Device Error Info
Section\n");
 
ia64_log_mem_dev_err_info_print((sal_log_mem_dev_err_info_t *)slsh,
 							prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_SEL_DEV_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform SEL Device Error Info Section\n");
 
ia64_log_sel_dev_err_info_print((sal_log_sel_dev_err_info_t *)slsh,
 							prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_PCI_BUS_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform PCI Bus Error Info Section\n");
 
ia64_log_pci_bus_err_info_print((sal_log_pci_bus_err_info_t *)slsh,
 							prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform SMBIOS Device Error Info
Section\n");
 
ia64_log_smbios_dev_err_info_print((sal_log_smbios_dev_err_info_t *)slsh,
 							   prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_PCI_COMP_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform PCI Component Error Info
Section\n");
 
ia64_log_pci_comp_err_info_print((sal_log_pci_comp_err_info_t *)slsh,
 							 prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_SPECIFIC_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform Specific Error Info Section\n");
 
ia64_log_plat_specific_err_info_print((sal_log_plat_specific_err_info_t *)
 							      slsh,
 							      prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_HOST_CTLR_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform Host Controller Error Info
Section\n");
 
ia64_log_host_ctlr_err_info_print((sal_log_host_ctlr_err_info_t *)slsh,
 							  prfunc);
 		} else if (efi_guidcmp(slsh->guid,
SAL_PLAT_BUS_ERR_SECT_GUID) == 0) {
+			platform_err = 1;
 			prfunc("+Platform Bus Error Info Section\n");
 
ia64_log_plat_bus_err_info_print((sal_log_plat_bus_err_info_t *)slsh,
 							 prfunc);
@@ -1838,8 +1885,9 @@
 		       n_sects, lh->len);
 	if (!n_sects) {
 		prfunc("No Platform Error Info Sections found\n");
-		return;
+		return platform_err;
 	}
+	return platform_err;
 }
 
 /*
@@ -1849,15 +1897,17 @@
  *
  *  Inputs   :  info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
  *              prfunc      (fn ptr of log output function to use)
- * Outputs	:	None
+ * Outputs	:	platform error status
  */
-void
+int
 ia64_log_print(int sal_info_type, prfunc_t prfunc)
 {
+	int platform_err = 0;
+
 	switch(sal_info_type) {
 	      case SAL_INFO_TYPE_MCA:
 		prfunc("+BEGIN HARDWARE ERROR STATE AT MCA\n");
-
ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
+		platform_err =
ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
 		prfunc("+END HARDWARE ERROR STATE AT MCA\n");
 		break;
 	      case SAL_INFO_TYPE_INIT:
@@ -1877,4 +1927,5 @@
 		prfunc("+MCA UNKNOWN ERROR LOG (UNIMPLEMENTED)\n");
 		break;
 	}
+	return platform_err;
 }
diff -urN ./linux-2.4.17/arch/ia64/kernel/mca_asm.S
mca/linux-2.4.17/arch/ia64/kernel/mca_asm.S
--- ./linux-2.4.17/arch/ia64/kernel/mca_asm.S	Fri Nov  9 14:26:17 2001
+++ mca/linux-2.4.17/arch/ia64/kernel/mca_asm.S	Fri Jan  4 18:19:27 2002
@@ -7,6 +7,12 @@
 // 00/03/29 cfleck Added code to save INIT handoff state in pt_regs format,
switch to temp
 //		   kstack, switch modes, jump to C INIT handler
 //
+// 02/01/04 J.Hall <jenna.s.hall@intel.com>
+//		   Before entering virtual mode code:
+//		   1. Check for TLB CPU error
+//		   2. Restore current thread pointer to kr6
+//		   3. Move stack ptr 16 bytes to conform to C calling
convention
+//
 #include <linux/config.h>
 
 #include <asm/asmmacro.h>
@@ -21,10 +27,21 @@
  */
 #define	MINSTATE_PHYS	/* Make sure stack access is physical for
MINSTATE */
 
+/*
+ * Needed for ia64_sal call
+ */
+#define SAL_GET_STATE_INFO      0x01000001
+
+/*
+ * Needed for return context to SAL
+ */
+#define IA64_MCA_SAME_CONTEXT	0x0
+#define IA64_MCA_COLD_BOOT	-2
+
 #include "minstate.h"
 
 /*
- *  SAL_TO_OS_MCA_HANDOFF_STATE (SAL 3.0 spec)
+ * SAL_TO_OS_MCA_HANDOFF_STATE (SAL 3.0 spec)
  *		1. GR1 = OS GP
  *		2. GR8 = PAL_PROC physical address
  *		3. GR9 = SAL_PROC physical address
@@ -40,26 +57,34 @@
 	st8	[_tmp]=r9,0x08;;			\
 	st8	[_tmp]=r10,0x08;;			\
 	st8	[_tmp]=r11,0x08;;			\
-	st8	[_tmp]=r12,0x08;;
+	st8	[_tmp]=r12,0x08
 
 /*
- *  OS_MCA_TO_SAL_HANDOFF_STATE (SAL 3.0 spec)
- *      1. GR8 = OS_MCA return status
+ * OS_MCA_TO_SAL_HANDOFF_STATE (SAL 3.0 spec)
+ * (p6) is executed if we never entered virtual mode (TLB error)
+ * (p7) is executed if we entered virtual mode as expected (normal case)
+ *	1. GR8 = OS_MCA return status
  *	2. GR9 = SAL GP (physical)
- *      3. GR10 = 0/1 returning same/new context
- *      4. GR22 = New min state save area pointer
- *      returns ptr to SAL rtn save loc in _tmp
+ *	3. GR10 = 0/1 returning same/new context
+ *	4. GR22 = New min state save area pointer
+ *	returns ptr to SAL rtn save loc in _tmp
  */
-#define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)
\
-	movl	_tmp=ia64_os_to_sal_handoff_state;;
\
-	DATA_VA_TO_PA(_tmp);;
\
-	ld8	r8=[_tmp],0x08;;
\
-	ld8	r9=[_tmp],0x08;;
\
-	ld8     r10=[_tmp],0x08;;
\
-	ld8     r22=[_tmp],0x08;;
\
-	movl    _tmp=ia64_sal_to_os_handoff_state;;
\
-	DATA_VA_TO_PA(_tmp);;
\
-	add     _tmp=0x28,_tmp;;            // point to SAL rtn save
location
+#define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)	\
+(p6)	movl	_tmp=ia64_sal_to_os_handoff_state;;	\
+(p7)	movl	_tmp=ia64_os_to_sal_handoff_state;;	\
+	DATA_VA_TO_PA(_tmp);;				\
+(p6)	movl	r8=IA64_MCA_COLD_BOOT;			\
+(p6)	movl	r10=IA64_MCA_SAME_CONTEXT;		\
+(p6)	add     _tmp=0x18,_tmp;;			\
+(p6)	ld8	r9=[_tmp],0x10;				\
+(p6)	movl	r22=ia64_mca_min_state_save_info;;	\
+(p7)	ld8	r8=[_tmp],0x08;;			\
+(p7)	ld8	r9=[_tmp],0x08;;			\
+(p7)	ld8     r10=[_tmp],0x08;;			\
+(p7)	ld8     r22=[_tmp],0x08;;			\
+	DATA_VA_TO_PA(r22)
+	// now _tmp is pointing to SAL rtn save location
+
 
 	.global ia64_os_mca_dispatch
 	.global ia64_os_mca_dispatch_end
@@ -70,6 +95,9 @@
 	.global	ia64_mca_stackframe
 	.global	ia64_mca_bspstore
 	.global ia64_init_stack
+	.global ia64_mca_sal_data_area
+	.global ia64_tlb_functional
+	.global ia64_mca_min_state_save_info
 
 	.text
 	.align 16
@@ -90,26 +118,34 @@
 	//	  for ia64_mca_sal_to_os_state_t has been
 	//	  defined in include/asm/mca.h
 	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
+	;;
 
 	// LOG PROCESSOR STATE INFO FROM HERE ON..
-	;;
 begin_os_mca_dump:
 	br	ia64_os_mca_proc_state_dump;;
 
 ia64_os_mca_done_dump:
 
 	// Setup new stack frame for OS_MCA handling
-	movl    r2=ia64_mca_bspstore;;      // local bspstore area location
in r2
+	movl	r2=ia64_mca_bspstore;;	// local bspstore area location in
r2
 	DATA_VA_TO_PA(r2);;
-	movl    r3=ia64_mca_stackframe;;    // save stack frame to memory in
r3
+	movl	r3=ia64_mca_stackframe;; // save stack frame to memory in r3
 	DATA_VA_TO_PA(r3);;
-	rse_switch_context(r6,r3,r2);;                  // RSC management in
this new context
-	movl        r12=ia64_mca_stack;;
-	mov     r2=8*1024;;                 // stack size must be same as c
array
-	add     r12=r2,r12;;                // stack base @ bottom of array
+	rse_switch_context(r6,r3,r2);;	// RSC management in this new
context
+	movl	r12=ia64_mca_stack
+	mov	r2=8*1024;;		// stack size must be same as C
array
+	add	r12=r2,r12;;		// stack base @ bottom of array
+	adds	r12=-16,r12;;		// allow 16 bytes of scratch
+					// (C calling convention)
 	DATA_VA_TO_PA(r12);;
 
-	// Enter virtual mode from physical mode
+	// Check to see if the MCA resulted from a TLB error
+begin_tlb_error_check:
+        br      ia64_os_mca_tlb_error_check;;
+
+done_tlb_error_check:
+
+        // If TLB is functional, enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
 ia64_os_mca_virtual_begin:
 
@@ -130,25 +166,28 @@
 #endif	/* #if defined(MCA_TEST) */
 
 	// restore the original stack frame here
-	movl    r2=ia64_mca_stackframe               // restore stack frame
from memory at r2
+	movl    r2=ia64_mca_stackframe	// restore stack frame from memory
at r2
 	;;
 	DATA_VA_TO_PA(r2)
 	movl    r4=IA64_PSR_MC
 	;;
-	rse_return_context(r4,r3,r2)                 // switch from
interrupt context for RSE
+	rse_return_context(r4,r3,r2)	// switch from interrupt context for
RSE
 
 	// let us restore all the registers from our PSI structure
-	mov		r8=gp
+	mov	r8=gp
 	;;
 begin_os_mca_restore:
 	br	ia64_os_mca_proc_state_restore;;
 
 ia64_os_mca_done_restore:
-	;;
+	movl	r3=ia64_tlb_functional;;
+	DATA_VA_TO_PA(r3);;
+	ld8	r3=[r3];;
+	cmp.eq	p6,p7=r0,r3;;
+	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2);;
 	// branch back to SALE_CHECK
-	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2)
 	ld8		r3=[r2];;
-	mov		b0=r3;;			      // SAL_CHECK return
address
+	mov		b0=r3;;		// SAL_CHECK return address
 	br		b0
 	;;
 ia64_os_mca_dispatch_end:
@@ -405,7 +444,7 @@
 	movl		r2=ia64_mca_proc_state_dump	// Convert virtual
address
 	;;						// of OS state dump
area
 	DATA_VA_TO_PA(r2)				// to physical
address
-	;;
+
 restore_GRs:                                    // restore bank-1 GRs 16-31
 	bsw.1;;
 	add		r3=16*8,r2;;                // to get to NaT of GR
16-31
@@ -621,6 +660,80 @@
 
 
//EndStub///////////////////////////////////////////////////////////////////
///
 
+//++
+// Name:
+//	ia64_os_mca_tlb_error_check()
+//
+// Stub Description:
+//
+//	This stub checks to see if the MCA resulted from a TLB error
+//
+//--
+
+ia64_os_mca_tlb_error_check:
+
+	// Retrieve sal data structure for uncorrected MCA
+
+	// Make the ia64_sal_get_state_info() call
+	movl	r4=ia64_mca_sal_data_area;;
+	movl	r7=ia64_sal;;
+	mov	r6=r1			// save gp
+	DATA_VA_TO_PA(r4)		// convert to physical address
+	DATA_VA_TO_PA(r7);;		// convert to physical address
+	ld8	r7=[r7]			// get addr of pdesc from ia64_sal
+	movl	r3=SAL_GET_STATE_INFO;;
+	DATA_VA_TO_PA(r7);;		// convert to physical address
+	ld8	r8=[r7],8;;		// get pdesc function pointer
+	DATA_VA_TO_PA(r8)		// convert to physical address
+	ld8	r1=[r7];;		// set new (ia64_sal) gp
+	DATA_VA_TO_PA(r1)		// convert to physical address
+	mov	b6=r8
+
+	alloc	r5=ar.pfs,8,0,8,0;;	// allocate stack frame for SAL call
+	mov	out0=r3			// which SAL proc to call
+	mov	out1=r0			// error type == MCA
+	mov	out2=r0			// null arg
+	mov	out3=r4			// data copy area
+	mov	out4=r0			// null arg
+	mov	out5=r0			// null arg
+	mov	out6=r0			// null arg
+	mov	out7=r0;;		// null arg
+
+	br.call.sptk.few	b0=b6;;
+
+	mov	r1=r6			// restore gp
+	mov	ar.pfs=r5;;		// restore ar.pfs
+
+	movl	r6=ia64_tlb_functional;;
+	DATA_VA_TO_PA(r6)		// needed later
+
+	cmp.eq	p6,p7=r0,r8;;		// check SAL call return address
+(p7)	st8	[r6]=r0			// clear tlb_functional flag
+(p7)    br	tlb_failure		// error; return to SAL
+
+	// examine processor error log for type of error
+	add	r4=40+24,r4;;		// parse past record header
(length=40)
+					// and section header (length=24)
+	ld4	r4=[r4]			// get valid field of processor log
+	mov	r5=0xf00;;
+	and	r5=r4,r5;;		// read bits 8-11 of valid field
+					// to determine if we have a TLB
error
+	movl	r3=0x1
+	cmp.eq	p6,p7=r0,r5;;
+	// if no TLB failure, set tlb_functional flag
+(p6)	st8	[r6]=r3
+	// else clear flag
+(p7)	st8	[r6]=r0
+
+	// if no TLB failure, continue with normal virtual mode logging
+(p6)    br	done_tlb_error_check
+	// else no point in entering virtual mode for logging
+tlb_failure:
+	br      ia64_os_mca_virtual_end
+
+//EndStub//////////////////////////////////////////////////////////////////
////
+
+
 // ok, the issue here is that we need to save state information so
 // it can be useable by the kernel debugger and show regs routines.
 // In order to do this, our best bet is save the current state (plus
@@ -633,7 +746,7 @@
 // This has been defined for registration purposes with SAL
 // as a part of ia64_mca_init.
 //
-// When we get here, the follow registers have been
+// When we get here, the following registers have been
 // set by the SAL for our use
 //
 //		1. GR1 = OS INIT GP
@@ -649,42 +762,10 @@
 
 
 GLOBAL_ENTRY(ia64_monarch_init_handler)
-#if defined(CONFIG_SMP) && defined(SAL_MPINIT_WORKAROUND)
-	//
-	// work around SAL bug that sends all processors to monarch entry
-	//
-	mov	r17=cr.lid
-	// XXX fix me: this is wrong: hard_smp_processor_id() is a pair of
lid/eid
-	movl	r18=ia64_cpu_to_sapicid
-	;;
-	dep	r18=0,r18,61,3		// convert to physical address
-	;;
-	shr.u	r17=r17,16
-	ld4	r18=[r18]		// get the BSP ID
-	;;
-	dep	r17=0,r17,16,48
-	;;
-	cmp4.ne	p6,p0=r17,r18		// Am I the BSP ?
-(p6)	br.cond.spnt slave_init_spin_me
-	;;
-#endif
-
 
-//
-// ok, the first thing we do is stash the information
-// the SAL passed to os
-//
-_tmp = r2
-	movl	_tmp=ia64_sal_to_os_handoff_state
-	;;
-	dep	_tmp=0,_tmp, 61, 3	// get physical address
+	// stash the information the SAL passed to os
+	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
 	;;
-	st8	[_tmp]=r1,0x08;;
-	st8	[_tmp]=r8,0x08;;
-	st8	[_tmp]=r9,0x08;;
-	st8	[_tmp]=r10,0x08;;
-	st8	[_tmp]=r11,0x08;;
-	st8	[_tmp]=r12,0x08;;
 
 // now we want to save information so we can dump registers
 	SAVE_MIN_WITH_COVER
@@ -695,12 +776,10 @@
 	;;
 	SAVE_REST
 
-// ok, enough should be saved at this point to be dangerous, and  supply
+// ok, enough should be saved at this point to be dangerous, and supply
 // information for a dump
 // We need to switch to Virtual mode before hitting the C functions.
-//
-//
-//
+
 	movl
r2=IA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|IA64_PSR_BN
 	mov	r3=psr	// get the current psr, minimum enabled at this
point
 	;;
@@ -708,8 +787,8 @@
 	;;
 	movl	r3=IVirtual_Switch
 	;;
-	mov	cr.iip=r3		// short return to set the
appropriate bits
-	mov	cr.ipsr=r2		// need to do an rfi to set
appropriate bits
+	mov	cr.iip=r3	// short return to set the appropriate bits
+	mov	cr.ipsr=r2	// need to do an rfi to set appropriate bits
 	;;
 	rfi
 	;;
@@ -717,7 +796,7 @@
 	//
 	// We should now be running virtual
 	//
-	// Lets call the C handler to get the rest of the state info
+	// Let's call the C handler to get the rest of the state info
 	//
 	alloc r14=ar.pfs,0,0,1,0		// now it's safe (must be
first in insn group!)
 	;;					//
diff -urN ./linux-2.4.17/arch/ia64/sn/kernel/mca.c
mca/linux-2.4.17/arch/ia64/sn/kernel/mca.c
--- ./linux-2.4.17/arch/ia64/sn/kernel/mca.c	Thu Jan  3 10:04:02 2002
+++ mca/linux-2.4.17/arch/ia64/sn/kernel/mca.c	Thu Jan  3 10:45:46 2002
@@ -14,6 +14,7 @@
 #include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/smp_lock.h>
+#include <linux/kdb.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -202,32 +203,32 @@
 void
 sn_cpei_handler(int irq, void *devid, struct pt_regs *regs) {
 
-	struct ia64_sal_retval isrv;
+        struct ia64_sal_retval isrv;
 // this function's sole purpose is to call SAL when we receive
 // a CE interrupt from SHUB or when the timer routine decides
 // we need to call SAL to check for CEs.
 
-	// CALL SAL_LOG_CE
-	SAL_CALL(isrv, SN_SAL_LOG_CE, irq, 0, 0, 0, 0, 0, 0);
+        // CALL SAL_LOG_CE
+        SAL_CALL(isrv, SN_SAL_LOG_CE, irq, 0, 0, 0, 0, 0, 0);
 }
 
 #include <linux/timer.h>
 
-#define CPEI_INTERVAL	(HZ/100)
+#define CPEI_INTERVAL   (HZ/100)
 struct timer_list sn_cpei_timer;
 void sn_init_cpei_timer(void);
 
 void
 sn_cpei_timer_handler(unsigned long dummy) {
-	sn_cpei_handler(-1, NULL, NULL);
-	del_timer(&sn_cpei_timer);
-	sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
+        sn_cpei_handler(-1, NULL, NULL);
+        del_timer(&sn_cpei_timer);
+        sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
         add_timer(&sn_cpei_timer);
 }
 
 void
 sn_init_cpei_timer() {
-	sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
+        sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
         sn_cpei_timer.function = sn_cpei_timer_handler;
         add_timer(&sn_cpei_timer);
 }
@@ -238,16 +239,16 @@
 
 void
 sn_ce_timer_handler(long dummy) {
-	unsigned long *pi_ce_error_inject_reg = 0xc00000092fffff00;
+        unsigned long *pi_ce_error_inject_reg = 0xc00000092fffff00;
 
-	*pi_ce_error_inject_reg = 0x0000000000000100;
-	del_timer(&sn_ce_timer);
-	sn_ce_timer.expires = jiffies + CPEI_INTERVAL;
+        *pi_ce_error_inject_reg = 0x0000000000000100;
+        del_timer(&sn_ce_timer);
+        sn_ce_timer.expires = jiffies + CPEI_INTERVAL;
         add_timer(&sn_ce_timer);
 }
 
 sn_init_ce_timer() {
-	sn_ce_timer.expires = jiffies + CPEI_INTERVAL;
+        sn_ce_timer.expires = jiffies + CPEI_INTERVAL;
         sn_ce_timer.function = sn_ce_timer_handler;
         add_timer(&sn_ce_timer);
 }
diff -urN ./linux-2.4.17/include/asm-ia64/mca.h
mca/linux-2.4.17/include/asm-ia64/mca.h
--- ./linux-2.4.17/include/asm-ia64/mca.h	Mon Jan 14 14:31:50 2002
+++ mca/linux-2.4.17/include/asm-ia64/mca.h	Tue Jan 15 11:24:50 2002
@@ -7,9 +7,6 @@
  * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
  */
 
-/* XXX use this temporary define for MP systems trying to INIT */
-#undef SAL_MPINIT_WORKAROUND
-
 #ifndef _ASM_IA64_MCA_H
 #define _ASM_IA64_MCA_H
 
@@ -101,12 +98,19 @@
 	IA64_MCA_HALT		=	-3	/* System to be halted by
SAL */
 };
 
+enum {
+	IA64_MCA_SAME_CONTEXT	=	0x0,	/* SAL to return to same
context */
+	IA64_MCA_NEW_CONTEXT	=	-1	/* SAL to return to new
context */
+};
+
 typedef struct ia64_mca_os_to_sal_state_s {
 	u64		imots_os_status;	/*   OS status to SAL as to
what happened
 						 *   with the MCA handling.
 						 */
 	u64		imots_sal_gp;		/* GP of the SAL - physical
*/
-	u64		imots_new_min_state;	/* Pointer to structure
containing
+	u64		imots_context;		/* 0 if return to same
context
+						   1 if return to new
context */
+	u64		*imots_new_min_state;	/* Pointer to structure
containing
 						 * new values of registers
in the min state
 						 * save area.
 						 */
@@ -127,12 +131,19 @@
 extern void ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
 extern void ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
 extern void ia64_mca_cpe_int_handler(int,void *,struct pt_regs *);
-extern void ia64_log_print(int,prfunc_t);
+extern int  ia64_log_print(int,prfunc_t);
 extern void ia64_mca_cmc_vector_setup(void);
 extern void ia64_mca_check_errors( void );
 extern u64  ia64_log_get(int, prfunc_t);
 
 #define PLATFORM_CALL(fn, args)	printk("Platform call TBD\n")
+
+#define platform_mem_dev_err_print ia64_log_prt_oem_data
+#define platform_pci_bus_err_print ia64_log_prt_oem_data
+#define platform_pci_comp_err_print ia64_log_prt_oem_data
+#define platform_plat_specific_err_print ia64_log_prt_oem_data
+#define platform_host_ctlr_err_print ia64_log_prt_oem_data
+#define platform_plat_bus_err_print ia64_log_prt_oem_data
 
 #undef	MCA_TEST
 
diff -urN ./linux-2.4.17/include/asm-ia64/mca_asm.h
mca/linux-2.4.17/include/asm-ia64/mca_asm.h
--- ./linux-2.4.17/include/asm-ia64/mca_asm.h	Fri Nov  9 14:26:17 2001
+++ mca/linux-2.4.17/include/asm-ia64/mca_asm.h	Fri Jan  4 18:10:27 2002
@@ -6,6 +6,8 @@
  * Copyright (C) Srinivasa Thirumalachar <sprasad@engr.sgi.com>
  * Copyright (C) 2000 Hewlett-Packard Co.
  * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2002 Intel Corp.
+ * Copyright (C) 2002 Jenna Hall <jenna.s.hall@intel.com>
  */
 #ifndef _ASM_IA64_MCA_ASM_H
 #define _ASM_IA64_MCA_ASM_H
@@ -24,7 +26,7 @@
  *	1. Lop off bits 61 thru 63 in the virtual address
  */
 #define INST_VA_TO_PA(addr)
\
-	dep	addr	= 0, addr, 61, 3;
+	dep	addr	= 0, addr, 61, 3
 /*
  * This macro converts a data virtual address to a physical address
  * Right now for simulation purposes the virtual addresses are
@@ -32,7 +34,7 @@
  *	1. Lop off bits 61 thru 63 in the virtual address
  */
 #define DATA_VA_TO_PA(addr)
\
-	dep	addr	= 0, addr, 61, 3;
+	dep	addr	= 0, addr, 61, 3
 /*
  * This macro converts a data physical address to a virtual address
  * Right now for simulation purposes the virtual addresses are
@@ -41,7 +43,7 @@
  */
 #define DATA_PA_TO_VA(addr,temp)
\
 	mov	temp	= 0x7	;;
\
-	dep	addr	= temp, addr, 61, 3;;
+	dep	addr	= temp, addr, 61, 3
 
 /*
  * This macro jumps to the instruction at the given virtual address
@@ -112,8 +114,8 @@
 	;;
\
 	mov	cr.iip = temp2;
\
 	mov	cr.ifs = r0;
\
-	DATA_VA_TO_PA(sp)
\
-	DATA_VA_TO_PA(gp)
\
+	DATA_VA_TO_PA(sp);
\
+	DATA_VA_TO_PA(gp);
\
 	;;
\
 	srlz.i;
\
 	;;
\
@@ -130,8 +132,7 @@
  * translations turned on.
  *	1.	Get the old saved psr
  *
- *	2.	Clear the interrupt enable and interrupt state collection
bits
- *		in the current psr.
+ *	2.	Clear the interrupt state collection bit in the current psr.
  *
  *	3.	Set the instruction translation bit back in the old psr
  *		Note we have to do this since we are right now saving only
the
@@ -140,9 +141,11 @@
  *
  *	4.	Set ipsr to this old_psr with "it" bit set and "bn" = 1.
  *
- *	5.	Set iip to the virtual address of the next instruction
bundle.
+ *	5.	Reset the current thread pointer (r13).
  *
- *	6.	Do an rfi to move ipsr to psr and iip to ip.
+ *	6.	Set iip to the virtual address of the next instruction
bundle.
+ *
+ *	7.	Do an rfi to move ipsr to psr and iip to ip.
  */
 
 #define VIRTUAL_MODE_ENTER(temp1, temp2, start_addr, old_psr)	\
@@ -156,6 +159,10 @@
 	mov	ar.rsc = 0;					\
 	;;							\
 	srlz.d;							\
+	mov	r13 = ar.k6;					\
+	;;							\
+	DATA_PA_TO_VA(r13,temp1);				\
+	;;							\
 	mov	temp2 = ar.bspstore;				\
 	;;							\
 	DATA_PA_TO_VA(temp2,temp1);				\
@@ -170,8 +177,6 @@
 	;;							\
 	mov	temp2 = 1;					\
 	;;							\
-	dep	temp1 = temp2, temp1, PSR_I,  1;		\
-	;;							\
 	dep	temp1 = temp2, temp1, PSR_IC, 1;		\
 	;;							\
 	dep	temp1 = temp2, temp1, PSR_IT, 1;		\
@@ -195,7 +200,7 @@
 	nop	1;						\
 	nop	2;						\
 	nop	1;						\
-	rfi;							\
+	rfi							\
 	;;
 
 /*
diff -urN ./linux-2.4.17/include/asm-ia64/sal.h
mca/linux-2.4.17/include/asm-ia64/sal.h
--- ./linux-2.4.17/include/asm-ia64/sal.h	Mon Jan 14 14:31:37 2002
+++ mca/linux-2.4.17/include/asm-ia64/sal.h	Tue Jan 15 11:23:26 2002
@@ -8,11 +8,14 @@
  * Abstraction Layer".
  *
  * Copyright (C) 2001 Intel
+ * Copyright (C) 2002 Jenna Hall <jenna.s.hall@intel.com>
  * Copyright (C) 2001 Fred Lewis <frederick.v.lewis@intel.com>
  * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
  * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Srinivasa Prasad Thirumalachar
<sprasad@sprasad.engr.sgi.com>
  *
+ * 02/01/04 J. Hall Updated Error Record Structures to conform to July 2001
+ *		    revision of the SAL spec.
  * 01/01/03 fvlewis Updated Error Record Structures to conform with Nov.
2000
  *                  revision of the SAL spec.
  * 99/09/29 davidm	Updated for SAL 2.6.
@@ -228,6 +231,10 @@
 	SAL_VECTOR_OS_BOOT_RENDEZ	= 2
 };
 
+/* Encodings for mca_opt parameter sent to SAL_MC_SET_PARAMS */
+#define	SAL_MC_PARAM_RZ_ALWAYS		0x1
+#define	SAL_MC_PARAM_BINIT_ESCALATE	0x10
+
 /*
 ** Definition of the SAL Error Log from the SAL spec
 */
@@ -516,12 +523,12 @@
     {
         u16 vendor_id;
         u16 device_id;
-        u16 class_code;
+	u8  class_code[3];
         u8  func_num;
         u8  dev_num;
         u8  bus_num;
         u8  seg_num;
-        u8  reserved[6];
+        u8  reserved[5];
     }               comp_info;
     u32             num_mem_regs;
     u32             num_io_regs;



-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Friday, January 11, 2002 1:33 PM
To: Mallick, Asit K
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] latest MCA logging patch

>>>>> On Fri, 11 Jan 2002 13:25:40 -0800, "Mallick, Asit K"
<asit.k.mallick@intel.com> said:

  Asit> David, SAL re-entrancy issue was primarily observed with
  Asit> SAL_PCI_READ/WRITE_CONFIG in very early firmwares and earlier
  Asit> kernels. However, this re-entrancy problem is fixed with the
  Asit> use of the pci_lock.

If the pci_lock is sufficient for SAL_PCI_READ/WRITE_CONFIG, we can
remove it for those two cases (with a comment to that effect).  I
don't really see much point in doing this though.  It's not like this
is a performance critical operation.

  Asit> Other SAL calls are used during the
  Asit> initialization time and should have re-entrancy
  Asit> problem. Anyway, Jenna is checking with FW team on re-entrancy
  Asit> and will provide the FW versions.

Will you check only for Intel firmware or all IA-64 firmware in
existence?  The original SAL spec did not require re-entrancy and I
don't think it's safe to remove the lock unless we know for sure that
all existing implementations have been fixed (or are no longer in
use).

        --david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


------_=_NextPart_000_01C19E15.00A80E00
Content-Type: application/octet-stream;
	name="mca_2417.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="mca_2417.diff"

diff -urN ./linux-2.4.17/arch/ia64/kernel/mca.c =
mca/linux-2.4.17/arch/ia64/kernel/mca.c=0A=
--- ./linux-2.4.17/arch/ia64/kernel/mca.c	Fri Nov  9 14:26:17 2001=0A=
+++ mca/linux-2.4.17/arch/ia64/kernel/mca.c	Thu Jan 10 14:38:50 2002=0A=
@@ -3,6 +3,9 @@=0A=
  * Purpose:	Generic MCA handling layer=0A=
  *=0A=
  * Updated for latest kernel=0A=
+ * Copyright (C) 2002 Intel=0A=
+ * Copyright (C) Jenna Hall (jenna.s.hall@intel.com)=0A=
+ *=0A=
  * Copyright (C) 2001 Intel=0A=
  * Copyright (C) Fred Lewis (frederick.v.lewis@intel.com)=0A=
  *=0A=
@@ -12,6 +15,11 @@=0A=
  * Copyright (C) 1999 Silicon Graphics, Inc.=0A=
  * Copyright (C) Vijay Chander(vijay@engr.sgi.com)=0A=
  *=0A=
+ * 02/01/04 J. Hall	Aligned MCA stack to 16 bytes, added platform vs. =
CPU=0A=
+ *			error flag, set SAL default return values, changed=0A=
+ *			error record structure to linked list, added init call=0A=
+ *			to sal_get_state_info_size().=0A=
+ *=0A=
  * 01/01/03 F. Lewis    Added setup of CMCI and CPEI IRQs, logging of =
corrected=0A=
  *                      platform errors, completed code for logging =
of=0A=
  *                      corrected & uncorrected machine check errors, =
and=0A=
@@ -27,6 +35,7 @@=0A=
 #include <linux/interrupt.h>=0A=
 #include <linux/irq.h>=0A=
 #include <linux/smp_lock.h>=0A=
+#include <linux/bootmem.h>=0A=
 =0A=
 #include <asm/machvec.h>=0A=
 #include <asm/page.h>=0A=
@@ -50,18 +59,22 @@=0A=
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;=0A=
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;=0A=
 u64				ia64_mca_proc_state_dump[512];=0A=
-u64				ia64_mca_stack[1024];=0A=
+u64				ia64_mca_stack[1024] __attribute__((aligned(16)));=0A=
 u64				ia64_mca_stackframe[32];=0A=
 u64				ia64_mca_bspstore[1024];=0A=
 u64				ia64_init_stack[INIT_TASK_SIZE] =
__attribute__((aligned(16)));=0A=
+u64				ia64_mca_sal_data_area[1356];=0A=
+u64				ia64_mca_min_state_save_info;=0A=
+u64				ia64_tlb_functional;=0A=
+u64				ia64_os_mca_recovery_successful;=0A=
 =0A=
 static void			ia64_mca_wakeup_ipi_wait(void);=0A=
 static void			ia64_mca_wakeup(int cpu);=0A=
 static void			ia64_mca_wakeup_all(void);=0A=
 static void			ia64_log_init(int);=0A=
-extern void		        ia64_monarch_init_handler (void);=0A=
-extern void		        ia64_slave_init_handler (void);=0A=
-extern struct hw_interrupt_type irq_type_iosapic_level;=0A=
+extern void			ia64_monarch_init_handler (void);=0A=
+extern void			ia64_slave_init_handler (void);=0A=
+extern struct hw_interrupt_type	irq_type_iosapic_level;=0A=
 =0A=
 static struct irqaction cmci_irqaction =3D {=0A=
 	handler:    ia64_mca_cmc_int_handler,=0A=
@@ -95,25 +108,31 @@=0A=
  *  memory.=0A=
  *=0A=
  *  Inputs  :   sal_info_type   (Type of error record =
MCA/CMC/CPE/INIT)=0A=
- *  Outputs :   None=0A=
+ *  Outputs :   platform error status=0A=
  */=0A=
-void=0A=
+int=0A=
 ia64_mca_log_sal_error_record(int sal_info_type)=0A=
 {=0A=
+	int platform_err =3D 0;=0A=
+=0A=
 	/* Get the MCA error record */=0A=
 	if (!ia64_log_get(sal_info_type, (prfunc_t)printk))=0A=
-		return;                 // no record retrieved=0A=
+		return platform_err;                 // no record retrieved=0A=
 =0A=
-	/* Log the error record */=0A=
-	ia64_log_print(sal_info_type, (prfunc_t)printk);=0A=
+	/* TODO:=0A=
+	 * 1. analyze error logs to determine recoverability=0A=
+	 * 2. perform error recovery procedures, if applicable=0A=
+	 * 3. set ia64_os_mca_recovery_successful flag, if applicable=0A=
+	 */=0A=
 =0A=
-	/* Clear the CMC SAL logs now that they have been logged */=0A=
+	platform_err =3D ia64_log_print(sal_info_type, (prfunc_t)printk);=0A=
 	ia64_sal_clear_state_info(sal_info_type);=0A=
+=0A=
+	return platform_err;=0A=
 }=0A=
 =0A=
 /*=0A=
- * hack for now, add platform dependent handlers=0A=
- * here=0A=
+ * platform dependent error handling=0A=
  */=0A=
 #ifndef PLATFORM_MCA_HANDLERS=0A=
 void=0A=
@@ -275,8 +294,8 @@=0A=
 	cmcv_reg_t	cmcv;=0A=
 =0A=
 	cmcv.cmcv_regval	=3D 0;=0A=
-	cmcv.cmcv_mask      =3D 0;        /* Unmask/enable interrupt */=0A=
-	cmcv.cmcv_vector    =3D IA64_CMC_VECTOR;=0A=
+	cmcv.cmcv_mask		=3D 0;        /* Unmask/enable interrupt */=0A=
+	cmcv.cmcv_vector	=3D IA64_CMC_VECTOR;=0A=
 	ia64_set_cmcv(cmcv.cmcv_regval);=0A=
 =0A=
 	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d corrected "=0A=
@@ -374,6 +393,9 @@=0A=
 =0A=
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");=0A=
 =0A=
+	/* initialize recovery success indicator */=0A=
+	ia64_os_mca_recovery_successful =3D 0;=0A=
+=0A=
 	/* Clear the Rendez checkin flag for all cpus */=0A=
 	for(i =3D 0 ; i < NR_CPUS; i++)=0A=
 		ia64_mc_info.imi_rendez_checkin[i] =3D =
IA64_MCA_RENDEZ_CHECKIN_NOTDONE;=0A=
@@ -459,7 +481,7 @@=0A=
 =0A=
 	/*=0A=
 	 *  Configure the CMCI vector and handler. Interrupts for CMC are=0A=
-	 *  per-processor, so AP CMC interrupts are setup in smp_callin() =
(smp.c).=0A=
+	 *  per-processor, so AP CMC interrupts are setup in smp_callin() =
(smpboot.c).=0A=
 	 */=0A=
 	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);=0A=
 	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP & enable =
*/=0A=
@@ -498,6 +520,9 @@=0A=
 	ia64_log_init(SAL_INFO_TYPE_CMC);=0A=
 	ia64_log_init(SAL_INFO_TYPE_CPE);=0A=
 =0A=
+	/* Zero the min state save info */=0A=
+	ia64_mca_min_state_save_info =3D 0;=0A=
+=0A=
 #if defined(MCA_TEST)=0A=
 	mca_test();=0A=
 #endif /* #if defined(MCA_TEST) */=0A=
@@ -576,7 +601,7 @@=0A=
 	int cpu;=0A=
 =0A=
 	/* Clear the Rendez checkin flag for all cpus */=0A=
-	for(cpu =3D 0 ; cpu < smp_num_cpus; cpu++)=0A=
+	for(cpu =3D 0; cpu < smp_num_cpus; cpu++)=0A=
 		if (ia64_mc_info.imi_rendez_checkin[cpu] =3D=3D =
IA64_MCA_RENDEZ_CHECKIN_DONE)=0A=
 			ia64_mca_wakeup(cpu);=0A=
 =0A=
@@ -668,6 +693,13 @@=0A=
 =0A=
 	/* Cold Boot for uncorrectable MCA */=0A=
 	ia64_os_to_sal_handoff_state.imots_os_status =3D =
IA64_MCA_COLD_BOOT;=0A=
+=0A=
+	/* Default =3D tell SAL to return to same context */=0A=
+	ia64_os_to_sal_handoff_state.imots_context =3D =
IA64_MCA_SAME_CONTEXT;=0A=
+=0A=
+	/* Register pointer to new min state values */=0A=
+	/* NOTE: need to do something with this during recovery phase */=0A=
+	ia64_os_to_sal_handoff_state.imots_new_min_state =3D =
&ia64_mca_min_state_save_info;=0A=
 }=0A=
 =0A=
 /*=0A=
@@ -678,10 +710,10 @@=0A=
  *	This is the place where the core of OS MCA handling is done.=0A=
  *	Right now the logs are extracted and displayed in a well-defined=0A=
  *	format. This handler code is supposed to be run only on the=0A=
- *	monarch processor. Once the  monarch is done with MCA handling=0A=
+ *	monarch processor. Once the monarch is done with MCA handling=0A=
  *	further MCA logging is enabled by clearing logs.=0A=
  *	Monarch also has the duty of sending wakeup-IPIs to pull the=0A=
- *  slave processors out of rendezvous spinloop.=0A=
+ *	slave processors out of rendezvous spinloop.=0A=
  *=0A=
  *  Inputs  :   None=0A=
  *  Outputs :   None=0A=
@@ -689,20 +721,16 @@=0A=
 void=0A=
 ia64_mca_ucmc_handler(void)=0A=
 {=0A=
-#if 0   /* stubbed out @FVL */=0A=
-	/*=0A=
-	 *  Attempting to log a DBE error Causes "reserved register/field =
panic"=0A=
-	 *  in printk.=0A=
-	 */=0A=
+	int platform_err =3D 0;=0A=
 =0A=
 	/* Get the MCA error record and log it */=0A=
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);=0A=
-#endif  /* stubbed out @FVL */=0A=
+	platform_err =3D ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);=0A=
 =0A=
 	/*=0A=
 	 *  Do Platform-specific mca error handling if required.=0A=
 	 */=0A=
-	mca_handler_platform() ;=0A=
+	if (platform_err)=0A=
+		mca_handler_platform();=0A=
 =0A=
 	/*=0A=
 	 *  Wakeup all the processors which are spinning in the rendezvous=0A=
@@ -749,13 +777,16 @@=0A=
 {=0A=
 	spinlock_t	isl_lock;=0A=
 	int		isl_index;=0A=
-	ia64_err_rec_t  isl_log[IA64_MAX_LOGS]; /* need space to store header =
+ error log */=0A=
+	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store =
header + error log */=0A=
 } ia64_state_log_t;=0A=
 =0A=
 static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];=0A=
 =0A=
-/* Note:  Some of these macros assume IA64_MAX_LOGS is always 2.  =
Should be */=0A=
-/* fixed. @FVL                                                         =
     */=0A=
+#define IA64_LOG_ALLOCATE(it, size) \=0A=
+	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] =3D \=0A=
+		(ia64_err_rec_t *)alloc_bootmem(size); \=0A=
+	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] =3D \=0A=
+		(ia64_err_rec_t *)alloc_bootmem(size);}=0A=
 #define IA64_LOG_LOCK_INIT(it) =
spin_lock_init(&ia64_state_log[it].isl_lock)=0A=
 #define IA64_LOG_LOCK(it)      =
spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)=0A=
 #define IA64_LOG_UNLOCK(it)    =
spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)=0A=
@@ -765,13 +796,13 @@=0A=
     ia64_state_log[it].isl_index =3D 1 - =
ia64_state_log[it].isl_index=0A=
 #define IA64_LOG_INDEX_DEC(it) \=0A=
     ia64_state_log[it].isl_index =3D 1 - =
ia64_state_log[it].isl_index=0A=
-#define IA64_LOG_NEXT_BUFFER(it)   (void =
*)(&(ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)]))=0A=
-#define IA64_LOG_CURR_BUFFER(it)   (void =
*)(&(ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))=0A=
+#define IA64_LOG_NEXT_BUFFER(it)   (void =
*)((ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)]))=0A=
+#define IA64_LOG_CURR_BUFFER(it)   (void =
*)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))=0A=
 =0A=
 /*=0A=
  * C portion of the OS INIT handler=0A=
  *=0A=
- * Called from ia64_<monarch/slave>_init_handler=0A=
+ * Called from ia64_monarch_init_handler=0A=
  *=0A=
  * Inputs: pointer to pt_regs where processor info was saved.=0A=
  *=0A=
@@ -885,10 +916,18 @@=0A=
 void=0A=
 ia64_log_init(int sal_info_type)=0A=
 {=0A=
-	IA64_LOG_LOCK_INIT(sal_info_type);=0A=
+	u64	max_size =3D 0;=0A=
+=0A=
 	IA64_LOG_NEXT_INDEX(sal_info_type) =3D 0;=0A=
-	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0,=0A=
-	       sizeof(ia64_err_rec_t) * IA64_MAX_LOGS);=0A=
+	IA64_LOG_LOCK_INIT(sal_info_type);=0A=
+=0A=
+	// SAL will tell us the maximum size of any error record of this =
type=0A=
+	max_size =3D ia64_sal_get_state_info_size(sal_info_type);=0A=
+=0A=
+	// set up OS data structures to hold error info=0A=
+	IA64_LOG_ALLOCATE(sal_info_type, max_size);=0A=
+	memset(IA64_LOG_CURR_BUFFER(sal_info_type), 0, max_size);=0A=
+	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0, max_size);=0A=
 }=0A=
 =0A=
 /*=0A=
@@ -923,8 +962,7 @@=0A=
 		return total_len;=0A=
 	} else {=0A=
 		IA64_LOG_UNLOCK(sal_info_type);=0A=
-		prfunc("ia64_log_get: Failed to retrieve SAL error record type =
%d\n",=0A=
-		       sal_info_type);=0A=
+		prfunc("ia64_log_get: No SAL error record available for type %d\n", =
sal_info_type);=0A=
 		return 0;=0A=
 	}=0A=
 }=0A=
@@ -1268,7 +1306,7 @@=0A=
 	}=0A=
 =0A=
 	if (mdei->valid.oem_data) {=0A=
-		ia64_log_prt_oem_data((int)mdei->header.len,=0A=
+		platform_mem_dev_err_print((int)mdei->header.len,=0A=
 				      (int)sizeof(sal_log_mem_dev_err_info_t) - 1,=0A=
 				      &(mdei->oem_data[0]), prfunc);=0A=
 	}=0A=
@@ -1357,7 +1395,7 @@=0A=
 		prfunc("\n");=0A=
 =0A=
 	if (pbei->valid.oem_data) {=0A=
-		ia64_log_prt_oem_data((int)pbei->header.len,=0A=
+		platform_pci_bus_err_print((int)pbei->header.len,=0A=
 				      (int)sizeof(sal_log_pci_bus_err_info_t) - 1,=0A=
 				      &(pbei->oem_data[0]), prfunc);=0A=
 	}=0A=
@@ -1456,7 +1494,7 @@=0A=
 		}=0A=
 	}=0A=
 	if (pcei->valid.oem_data) {=0A=
-		ia64_log_prt_oem_data((int)pcei->header.len, n_pci_data,=0A=
+		platform_pci_comp_err_print((int)pcei->header.len, n_pci_data,=0A=
 				      p_oem_data, prfunc);=0A=
 		prfunc("\n");=0A=
 	}=0A=
@@ -1485,7 +1523,7 @@=0A=
 		ia64_log_prt_guid(&psei->guid, prfunc);=0A=
 	}=0A=
 	if (psei->valid.oem_data) {=0A=
-		ia64_log_prt_oem_data((int)psei->header.len,=0A=
+		platform_plat_specific_err_print((int)psei->header.len,=0A=
 				      (int)sizeof(sal_log_plat_specific_err_info_t) - 1,=0A=
 				      &(psei->oem_data[0]), prfunc);=0A=
 	}=0A=
@@ -1519,7 +1557,7 @@=0A=
 	if (hcei->valid.bus_spec_data)=0A=
 		prfunc(" Bus Specific Data: %#lx", hcei->bus_spec_data);=0A=
 	if (hcei->valid.oem_data) {=0A=
-		ia64_log_prt_oem_data((int)hcei->header.len,=0A=
+		platform_host_ctlr_err_print((int)hcei->header.len,=0A=
 				      (int)sizeof(sal_log_host_ctlr_err_info_t) - 1,=0A=
 				      &(hcei->oem_data[0]), prfunc);=0A=
 	}=0A=
@@ -1553,7 +1591,7 @@=0A=
 	if (pbei->valid.bus_spec_data)=0A=
 		prfunc(" Bus Specific Data: %#lx", pbei->bus_spec_data);=0A=
 	if (pbei->valid.oem_data) {=0A=
-		ia64_log_prt_oem_data((int)pbei->header.len,=0A=
+		platform_plat_bus_err_print((int)pbei->header.len,=0A=
 				      (int)sizeof(sal_log_plat_bus_err_info_t) - 1,=0A=
 				      &(pbei->oem_data[0]), prfunc);=0A=
 	}=0A=
@@ -1745,17 +1783,18 @@=0A=
  *  Inputs  :   lh      (Pointer to the sal error record header with =
format=0A=
  *                       specified by the SAL spec).=0A=
  *              prfunc  (fn ptr of log output function to use)=0A=
- *  Outputs :   None=0A=
+ *  Outputs :	platform error status=0A=
  */=0A=
-void=0A=
+int=0A=
 ia64_log_platform_info_print (sal_log_record_header_t *lh, prfunc_t =
prfunc)=0A=
 {=0A=
-	sal_log_section_hdr_t       *slsh;=0A=
-	int                         n_sects;=0A=
-	int                         ercd_pos;=0A=
+	sal_log_section_hdr_t	*slsh;=0A=
+	int			n_sects;=0A=
+	int			ercd_pos;=0A=
+	int			platform_err =3D 0;=0A=
 =0A=
 	if (!lh)=0A=
-		return;=0A=
+		return platform_err;=0A=
 =0A=
 #ifdef MCA_PRT_XTRA_DATA    // for test only @FVL=0A=
 	ia64_log_prt_record_header(lh, prfunc);=0A=
@@ -1765,7 +1804,7 @@=0A=
 		IA64_MCA_DEBUG("ia64_mca_log_print: "=0A=
 			       "truncated SAL error record. len =3D %d\n",=0A=
 			       lh->len);=0A=
-		return;=0A=
+		return platform_err;=0A=
 	}=0A=
 =0A=
 	/* Print record header info */=0A=
@@ -1796,35 +1835,43 @@=0A=
 			ia64_log_proc_dev_err_info_print((sal_log_processor_info_t =
*)slsh,=0A=
 							 prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) =
=3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform Memory Device Error Info Section\n");=0A=
 			ia64_log_mem_dev_err_info_print((sal_log_mem_dev_err_info_t =
*)slsh,=0A=
 							prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID) =
=3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform SEL Device Error Info Section\n");=0A=
 			ia64_log_sel_dev_err_info_print((sal_log_sel_dev_err_info_t =
*)slsh,=0A=
 							prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID) =
=3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform PCI Bus Error Info Section\n");=0A=
 			ia64_log_pci_bus_err_info_print((sal_log_pci_bus_err_info_t =
*)slsh,=0A=
 							prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, =
SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID) =3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform SMBIOS Device Error Info Section\n");=0A=
 			ia64_log_smbios_dev_err_info_print((sal_log_smbios_dev_err_info_t =
*)slsh,=0A=
 							   prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID) =
=3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform PCI Component Error Info Section\n");=0A=
 			ia64_log_pci_comp_err_info_print((sal_log_pci_comp_err_info_t =
*)slsh,=0A=
 							 prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) =
=3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform Specific Error Info Section\n");=0A=
 			=
ia64_log_plat_specific_err_info_print((sal_log_plat_specific_err_info_t =
*)=0A=
 							      slsh,=0A=
 							      prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID) =
=3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform Host Controller Error Info Section\n");=0A=
 			ia64_log_host_ctlr_err_info_print((sal_log_host_ctlr_err_info_t =
*)slsh,=0A=
 							  prfunc);=0A=
 		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_BUS_ERR_SECT_GUID) =
=3D=3D 0) {=0A=
+			platform_err =3D 1;=0A=
 			prfunc("+Platform Bus Error Info Section\n");=0A=
 			ia64_log_plat_bus_err_info_print((sal_log_plat_bus_err_info_t =
*)slsh,=0A=
 							 prfunc);=0A=
@@ -1838,8 +1885,9 @@=0A=
 		       n_sects, lh->len);=0A=
 	if (!n_sects) {=0A=
 		prfunc("No Platform Error Info Sections found\n");=0A=
-		return;=0A=
+		return platform_err;=0A=
 	}=0A=
+	return platform_err;=0A=
 }=0A=
 =0A=
 /*=0A=
@@ -1849,15 +1897,17 @@=0A=
  *=0A=
  *  Inputs   :  info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})=0A=
  *              prfunc      (fn ptr of log output function to use)=0A=
- * Outputs	:	None=0A=
+ * Outputs	:	platform error status=0A=
  */=0A=
-void=0A=
+int=0A=
 ia64_log_print(int sal_info_type, prfunc_t prfunc)=0A=
 {=0A=
+	int platform_err =3D 0;=0A=
+=0A=
 	switch(sal_info_type) {=0A=
 	      case SAL_INFO_TYPE_MCA:=0A=
 		prfunc("+BEGIN HARDWARE ERROR STATE AT MCA\n");=0A=
-		ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type), =
prfunc);=0A=
+		platform_err =3D =
ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type), =
prfunc);=0A=
 		prfunc("+END HARDWARE ERROR STATE AT MCA\n");=0A=
 		break;=0A=
 	      case SAL_INFO_TYPE_INIT:=0A=
@@ -1877,4 +1927,5 @@=0A=
 		prfunc("+MCA UNKNOWN ERROR LOG (UNIMPLEMENTED)\n");=0A=
 		break;=0A=
 	}=0A=
+	return platform_err;=0A=
 }=0A=
diff -urN ./linux-2.4.17/arch/ia64/kernel/mca_asm.S =
mca/linux-2.4.17/arch/ia64/kernel/mca_asm.S=0A=
--- ./linux-2.4.17/arch/ia64/kernel/mca_asm.S	Fri Nov  9 14:26:17 =
2001=0A=
+++ mca/linux-2.4.17/arch/ia64/kernel/mca_asm.S	Fri Jan  4 18:19:27 =
2002=0A=
@@ -7,6 +7,12 @@=0A=
 // 00/03/29 cfleck Added code to save INIT handoff state in pt_regs =
format, switch to temp=0A=
 //		   kstack, switch modes, jump to C INIT handler=0A=
 //=0A=
+// 02/01/04 J.Hall <jenna.s.hall@intel.com>=0A=
+//		   Before entering virtual mode code:=0A=
+//		   1. Check for TLB CPU error=0A=
+//		   2. Restore current thread pointer to kr6=0A=
+//		   3. Move stack ptr 16 bytes to conform to C calling =
convention=0A=
+//=0A=
 #include <linux/config.h>=0A=
 =0A=
 #include <asm/asmmacro.h>=0A=
@@ -21,10 +27,21 @@=0A=
  */=0A=
 #define	MINSTATE_PHYS	/* Make sure stack access is physical for =
MINSTATE */=0A=
 =0A=
+/*=0A=
+ * Needed for ia64_sal call=0A=
+ */=0A=
+#define SAL_GET_STATE_INFO      0x01000001=0A=
+=0A=
+/*=0A=
+ * Needed for return context to SAL=0A=
+ */=0A=
+#define IA64_MCA_SAME_CONTEXT	0x0=0A=
+#define IA64_MCA_COLD_BOOT	-2=0A=
+=0A=
 #include "minstate.h"=0A=
 =0A=
 /*=0A=
- *  SAL_TO_OS_MCA_HANDOFF_STATE (SAL 3.0 spec)=0A=
+ * SAL_TO_OS_MCA_HANDOFF_STATE (SAL 3.0 spec)=0A=
  *		1. GR1 =3D OS GP=0A=
  *		2. GR8 =3D PAL_PROC physical address=0A=
  *		3. GR9 =3D SAL_PROC physical address=0A=
@@ -40,26 +57,34 @@=0A=
 	st8	[_tmp]=3Dr9,0x08;;			\=0A=
 	st8	[_tmp]=3Dr10,0x08;;			\=0A=
 	st8	[_tmp]=3Dr11,0x08;;			\=0A=
-	st8	[_tmp]=3Dr12,0x08;;=0A=
+	st8	[_tmp]=3Dr12,0x08=0A=
 =0A=
 /*=0A=
- *  OS_MCA_TO_SAL_HANDOFF_STATE (SAL 3.0 spec)=0A=
- *      1. GR8 =3D OS_MCA return status=0A=
+ * OS_MCA_TO_SAL_HANDOFF_STATE (SAL 3.0 spec)=0A=
+ * (p6) is executed if we never entered virtual mode (TLB error)=0A=
+ * (p7) is executed if we entered virtual mode as expected (normal =
case)=0A=
+ *	1. GR8 =3D OS_MCA return status=0A=
  *	2. GR9 =3D SAL GP (physical)=0A=
- *      3. GR10 =3D 0/1 returning same/new context=0A=
- *      4. GR22 =3D New min state save area pointer=0A=
- *      returns ptr to SAL rtn save loc in _tmp=0A=
+ *	3. GR10 =3D 0/1 returning same/new context=0A=
+ *	4. GR22 =3D New min state save area pointer=0A=
+ *	returns ptr to SAL rtn save loc in _tmp=0A=
  */=0A=
-#define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)				\=0A=
-	movl	_tmp=3Dia64_os_to_sal_handoff_state;;				\=0A=
-	DATA_VA_TO_PA(_tmp);;							\=0A=
-	ld8	r8=3D[_tmp],0x08;;						\=0A=
-	ld8	r9=3D[_tmp],0x08;;						\=0A=
-	ld8     r10=3D[_tmp],0x08;;						\=0A=
-	ld8     r22=3D[_tmp],0x08;;						\=0A=
-	movl    _tmp=3Dia64_sal_to_os_handoff_state;;				\=0A=
-	DATA_VA_TO_PA(_tmp);;							\=0A=
-	add     _tmp=3D0x28,_tmp;;            // point to SAL rtn save =
location=0A=
+#define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)	\=0A=
+(p6)	movl	_tmp=3Dia64_sal_to_os_handoff_state;;	\=0A=
+(p7)	movl	_tmp=3Dia64_os_to_sal_handoff_state;;	\=0A=
+	DATA_VA_TO_PA(_tmp);;				\=0A=
+(p6)	movl	r8=3DIA64_MCA_COLD_BOOT;			\=0A=
+(p6)	movl	r10=3DIA64_MCA_SAME_CONTEXT;		\=0A=
+(p6)	add     _tmp=3D0x18,_tmp;;			\=0A=
+(p6)	ld8	r9=3D[_tmp],0x10;				\=0A=
+(p6)	movl	r22=3Dia64_mca_min_state_save_info;;	\=0A=
+(p7)	ld8	r8=3D[_tmp],0x08;;			\=0A=
+(p7)	ld8	r9=3D[_tmp],0x08;;			\=0A=
+(p7)	ld8     r10=3D[_tmp],0x08;;			\=0A=
+(p7)	ld8     r22=3D[_tmp],0x08;;			\=0A=
+	DATA_VA_TO_PA(r22)=0A=
+	// now _tmp is pointing to SAL rtn save location=0A=
+=0A=
 =0A=
 	.global ia64_os_mca_dispatch=0A=
 	.global ia64_os_mca_dispatch_end=0A=
@@ -70,6 +95,9 @@=0A=
 	.global	ia64_mca_stackframe=0A=
 	.global	ia64_mca_bspstore=0A=
 	.global ia64_init_stack=0A=
+	.global ia64_mca_sal_data_area=0A=
+	.global ia64_tlb_functional=0A=
+	.global ia64_mca_min_state_save_info=0A=
 =0A=
 	.text=0A=
 	.align 16=0A=
@@ -90,26 +118,34 @@=0A=
 	//	  for ia64_mca_sal_to_os_state_t has been=0A=
 	//	  defined in include/asm/mca.h=0A=
 	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)=0A=
+	;;=0A=
 =0A=
 	// LOG PROCESSOR STATE INFO FROM HERE ON..=0A=
-	;;=0A=
 begin_os_mca_dump:=0A=
 	br	ia64_os_mca_proc_state_dump;;=0A=
 =0A=
 ia64_os_mca_done_dump:=0A=
 =0A=
 	// Setup new stack frame for OS_MCA handling=0A=
-	movl    r2=3Dia64_mca_bspstore;;      // local bspstore area location =
in r2=0A=
+	movl	r2=3Dia64_mca_bspstore;;	// local bspstore area location in =
r2=0A=
 	DATA_VA_TO_PA(r2);;=0A=
-	movl    r3=3Dia64_mca_stackframe;;    // save stack frame to memory =
in r3=0A=
+	movl	r3=3Dia64_mca_stackframe;; // save stack frame to memory in =
r3=0A=
 	DATA_VA_TO_PA(r3);;=0A=
-	rse_switch_context(r6,r3,r2);;                  // RSC management in =
this new context=0A=
-	movl        r12=3Dia64_mca_stack;;=0A=
-	mov     r2=3D8*1024;;                 // stack size must be same as c =
array=0A=
-	add     r12=3Dr2,r12;;                // stack base @ bottom of =
array=0A=
+	rse_switch_context(r6,r3,r2);;	// RSC management in this new =
context=0A=
+	movl	r12=3Dia64_mca_stack=0A=
+	mov	r2=3D8*1024;;		// stack size must be same as C array=0A=
+	add	r12=3Dr2,r12;;		// stack base @ bottom of array=0A=
+	adds	r12=3D-16,r12;;		// allow 16 bytes of scratch=0A=
+					// (C calling convention)=0A=
 	DATA_VA_TO_PA(r12);;=0A=
 =0A=
-	// Enter virtual mode from physical mode=0A=
+	// Check to see if the MCA resulted from a TLB error=0A=
+begin_tlb_error_check:=0A=
+        br      ia64_os_mca_tlb_error_check;;=0A=
+=0A=
+done_tlb_error_check:=0A=
+=0A=
+        // If TLB is functional, enter virtual mode from physical =
mode=0A=
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)=0A=
 ia64_os_mca_virtual_begin:=0A=
 =0A=
@@ -130,25 +166,28 @@=0A=
 #endif	/* #if defined(MCA_TEST) */=0A=
 =0A=
 	// restore the original stack frame here=0A=
-	movl    r2=3Dia64_mca_stackframe               // restore stack frame =
from memory at r2=0A=
+	movl    r2=3Dia64_mca_stackframe	// restore stack frame from memory =
at r2=0A=
 	;;=0A=
 	DATA_VA_TO_PA(r2)=0A=
 	movl    r4=3DIA64_PSR_MC=0A=
 	;;=0A=
-	rse_return_context(r4,r3,r2)                 // switch from interrupt =
context for RSE=0A=
+	rse_return_context(r4,r3,r2)	// switch from interrupt context for =
RSE=0A=
 =0A=
 	// let us restore all the registers from our PSI structure=0A=
-	mov		r8=3Dgp=0A=
+	mov	r8=3Dgp=0A=
 	;;=0A=
 begin_os_mca_restore:=0A=
 	br	ia64_os_mca_proc_state_restore;;=0A=
 =0A=
 ia64_os_mca_done_restore:=0A=
-	;;=0A=
+	movl	r3=3Dia64_tlb_functional;;=0A=
+	DATA_VA_TO_PA(r3);;=0A=
+	ld8	r3=3D[r3];;=0A=
+	cmp.eq	p6,p7=3Dr0,r3;;=0A=
+	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2);;=0A=
 	// branch back to SALE_CHECK=0A=
-	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2)=0A=
 	ld8		r3=3D[r2];;=0A=
-	mov		b0=3Dr3;;			      // SAL_CHECK return address=0A=
+	mov		b0=3Dr3;;		// SAL_CHECK return address=0A=
 	br		b0=0A=
 	;;=0A=
 ia64_os_mca_dispatch_end:=0A=
@@ -405,7 +444,7 @@=0A=
 	movl		r2=3Dia64_mca_proc_state_dump	// Convert virtual address=0A=
 	;;						// of OS state dump area=0A=
 	DATA_VA_TO_PA(r2)				// to physical address=0A=
-	;;=0A=
+=0A=
 restore_GRs:                                    // restore bank-1 GRs =
16-31=0A=
 	bsw.1;;=0A=
 	add		r3=3D16*8,r2;;                // to get to NaT of GR 16-31=0A=
@@ -621,6 +660,80 @@=0A=
 =0A=
 =
//EndStub///////////////////////////////////////////////////////////////=
///////=0A=
 =0A=
+//++=0A=
+// Name:=0A=
+//	ia64_os_mca_tlb_error_check()=0A=
+//=0A=
+// Stub Description:=0A=
+//=0A=
+//	This stub checks to see if the MCA resulted from a TLB error=0A=
+//=0A=
+//--=0A=
+=0A=
+ia64_os_mca_tlb_error_check:=0A=
+=0A=
+	// Retrieve sal data structure for uncorrected MCA=0A=
+=0A=
+	// Make the ia64_sal_get_state_info() call=0A=
+	movl	r4=3Dia64_mca_sal_data_area;;=0A=
+	movl	r7=3Dia64_sal;;=0A=
+	mov	r6=3Dr1			// save gp=0A=
+	DATA_VA_TO_PA(r4)		// convert to physical address=0A=
+	DATA_VA_TO_PA(r7);;		// convert to physical address=0A=
+	ld8	r7=3D[r7]			// get addr of pdesc from ia64_sal=0A=
+	movl	r3=3DSAL_GET_STATE_INFO;;=0A=
+	DATA_VA_TO_PA(r7);;		// convert to physical address=0A=
+	ld8	r8=3D[r7],8;;		// get pdesc function pointer=0A=
+	DATA_VA_TO_PA(r8)		// convert to physical address=0A=
+	ld8	r1=3D[r7];;		// set new (ia64_sal) gp=0A=
+	DATA_VA_TO_PA(r1)		// convert to physical address=0A=
+	mov	b6=3Dr8=0A=
+=0A=
+	alloc	r5=3Dar.pfs,8,0,8,0;;	// allocate stack frame for SAL call=0A=
+	mov	out0=3Dr3			// which SAL proc to call=0A=
+	mov	out1=3Dr0			// error type =3D=3D MCA=0A=
+	mov	out2=3Dr0			// null arg=0A=
+	mov	out3=3Dr4			// data copy area=0A=
+	mov	out4=3Dr0			// null arg=0A=
+	mov	out5=3Dr0			// null arg=0A=
+	mov	out6=3Dr0			// null arg=0A=
+	mov	out7=3Dr0;;		// null arg=0A=
+=0A=
+	br.call.sptk.few	b0=3Db6;;=0A=
+=0A=
+	mov	r1=3Dr6			// restore gp=0A=
+	mov	ar.pfs=3Dr5;;		// restore ar.pfs=0A=
+=0A=
+	movl	r6=3Dia64_tlb_functional;;=0A=
+	DATA_VA_TO_PA(r6)		// needed later=0A=
+=0A=
+	cmp.eq	p6,p7=3Dr0,r8;;		// check SAL call return address=0A=
+(p7)	st8	[r6]=3Dr0			// clear tlb_functional flag=0A=
+(p7)    br	tlb_failure		// error; return to SAL=0A=
+=0A=
+	// examine processor error log for type of error=0A=
+	add	r4=3D40+24,r4;;		// parse past record header (length=3D40)=0A=
+					// and section header (length=3D24)=0A=
+	ld4	r4=3D[r4]			// get valid field of processor log=0A=
+	mov	r5=3D0xf00;;=0A=
+	and	r5=3Dr4,r5;;		// read bits 8-11 of valid field=0A=
+					// to determine if we have a TLB error=0A=
+	movl	r3=3D0x1=0A=
+	cmp.eq	p6,p7=3Dr0,r5;;=0A=
+	// if no TLB failure, set tlb_functional flag=0A=
+(p6)	st8	[r6]=3Dr3=0A=
+	// else clear flag=0A=
+(p7)	st8	[r6]=3Dr0=0A=
+=0A=
+	// if no TLB failure, continue with normal virtual mode logging=0A=
+(p6)    br	done_tlb_error_check=0A=
+	// else no point in entering virtual mode for logging=0A=
+tlb_failure:=0A=
+	br      ia64_os_mca_virtual_end=0A=
+=0A=
+//EndStub//////////////////////////////////////////////////////////////=
////////=0A=
+=0A=
+=0A=
 // ok, the issue here is that we need to save state information so=0A=
 // it can be useable by the kernel debugger and show regs routines.=0A=
 // In order to do this, our best bet is save the current state =
(plus=0A=
@@ -633,7 +746,7 @@=0A=
 // This has been defined for registration purposes with SAL=0A=
 // as a part of ia64_mca_init.=0A=
 //=0A=
-// When we get here, the follow registers have been=0A=
+// When we get here, the following registers have been=0A=
 // set by the SAL for our use=0A=
 //=0A=
 //		1. GR1 =3D OS INIT GP=0A=
@@ -649,42 +762,10 @@=0A=
 =0A=
 =0A=
 GLOBAL_ENTRY(ia64_monarch_init_handler)=0A=
-#if defined(CONFIG_SMP) && defined(SAL_MPINIT_WORKAROUND)=0A=
-	//=0A=
-	// work around SAL bug that sends all processors to monarch entry=0A=
-	//=0A=
-	mov	r17=3Dcr.lid=0A=
-	// XXX fix me: this is wrong: hard_smp_processor_id() is a pair of =
lid/eid=0A=
-	movl	r18=3Dia64_cpu_to_sapicid=0A=
-	;;=0A=
-	dep	r18=3D0,r18,61,3		// convert to physical address=0A=
-	;;=0A=
-	shr.u	r17=3Dr17,16=0A=
-	ld4	r18=3D[r18]		// get the BSP ID=0A=
-	;;=0A=
-	dep	r17=3D0,r17,16,48=0A=
-	;;=0A=
-	cmp4.ne	p6,p0=3Dr17,r18		// Am I the BSP ?=0A=
-(p6)	br.cond.spnt slave_init_spin_me=0A=
-	;;=0A=
-#endif=0A=
-=0A=
 =0A=
-//=0A=
-// ok, the first thing we do is stash the information=0A=
-// the SAL passed to os=0A=
-//=0A=
-_tmp =3D r2=0A=
-	movl	_tmp=3Dia64_sal_to_os_handoff_state=0A=
-	;;=0A=
-	dep	_tmp=3D0,_tmp, 61, 3	// get physical address=0A=
+	// stash the information the SAL passed to os=0A=
+	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)=0A=
 	;;=0A=
-	st8	[_tmp]=3Dr1,0x08;;=0A=
-	st8	[_tmp]=3Dr8,0x08;;=0A=
-	st8	[_tmp]=3Dr9,0x08;;=0A=
-	st8	[_tmp]=3Dr10,0x08;;=0A=
-	st8	[_tmp]=3Dr11,0x08;;=0A=
-	st8	[_tmp]=3Dr12,0x08;;=0A=
 =0A=
 // now we want to save information so we can dump registers=0A=
 	SAVE_MIN_WITH_COVER=0A=
@@ -695,12 +776,10 @@=0A=
 	;;=0A=
 	SAVE_REST=0A=
 =0A=
-// ok, enough should be saved at this point to be dangerous, and  =
supply=0A=
+// ok, enough should be saved at this point to be dangerous, and =
supply=0A=
 // information for a dump=0A=
 // We need to switch to Virtual mode before hitting the C =
functions.=0A=
-//=0A=
-//=0A=
-//=0A=
+=0A=
 	movl	=
r2=3DIA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|IA64_P=
SR_BN=0A=
 	mov	r3=3Dpsr	// get the current psr, minimum enabled at this point=0A=
 	;;=0A=
@@ -708,8 +787,8 @@=0A=
 	;;=0A=
 	movl	r3=3DIVirtual_Switch=0A=
 	;;=0A=
-	mov	cr.iip=3Dr3		// short return to set the appropriate bits=0A=
-	mov	cr.ipsr=3Dr2		// need to do an rfi to set appropriate bits=0A=
+	mov	cr.iip=3Dr3	// short return to set the appropriate bits=0A=
+	mov	cr.ipsr=3Dr2	// need to do an rfi to set appropriate bits=0A=
 	;;=0A=
 	rfi=0A=
 	;;=0A=
@@ -717,7 +796,7 @@=0A=
 	//=0A=
 	// We should now be running virtual=0A=
 	//=0A=
-	// Lets call the C handler to get the rest of the state info=0A=
+	// Let's call the C handler to get the rest of the state info=0A=
 	//=0A=
 	alloc r14=3Dar.pfs,0,0,1,0		// now it's safe (must be first in insn =
group!)=0A=
 	;;					//=0A=
diff -urN ./linux-2.4.17/arch/ia64/sn/kernel/mca.c =
mca/linux-2.4.17/arch/ia64/sn/kernel/mca.c=0A=
--- ./linux-2.4.17/arch/ia64/sn/kernel/mca.c	Thu Jan  3 10:04:02 =
2002=0A=
+++ mca/linux-2.4.17/arch/ia64/sn/kernel/mca.c	Thu Jan  3 10:45:46 =
2002=0A=
@@ -14,6 +14,7 @@=0A=
 #include <linux/interrupt.h>=0A=
 #include <linux/irq.h>=0A=
 #include <linux/smp_lock.h>=0A=
+#include <linux/kdb.h>=0A=
 =0A=
 #include <asm/machvec.h>=0A=
 #include <asm/page.h>=0A=
@@ -202,32 +203,32 @@=0A=
 void=0A=
 sn_cpei_handler(int irq, void *devid, struct pt_regs *regs) {=0A=
 =0A=
-	struct ia64_sal_retval isrv;=0A=
+        struct ia64_sal_retval isrv;=0A=
 // this function's sole purpose is to call SAL when we receive=0A=
 // a CE interrupt from SHUB or when the timer routine decides=0A=
 // we need to call SAL to check for CEs.=0A=
 =0A=
-	// CALL SAL_LOG_CE=0A=
-	SAL_CALL(isrv, SN_SAL_LOG_CE, irq, 0, 0, 0, 0, 0, 0);=0A=
+        // CALL SAL_LOG_CE=0A=
+        SAL_CALL(isrv, SN_SAL_LOG_CE, irq, 0, 0, 0, 0, 0, 0);=0A=
 }=0A=
 =0A=
 #include <linux/timer.h>=0A=
 =0A=
-#define CPEI_INTERVAL	(HZ/100)=0A=
+#define CPEI_INTERVAL   (HZ/100)=0A=
 struct timer_list sn_cpei_timer;=0A=
 void sn_init_cpei_timer(void);=0A=
 =0A=
 void=0A=
 sn_cpei_timer_handler(unsigned long dummy) {=0A=
-	sn_cpei_handler(-1, NULL, NULL);=0A=
-	del_timer(&sn_cpei_timer);=0A=
-	sn_cpei_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
+        sn_cpei_handler(-1, NULL, NULL);=0A=
+        del_timer(&sn_cpei_timer);=0A=
+        sn_cpei_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
         add_timer(&sn_cpei_timer);=0A=
 }=0A=
 =0A=
 void=0A=
 sn_init_cpei_timer() {=0A=
-	sn_cpei_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
+        sn_cpei_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
         sn_cpei_timer.function =3D sn_cpei_timer_handler;=0A=
         add_timer(&sn_cpei_timer);=0A=
 }=0A=
@@ -238,16 +239,16 @@=0A=
 =0A=
 void=0A=
 sn_ce_timer_handler(long dummy) {=0A=
-	unsigned long *pi_ce_error_inject_reg =3D 0xc00000092fffff00;=0A=
+        unsigned long *pi_ce_error_inject_reg =3D =
0xc00000092fffff00;=0A=
 =0A=
-	*pi_ce_error_inject_reg =3D 0x0000000000000100;=0A=
-	del_timer(&sn_ce_timer);=0A=
-	sn_ce_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
+        *pi_ce_error_inject_reg =3D 0x0000000000000100;=0A=
+        del_timer(&sn_ce_timer);=0A=
+        sn_ce_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
         add_timer(&sn_ce_timer);=0A=
 }=0A=
 =0A=
 sn_init_ce_timer() {=0A=
-	sn_ce_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
+        sn_ce_timer.expires =3D jiffies + CPEI_INTERVAL;=0A=
         sn_ce_timer.function =3D sn_ce_timer_handler;=0A=
         add_timer(&sn_ce_timer);=0A=
 }=0A=
diff -urN ./linux-2.4.17/include/asm-ia64/mca.h =
mca/linux-2.4.17/include/asm-ia64/mca.h=0A=
--- ./linux-2.4.17/include/asm-ia64/mca.h	Mon Jan 14 14:31:50 2002=0A=
+++ mca/linux-2.4.17/include/asm-ia64/mca.h	Tue Jan 15 11:24:50 2002=0A=
@@ -7,9 +7,6 @@=0A=
  * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)=0A=
  */=0A=
 =0A=
-/* XXX use this temporary define for MP systems trying to INIT */=0A=
-#undef SAL_MPINIT_WORKAROUND=0A=
-=0A=
 #ifndef _ASM_IA64_MCA_H=0A=
 #define _ASM_IA64_MCA_H=0A=
 =0A=
@@ -101,12 +98,19 @@=0A=
 	IA64_MCA_HALT		=3D	-3	/* System to be halted by SAL */=0A=
 };=0A=
 =0A=
+enum {=0A=
+	IA64_MCA_SAME_CONTEXT	=3D	0x0,	/* SAL to return to same context */=0A=
+	IA64_MCA_NEW_CONTEXT	=3D	-1	/* SAL to return to new context */=0A=
+};=0A=
+=0A=
 typedef struct ia64_mca_os_to_sal_state_s {=0A=
 	u64		imots_os_status;	/*   OS status to SAL as to what happened=0A=
 						 *   with the MCA handling.=0A=
 						 */=0A=
 	u64		imots_sal_gp;		/* GP of the SAL - physical */=0A=
-	u64		imots_new_min_state;	/* Pointer to structure containing=0A=
+	u64		imots_context;		/* 0 if return to same context=0A=
+						   1 if return to new context */=0A=
+	u64		*imots_new_min_state;	/* Pointer to structure containing=0A=
 						 * new values of registers in the min state=0A=
 						 * save area.=0A=
 						 */=0A=
@@ -127,12 +131,19 @@=0A=
 extern void ia64_mca_wakeup_int_handler(int,void *,struct pt_regs =
*);=0A=
 extern void ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);=0A=
 extern void ia64_mca_cpe_int_handler(int,void *,struct pt_regs *);=0A=
-extern void ia64_log_print(int,prfunc_t);=0A=
+extern int  ia64_log_print(int,prfunc_t);=0A=
 extern void ia64_mca_cmc_vector_setup(void);=0A=
 extern void ia64_mca_check_errors( void );=0A=
 extern u64  ia64_log_get(int, prfunc_t);=0A=
 =0A=
 #define PLATFORM_CALL(fn, args)	printk("Platform call TBD\n")=0A=
+=0A=
+#define platform_mem_dev_err_print ia64_log_prt_oem_data=0A=
+#define platform_pci_bus_err_print ia64_log_prt_oem_data=0A=
+#define platform_pci_comp_err_print ia64_log_prt_oem_data=0A=
+#define platform_plat_specific_err_print ia64_log_prt_oem_data=0A=
+#define platform_host_ctlr_err_print ia64_log_prt_oem_data=0A=
+#define platform_plat_bus_err_print ia64_log_prt_oem_data=0A=
 =0A=
 #undef	MCA_TEST=0A=
 =0A=
diff -urN ./linux-2.4.17/include/asm-ia64/mca_asm.h =
mca/linux-2.4.17/include/asm-ia64/mca_asm.h=0A=
--- ./linux-2.4.17/include/asm-ia64/mca_asm.h	Fri Nov  9 14:26:17 =
2001=0A=
+++ mca/linux-2.4.17/include/asm-ia64/mca_asm.h	Fri Jan  4 18:10:27 =
2002=0A=
@@ -6,6 +6,8 @@=0A=
  * Copyright (C) Srinivasa Thirumalachar <sprasad@engr.sgi.com>=0A=
  * Copyright (C) 2000 Hewlett-Packard Co.=0A=
  * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>=0A=
+ * Copyright (C) 2002 Intel Corp.=0A=
+ * Copyright (C) 2002 Jenna Hall <jenna.s.hall@intel.com>=0A=
  */=0A=
 #ifndef _ASM_IA64_MCA_ASM_H=0A=
 #define _ASM_IA64_MCA_ASM_H=0A=
@@ -24,7 +26,7 @@=0A=
  *	1. Lop off bits 61 thru 63 in the virtual address=0A=
  */=0A=
 #define INST_VA_TO_PA(addr)							\=0A=
-	dep	addr	=3D 0, addr, 61, 3;=0A=
+	dep	addr	=3D 0, addr, 61, 3=0A=
 /*=0A=
  * This macro converts a data virtual address to a physical address=0A=
  * Right now for simulation purposes the virtual addresses are=0A=
@@ -32,7 +34,7 @@=0A=
  *	1. Lop off bits 61 thru 63 in the virtual address=0A=
  */=0A=
 #define DATA_VA_TO_PA(addr)							\=0A=
-	dep	addr	=3D 0, addr, 61, 3;=0A=
+	dep	addr	=3D 0, addr, 61, 3=0A=
 /*=0A=
  * This macro converts a data physical address to a virtual address=0A=
  * Right now for simulation purposes the virtual addresses are=0A=
@@ -41,7 +43,7 @@=0A=
  */=0A=
 #define DATA_PA_TO_VA(addr,temp)							\=0A=
 	mov	temp	=3D 0x7	;;							\=0A=
-	dep	addr	=3D temp, addr, 61, 3;;=0A=
+	dep	addr	=3D temp, addr, 61, 3=0A=
 =0A=
 /*=0A=
  * This macro jumps to the instruction at the given virtual address=0A=
@@ -112,8 +114,8 @@=0A=
 	;;										\=0A=
 	mov	cr.iip =3D temp2;								\=0A=
 	mov	cr.ifs =3D r0;								\=0A=
-	DATA_VA_TO_PA(sp)								\=0A=
-	DATA_VA_TO_PA(gp)								\=0A=
+	DATA_VA_TO_PA(sp);								\=0A=
+	DATA_VA_TO_PA(gp);								\=0A=
 	;;										\=0A=
 	srlz.i;										\=0A=
 	;;										\=0A=
@@ -130,8 +132,7 @@=0A=
  * translations turned on.=0A=
  *	1.	Get the old saved psr=0A=
  *=0A=
- *	2.	Clear the interrupt enable and interrupt state collection =
bits=0A=
- *		in the current psr.=0A=
+ *	2.	Clear the interrupt state collection bit in the current psr.=0A=
  *=0A=
  *	3.	Set the instruction translation bit back in the old psr=0A=
  *		Note we have to do this since we are right now saving only the=0A=
@@ -140,9 +141,11 @@=0A=
  *=0A=
  *	4.	Set ipsr to this old_psr with "it" bit set and "bn" =3D 1.=0A=
  *=0A=
- *	5.	Set iip to the virtual address of the next instruction =
bundle.=0A=
+ *	5.	Reset the current thread pointer (r13).=0A=
  *=0A=
- *	6.	Do an rfi to move ipsr to psr and iip to ip.=0A=
+ *	6.	Set iip to the virtual address of the next instruction =
bundle.=0A=
+ *=0A=
+ *	7.	Do an rfi to move ipsr to psr and iip to ip.=0A=
  */=0A=
 =0A=
 #define VIRTUAL_MODE_ENTER(temp1, temp2, start_addr, old_psr)	\=0A=
@@ -156,6 +159,10 @@=0A=
 	mov	ar.rsc =3D 0;					\=0A=
 	;;							\=0A=
 	srlz.d;							\=0A=
+	mov	r13 =3D ar.k6;					\=0A=
+	;;							\=0A=
+	DATA_PA_TO_VA(r13,temp1);				\=0A=
+	;;							\=0A=
 	mov	temp2 =3D ar.bspstore;				\=0A=
 	;;							\=0A=
 	DATA_PA_TO_VA(temp2,temp1);				\=0A=
@@ -170,8 +177,6 @@=0A=
 	;;							\=0A=
 	mov	temp2 =3D 1;					\=0A=
 	;;							\=0A=
-	dep	temp1 =3D temp2, temp1, PSR_I,  1;		\=0A=
-	;;							\=0A=
 	dep	temp1 =3D temp2, temp1, PSR_IC, 1;		\=0A=
 	;;							\=0A=
 	dep	temp1 =3D temp2, temp1, PSR_IT, 1;		\=0A=
@@ -195,7 +200,7 @@=0A=
 	nop	1;						\=0A=
 	nop	2;						\=0A=
 	nop	1;						\=0A=
-	rfi;							\=0A=
+	rfi							\=0A=
 	;;=0A=
 =0A=
 /*=0A=
diff -urN ./linux-2.4.17/include/asm-ia64/sal.h =
mca/linux-2.4.17/include/asm-ia64/sal.h=0A=
--- ./linux-2.4.17/include/asm-ia64/sal.h	Mon Jan 14 14:31:37 2002=0A=
+++ mca/linux-2.4.17/include/asm-ia64/sal.h	Tue Jan 15 11:23:26 2002=0A=
@@ -8,11 +8,14 @@=0A=
  * Abstraction Layer".=0A=
  *=0A=
  * Copyright (C) 2001 Intel=0A=
+ * Copyright (C) 2002 Jenna Hall <jenna.s.hall@intel.com>=0A=
  * Copyright (C) 2001 Fred Lewis <frederick.v.lewis@intel.com>=0A=
  * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co=0A=
  * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang =
<davidm@hpl.hp.com>=0A=
  * Copyright (C) 1999 Srinivasa Prasad Thirumalachar =
<sprasad@sprasad.engr.sgi.com>=0A=
  *=0A=
+ * 02/01/04 J. Hall Updated Error Record Structures to conform to July =
2001=0A=
+ *		    revision of the SAL spec.=0A=
  * 01/01/03 fvlewis Updated Error Record Structures to conform with =
Nov. 2000=0A=
  *                  revision of the SAL spec.=0A=
  * 99/09/29 davidm	Updated for SAL 2.6.=0A=
@@ -228,6 +231,10 @@=0A=
 	SAL_VECTOR_OS_BOOT_RENDEZ	=3D 2=0A=
 };=0A=
 =0A=
+/* Encodings for mca_opt parameter sent to SAL_MC_SET_PARAMS */=0A=
+#define	SAL_MC_PARAM_RZ_ALWAYS		0x1=0A=
+#define	SAL_MC_PARAM_BINIT_ESCALATE	0x10=0A=
+=0A=
 /*=0A=
 ** Definition of the SAL Error Log from the SAL spec=0A=
 */=0A=
@@ -516,12 +523,12 @@=0A=
     {=0A=
         u16 vendor_id;=0A=
         u16 device_id;=0A=
-        u16 class_code;=0A=
+	u8  class_code[3];=0A=
         u8  func_num;=0A=
         u8  dev_num;=0A=
         u8  bus_num;=0A=
         u8  seg_num;=0A=
-        u8  reserved[6];=0A=
+        u8  reserved[5];=0A=
     }               comp_info;=0A=
     u32             num_mem_regs;=0A=
     u32             num_io_regs;=0A=

------_=_NextPart_000_01C19E15.00A80E00--

