From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 24 Aug 2004 05:35:19 +0000
Subject: [PATCH] OS_MCA Recovery from poisoned memory read
Message-Id: <412AD397.5060005@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi, Tony and all MCA experts,

This is the latest/Updated OS_MCA handler which try to do recovery
from multibit-ECC/poisoned memory-read error on user-land.
(Thank you very much for comments, Keith and Grant!)

I'd still appreciate it if anyone having good test environment
could apply my patch and could report how it works.
(especially reports on non-Tiger/non-Intel platform are welcome.)

Tony, isn't it about time you thought about applying my patch to
your linux-ia64-test-2.6.8.1/test-2.6 tree?

Thanks,

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----

diff -Nur linux-2.6.8.1/arch/ia64/Kconfig linux-2.6.8.1-mcadrv/arch/ia64/Kc=
onfig
--- linux-2.6.8.1/arch/ia64/Kconfig	2004-08-14 19:56:22.000000000 +0900
+++ linux-2.6.8.1-mcadrv/arch/ia64/Kconfig	2004-08-24 11:57:43.000000000 +0=
900
@@ -270,6 +270,9 @@
  	depends on IA32_SUPPORT
  	default y

+config IA64_MCA_RECOVERY
+	tristate "MCA recovery from errors other than TLB."
+
  config PERFMON
  	bool "Performance monitor support"
  	help
diff -Nur linux-2.6.8.1/arch/ia64/kernel/Makefile linux-2.6.8.1-mcadrv/arch=
/ia64/kernel/Makefile
--- linux-2.6.8.1/arch/ia64/kernel/Makefile	2004-08-14 19:56:23.000000000 +=
0900
+++ linux-2.6.8.1-mcadrv/arch/ia64/kernel/Makefile	2004-08-24 11:57:43.0000=
00000 +0900
@@ -17,6 +17,8 @@
  obj-$(CONFIG_SMP)		+=3D smp.o smpboot.o
  obj-$(CONFIG_PERFMON)		+=3D perfmon_default_smpl.o
  obj-$(CONFIG_IA64_CYCLONE)	+=3D cyclone.o
+obj-$(CONFIG_IA64_MCA_RECOVERY)	+=3D mca_recovery.o
+mca_recovery-y			+=3D mca_drv.o mca_drv_asm.o

  # The gate DSO image is built using a special linker script.
  targets +=3D gate.so gate-syms.o
diff -Nur linux-2.6.8.1/arch/ia64/kernel/mca.c linux-2.6.8.1-mcadrv/arch/ia=
64/kernel/mca.c
--- linux-2.6.8.1/arch/ia64/kernel/mca.c	2004-08-14 19:55:32.000000000 +0900
+++ linux-2.6.8.1-mcadrv/arch/ia64/kernel/mca.c	2004-08-24 11:57:43.0000000=
00 +0900
@@ -82,11 +82,6 @@
  # define IA64_MCA_DEBUG(fmt...)
  #endif

-typedef struct ia64_fptr {
-	unsigned long fp;
-	unsigned long gp;
-} ia64_fptr_t;
-
  /* Used by mca_asm.S */
  ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
  ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
@@ -831,6 +826,12 @@

  }

+/* This is a function pointer to other error recovery from MCA */
+int (*ia64_mca_ucmc_other_recover_fp)
+	(void*,ia64_mca_sal_to_os_state_t*,ia64_mca_os_to_sal_state_t*)
+	=3D NULL;
+EXPORT_SYMBOL(ia64_mca_ucmc_other_recover_fp);
+
  /*
   * ia64_mca_ucmc_handler
   *
@@ -852,11 +853,20 @@
  {
  	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t *)
  		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover =3D psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
+	int recover;

  	/* Get the MCA error record and log it */
  	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);

+	/* Only TLB error is exist in this SAL error record */
+	recover =3D (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
+	/* other error recovery */
+	   || (ia64_mca_ucmc_other_recover_fp
+		&& ia64_mca_ucmc_other_recover_fp(
+			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
+			&ia64_sal_to_os_handoff_state,
+			&ia64_os_to_sal_handoff_state));
+
  	/*
  	 *  Wakeup all the processors which are spinning in the rendezvous
  	 *  loop.
diff -Nur linux-2.6.8.1/arch/ia64/kernel/mca_drv_asm.S linux-2.6.8.1-mcadrv=
/arch/ia64/kernel/mca_drv_asm.S
--- linux-2.6.8.1/arch/ia64/kernel/mca_drv_asm.S	1970-01-01 09:00:00.000000=
000 +0900
+++ linux-2.6.8.1-mcadrv/arch/ia64/kernel/mca_drv_asm.S	2004-08-24 12:03:00=
.000000000 +0900
@@ -0,0 +1,45 @@
+/*
+ * File:        mca_drv_asm.S
+ * Purpose:     Assembly portion of Generic MCA handling
+ *
+ * Copyright (C) 2004 FUJITSU LIMITED
+ * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
+ */
+#include <linux/config.h>
+#include <linux/threads.h>
+
+#include <asm/asmmacro.h>
+#include <asm/processor.h>
+
+GLOBAL_ENTRY(mca_handler_bhhook)
+	invala						// clear RSE ?
+	;;						//
+	cover						//
+	;;						//
+	clrrrb						//
+	;;					=09
+	alloc		r16=3Dar.pfs,0,2,1,0		// make a new frame
+	;;
+	mov		r13=3DIA64_KR(CURRENT)		// current task pointer
+	;;
+	adds		r12=3DIA64_TASK_THREAD_KSP_OFFSET,r13
+	;;
+	ld8		r12=3D[r12]			// stack pointer
+	;;
+	mov		loc0=3Dr16
+	movl		loc1=3Dmca_handler_bh		// recovery C function
+	;;
+	mov		out0=3Dr8				// poisoned address
+	mov		b6=3Dloc1
+	;;
+	mov		loc1=3Drp
+	;;
+	br.call.sptk.many    rp=B6			// not return ...
+	;;
+	mov		ar.pfs=3Dloc0
+	mov 		rp=3Dloc1
+	;;
+	mov		r8=3Dr0
+	br.ret.sptk.many rp
+	;;
+END(mca_handler_bhhook)
diff -Nur linux-2.6.8.1/arch/ia64/kernel/mca_drv.c linux-2.6.8.1-mcadrv/arc=
h/ia64/kernel/mca_drv.c
--- linux-2.6.8.1/arch/ia64/kernel/mca_drv.c	1970-01-01 09:00:00.000000000 =
+0900
+++ linux-2.6.8.1-mcadrv/arch/ia64/kernel/mca_drv.c	2004-08-24 12:02:11.000=
000000 +0900
@@ -0,0 +1,636 @@
+/*
+ * File:	mca_drv.c
+ * Purpose:	Generic MCA handling layer
+ *
+ * Copyright (C) 2004 FUJITSU LIMITED
+ * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
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
+#include <linux/mm.h>
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
+#include "mca_drv.h"
+
+/* max size of SAL error record (default) */
+static int sal_rec_max =3D 10000;
+
+/* from mca.c */
+static ia64_mca_sal_to_os_state_t *sal_to_os_handoff_state;
+static ia64_mca_os_to_sal_state_t *os_to_sal_handoff_state;
+
+/* from mca_drv_asm.S */
+extern void *mca_handler_bhhook(void);
+
+static spinlock_t mca_bh_lock =3D SPIN_LOCK_UNLOCKED;
+
+typedef enum {
+	MCA_IS_LOCAL  =3D 0,
+	MCA_IS_GLOBAL =3D 1
+} mca_type_t;
+
+#define MAX_PAGE_ISOLATE 32
+
+static struct page *page_isolate[MAX_PAGE_ISOLATE];
+static int num_page_isolate =3D 0;
+
+typedef enum {
+	FAIL_TO_ISOLATE =3D 0,
+	ISOLATE_OK	=3D 1
+} isolate_status_t;
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
+/**
+ * mca_page_isolate - isolate a poisoned page in order not to use it later
+ * @paddr:	poisoned memory location
+ *
+ * Return value:
+ *	ISOLATE_OK / FAIL_TO_ISOLATE
+ */
+
+static isolate_status_t
+mca_page_isolate(unsigned long paddr)
+{
+	int i;
+	struct page *p;
+
+	/* whether physical address is valid or not */
+	if ( !ia64_phys_addr_valid(paddr) )
+		return FAIL_TO_ISOLATE;
+
+	/* convert physical address to physical page number */
+	p =3D pfn_to_page(paddr>>PAGE_SHIFT);
+
+	/* check whether a page number have been already registered or not */
+	for( i =3D 0; i < num_page_isolate; i++ )
+		if( page_isolate[i] =3D p )
+			return ISOLATE_OK; /* already listed */
+
+	/* limitation check */
+	if( num_page_isolate =3D MAX_PAGE_ISOLATE )
+		return FAIL_TO_ISOLATE;
+
+	/* kick pages having attribute 'SLAB' or 'Reserved' */
+	if( PageSlab(p) || PageReserved(p) )
+		return FAIL_TO_ISOLATE;
+
+	/* add attribute 'Reserved' and register the page */
+	SetPageReserved(p);
+	page_isolate[num_page_isolate++] =3D p;
+
+	return ISOLATE_OK;
+}
+
+/**
+ * mca_hanlder_bh - Kill the process which occurred memory read error
+ * @paddr:	poisoned address received from MCA Handler
+ */
+
+void
+mca_handler_bh(unsigned long paddr)
+{
+	printk(KERN_DEBUG "OS_MCA: process [pid: %d](%s) encounters MCA.\n",
+		current->pid, current->comm);
+
+	spin_lock(&mca_bh_lock);
+	if (mca_page_isolate(paddr) =3D ISOLATE_OK) {
+		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
+	} else {
+		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
+	}
+	spin_unlock(&mca_bh_lock);
+
+	/* This process is about to be killed itself */
+	force_sig(SIGKILL, current);
+	schedule();
+}
+
+/**
+ * mca_make_peidx - Make index of processor error section
+ * @slpi:	pointer to record of processor error section
+ * @peidx:	pointer to index of processor error section
+ */
+
+static void
+mca_make_peidx(sal_log_processor_info_t *slpi, peidx_table_t *peidx)
+{
+	/*
+	 * calculate the start address of
+	 *   "struct cpuid_info" and "sal_processor_static_info_t".
+	 */
+	u64 total_check_num =3D slpi->valid.num_cache_check
+				+ slpi->valid.num_tlb_check
+				+ slpi->valid.num_bus_check
+				+ slpi->valid.num_reg_file_check
+				+ slpi->valid.num_ms_check;
+	u64 head_size =3D	sizeof(sal_log_mod_error_info_t) * total_check_num
+			+ sizeof(sal_log_processor_info_t);
+	u64 mid_size  =3D slpi->valid.cpuid_info * sizeof(struct sal_cpuid_info);
+
+	peidx_head(peidx)   =3D slpi;
+	peidx_mid(peidx)    =3D (struct sal_cpuid_info *)
+		(slpi->valid.cpuid_info ? ((char*)slpi + head_size) : NULL);
+	peidx_bottom(peidx) =3D (sal_processor_static_info_t *)
+		(slpi->valid.psi_static_struct ?
+			((char*)slpi + head_size + mid_size) : NULL);
+}
+
+/**
+ * mca_make_slidx -  Make index of SAL error record
+ * @buffer:	pointer to SAL error record
+ * @slidx:	pointer to index of SAL error record
+ *
+ * Return value:
+ *	1 if record has platform error / 0 if not
+ */
+#define LOG_INDEX_ADD_SECT_PTR(sect, ptr) \
+        { slidx_list_t *hl =3D &slidx_pool.buffer[slidx_pool.cur_idx]; \
+          hl->hdr =3D ptr; \
+          list_add(&hl->list, &(sect)); \
+          slidx_pool.cur_idx =3D (slidx_pool.cur_idx + 1)%slidx_pool.max_i=
dx; }
+
+static int
+mca_make_slidx(void *buffer, slidx_table_t *slidx)
+{
+	int platform_err =3D 0;
+	int record_len =3D ((sal_log_record_header_t*)buffer)->len;
+	u32 ercd_pos;
+	int sects;
+	sal_log_section_hdr_t *sp;
+
+	/*
+	 * Initialize index referring current record
+	 */
+	INIT_LIST_HEAD(&(slidx->proc_err));
+	INIT_LIST_HEAD(&(slidx->mem_dev_err));
+	INIT_LIST_HEAD(&(slidx->sel_dev_err));
+	INIT_LIST_HEAD(&(slidx->pci_bus_err));
+	INIT_LIST_HEAD(&(slidx->smbios_dev_err));
+	INIT_LIST_HEAD(&(slidx->pci_comp_err));
+	INIT_LIST_HEAD(&(slidx->plat_specific_err));
+	INIT_LIST_HEAD(&(slidx->host_ctlr_err));
+	INIT_LIST_HEAD(&(slidx->plat_bus_err));
+	INIT_LIST_HEAD(&(slidx->unsupported));
+
+	/*
+	 * Extract a Record Header
+	 */
+	slidx->header =3D buffer;
+
+	/*
+	 * Extract each section records
+	 * (arranged from "int ia64_log_platform_info_print()")
+	 */
+	for (ercd_pos =3D sizeof(sal_log_record_header_t), sects =3D 0;
+		ercd_pos < record_len; ercd_pos +=3D sp->len, sects++) {
+		sp =3D (sal_log_section_hdr_t *)((char*)buffer + ercd_pos);
+		if (!efi_guidcmp(sp->guid, SAL_PROC_DEV_ERR_SECT_GUID)) {
+			LOG_INDEX_ADD_SECT_PTR(slidx->proc_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->mem_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->sel_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->pci_bus_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->smbios_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->pci_comp_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->plat_specific_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->host_ctlr_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_BUS_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			LOG_INDEX_ADD_SECT_PTR(slidx->plat_bus_err, sp);
+		} else {
+			LOG_INDEX_ADD_SECT_PTR(slidx->unsupported, sp);
+		}
+	}
+	slidx->n_sections =3D sects;
+
+	return platform_err;
+}
+
+/**
+ * init_record_index_pools - Initialize pool of lists for SAL record index
+ *
+ * Return value:
+ *	0 on Success / -ENOMEM on Failure
+ */
+static int
+init_record_index_pools(void)
+{
+	int i;
+	int rec_max_size;  /* Maximum size of SAL error records */
+	int sect_min_size; /* Minimum size of SAL error sections */
+	/* minimum size table of each section */
+	static int sal_log_sect_min_sizes[] =3D {
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
+	 * MCA handler cannot allocate new memory on flight,
+	 * so we preallocate enough memory to handle a SAL record.
+	 *
+	 * Initialize a handling set of slidx_pool:
+	 *   1. Pick up the max size of SAL error records
+	 *   2. Pick up the min size of SAL error sections
+	 *   3. Allocate the pool as enough to 2 SAL records
+	 *     (now we can estimate the maxinum of section in a record.)
+	 */
+
+	/* - 1 - */
+	rec_max_size =3D sal_rec_max;
+
+	/* - 2 - */
+	sect_min_size =3D sal_log_sect_min_sizes[0];
+	for (i =3D 1; i < sizeof sal_log_sect_min_sizes/sizeof(size_t); i++)
+		if (sect_min_size > sal_log_sect_min_sizes[i])
+			sect_min_size =3D sal_log_sect_min_sizes[i];
+
+	/* - 3 - */
+	slidx_pool.max_idx =3D (rec_max_size/sect_min_size) * 2 + 1;
+	slidx_pool.buffer =3D (slidx_list_t *) kmalloc(slidx_pool.max_idx * sizeo=
f(slidx_list_t), GFP_KERNEL);
+
+	return slidx_pool.buffer ? 0 : -ENOMEM;
+}
+
+
+/*************************************************************************=
****
+ * Recovery functions                                                     =
   *
+ *************************************************************************=
****/
+
+/**
+ * is_mca_global - Check whether this MCA is global or not
+ * @peidx:	pointer of index of processor error section
+ * @pbci:	pointer to pal_bus_check_info_t
+ *
+ * Return value:
+ *	MCA_IS_LOCAL / MCA_IS_GLOBAL
+ */
+
+static mca_type_t
+is_mca_global(peidx_table_t *peidx, pal_bus_check_info_t *pbci)
+{
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+
+	/*
+	 * PAL can request a rendezvous, if the MCA has a global scope.
+	 * If "rz_always" flag is set, SAL requests MCA rendezvous
+	 * in spite of global MCA.
+	 * Therefore it is local MCA when rendezvous has not been requested.
+	 * Failed to rendezvous, the system must be down.
+	 */
+	switch (sal_to_os_handoff_state->imsto_rendez_state) {
+		case -1: /* SAL rendezvous unsuccessful */
+			return MCA_IS_GLOBAL;
+		case  0: /* SAL rendezvous not required */
+			return MCA_IS_LOCAL;
+		case  1: /* SAL rendezvous successful int */
+		case  2: /* SAL rendezvous successful int with init */
+		default:
+			break;
+	}
+
+	/*
+	 * If One or more Cache/TLB/Reg_File/Uarch_Check is here,
+	 * it would be a local MCA. (i.e. processor internal error)
+	 */
+	if (psp->tc || psp->cc || psp->rc || psp->uc)
+		return MCA_IS_LOCAL;
+=09
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
+	 *
+	 * Referring Bus_Check.bsi:
+	 *   0: Unknown/unclassified
+	 *   1: BERR#
+	 *   2: BINIT#
+	 *   3: Hard Fail
+	 * (FIXME: Are these SGI specific or generic bsi values?)
+	 */
+	if (pbci->eb)
+		switch (pbci->bsi) {
+			case 0:
+				/* e.g. a load from poisoned memory */
+				return MCA_IS_LOCAL;
+			case 1:
+			case 2:
+			case 3:
+				return MCA_IS_GLOBAL;
+		}
+
+	return MCA_IS_GLOBAL;
+}
+
+/**
+ * recover_from_read_error - Try to recover the errors which type are "rea=
d"s.
+ * @slidx:	pointer of index of SAL error record
+ * @peidx:	pointer of index of processor error section
+ * @pbci:	pointer of pal_bus_check_info
+ *
+ * Return value:
+ *	1 on Success / 0 on Failure
+ */
+
+static int
+recover_from_read_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bu=
s_check_info_t *pbci)
+{
+	sal_log_mod_error_info_t *smei;
+	pal_min_state_area_t *pmsa;
+	struct ia64_psr *psr1, *psr2;
+	ia64_fptr_t *mca_hdlr_bh =3D (ia64_fptr_t*)mca_handler_bhhook;
+
+	/* Is target address valid? */
+	if (!pbci->tv)
+		return 0;
+
+	/*
+	 * cpu read or memory-mapped io read
+	 *
+	 *    offending process  affected process  OS MCA do
+	 *     kernel mode        kernel mode       down system
+	 *     kernel mode        user   mode       kill the process
+	 *     user   mode        kernel mode       down system (*)
+	 *     user   mode        user   mode       kill the process
+	 *
+	 * (*) You could terminate offending user-mode process
+	 *    if (pbci->pv && pbci->pl !=3D 0) *and* if you sure
+	 *    the process not have any locks of kernel.
+	 */
+
+	psr1 =3D(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
+
+	/*
+	 *  Check the privilege level of interrupted context.
+	 *   If it is user-mode, then terminate affected process.
+	 */
+	if (psr1->cpl !=3D 0) {
+		smei =3D peidx_bus_check(peidx, 0);
+		if (smei->valid.target_identifier) {
+			/*
+			 *  setup for resume to bottom half of MCA,
+			 * "mca_handler_bhhook"
+			 */
+			pmsa =3D (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_stat=
e | (6ul<<61));
+			/* pass to bhhook as 1st argument (gr8) */
+			pmsa->pmsa_gr[8-1] =3D smei->target_identifier;
+			/* set interrupted return address (but no use) */
+			pmsa->pmsa_br0 =3D pmsa->pmsa_iip;
+			/* change resume address to bottom half */
+			pmsa->pmsa_iip =3D mca_hdlr_bh->fp;
+			pmsa->pmsa_gr[1-1] =3D mca_hdlr_bh->gp;
+			/* set cpl with kernel mode */
+			psr2 =3D (struct ia64_psr *)&pmsa->pmsa_ipsr;
+			psr2->cpl =3D 0;
+			psr2->ri  =3D 0;
+
+			return 1;
+		}
+
+	}
+
+	return 0;
+}
+
+/**
+ * recover_from_platform_error - Recover from platform error.
+ * @slidx:	pointer of index of SAL error record
+ * @peidx:	pointer of index of processor error section
+ * @pbci:	pointer of pal_bus_check_info
+ *
+ * Return value:
+ *	1 on Success / 0 on Failure
+ */
+
+static int
+recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx, pa=
l_bus_check_info_t *pbci)
+{
+	int status =3D 0;
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+
+	if (psp->bc && pbci->eb && pbci->bsi =3D 0) {
+		switch(pbci->type) {
+		case 1: /* partial read */
+		case 3: /* full line(cpu) read */
+		case 9: /* I/O space read */
+			status =3D recover_from_read_error(slidx, peidx, pbci);
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
+/**
+ * recover_from_processor_error
+ * @platform:	whether there are some platform error section or not
+ * @slidx:	pointer of index of SAL error record
+ * @peidx:	pointer of index of processor error section
+ * @pbci:	pointer of pal_bus_check_info
+ *
+ * Return value:
+ *	1 on Success / 0 on Failure
+ */
+/*
+ *  Later we try to recover when below all conditions are satisfied.
+ *   1. Only one processor error section is exist.
+ *   2. BUS_CHECK is exist and the others are not exist.(Except TLB_CHECK)
+ *   3. The entry of BUS_CHECK_INFO is 1.
+ *   4. "External bus error" flag is set and the others are not set.
+ */
+
+static int
+recover_from_processor_error(int platform, slidx_table_t *slidx, peidx_tab=
le_t *peidx, pal_bus_check_info_t *pbci)
+{
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+
+	/*
+	 * We cannot recover errors with other than bus_check.
+	 */
+	if (psp->cc || psp->rc || psp->uc)
+		return 0;
+
+	/*
+	 * If there is no bus error, record is weird but we need not to recover.
+	 */
+	if (psp->bc =3D 0 || pbci =3D NULL)
+		return 1;
+
+	/*
+	 * Sorry, we cannot handle so many.
+	 */
+	if (peidx_bus_check_num(peidx) > 1)
+		return 0;
+	/*
+	 * Well, here is only one bus error.
+	 */
+	if (pbci->ib || pbci->cc)
+		return 0;
+	if (pbci->eb && pbci->bsi > 0)
+		return 0;
+	if (psp->ci =3D 0)
+		return 0;
+
+	/*
+	 * This is a local MCA and estimated as recoverble external bus error.
+	 * (e.g. a load from poisoned memory)
+	 * This means "there are some platform errors".
+	 */
+	if (platform)
+		return recover_from_platform_error(slidx, peidx, pbci);
+	/*
+	 * On account of strange SAL error record, we cannot recover.
+	 */
+	return 0;
+}
+
+/**
+ * mca_try_to_recover - Try to recover from MCA
+ * @rec:	pointer to a SAL error record
+ *
+ * Return value:
+ *	1 on Success / 0 on Failure
+ */
+
+static int
+mca_try_to_recover(void *rec,
+	ia64_mca_sal_to_os_state_t *sal_to_os_state,
+	ia64_mca_os_to_sal_state_t *os_to_sal_state)
+{
+	int platform_err;
+	int n_proc_err;
+	slidx_table_t slidx;
+	peidx_table_t peidx;
+	pal_bus_check_info_t pbci;
+
+	/* handoff state from/to mca.c */
+	sal_to_os_handoff_state =3D sal_to_os_state;
+	os_to_sal_handoff_state =3D os_to_sal_state;
+
+	/* Make index of SAL error record */
+	platform_err =3D mca_make_slidx(rec, &slidx);
+
+	/* Count processor error sections */
+	n_proc_err =3D slidx_count(&slidx, proc_err);
+
+	 /* Now, OS can recover when there is one processor error section */
+	if (n_proc_err > 1)
+		return 0;
+	else if (n_proc_err =3D 0) {
+		/* Weird SAL record ... We need not to recover */
+
+		return 1;
+	}
+
+	/* Make index of processor error section */
+	mca_make_peidx((sal_log_processor_info_t*)slidx_first_entry(&slidx.proc_e=
rr)->hdr, &peidx);
+
+	/* Extract Processor BUS_CHECK[0] */
+	*((u64*)&pbci) =3D peidx_check_info(&peidx, bus_check, 0);
+
+	/* Check whether MCA is global or not */
+	if (is_mca_global(&peidx, &pbci))
+		return 0;
+=09
+	/* Try to recover a processor error */
+	return recover_from_processor_error(platform_err, &slidx, &peidx, &pbci);
+}
+
+/*
+ * =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+ */
+
+int __init mca_external_handler_init(void)
+{
+	if (init_record_index_pools())
+		return -ENOMEM;
+
+	/* register external mca handlers */
+	ia64_mca_ucmc_other_recover_fp =3D mca_try_to_recover;
+
+	return 0;
+}
+
+void __exit mca_external_handler_exit(void)
+{
+	/* unregister external mca handlers */
+	ia64_mca_ucmc_other_recover_fp =3D NULL;
+	kfree(slidx_pool.buffer);
+}
+
+module_init(mca_external_handler_init);
+module_exit(mca_external_handler_exit);
+
+module_param(sal_rec_max, int, 0644);
+MODULE_PARM_DESC(sal_rec_max, "Max size of SAL error record");
+
+MODULE_DESCRIPTION("ia64 platform dependent mca handler driver");
+MODULE_LICENSE("GPL");
diff -Nur linux-2.6.8.1/arch/ia64/kernel/mca_drv.h linux-2.6.8.1-mcadrv/arc=
h/ia64/kernel/mca_drv.h
--- linux-2.6.8.1/arch/ia64/kernel/mca_drv.h	1970-01-01 09:00:00.000000000 =
+0900
+++ linux-2.6.8.1-mcadrv/arch/ia64/kernel/mca_drv.h	2004-08-24 12:02:23.000=
000000 +0900
@@ -0,0 +1,113 @@
+/*
+ * File:	mca_drv.h
+ * Purpose:	Define helpers for Generic MCA handling
+ *
+ * Copyright (C) 2004 FUJITSU LIMITED
+ * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
+ */
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
+#define peidx_reg_file_check_num(p) (peidx_head(p)->valid.num_reg_file_che=
ck)
+#define peidx_ms_check_num(p)       (peidx_head(p)->valid.num_ms_check)
+
+#define peidx_cache_check_idx(p, n)    (n)
+#define peidx_tlb_check_idx(p, n)      (peidx_cache_check_idx(p, peidx_cac=
he_check_num(p)) + n)
+#define peidx_bus_check_idx(p, n)      (peidx_tlb_check_idx(p, peidx_tlb_c=
heck_num(p)) + n)
+#define peidx_reg_file_check_idx(p, n) (peidx_bus_check_idx(p, peidx_bus_c=
heck_num(p)) + n)
+#define peidx_ms_check_idx(p, n)       (peidx_reg_file_check_idx(p, peidx_=
reg_file_check_num(p)) + n)
+
+#define peidx_mod_error_info(p, name, n) \
+({	int __idx =3D peidx_##name##_idx(p, n); \
+	sal_log_mod_error_info_t *__ret =3D NULL; \
+	if (peidx_##name##_num(p) > n) /*BUG*/ \
+		__ret =3D &(peidx_head(p)->info[__idx]); \
+	__ret; })
+
+#define peidx_cache_check(p, n)    peidx_mod_error_info(p, cache_check, n)
+#define peidx_tlb_check(p, n)      peidx_mod_error_info(p, tlb_check, n)
+#define peidx_bus_check(p, n)      peidx_mod_error_info(p, bus_check, n)
+#define peidx_reg_file_check(p, n) peidx_mod_error_info(p, reg_file_check,=
 n)
+#define peidx_ms_check(p, n)       peidx_mod_error_info(p, ms_check, n)
+
+#define peidx_check_info(proc, name, n) \
+({ \
+	sal_log_mod_error_info_t *__info =3D peidx_mod_error_info(proc, name, n);\
+	u64 __temp =3D __info && __info->valid.check_info \
+		? __info->check_info : 0; \
+	__temp; })
+
+/* slidx: index of SAL log error record */
+
+typedef struct slidx_list {
+	struct list_head list;
+	sal_log_section_hdr_t *hdr;
+} slidx_list_t;
+
+typedef struct slidx_table {
+	sal_log_record_header_t *header;
+	int n_sections;			/* # of section headers */
+	struct list_head proc_err;
+	struct list_head mem_dev_err;
+	struct list_head sel_dev_err;
+	struct list_head pci_bus_err;
+	struct list_head smbios_dev_err;
+	struct list_head pci_comp_err;
+	struct list_head plat_specific_err;
+	struct list_head host_ctlr_err;
+	struct list_head plat_bus_err;
+	struct list_head unsupported;	/* list of unsupported sections */
+} slidx_table_t;
+
+#define slidx_foreach_entry(pos, head) \
+	list_for_each_entry(pos, head, list)
+#define slidx_first_entry(head) \
+	(((head)->next !=3D (head)) ? list_entry((head)->next, typeof(slidx_list_=
t), list) : NULL)
+#define slidx_count(slidx, sec) \
+({	int __count =3D 0; \
+	slidx_list_t *__pos; \
+	slidx_foreach_entry(__pos, &((slidx)->sec)) { __count++; }\
+	__count; })
+
diff -Nur linux-2.6.8.1/include/asm-ia64/mca.h linux-2.6.8.1-mcadrv/include=
/asm-ia64/mca.h
--- linux-2.6.8.1/include/asm-ia64/mca.h	2004-08-14 19:54:51.000000000 +0900
+++ linux-2.6.8.1-mcadrv/include/asm-ia64/mca.h	2004-08-24 11:57:43.0000000=
00 +0900
@@ -22,6 +22,11 @@

  #define IA64_MCA_RENDEZ_TIMEOUT		(20 * 1000)	/* value in milliseconds - 2=
0 seconds */

+typedef struct ia64_fptr {
+	unsigned long fp;
+	unsigned long gp;
+} ia64_fptr_t;
+
  typedef union cmcv_reg_u {
  	u64	cmcv_regval;
  	struct	{
@@ -114,6 +119,7 @@
  extern void ia64_monarch_init_handler(void);
  extern void ia64_slave_init_handler(void);
  extern void ia64_mca_cmc_vector_setup(void);
+extern int  (*ia64_mca_ucmc_other_recover_fp)(void *,ia64_mca_sal_to_os_st=
ate_t *,ia64_mca_os_to_sal_state_t *);

  #endif /* !__ASSEMBLY__ */
  #endif /* _ASM_IA64_MCA_H */



