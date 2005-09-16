From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 16 Sep 2005 03:14:49 +0000
Subject: [PATCH] mca_drv cleanup
Message-Id: <432A38A9.509@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030107060108080203010202"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030107060108080203010202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

There were some trailing white spaces, long lines, and so on.
This patch cleans them.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

--------------030107060108080203010202
Content-Type: text/plain;
 name="mca_drv_cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca_drv_cleanup.patch"

 arch/ia64/kernel/mca_drv.c     |  108 +++++++++++++++++++++++++----------------
 arch/ia64/kernel/mca_drv.h     |    2 
 arch/ia64/kernel/mca_drv_asm.S |   48 +++++++++---------
 3 files changed, 91 insertions(+), 67 deletions(-)

Index: linux-2.6.14-rc1/arch/ia64/kernel/mca_drv.c
===================================================================
--- linux-2.6.14-rc1.orig/arch/ia64/kernel/mca_drv.c
+++ linux-2.6.14-rc1/arch/ia64/kernel/mca_drv.c
@@ -84,7 +84,7 @@ mca_page_isolate(unsigned long paddr)
 	struct page *p;
 
 	/* whether physical address is valid or not */
-	if ( !ia64_phys_addr_valid(paddr) ) 
+	if ( !ia64_phys_addr_valid(paddr) )
 		return ISOLATE_NG;
 
 	/* convert physical address to physical page number */
@@ -96,11 +96,11 @@ mca_page_isolate(unsigned long paddr)
 			return ISOLATE_OK; /* already listed */
 
 	/* limitation check */
-	if( num_page_isolate == MAX_PAGE_ISOLATE ) 
+	if( num_page_isolate == MAX_PAGE_ISOLATE )
 		return ISOLATE_NG;
 
 	/* kick pages having attribute 'SLAB' or 'Reserved' */
-	if( PageSlab(p) || PageReserved(p) ) 
+	if( PageSlab(p) || PageReserved(p) )
 		return ISOLATE_NG;
 
 	/* add attribute 'Reserved' and register the page */
@@ -139,10 +139,10 @@ mca_handler_bh(unsigned long paddr)
  * @peidx:	pointer to index of processor error section
  */
 
-static void 
+static void
 mca_make_peidx(sal_log_processor_info_t *slpi, peidx_table_t *peidx)
 {
-	/* 
+	/*
 	 * calculate the start address of
 	 *   "struct cpuid_info" and "sal_processor_static_info_t".
 	 */
@@ -164,7 +164,7 @@ mca_make_peidx(sal_log_processor_info_t 
 }
 
 /**
- * mca_make_slidx -  Make index of SAL error record 
+ * mca_make_slidx -  Make index of SAL error record
  * @buffer:	pointer to SAL error record
  * @slidx:	pointer to index of SAL error record
  *
@@ -172,12 +172,12 @@ mca_make_peidx(sal_log_processor_info_t 
  *	1 if record has platform error / 0 if not
  */
 #define LOG_INDEX_ADD_SECT_PTR(sect, ptr) \
-        { slidx_list_t *hl = &slidx_pool.buffer[slidx_pool.cur_idx]; \
-          hl->hdr = ptr; \
-          list_add(&hl->list, &(sect)); \
-          slidx_pool.cur_idx = (slidx_pool.cur_idx + 1)%slidx_pool.max_idx; }
+	{slidx_list_t *hl = &slidx_pool.buffer[slidx_pool.cur_idx]; \
+	hl->hdr = ptr; \
+	list_add(&hl->list, &(sect)); \
+	slidx_pool.cur_idx = (slidx_pool.cur_idx + 1)%slidx_pool.max_idx; }
 
-static int 
+static int
 mca_make_slidx(void *buffer, slidx_table_t *slidx)
 {
 	int platform_err = 0;
@@ -214,28 +214,36 @@ mca_make_slidx(void *buffer, slidx_table
 		sp = (sal_log_section_hdr_t *)((char*)buffer + ercd_pos);
 		if (!efi_guidcmp(sp->guid, SAL_PROC_DEV_ERR_SECT_GUID)) {
 			LOG_INDEX_ADD_SECT_PTR(slidx->proc_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_MEM_DEV_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->mem_dev_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SEL_DEV_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_SEL_DEV_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->sel_dev_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_BUS_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_PCI_BUS_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->pci_bus_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->smbios_dev_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_PCI_COMP_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_PCI_COMP_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->pci_comp_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_SPECIFIC_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->plat_specific_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_HOST_CTLR_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_HOST_CTLR_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->host_ctlr_err, sp);
-		} else if (!efi_guidcmp(sp->guid, SAL_PLAT_BUS_ERR_SECT_GUID)) {
+		} else if (!efi_guidcmp(sp->guid,
+				SAL_PLAT_BUS_ERR_SECT_GUID)) {
 			platform_err = 1;
 			LOG_INDEX_ADD_SECT_PTR(slidx->plat_bus_err, sp);
 		} else {
@@ -253,15 +261,16 @@ mca_make_slidx(void *buffer, slidx_table
  * Return value:
  *	0 on Success / -ENOMEM on Failure
  */
-static int 
+static int
 init_record_index_pools(void)
 {
 	int i;
 	int rec_max_size;  /* Maximum size of SAL error records */
 	int sect_min_size; /* Minimum size of SAL error sections */
 	/* minimum size table of each section */
-	static int sal_log_sect_min_sizes[] = { 
-		sizeof(sal_log_processor_info_t) + sizeof(sal_processor_static_info_t),
+	static int sal_log_sect_min_sizes[] = {
+		sizeof(sal_log_processor_info_t)
+		+ sizeof(sal_processor_static_info_t),
 		sizeof(sal_log_mem_dev_err_info_t),
 		sizeof(sal_log_sel_dev_err_info_t),
 		sizeof(sal_log_pci_bus_err_info_t),
@@ -294,7 +303,8 @@ init_record_index_pools(void)
 
 	/* - 3 - */
 	slidx_pool.max_idx = (rec_max_size/sect_min_size) * 2 + 1;
-	slidx_pool.buffer = (slidx_list_t *) kmalloc(slidx_pool.max_idx * sizeof(slidx_list_t), GFP_KERNEL);
+	slidx_pool.buffer = (slidx_list_t *)
+		kmalloc(slidx_pool.max_idx * sizeof(slidx_list_t), GFP_KERNEL);
 
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
-	pal_processor_state_info_t *psp = (pal_processor_state_info_t*)peidx_psp(peidx);
+	pal_processor_state_info_t *psp =
+		(pal_processor_state_info_t*)peidx_psp(peidx);
 
-	/* 
+	/*
 	 * PAL can request a rendezvous, if the MCA has a global scope.
-	 * If "rz_always" flag is set, SAL requests MCA rendezvous 
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
 
 static int
-recover_from_read_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bus_check_info_t *pbci,
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
 
 static int
-recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx, pal_bus_check_info_t *pbci,
+recover_from_platform_error(slidx_table_t *slidx, peidx_table_t *peidx,
+			    pal_bus_check_info_t *pbci,
 			    struct ia64_sal_os_state *sos)
 {
 	int status = 0;
-	pal_processor_state_info_t *psp = (pal_processor_state_info_t*)peidx_psp(peidx);
+	pal_processor_state_info_t *psp =
+		(pal_processor_state_info_t*)peidx_psp(peidx);
 
 	if (psp->bc && pbci->eb && pbci->bsi == 0) {
 		switch(pbci->type) {
 		case 1: /* partial read */
 		case 3: /* full line(cpu) read */
 		case 9: /* I/O space read */
-			status = recover_from_read_error(slidx, peidx, pbci, sos);
+			status = recover_from_read_error(slidx, peidx, pbci,
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
 
 static int
-recover_from_processor_error(int platform, slidx_table_t *slidx, peidx_table_t *peidx, pal_bus_check_info_t *pbci,
+recover_from_processor_error(int platform, slidx_table_t *slidx,
+			     peidx_table_t *peidx, pal_bus_check_info_t *pbci,
 			     struct ia64_sal_os_state *sos)
 {
-	pal_processor_state_info_t *psp = (pal_processor_state_info_t*)peidx_psp(peidx);
+	pal_processor_state_info_t *psp =
+		(pal_processor_state_info_t*)peidx_psp(peidx);
 
-	/* 
+	/*
 	 * We cannot recover errors with other than bus_check.
 	 */
-	if (psp->cc || psp->rc || psp->uc) 
+	if (psp->cc || psp->rc || psp->uc)
 		return 0;
 
 	/*
@@ -546,10 +568,10 @@ recover_from_processor_error(int platfor
 	 * (e.g. a load from poisoned memory)
 	 * This means "there are some platform errors".
 	 */
-	if (platform) 
+	if (platform)
 		return recover_from_platform_error(slidx, peidx, pbci, sos);
-	/* 
-	 * On account of strange SAL error record, we cannot recover. 
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
 
 static int
-mca_try_to_recover(void *rec, 
-	struct ia64_sal_os_state *sos)
+mca_try_to_recover(void *rec, struct ia64_sal_os_state *sos)
 {
 	int platform_err;
 	int n_proc_err;
@@ -588,7 +610,8 @@ mca_try_to_recover(void *rec, 
 	}
 
 	/* Make index of processor error section */
-	mca_make_peidx((sal_log_processor_info_t*)slidx_first_entry(&slidx.proc_err)->hdr, &peidx);
+	mca_make_peidx((sal_log_processor_info_t*)
+		slidx_first_entry(&slidx.proc_err)->hdr, &peidx);
 
 	/* Extract Processor BUS_CHECK[0] */
 	*((u64*)&pbci) = peidx_check_info(&peidx, bus_check, 0);
@@ -598,7 +621,8 @@ mca_try_to_recover(void *rec, 
 		return 0;
 	
 	/* Try to recover a processor error */
-	return recover_from_processor_error(platform_err, &slidx, &peidx, &pbci, sos);
+	return recover_from_processor_error(platform_err, &slidx, &peidx,
+					    &pbci, sos);
 }
 
 /*
Index: linux-2.6.14-rc1/arch/ia64/kernel/mca_drv.h
===================================================================
--- linux-2.6.14-rc1.orig/arch/ia64/kernel/mca_drv.h
+++ linux-2.6.14-rc1/arch/ia64/kernel/mca_drv.h
@@ -6,7 +6,7 @@
  * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
  */
 /*
- * Processor error section: 
+ * Processor error section:
  *
  *  +-sal_log_processor_info_t *info-------------+
  *  | sal_log_section_hdr_t header;              |
Index: linux-2.6.14-rc1/arch/ia64/kernel/mca_drv_asm.S
===================================================================
--- linux-2.6.14-rc1.orig/arch/ia64/kernel/mca_drv_asm.S
+++ linux-2.6.14-rc1/arch/ia64/kernel/mca_drv_asm.S
@@ -13,45 +13,45 @@
 #include <asm/ptrace.h>
 
 GLOBAL_ENTRY(mca_handler_bhhook)
-	invala						// clear RSE ?
-	;;						//
-	cover						// 
-	;;						//
-	clrrrb						//
+	invala				// clear RSE ?
+	;;
+	cover
+	;;
+	clrrrb
 	;;						
-	alloc		r16=ar.pfs,0,2,1,0		// make a new frame
+	alloc	r16=ar.pfs,0,2,1,0	// make a new frame
 	;;
-	mov		ar.rsc=0
+	mov	ar.rsc=0
 	;;
-	mov		r13=IA64_KR(CURRENT)		// current task pointer
+	mov	r13=IA64_KR(CURRENT)	// current task pointer
 	;;
-	mov		r2=r13
+	mov	r2=r13
 	;;
-	addl		r22=IA64_RBS_OFFSET,r2
+	addl	r22=IA64_RBS_OFFSET,r2
 	;;
-	mov		ar.bspstore=r22
+	mov	ar.bspstore=r22
 	;;
-	addl		sp=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2
+	addl	sp=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2
 	;;
-	adds		r2=IA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	adds	r2=IA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
-	st1		[r2]=r0				// clear current->thread.on_ustack flag
-	mov		loc0=r16
-	movl		loc1=mca_handler_bh		// recovery C function
+	st1	[r2]=r0		// clear current->thread.on_ustack flag
+	mov	loc0=r16
+	movl	loc1=mca_handler_bh	// recovery C function
 	;;
-	mov		out0=r8				// poisoned address
-	mov		b6=loc1
+	mov	out0=r8			// poisoned address
+	mov	b6=loc1
 	;;
-	mov		loc1=rp
+	mov	loc1=rp
 	;;
-	ssm		psr.i
+	ssm	psr.i
 	;;
-	br.call.sptk.many    rp=b6			// does not return ...
+	br.call.sptk.many rp=b6		// does not return ...
 	;;
-	mov		ar.pfs=loc0
-	mov 		rp=loc1
+	mov	ar.pfs=loc0
+	mov 	rp=loc1
 	;;
-	mov		r8=r0
+	mov	r8=r0
 	br.ret.sptk.many rp
 	;;
 END(mca_handler_bhhook)

--------------030107060108080203010202--

