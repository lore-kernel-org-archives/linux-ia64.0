From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 09 Apr 2004 09:27:32 +0000
Subject: [PATCH] MCA recovery from memory read error using poisoned page
Message-Id: <0HVW00APQCXW7Y@fjmail501.fjmail.jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <0HTB004BEV6M3H@fjmail506.fjmail.jp.fujitsu.com>
In-Reply-To: <0HTB004BEV6M3H@fjmail506.fjmail.jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,


This is a revised patch for MCA handler that should prevent system from=20
down when memory read error caused on userland.

If MCA occur and SAL record indicates a read error, and if the privilege=20
level of the process offending error is user, handler kills the process=20
and isolates the poisoned page from your system.

I confirmed this work very well with simulated record. I modified Zoltan's =

patch that originally generate a TLB error. With some additional codes,=20
now it generate a Bus error that indicate a memory read error, instead.

When I posted this last time, there isn't page isolation codes, but now=20
there is.

[PATCH] MCA recovery from memory read error caused by application
  http://marc.theaimsgroup.com/?l=3Dlinux-ia64&m=107718770916540&w=3D2

Still here isn't code to deal with isolated pages in array, but usually=20
there will be not so many pages in the array, so it isn't serious problem.
In the future, this array will be dealed by something like recycle-daemon
who restore the poisoned page and return it to the system.


Thanks,

H.Seto

-----

diff -Nur linux-2.6.5/arch/ia64/kernel/Makefile linux-2.6.5-recovery/arch/i=
a64/kernel/Makefile
--- linux-2.6.5/arch/ia64/kernel/Makefile	2004-04-04 12:38:23.000000000 +09=
00
+++ linux-2.6.5-recovery/arch/ia64/kernel/Makefile	2004-04-09 17:31:00.4661=
39496 +0900
@@ -6,7 +6,7 @@
=20
 obj-y :=3D acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o=
 irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o =
sal.o		\
-	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unalign=
ed.o unwind.o mca.o mca_asm.o
+	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unalign=
ed.o unwind.o mca.o mca_recovery.o mca_asm.o
=20
 obj-$(CONFIG_EFI_VARS)		+=3D efivars.o
 obj-$(CONFIG_IA64_BRL_EMU)	+=3D brl_emu.o
diff -Nur linux-2.6.5/arch/ia64/kernel/mca.c linux-2.6.5-recovery/arch/ia64=
/kernel/mca.c
--- linux-2.6.5/arch/ia64/kernel/mca.c	2004-04-04 12:37:06.000000000 +0900
+++ linux-2.6.5-recovery/arch/ia64/kernel/mca.c	2004-04-09 17:30:36.4602804=
15 +0900
@@ -75,6 +75,7 @@
=20
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
+#include "mca_recovery.h"
=20
 #if defined(IA64_MCA_DEBUG_INFO)
 # define IA64_MCA_DEBUG(fmt...)	printk(fmt)
@@ -101,6 +102,10 @@
 extern void			ia64_monarch_init_handler (void);
 extern void			ia64_slave_init_handler (void);
=20
+/* In mca_recovery.c */
+extern void 			ia64_mca_try_to_recover(void *);
+extern void			ia64_mca_init_for_recovery(void); /* Initialize section poin=
ter list pool */
+
 static ia64_mc_info_t		ia64_mc_info;
=20
 struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
@@ -140,16 +145,16 @@
 	spinlock_t	isl_lock;
 	int		isl_index;
 	unsigned long	isl_count;
-	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + =
error log */
+	void		*isl_log[IA64_MAX_LOGS]; /* need space to store header + error log =
*/
 } ia64_state_log_t;
=20
 static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
=20
 #define IA64_LOG_ALLOCATE(it, size) \
 	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] =3D \
-		(ia64_err_rec_t *)alloc_bootmem(size); \
+		alloc_bootmem(size); \
 	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] =3D \
-		(ia64_err_rec_t *)alloc_bootmem(size);}
+		alloc_bootmem(size);}
 #define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
 #define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_l=
ock, s)
 #define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].=
isl_lock,s)
@@ -276,7 +281,7 @@
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
=20
-	/* Get the CMC error record and log it */
+	/* Get the CPE error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
 	return IRQ_HANDLED;
 }
@@ -739,23 +744,17 @@
 }
=20
 /*
- * ia64_return_to_sal_check
+ * ia64_set_default_os2sal_state
  *
- *	This is function called before going back from the OS_MCA handler
- *	to the OS_MCA dispatch code which finally takes the control back
- *	to the SAL.
- *	The main purpose of this routine is to setup the OS_MCA to SAL
- *	return state which can be used by the OS_MCA dispatch code
- *	just before going back to SAL.
+ *  set all fields of "ia64_os_to_sal_handoff_state",
+ * which are used by SAL handling from MCA recovery.
  *
- *  Inputs  :   None
- *  Outputs :   None
+ *  Inputs & Outpus : 	None
  */
=20
 static void
-ia64_return_to_sal_check(int recover)
+ia64_set_default_os2sal_state(void)
 {
-
 	/* Copy over some relevant stuff from the sal_to_os_mca_handoff
 	 * so that it can be used at the time of os_mca_to_sal_handoff
 	 */
@@ -765,17 +764,12 @@
 	ia64_os_to_sal_handoff_state.imots_sal_check_ra  		ia64_sal_to_os_handoff=
_state.imsto_sal_check_ra;
=20
-	if (recover)
-		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_CORRECTED;
-	else
-		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_COLD_BOOT;
+	ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_COLD_BOOT;
=20
-	/* Default =3D tell SAL to return to same context */
 	ia64_os_to_sal_handoff_state.imots_context =3D IA64_MCA_SAME_CONTEXT;
=20
 	ia64_os_to_sal_handoff_state.imots_new_min_state  		(u64 *)ia64_sal_to_os=
_handoff_state.pal_min_state;
-
 }
=20
 /*
@@ -797,21 +791,21 @@
 void
 ia64_mca_ucmc_handler(void)
 {
-	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t *)
-		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover =3D psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
+	ia64_set_default_os2sal_state(); /* set default values */
=20
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
=20
 	/*
+	 * Try to recover from MCA
+	 */
+	ia64_mca_try_to_recover(IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA));
+
+	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
 	 *  loop.
 	 */
 	ia64_mca_wakeup_all();
-
-	/* Return to SAL */
-	ia64_return_to_sal_check(recover);
 }
=20
 static DECLARE_WORK(cmc_disable_work, ia64_mca_cmc_vector_disable_keventd,=
 NULL);
@@ -1266,6 +1260,7 @@
 	ia64_log_init(SAL_INFO_TYPE_INIT);
 	ia64_log_init(SAL_INFO_TYPE_CMC);
 	ia64_log_init(SAL_INFO_TYPE_CPE);
+	ia64_mca_init_for_recovery();
=20
 	printk(KERN_INFO "MCA related initialization done\n");
 }
diff -Nur linux-2.6.5/arch/ia64/kernel/mca_asm.S linux-2.6.5-recovery/arch/=
ia64/kernel/mca_asm.S
--- linux-2.6.5/arch/ia64/kernel/mca_asm.S	2004-04-04 12:38:13.000000000 +0=
900
+++ linux-2.6.5-recovery/arch/ia64/kernel/mca_asm.S	2004-04-09 17:30:36.461=
256977 +0900
@@ -925,3 +925,35 @@
 GLOBAL_ENTRY(ia64_slave_init_handler)
 1:	br.sptk 1b
 END(ia64_slave_init_handler)
+
+GLOBAL_ENTRY(ia64_mca_handler_bhhook)
+{	.mfi
+	alloc 		r33=3Dar.pfs,0,4,0,0
+	nop.f		0
+	mov		r32=B0;;
+}
+{	.mlx
+	nop.m		0
+	movl		r34=3Dia64_mca_handler_bh;;
+}
+{	.mmi
+	mov		r35=3Dr8
+	nop.m		0
+	mov		b6=3Dr34;;
+}
+{	.mfb
+	nop.m		0
+	nop.f		0
+	br.call.sptk.many    b0=B6;;
+}
+{	.mii
+	nop.m		0
+	mov		ar.pfs=3Dr33
+	mov 		b0=3Dr32;;
+}
+{	.mfb
+	mov		r8=3Dr0
+	nop.f		0
+	br.ret.sptk.many b0;;
+}
+END(ia64_mca_handler_bhhook)
diff -Nur linux-2.6.5/arch/ia64/kernel/mca_recovery.c linux-2.6.5-recovery/=
arch/ia64/kernel/mca_recovery.c
--- linux-2.6.5/arch/ia64/kernel/mca_recovery.c	1970-01-01 09:00:00.0000000=
00 +0900
+++ linux-2.6.5-recovery/arch/ia64/kernel/mca_recovery.c	2004-04-09 17:30:3=
6.473952290 +0900
@@ -0,0 +1,626 @@
+/*
+ * File:	mca_recovery.c
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
+#include "mca_recovery.h"
+
+extern ia64_mca_sal_to_os_state_t ia64_sal_to_os_handoff_state;
+extern ia64_mca_os_to_sal_state_t ia64_os_to_sal_handoff_state;
+extern void *ia64_mca_handler_bhhook(void);
+
+typedef enum {
+	RECOVERY_ON_PROCESSING	   =3D IA64_MCA_CORRECTED + 1,
+	RECOVERY_OK 		   =3D IA64_MCA_CORRECTED,
+	RECOVERY_NG_THEN_COLD_BOOT =3D IA64_MCA_COLD_BOOT,
+	RECOVERY_NG_THEN_WARM_BOOT =3D IA64_MCA_WARM_BOOT,
+	RECOVERY_NG_THEN_HALT 	   =3D IA64_MCA_COLD_BOOT,
+} os_recovery_state_t;
+
+typedef enum {
+	MCA_IS_LOCAL  =3D 0,
+	MCA_IS_GLOBAL =3D 1
+} mca_type_t;
+
+#define MAX_PAGE_ISOLATE 16
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
+        { slidx_list_t *hl =3D &slidx_pool.buffer[slidx_pool.cur_idx]; \
+          hl->hdr =3D ptr; \
+          list_add(&hl->list, &(sect)); \
+          slidx_pool.cur_idx =3D (slidx_pool.cur_idx + 1)%slidx_pool.max_i=
dx; }
+
+/*
+ * ia64_mca_page_isolate
+ *
+ *	isolate a poisoned page	in order not to use it later
+ *=20
+ *  Input	: paddr (poisoned memory location)
+ *  Output	: isolate_status (whether page isolation was succeeded=20
+ *					or failed.)
+ */
+static isolate_status_t
+ia64_mca_page_isolate(unsigned long paddr)
+{
+	int i;
+	struct page *p;
+
+	/* whether physical address is valid or not */
+	if ( !ia64_phys_addr_valid(paddr)=20
+		|| num_page_isolate =3D MAX_PAGE_ISOLATE )=20
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
+	/* page attribute has 'SLAB' or 'Reserved' */
+	if( PageSlab(p) || PageReserved(p) )
+		return FAIL_TO_ISOLATE;
+
+	/* add page attribute, 'Reserved' */
+	SetPageReserved(p);
+	/* register a page number */
+	page_isolate[num_page_isolate++] =3D p;
+
+	return ISOLATE_OK;
+}
+
+/*
+ * ia64_mca_hanlder_bh
+ *
+ *  Kill the process which occurred memory read error
+ *  and isolate a poisoned address.=20
+ *
+ *  Input	: paddr	(poisoned memory location)
+ */
+void
+ia64_mca_handler_bh(void/* *paddr*/)
+{
+	register u64 ia64_r8 asm("r8"); /* received from MCA Handler */
+	unsigned long paddr =3D ia64_r8;
+
+	if (ia64_mca_page_isolate(paddr) =3D ISOLATE_OK) {
+		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
+	} else {
+		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
+	}
+	/* terminate myself and send a signal */
+	do_group_exit(SIGKILL);
+}
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
+static void=20
+ia64_mca_make_peidx(sal_log_processor_info_t *slpi, peidx_table_t *peidx)
+{
+	/*=20
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
+/*
+ * ia64_mca_make_slidx
+ *
+ *  Make index of SAL error record=20
+ *
+ *  Inputs	:  buffer (pointer to SAL error record)
+ *  In/Outputs	:  slidx  (pointer to index of SAL error record)
+ *  Outputs	:  platform error status
+ */
+
+static int=20
+ia64_mca_make_slidx(void *buffer, slidx_table_t *slidx)
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
+	IA64_LOG_INDEX_INIT_PTR(slidx);
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
+	if (!slidx_pool.buffer) /* no space */
+		return platform_err;
+	for (ercd_pos =3D sizeof(sal_log_record_header_t), sects =3D 0;
+		ercd_pos < record_len; ercd_pos +=3D sp->len, sects++) {
+		sp =3D (sal_log_section_hdr_t *)((char*)buffer + ercd_pos);
+		if (!efi_guidcmp(sp->guid, SAL_PROC_DEV_ERR_SECT_GUID)) {
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->proc_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->mem_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->sel_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->pci_bus_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->smbios_dev_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->pci_comp_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->plat_specific_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->host_ctlr_err, sp);
+		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_BUS_ERR_SECT_GUID)) {
+			platform_err =3D 1;
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->plat_bus_err, sp);
+		} else {
+			IA64_LOG_INDEX_ADD_SECT_PTR(slidx->unsupported, sp);
+		}
+	}
+	slidx->n_sections =3D sects;
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
+void=20
+ia64_mca_init_for_recovery(void)
+{
+	int i;
+	/* SAL info type or SAL record max size */
+	int temp[] =3D { SAL_INFO_TYPE_MCA, SAL_INFO_TYPE_INIT,
+			SAL_INFO_TYPE_CMC, SAL_INFO_TYPE_CPE };
+	int rec_max_size;  /* Maximum size of SAL error records */
+	int sect_min_size; /* Minimum size of SAL error sections */
+	/* minimum size table of each section */
+	static int sal_log_sect_min_sizes[] =3D {=20
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
+	for (i =3D 0; i < sizeof temp/sizeof(int); i++)
+		temp[i] =3D ia64_sal_get_state_info_size(temp[i]);
+	rec_max_size =3D temp[0];
+	for (i =3D 1; i < sizeof temp/sizeof(int); i++)
+		if (rec_max_size < temp[i])
+			rec_max_size =3D temp[i];
+
+	/* - 2 - */
+	sect_min_size =3D sal_log_sect_min_sizes[0];
+	for (i =3D 1; i < sizeof sal_log_sect_min_sizes/sizeof(size_t); i++)
+		if (sect_min_size > sal_log_sect_min_sizes[i])
+			sect_min_size =3D sal_log_sect_min_sizes[i];
+
+	/* - 3 - */
+	slidx_pool.max_idx =3D (rec_max_size/sect_min_size) * 2 + 1;
+	slidx_pool.buffer =3D (slidx_list_t *) alloc_bootmem(slidx_pool.max_idx *=
 sizeof(slidx_list_t));
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
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+	extern ia64_mca_sal_to_os_state_t ia64_sal_to_os_handoff_state;
+	enum {
+		SAL_RENDEZ_UNSUCCESSFUL =3D -1,
+		SAL_RENDEZ_NOT_REQUIRED =3D 0,
+		SAL_RENDEZ_SUCCESSFUL_INT =3D 1,
+		SAL_RENDEZ_SUCCESSFUL_INT_WITH_INIT =3D 2
+	};
+
+	/*=20
+	 * PAL can request a rendezvous, if the MCA has a global scope.
+	 * If "rz_always" flag is set, SAL requests MCA rendezvous=20
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
+recover_from_processor_error(slidx_table_t *slidx, peidx_table_t *peidx, p=
al_bus_check_info_t *pbci)
+{
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+
+	/*
+	 * Did we correct the error?
+	 * When TLB error has occured, we have already fixed TLB error.
+	 */
+	if (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))=20
+		return RECOVERY_OK;
+
+	/*=20
+	 * We cannot recover errors with other than bus_check.
+	 */
+	if (psp->cc || psp->rc || psp->uc)=20
+		return RECOVERY_NG_THEN_COLD_BOOT;
+
+	/*
+	 * If there is no bus error, record is weird but we need not to recover.
+	 */
+	if (psp->bc =3D 0 || pbci =3D NULL)
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
+	if (pbci->eb && pbci->bsi !=3D 1)
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
+recover_from_read_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bu=
s_check_info_t *pbci)
+{
+	sal_log_mod_error_info_t *smei;
+	pal_min_state_area_t *pmsa;
+	struct ia64_psr *ia64psr;
+	struct ia64_func_st {
+		unsigned long ip;
+		unsigned long gp;
+	};
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
+	ia64psr =3D(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
+        /*
+         *  Check the privilege level of interrupted context.
+         *   If it is user-mode, then terminate affected process.
+         */
+	if ((ia64psr->cpl !=3D 0)
+                /*
+                 * Check the privilege level when received poisoned data.
+                 *  If it is user-mode, then terminate offending process.
+                 */
+                || (pbci->pv && pbci->pl !=3D 0)) {
+                smei =3D peidx_bus_check(peidx, 0);
+                if (smei->valid.target_identifier) {
+                        /*
+                         *  setup for resume to bottom half of MCA,
+                         * "ia64_mca_handler_bhhook"
+                         */
+			pmsa =3D (pal_min_state_area_t *)(ia64_sal_to_os_handoff_state.pal_min_=
state | (6ul<<61));
+			/* pass to bhhook as 1st argument (gr8) */
+			pmsa->pmsa_gr[8-1] =3D smei->target_identifier;
+			/* set interrupted return address */
+			/* but no use                     */
+			pmsa->pmsa_br0 =3D pmsa->pmsa_iip;
+			/* change resume address to bhhook */
+			pmsa->pmsa_iip =3D ((struct ia64_func_st*)ia64_mca_handler_bhhook)->ip;
+			ia64_os_to_sal_handoff_state.imots_context =3D IA64_MCA_SAME_CONTEXT;
+
+			return RECOVERY_OK;
+		}
+
+	}=20
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
+recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx, pa=
l_bus_check_info_t *pbci)
+{
+	os_recovery_state_t status =3D RECOVERY_NG_THEN_COLD_BOOT;
+	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+
+	if (psp->bc && psp->co && psp->ci && pbci->eb && pbci->bsi =3D 1) {
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
+/*
+ * ia64_mca_try_to_recover
+ *
+ *  Try to recover from MCA
+ *
+ * Inputs	: rec 	    (pointer to a SAL error record)
+ * Outputs	: None
+ */
+
+
+void
+ia64_mca_try_to_recover(void *rec)
+{
+	u64 os_status;
+	int platform_err;
+	int n_proc_err;
+	slidx_table_t slidx;
+	peidx_table_t peidx;
+	pal_bus_check_info_t pbci;
+
+	/* Make index of SAL error record */
+	platform_err =3D ia64_mca_make_slidx(rec, &slidx);
+
+	/* Count processor error sections */
+	n_proc_err =3D slidx_count(&slidx, proc_err);
+
+	 /* Now, OS can recover when there is one processor error section */
+	if (n_proc_err > 1)
+		return;
+	else if (n_proc_err =3D 0) {
+		/* Weird SAL record ... We need not to recover */
+		ia64_os_to_sal_handoff_state.imots_os_status =3D IA64_MCA_CORRECTED;
+
+		return;
+	}
+
+	/* Make index of processor error section */
+	ia64_mca_make_peidx((sal_log_processor_info_t*)slidx_first_entry(&slidx.p=
roc_err)->hdr, &peidx);
+
+	/* Extract Processor BUS_CHECK[0] */
+	*((u64*)&pbci) =3D peidx_check_info(&peidx, bus_check, 0);
+
+	/* Check whether MCA is global or not */
+	if (is_mca_global(&peidx, &pbci))
+		return;
+=09
+	/* Try to recover a processor error */
+	if ((os_status =3D recover_from_processor_error(&slidx, &peidx, &pbci)) !=
=3D RECOVERY_ON_PROCESSING) {
+		ia64_os_to_sal_handoff_state.imots_os_status =3D os_status;
+
+		return;
+	}
+
+	/* Try to recover a platform error */
+	if (platform_err) {
+		os_status =3D recover_from_platform_error(&slidx, &peidx, &pbci);
+		ia64_os_to_sal_handoff_state.imots_os_status =3D os_status;
+	}
+}
+
+
diff -Nur linux-2.6.5/arch/ia64/kernel/mca_recovery.h linux-2.6.5-recovery/=
arch/ia64/kernel/mca_recovery.h
--- linux-2.6.5/arch/ia64/kernel/mca_recovery.h	1970-01-01 09:00:00.0000000=
00 +0900
+++ linux-2.6.5-recovery/arch/ia64/kernel/mca_recovery.h	2004-04-09 17:30:3=
6.473952290 +0900
@@ -0,0 +1,111 @@
+/*
+ * File:	mca_recovery.h
+ * Purpose:	Define helpers for Generic MCA handling
+ */
+
+/*=20
+ * Processor error section:=20
+ *=20
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
+	(((head)->next !=3D (head)) ? list_entry((head)->next, typeof(slidx_list_=
t), list) : NULL)
+#define slidx_count(slidx, sec) \
+({	int __count =3D 0; \
+	slidx_list_t *__pos; \
+	slidx_foreach_entry(__pos, &((slidx)->sec)) { __count++; }\
+	__count; })
+
diff -Nur linux-2.6.5/include/asm-ia64/mca.h linux-2.6.5-recovery/include/a=
sm-ia64/mca.h
--- linux-2.6.5/include/asm-ia64/mca.h	2004-04-04 12:36:26.000000000 +0900
+++ linux-2.6.5-recovery/include/asm-ia64/mca.h	2004-04-09 17:30:36.4749288=
52 +0900
@@ -114,6 +114,7 @@
 extern void ia64_monarch_init_handler(void);
 extern void ia64_slave_init_handler(void);
 extern void ia64_mca_cmc_vector_setup(void);
+extern void ia64_mca_handler_bh(void /***/);
=20
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_MCA_H */
diff -Nur linux-2.6.5/include/asm-ia64/sal.h linux-2.6.5-recovery/include/a=
sm-ia64/sal.h
--- linux-2.6.5/include/asm-ia64/sal.h	2004-04-04 12:38:18.000000000 +0900
+++ linux-2.6.5-recovery/include/asm-ia64/sal.h	2004-04-09 17:30:36.4759054=
15 +0900
@@ -319,7 +319,12 @@
 typedef struct sal_log_record_header {
 	u64 id;				/* Unique monotonically increasing ID */
 	sal_log_revision_t revision;	/* Major and Minor revision of header */
-	u16 severity;			/* Error Severity */
+	u8  severity;			/* Error Severity */
+	struct {
+		u8 platform_guid : 1,
+		   timestamp     : 1,
+		   reserved      : 6;
+	} valid;
 	u32 len;			/* Length of this error log in bytes */
 	sal_log_timestamp_t timestamp;	/* Timestamp */
 	efi_guid_t platform_guid;	/* Unique OEM Platform ID */
@@ -329,7 +334,16 @@
 typedef struct sal_log_sec_header {
     efi_guid_t guid;			/* Unique Section ID */
     sal_log_revision_t revision;	/* Major and Minor revision of Section */
-    u16 reserved;
+    struct {
+	u8 valid_information       : 1,
+	   reserved                : 2,
+	   resoruce_not_accessible : 1,
+	   error_threshold_exceed  : 1,
+	   reset                   : 1,
+	   containment_warning     : 1,
+	   error_corrected         : 1;
+    } error_recovery_info;
+    u8  reserved;
     u32 len;				/* Section length */
 } sal_log_section_hdr_t;
=20
@@ -364,7 +378,7 @@
 	u64 cr[128];
 	u64 ar[128];
 	u64 rr[8];
-	struct ia64_fpreg fr[128];
+	struct ia64_fpreg __attribute__ ((packed)) fr[128];
 } sal_processor_static_info_t;
=20
 struct sal_cpuid_info {
@@ -474,7 +488,8 @@
 		    event_data1     : 1,
 		    event_data2     : 1,
 		    event_data3     : 1,
-		    reserved        : 54;
+		    timestamp       : 1,
+		    reserved        : 53;
 	} valid;
 	u16 record_id;
 	u8 record_type;
@@ -569,12 +584,21 @@
 	sal_log_section_hdr_t header;
 	struct {
 		u64 err_status      : 1,
-		    guid            : 1,
+		    requestor_id    : 1,
+		    responder_id    : 1,
+		    target_id       : 1,
+		    bus_spec_data   : 1,
+		    oem_id          : 1,
 		    oem_data        : 1,
-		    reserved        : 61;
+		    oem_device      : 1,
+		    reserved        : 56;
 	} valid;
 	u64 err_status;
-	efi_guid_t guid;
+	u64 requestor_id;
+	u64 responder_id;
+	u64 target_id;
+	u64 bus_spec_data;
+	u64 oem_component_id[2];
 	u8 oem_data[1];			/* platform specific variable length data */
 } sal_log_plat_specific_err_info_t;
=20

