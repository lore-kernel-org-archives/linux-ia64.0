From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 16 Sep 2005 18:45:22 +0000
Subject: bug fix git pull on ia64 linux tree
Message-Id: <200509161845.j8GIjMAR009962@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git relea=
se

More cleanup for 2.6.14.  The big piece is some documentation from Keith
on how machine check works on ia64 under Linux.  The other two commits
just cleanup some warnings and coding style.

[Note for ia64 readers, these commits have also been applied to the test tr=
ee]

Thanks!

-Tony

 Documentation/ia64/mca.txt     |  194 ++++++++++++++++++++++++++++++++++++=
+++++
 arch/ia64/kernel/acpi.c        |    2=20
 arch/ia64/kernel/entry.S       |    2=20
 arch/ia64/kernel/mca_drv.c     |  114 ++++++++++++++----------
 arch/ia64/kernel/mca_drv.h     |    2=20
 arch/ia64/kernel/mca_drv_asm.S |   48 +++++-----
 arch/ia64/kernel/perfmon.c     |    2=20
 drivers/char/agp/hp-agp.c      |    2=20
 8 files changed, 292 insertions(+), 74 deletions(-)

Hidetoshi Seto:
  [IA64] mca_drv cleanup

Keith Owens:
  [IA64] Add Documentation/ia64/mca.txt

Peter Chubb:
  [IA64] Remove warnings for gcc 4.0 IA64 compilation.


diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -84,23 +84,23 @@ mca_page_isolate(unsigned long paddr)
 	struct page *p;
=20
 	/* whether physical address is valid or not */
-	if ( !ia64_phys_addr_valid(paddr) )=20
+	if (!ia64_phys_addr_valid(paddr))
 		return ISOLATE_NG;
=20
 	/* convert physical address to physical page number */
 	p =3D pfn_to_page(paddr>>PAGE_SHIFT);
=20
 	/* check whether a page number have been already registered or not */
-	for( i =3D 0; i < num_page_isolate; i++ )
-		if( page_isolate[i] =3D p )
+	for (i =3D 0; i < num_page_isolate; i++)
+		if (page_isolate[i] =3D p)
 			return ISOLATE_OK; /* already listed */
=20
 	/* limitation check */
-	if( num_page_isolate =3D MAX_PAGE_ISOLATE )=20
+	if (num_page_isolate =3D MAX_PAGE_ISOLATE)
 		return ISOLATE_NG;
=20
 	/* kick pages having attribute 'SLAB' or 'Reserved' */
-	if( PageSlab(p) || PageReserved(p) )=20
+	if (PageSlab(p) || PageReserved(p))
 		return ISOLATE_NG;
=20
 	/* add attribute 'Reserved' and register the page */
@@ -139,10 +139,10 @@ mca_handler_bh(unsigned long paddr)
  * @peidx:	pointer to index of processor error section
  */
=20
-static void=20
+static void
 mca_make_peidx(sal_log_processor_info_t *slpi, peidx_table_t *peidx)
 {
-	/*=20
+	/*
 	 * calculate the start address of
 	 *   "struct cpuid_info" and "sal_processor_static_info_t".
 	 */
@@ -164,7 +164,7 @@ mca_make_peidx(sal_log_processor_info_t=20
 }
=20
 /**
- * mca_make_slidx -  Make index of SAL error record=20
+ * mca_make_slidx -  Make index of SAL error record
  * @buffer:	pointer to SAL error record
  * @slidx:	pointer to index of SAL error record
  *
@@ -172,12 +172,12 @@ mca_make_peidx(sal_log_processor_info_t=20
  *	1 if record has platform error / 0 if not
  */
 #define LOG_INDEX_ADD_SECT_PTR(sect, ptr) \
-        { slidx_list_t *hl =3D &slidx_pool.buffer[slidx_pool.cur_idx]; \
-          hl->hdr =3D ptr; \
-          list_add(&hl->list, &(sect)); \
-          slidx_pool.cur_idx =3D (slidx_pool.cur_idx + 1)%slidx_pool.max_i=
dx; }
+	{slidx_list_t *hl =3D &slidx_pool.buffer[slidx_pool.cur_idx]; \
+	hl->hdr =3D ptr; \
+	list_add(&hl->list, &(sect)); \
+	slidx_pool.cur_idx =3D (slidx_pool.cur_idx + 1)%slidx_pool.max_idx; }
=20
-static int=20
+static int
 mca_make_slidx(void *buffer, slidx_table_t *slidx)
 {
 	int platform_err =3D 0;
@@ -214,28 +214,36 @@ mca_make_slidx(void *buffer, slidx_table
 		sp =3D (sal_log_section_hdr_t *)((char*)buffer + ercd_pos);
 		if (!efi_guidcmp(sp->guid, SAL_PROC_DEV_ERR_SECT_GUID)) {
 			LOG_INDEX_ADD_SECT_PTR(slidx->proc_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_MEM_DEV_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->mem_dev_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_SEL_DEV_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->sel_dev_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_PCI_BUS_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->pci_bus_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->smbios_dev_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_PCI_COMP_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->pci_comp_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_SPECIFIC_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->plat_specific_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_HOST_CTLR_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->host_ctlr_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_BUS_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_BUS_ERR_SECT_GUID)) {
 			platform_err =3D 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->plat_bus_err, sp);
 		} else {
@@ -253,15 +261,16 @@ mca_make_slidx(void *buffer, slidx_table
  * Return value:
  *	0 on Success / -ENOMEM on Failure
  */
-static int=20
+static int
 init_record_index_pools(void)
 {
 	int i;
 	int rec_max_size;  /* Maximum size of SAL error records */
 	int sect_min_size; /* Minimum size of SAL error sections */
 	/* minimum size table of each section */
-	static int sal_log_sect_min_sizes[] =3D {=20
-		sizeof(sal_log_processor_info_t) + sizeof(sal_processor_static_info_t),
+	static int sal_log_sect_min_sizes[] =3D {
+		sizeof(sal_log_processor_info_t)
+		+ sizeof(sal_processor_static_info_t),
 		sizeof(sal_log_mem_dev_err_info_t),
 		sizeof(sal_log_sel_dev_err_info_t),
 		sizeof(sal_log_pci_bus_err_info_t),
@@ -294,7 +303,8 @@ init_record_index_pools(void)
=20
 	/* - 3 - */
 	slidx_pool.max_idx =3D (rec_max_size/sect_min_size) * 2 + 1;
-	slidx_pool.buffer =3D (slidx_list_t *) kmalloc(slidx_pool.max_idx * sizeo=
f(slidx_list_t), GFP_KERNEL);
+	slidx_pool.buffer =3D (slidx_list_t *)
+		kmalloc(slidx_pool.max_idx * sizeof(slidx_list_t), GFP_KERNEL);
=20
 	return slidx_pool.buffer ? 0 : -ENOMEM;
 }
@@ -308,6 +318,7 @@ init_record_index_pools(void)
  * is_mca_global - Check whether this MCA is global or not
  * @peidx:	pointer of index of processor error section
  * @pbci:	pointer to pal_bus_check_info_t
+ * @sos:	pointer to hand off struct between SAL and OS
  *
  * Return value:
  *	MCA_IS_LOCAL / MCA_IS_GLOBAL
@@ -317,11 +328,12 @@ static mca_type_t
 is_mca_global(peidx_table_t *peidx, pal_bus_check_info_t *pbci,
 	      struct ia64_sal_os_state *sos)
 {
-	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+	pal_processor_state_info_t *psp +		(pal_processor_state_info_t*)peidx_psp=
(peidx);
=20
-	/*=20
+	/*
 	 * PAL can request a rendezvous, if the MCA has a global scope.
-	 * If "rz_always" flag is set, SAL requests MCA rendezvous=20
+	 * If "rz_always" flag is set, SAL requests MCA rendezvous
 	 * in spite of global MCA.
 	 * Therefore it is local MCA when rendezvous has not been requested.
 	 * Failed to rendezvous, the system must be down.
@@ -381,13 +393,15 @@ is_mca_global(peidx_table_t *peidx, pal_
  * @slidx:	pointer of index of SAL error record
  * @peidx:	pointer of index of processor error section
  * @pbci:	pointer of pal_bus_check_info
+ * @sos:	pointer to hand off struct between SAL and OS
  *
  * Return value:
  *	1 on Success / 0 on Failure
  */
=20
 static int
-recover_from_read_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bu=
s_check_info_t *pbci,
+recover_from_read_error(slidx_table_t *slidx,
+			peidx_table_t *peidx, pal_bus_check_info_t *pbci,
 			struct ia64_sal_os_state *sos)
 {
 	sal_log_mod_error_info_t *smei;
@@ -453,24 +467,28 @@ recover_from_read_error(slidx_table_t *s
  * @slidx:	pointer of index of SAL error record
  * @peidx:	pointer of index of processor error section
  * @pbci:	pointer of pal_bus_check_info
+ * @sos:	pointer to hand off struct between SAL and OS
  *
  * Return value:
  *	1 on Success / 0 on Failure
  */
=20
 static int
-recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx, pa=
l_bus_check_info_t *pbci,
+recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx,
+			    pal_bus_check_info_t *pbci,
 			    struct ia64_sal_os_state *sos)
 {
 	int status =3D 0;
-	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+	pal_processor_state_info_t *psp +		(pal_processor_state_info_t*)peidx_psp=
(peidx);
=20
 	if (psp->bc && pbci->eb && pbci->bsi =3D 0) {
 		switch(pbci->type) {
 		case 1: /* partial read */
 		case 3: /* full line(cpu) read */
 		case 9: /* I/O space read */
-			status =3D recover_from_read_error(slidx, peidx, pbci, sos);
+			status =3D recover_from_read_error(slidx, peidx, pbci,
+							 sos);
 			break;
 		case 0: /* unknown */
 		case 2: /* partial write */
@@ -481,7 +499,8 @@ recover_from_platform_error(slidx_table_
 		case 8: /* write coalescing transactions */
 		case 10: /* I/O space write */
 		case 11: /* inter-processor interrupt message(IPI) */
-		case 12: /* interrupt acknowledge or external task priority cycle */
+		case 12: /* interrupt acknowledge or
+				external task priority cycle */
 		default:
 			break;
 		}
@@ -496,6 +515,7 @@ recover_from_platform_error(slidx_table_
  * @slidx:	pointer of index of SAL error record
  * @peidx:	pointer of index of processor error section
  * @pbci:	pointer of pal_bus_check_info
+ * @sos:	pointer to hand off struct between SAL and OS
  *
  * Return value:
  *	1 on Success / 0 on Failure
@@ -509,15 +529,17 @@ recover_from_platform_error(slidx_table_
  */
=20
 static int
-recover_from_processor_error(int platform, slidx_table_t *slidx, peidx_tab=
le_t *peidx, pal_bus_check_info_t *pbci,
+recover_from_processor_error(int platform, slidx_table_t *slidx,
+			     peidx_table_t *peidx, pal_bus_check_info_t *pbci,
 			     struct ia64_sal_os_state *sos)
 {
-	pal_processor_state_info_t *psp =3D (pal_processor_state_info_t*)peidx_ps=
p(peidx);
+	pal_processor_state_info_t *psp +		(pal_processor_state_info_t*)peidx_psp=
(peidx);
=20
-	/*=20
+	/*
 	 * We cannot recover errors with other than bus_check.
 	 */
-	if (psp->cc || psp->rc || psp->uc)=20
+	if (psp->cc || psp->rc || psp->uc)
 		return 0;
=20
 	/*
@@ -546,10 +568,10 @@ recover_from_processor_error(int platfor
 	 * (e.g. a load from poisoned memory)
 	 * This means "there are some platform errors".
 	 */
-	if (platform)=20
+	if (platform)
 		return recover_from_platform_error(slidx, peidx, pbci, sos);
-	/*=20
-	 * On account of strange SAL error record, we cannot recover.=20
+	/*
+	 * On account of strange SAL error record, we cannot recover.
 	 */
 	return 0;
 }
@@ -557,14 +579,14 @@ recover_from_processor_error(int platfor
 /**
  * mca_try_to_recover - Try to recover from MCA
  * @rec:	pointer to a SAL error record
+ * @sos:	pointer to hand off struct between SAL and OS
  *
  * Return value:
  *	1 on Success / 0 on Failure
  */
=20
 static int
-mca_try_to_recover(void *rec,=20
-	struct ia64_sal_os_state *sos)
+mca_try_to_recover(void *rec, struct ia64_sal_os_state *sos)
 {
 	int platform_err;
 	int n_proc_err;
@@ -588,7 +610,8 @@ mca_try_to_recover(void *rec,=20
 	}
=20
 	/* Make index of processor error section */
-	mca_make_peidx((sal_log_processor_info_t*)slidx_first_entry(&slidx.proc_e=
rr)->hdr, &peidx);
+	mca_make_peidx((sal_log_processor_info_t*)
+		slidx_first_entry(&slidx.proc_err)->hdr, &peidx);
=20
 	/* Extract Processor BUS_CHECK[0] */
 	*((u64*)&pbci) =3D peidx_check_info(&peidx, bus_check, 0);
@@ -598,7 +621,8 @@ mca_try_to_recover(void *rec,=20
 		return 0;
 =09
 	/* Try to recover a processor error */
-	return recover_from_processor_error(platform_err, &slidx, &peidx, &pbci, =
sos);
+	return recover_from_processor_error(platform_err, &slidx, &peidx,
+					    &pbci, sos);
 }
=20
 /*
@@ -611,7 +635,7 @@ int __init mca_external_handler_init(voi
 		return -ENOMEM;
=20
 	/* register external mca handlers */
-	if (ia64_reg_MCA_extension(mca_try_to_recover)){=09
+	if (ia64_reg_MCA_extension(mca_try_to_recover)) {=09
 		printk(KERN_ERR "ia64_reg_MCA_extension failed.\n");
 		kfree(slidx_pool.buffer);
 		return -EFAULT;
diff --git a/arch/ia64/kernel/mca_drv.h b/arch/ia64/kernel/mca_drv.h
--- a/arch/ia64/kernel/mca_drv.h
+++ b/arch/ia64/kernel/mca_drv.h
@@ -6,7 +6,7 @@
  * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
  */
 /*
- * Processor error section:=20
+ * Processor error section:
  *
  *  +-sal_log_processor_info_t *info-------------+
  *  | sal_log_section_hdr_t header;              |
diff --git a/arch/ia64/kernel/mca_drv_asm.S b/arch/ia64/kernel/mca_drv_asm.S
--- a/arch/ia64/kernel/mca_drv_asm.S
+++ b/arch/ia64/kernel/mca_drv_asm.S
@@ -13,45 +13,45 @@
 #include <asm/ptrace.h>
=20
 GLOBAL_ENTRY(mca_handler_bhhook)
-	invala						// clear RSE ?
-	;;						//
-	cover						//=20
-	;;						//
-	clrrrb						//
+	invala				// clear RSE ?
+	;;
+	cover
+	;;
+	clrrrb
 	;;					=09
-	alloc		r16=3Dar.pfs,0,2,1,0		// make a new frame
+	alloc	r16=3Dar.pfs,0,2,1,0	// make a new frame
 	;;
-	mov		ar.rsc=3D0
+	mov	ar.rsc=3D0
 	;;
-	mov		r13=3DIA64_KR(CURRENT)		// current task pointer
+	mov	r13=3DIA64_KR(CURRENT)	// current task pointer
 	;;
-	mov		r2=3Dr13
+	mov	r2=3Dr13
 	;;
-	addl		r22=3DIA64_RBS_OFFSET,r2
+	addl	r22=3DIA64_RBS_OFFSET,r2
 	;;
-	mov		ar.bspstore=3Dr22
+	mov	ar.bspstore=3Dr22
 	;;
-	addl		sp=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2
+	addl	sp=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2
 	;;
-	adds		r2=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	adds	r2=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
-	st1		[r2]=3Dr0				// clear current->thread.on_ustack flag
-	mov		loc0=3Dr16
-	movl		loc1=3Dmca_handler_bh		// recovery C function
+	st1	[r2]=3Dr0		// clear current->thread.on_ustack flag
+	mov	loc0=3Dr16
+	movl	loc1=3Dmca_handler_bh	// recovery C function
 	;;
-	mov		out0=3Dr8				// poisoned address
-	mov		b6=3Dloc1
+	mov	out0=3Dr8			// poisoned address
+	mov	b6=3Dloc1
 	;;
-	mov		loc1=3Drp
+	mov	loc1=3Drp
 	;;
-	ssm		psr.i
+	ssm	psr.i
 	;;
-	br.call.sptk.many    rp=B6			// does not return ...
+	br.call.sptk.many rp=B6		// does not return ...
 	;;
-	mov		ar.pfs=3Dloc0
-	mov 		rp=3Dloc1
+	mov	ar.pfs=3Dloc0
+	mov 	rp=3Dloc1
 	;;
-	mov		r8=3Dr0
+	mov	r8=3Dr0
 	br.ret.sptk.many rp
 	;;
 END(mca_handler_bhhook)

diff-tree 8ee9e23d41d2c51fafd158861fa4639fb199baf0 (from 24b8e0cc09483adc0f=
dd9c68914b19597bb9fddc)
Author: Keith Owens <kaos@sgi.com>
Date:   Fri Sep 16 14:49:14 2005 +1000

    [IA64] Add Documentation/ia64/mca.txt
   =20
    Add Documentation/ia64/mca.txt, an ad-hoc collection of notes on IA64
    MCA and INIT processing.
   =20
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/Documentation/ia64/mca.txt b/Documentation/ia64/mca.txt
new file mode 100644
--- /dev/null
+++ b/Documentation/ia64/mca.txt
@@ -0,0 +1,194 @@
+An ad-hoc collection of notes on IA64 MCA and INIT processing.  Feel
+free to update it with notes about any area that is not clear.
+
+---
+
+MCA/INIT are completely asynchronous.  They can occur at any time, when
+the OS is in any state.  Including when one of the cpus is already
+holding a spinlock.  Trying to get any lock from MCA/INIT state is
+asking for deadlock.  Also the state of structures that are protected
+by locks is indeterminate, including linked lists.
+
+---
+
+The complicated ia64 MCA process.  All of this is mandated by Intel's
+specification for ia64 SAL, error recovery and and unwind, it is not as
+if we have a choice here.
+
+* MCA occurs on one cpu, usually due to a double bit memory error.
+  This is the monarch cpu.
+
+* SAL sends an MCA rendezvous interrupt (which is a normal interrupt)
+  to all the other cpus, the slaves.
+
+* Slave cpus that receive the MCA interrupt call down into SAL, they
+  end up spinning disabled while the MCA is being serviced.
+
+* If any slave cpu was already spinning disabled when the MCA occurred
+  then it cannot service the MCA interrupt.  SAL waits ~20 seconds then
+  sends an unmaskable INIT event to the slave cpus that have not
+  already rendezvoused.
+
+* Because MCA/INIT can be delivered at any time, including when the cpu
+  is down in PAL in physical mode, the registers at the time of the
+  event are _completely_ undefined.  In particular the MCA/INIT
+  handlers cannot rely on the thread pointer, PAL physical mode can
+  (and does) modify TP.  It is allowed to do that as long as it resets
+  TP on return.  However MCA/INIT events expose us to these PAL
+  internal TP changes.  Hence curr_task().
+
+* If an MCA/INIT event occurs while the kernel was running (not user
+  space) and the kernel has called PAL then the MCA/INIT handler cannot
+  assume that the kernel stack is in a fit state to be used.  Mainly
+  because PAL may or may not maintain the stack pointer internally.
+  Because the MCA/INIT handlers cannot trust the kernel stack, they
+  have to use their own, per-cpu stacks.  The MCA/INIT stacks are
+  preformatted with just enough task state to let the relevant handlers
+  do their job.
+
+* Unlike most other architectures, the ia64 struct task is embedded in
+  the kernel stack[1].  So switching to a new kernel stack means that
+  we switch to a new task as well.  Because various bits of the kernel
+  assume that current points into the struct task, switching to a new
+  stack also means a new value for current.
+
+* Once all slaves have rendezvoused and are spinning disabled, the
+  monarch is entered.  The monarch now tries to diagnose the problem
+  and decide if it can recover or not.
+
+* Part of the monarch's job is to look at the state of all the other
+  tasks.  The only way to do that on ia64 is to call the unwinder,
+  as mandated by Intel.
+
+* The starting point for the unwind depends on whether a task is
+  running or not.  That is, whether it is on a cpu or is blocked.  The
+  monarch has to determine whether or not a task is on a cpu before it
+  knows how to start unwinding it.  The tasks that received an MCA or
+  INIT event are no longer running, they have been converted to blocked
+  tasks.  But (and its a big but), the cpus that received the MCA
+  rendezvous interrupt are still running on their normal kernel stacks!
+
+* To distinguish between these two cases, the monarch must know which
+  tasks are on a cpu and which are not.  Hence each slave cpu that
+  switches to an MCA/INIT stack, registers its new stack using
+  set_curr_task(), so the monarch can tell that the _original_ task is
+  no longer running on that cpu.  That gives us a decent chance of
+  getting a valid backtrace of the _original_ task.
+
+* MCA/INIT can be nested, to a depth of 2 on any cpu.  In the case of a
+  nested error, we want diagnostics on the MCA/INIT handler that
+  failed, not on the task that was originally running.  Again this
+  requires set_curr_task() so the MCA/INIT handlers can register their
+  own stack as running on that cpu.  Then a recursive error gets a
+  trace of the failing handler's "task".
+
+[1] My (Keith Owens) original design called for ia64 to separate its
+    struct task and the kernel stacks.  Then the MCA/INIT data would be
+    chained stacks like i386 interrupt stacks.  But that required
+    radical surgery on the rest of ia64, plus extra hard wired TLB
+    entries with its associated performance degradation.  David
+    Mosberger vetoed that approach.  Which meant that separate kernel
+    stacks meant separate "tasks" for the MCA/INIT handlers.
+
+---
+
+INIT is less complicated than MCA.  Pressing the nmi button or using
+the equivalent command on the management console sends INIT to all
+cpus.  SAL picks one one of the cpus as the monarch and the rest are
+slaves.  All the OS INIT handlers are entered at approximately the same
+time.  The OS monarch prints the state of all tasks and returns, after
+which the slaves return and the system resumes.
+
+At least that is what is supposed to happen.  Alas there are broken
+versions of SAL out there.  Some drive all the cpus as monarchs.  Some
+drive them all as slaves.  Some drive one cpu as monarch, wait for that
+cpu to return from the OS then drive the rest as slaves.  Some versions
+of SAL cannot even cope with returning from the OS, they spin inside
+SAL on resume.  The OS INIT code has workarounds for some of these
+broken SAL symptoms, but some simply cannot be fixed from the OS side.
+
+---
+
+The scheduler hooks used by ia64 (curr_task, set_curr_task) are layer
+violations.  Unfortunately MCA/INIT start off as massive layer
+violations (can occur at _any_ time) and they build from there.
+
+At least ia64 makes an attempt at recovering from hardware errors, but
+it is a difficult problem because of the asynchronous nature of these
+errors.  When processing an unmaskable interrupt we sometimes need
+special code to cope with our inability to take any locks.
+
+---
+
+How is ia64 MCA/INIT different from x86 NMI?
+
+* x86 NMI typically gets delivered to one cpu.  MCA/INIT gets sent to
+  all cpus.
+
+* x86 NMI cannot be nested.  MCA/INIT can be nested, to a depth of 2
+  per cpu.
+
+* x86 has a separate struct task which points to one of multiple kernel
+  stacks.  ia64 has the struct task embedded in the single kernel
+  stack, so switching stack means switching task.
+
+* x86 does not call the BIOS so the NMI handler does not have to worry
+  about any registers having changed.  MCA/INIT can occur while the cpu
+  is in PAL in physical mode, with undefined registers and an undefined
+  kernel stack.
+
+* i386 backtrace is not very sensitive to whether a process is running
+  or not.  ia64 unwind is very, very sensitive to whether a process is
+  running or not.
+
+---
+
+What happens when MCA/INIT is delivered what a cpu is running user
+space code?
+
+The user mode registers are stored in the RSE area of the MCA/INIT on
+entry to the OS and are restored from there on return to SAL, so user
+mode registers are preserved across a recoverable MCA/INIT.  Since the
+OS has no idea what unwind data is available for the user space stack,
+MCA/INIT never tries to backtrace user space.  Which means that the OS
+does not bother making the user space process look like a blocked task,
+i.e. the OS does not copy pt_regs and switch_stack to the user space
+stack.  Also the OS has no idea how big the user space RSE and memory
+stacks are, which makes it too risky to copy the saved state to a user
+mode stack.
+
+---
+
+How do we get a backtrace on the tasks that were running when MCA/INIT
+was delivered?
+
+mca.c:::ia64_mca_modify_original_stack().  That identifies and
+verifies the original kernel stack, copies the dirty registers from
+the MCA/INIT stack's RSE to the original stack's RSE, copies the
+skeleton struct pt_regs and switch_stack to the original stack, fills
+in the skeleton structures from the PAL minstate area and updates the
+original stack's thread.ksp.  That makes the original stack look
+exactly like any other blocked task, i.e. it now appears to be
+sleeping.  To get a backtrace, just start with thread.ksp for the
+original task and unwind like any other sleeping task.
+
+---
+
+How do we identify the tasks that were running when MCA/INIT was
+delivered?
+
+If the previous task has been verified and converted to a blocked
+state, then sos->prev_task on the MCA/INIT stack is updated to point to
+the previous task.  You can look at that field in dumps or debuggers.
+To help distinguish between the handler and the original tasks,
+handlers have _TIF_MCA_INIT set in thread_info.flags.
+
+The sos data is always in the MCA/INIT handler stack, at offset
+MCA_SOS_OFFSET.  You can get that value from mca_asm.h or calculate it
+as KERNEL_STACK_SIZE - sizeof(struct pt_regs) - sizeof(struct
+ia64_sal_os_state), with 16 byte alignment for all structures.
+
+Also the comm field of the MCA/INIT task is modified to include the pid
+of the original task, for humans to use.  For example, a comm field of
+'MCA 12159' means that pid 12159 was running when the MCA was
+delivered.

diff-tree 24b8e0cc09483adc0fdd9c68914b19597bb9fddc (from 065d9cac98a5406ecd=
5a1368f8fd38f55739dee9)
Author: Peter Chubb <peterc@gelato.unsw.edu.au>
Date:   Thu Sep 15 15:36:35 2005 +1000

    [IA64] Remove warnings for gcc 4.0 IA64 compilation.
   =20
    This patch removes some compilation warnings, mostly
    trivially. acpi.c fix also noted by Kenji Kaneshige.
   =20
    Signed-off-by; Peter Chubb <peterc@gelato.unsw.edu.au>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -899,7 +899,7 @@ int acpi_register_ioapic(acpi_handle han
 	if ((err =3D iosapic_init(phys_addr, gsi_base)))
 		return err;
=20
-#if CONFIG_ACPI_NUMA
+#ifdef CONFIG_ACPI_NUMA
 	acpi_map_iosapic(handle, 0, NULL, NULL);
 #endif				/* CONFIG_ACPI_NUMA */
=20
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -491,7 +491,7 @@ GLOBAL_ENTRY(prefetch_stack)
 	;;
 	lfetch.fault [r16], 128
 	br.ret.sptk.many rp
-END(prefetch_switch_stack)
+END(prefetch_stack)
=20
 GLOBAL_ENTRY(execve)
 	mov r15=3D__NR_execve			// put syscall number in place
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -574,7 +574,7 @@ pfm_protect_ctx_ctxsw(pfm_context_t *x)
 	return 0UL;
 }
=20
-static inline unsigned long
+static inline void
 pfm_unprotect_ctx_ctxsw(pfm_context_t *x, unsigned long f)
 {
 	spin_unlock(&(x)->ctx_lock);
diff --git a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
--- a/drivers/char/agp/hp-agp.c
+++ b/drivers/char/agp/hp-agp.c
@@ -252,7 +252,7 @@ hp_zx1_configure (void)
 		readl(hp->ioc_regs+HP_ZX1_PDIR_BASE);
 		writel(hp->io_tlb_ps, hp->ioc_regs+HP_ZX1_TCNFG);
 		readl(hp->ioc_regs+HP_ZX1_TCNFG);
-		writel(~(HP_ZX1_IOVA_SIZE-1), hp->ioc_regs+HP_ZX1_IMASK);
+		writel((unsigned int)(~(HP_ZX1_IOVA_SIZE-1)), hp->ioc_regs+HP_ZX1_IMASK);
 		readl(hp->ioc_regs+HP_ZX1_IMASK);
 		writel(hp->iova_base|1, hp->ioc_regs+HP_ZX1_IBASE);
 		readl(hp->ioc_regs+HP_ZX1_IBASE);
