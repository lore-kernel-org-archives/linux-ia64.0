From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Thu, 15 Jan 2004 16:40:28 +0000
Subject: Yet another INIT handler
Message-Id: <4006C27C.E692ADC7@nospam.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------CACE70477455A39A70D8CAE1"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------CACE70477455A39A70D8CAE1
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

As the MCA hand-off procedure differs just a bit from that of the
INIT, with a slight addition, I can handle the INITs, too.

Predicates can tell what to deal with in our mca_asm1.S.

Currently, my stuff is activated only if the kernel is compiled in
debug mode, otherwise the original routines take the INIT.

You push the button, each CPU goes in to the high level INIT routine,
prints out the most important registers ( in order to demonstrate that
we've caught the INIT ), and - if the PSP.co is on, - it returns with
success.

We could call the KDB from the high level INIT routine.

The key features of the INIT handler are:

* Everything is CPU local ( an MCA data area is allocated and hooked
  to each "cpuinfo" structure, there is room for the INIT, too )

* No locks to protect the stack, the RSE, ...

* No rendezvous
  - Does not seem to work if not all the CPUs are started up,
    i.e. you specify a "maxcpus=<NUM>"...

* No monarch, nor slave
  - All CPUs enter the high level INIT routine
  - The KDB has got a chance to synchronize them :-)

* The same data structure as for our MCA
  - The KDB can use common routines

There is a lock in the high level INIT routine for not to mix up
the print-outs.

Why do I use another, separate data area for the INIT ?
If I am lost in my MCA handler, and I push the button...

This patch is against the version 2.6.1 + kdb-v4.3-2.6.1-common-b0.bz2 +
kdb-v4.3-2.6.1-ia64-b0.bz2 + our MCA patch
(ftp://visibull.frec.bull.fr/pub/linux/mca/mca.patch-jan-14 ) 

Your remarks will be appreciated.

Zoltan Menyhart
--------------CACE70477455A39A70D8CAE1
Content-Type: text/plain; charset=us-ascii;
 name="init.patch-jan-15"
Content-Disposition: inline;
 filename="init.patch-jan-15"
Content-Transfer-Encoding: 7bit

diff -ruN tmp/arch/ia64/kernel/mca.c linux-2.6.1-jan-15/arch/ia64/kernel/mca.c
--- tmp/arch/ia64/kernel/mca.c	2004-01-15 17:02:39.000000000 +0100
+++ linux-2.6.1-jan-15/arch/ia64/kernel/mca.c	2004-01-15 16:19:16.000000000 +0100
@@ -121,8 +121,14 @@
 u64				ia64_mca_serialize;
 static void			ia64_mca_wakeup_ipi_wait(void);
 static void			ia64_log_init(int);
+
+#if defined(CONFIG_DEBUG_KERNEL)			// Temporary :-)
+extern void			ia64_os_init_dispatch(void);
+#else
 extern void			ia64_monarch_init_handler (void);
 extern void			ia64_slave_init_handler (void);
+#endif
+
 static u64			ia64_log_get(int sal_info_type, u8 **buffer);
 extern struct hw_interrupt_type	irq_type_iosapic_level;
 
@@ -710,8 +716,13 @@
 void __init
 ia64_mca_init(void)
 {
+#if defined(CONFIG_DEBUG_KERNEL)			// Temporary :-)
+	ia64_fptr_t *mon_init_ptr = (ia64_fptr_t *)ia64_os_init_dispatch;
+	ia64_fptr_t *slave_init_ptr = (ia64_fptr_t *)ia64_os_init_dispatch;
+#else
 	ia64_fptr_t *mon_init_ptr = (ia64_fptr_t *)ia64_monarch_init_handler;
 	ia64_fptr_t *slave_init_ptr = (ia64_fptr_t *)ia64_slave_init_handler;
+#endif
 	ia64_fptr_t *mca_hldlr_ptr = (ia64_fptr_t *)ia64_os_mca_dispatch;
 	int i;
 	s64 rc;
diff -ruN tmp/arch/ia64/kernel/mca1.c linux-2.6.1-jan-15/arch/ia64/kernel/mca1.c
--- tmp/arch/ia64/kernel/mca1.c	2004-01-15 17:02:39.000000000 +0100
+++ linux-2.6.1-jan-15/arch/ia64/kernel/mca1.c	2004-01-15 16:19:16.000000000 +0100
@@ -119,7 +119,7 @@
 _STATIC_ int		mca_check_sal_err_rec(void);
 _STATIC_ int		mca_cpu_and_patform_err(const sal_log_processor_info_t * const);
 static void		print_os_to_sal_handoff(void);
-extern int		mca_sal_clear_state_info(void);
+extern int		mca_sal_clear_state_info(unsigned int);
 extern int		mca_check_sal_log_version(const efi_guid_t, const sal_log_revision_t);
 extern sal_log_section_hdr_t *
 		mca_look_up_1st_section(const sal_log_record_header_t * const, const efi_guid_t);
@@ -204,12 +204,74 @@
  */
 
 
+spinlock_t	init_print_lock = SPIN_LOCK_UNLOCKED;
+
+
+/*
+ * ia64_hi_level_init_handler()
+ *
+ * C portion of the "OS_INIT" handler, called from the "OS_INIT" dispatch code (see in mca_asm1.S)
+ * which is in turn called from "SAL_INIT()".
+ *
+ * Inputs:	SAL to OS hand off state (see local_cpu_data->mca_page->init.handoff)
+ *
+ * Outputs:	OS to SAL hand off state (see also the same structure)
+ */
+void
+ia64_hi_level_init_handler(void)
+{
+	MCA_page_t				* const mca_p = (MCA_page_t *)
+								local_cpu_data->mca_page;
+	const pal_min_state_area_t		* const ms = (pal_min_state_area_t *)
+								mca_p->init.handoff.min_state;
+	const pal_processor_state_info_t	state = * (pal_processor_state_info_t *)
+								& mca_p->init.handoff.psp;
+
+	KDBA_MCA_TRACE();
+	spin_lock(&init_print_lock);
+	PRINT("\nINIT handler called on cpu %d\n\n", MY_GET_CPU());
+	PRINT("PSR: 0x%08lx_%08lx, ", mca_p->init.handoff.psr >> 32,
+							mca_p->init.handoff.psr & 0xffffffff);
+	PRINT("PSP (GR18): 0x%08lx_%08lx:\n", mca_p->init.handoff.psp >> 32,
+							mca_p->init.handoff.psp & 0xffffffff);
+	print_psp(mca_p->init.handoff.psp);
+	PRINT("min state from GR17: 0x%p:\n\n", ms);
+	/*
+	 * The min. sate must be accessed as non-cached memory. Use 0xc000... addresses.
+	 */
+	show_min_state((pal_min_state_area_t *) ((u64) ms | __IA64_UNCACHED_OFFSET));
+	_delay_();
+	spin_unlock(&init_print_lock);
+#if defined(CONFIG_KDB)
+//	kdba_mca_init(SAL_INFO_TYPE_INIT);		// One day it'll work :-)
+#endif
+	/*
+	 * By default: say INIT has been recovered and return to the same context.
+	 */
+	mca_p->init.handoff.status = IA64_MCA_CORRECTED;
+	mca_p->init.handoff.context = IA64_MCA_SAME_CONTEXT;
+
+	CALL_KDB();
+
+	(void) mca_sal_clear_state_info(SAL_INFO_TYPE_INIT);	// No lock
+
+	spin_lock(&init_print_lock);
+	PRINT("\nINIT handler returning on cpu %d\n\n", MY_GET_CPU());
+	if (state.co)					// Continuable bit is on
+		print_os_to_sal_handoff();
+	else
+		PRINT("\nPSP.co is off, I do not give you much chance :-)\n\n");
+	_delay_();
+	spin_unlock(&init_print_lock);
+}
+
+
 /*
  * ia64_mca_ucmc_handler()
  *
  * This is a wrapper function for the real machine check handler, mainly for debugging purpose,
- * called from the OS_MCA dispatch code (see in mca_asm1.S) which is in turn called from
- * SAL_CHECK().
+ * called from the "OS_MCA" dispatch code (see in mca_asm1.S) which is in turn called from
+ * "SAL_CHECK()".
  *
  * Inputs:	SAL to OS hand off state (see local_cpu_data->mca_page->mca.handoff)
  *
@@ -664,7 +726,7 @@
 		 */
 		// TODO: my error log...
 		if (rc == 0){					// All sections say "CORRECTED"
-			rc = mca_sal_clear_state_info();	// SAL_CLEAR_STATE_INFO - no lock
+			rc = mca_sal_clear_state_info(SAL_INFO_TYPE_MCA);// No lock
 			if (rc == SAL_CALL_OK_MORE_ERR_REC_AVAILABLE){
 				DEBUG_TEXT(more_sal_log);
 				return rc;
@@ -951,7 +1013,7 @@
 	case -1:					// CPU error recovery failed
 		return -1;
 	case 0:						// Already corrected: some TR errors
-		rc = mca_sal_clear_state_info();	// SAL_CLEAR_STATE_INFO - no lock
+		rc = mca_sal_clear_state_info(SAL_INFO_TYPE_MCA);// No lock
 		if (rc == SAL_CALL_OK_MORE_ERR_REC_AVAILABLE){
 			DEBUG_TEXT(more_sal_log);
 			return rc;
@@ -1144,7 +1206,7 @@
 	PRINT("OS to SAL hand-off sate:\nStatus:\t");
 	switch(mca_p->mca.handoff.status){
 	case IA64_MCA_CORRECTED:
-		p = "Error has been corrected by OS_MCA";
+		p = "Problem has been corrected by OS_MCA/OS_INIT";
 		break;
 	case IA64_MCA_WARM_BOOT:
 		p = "Warm boot of the system need from SAL";
diff -ruN tmp/arch/ia64/kernel/mca_asm.S linux-2.6.1-jan-15/arch/ia64/kernel/mca_asm.S
--- tmp/arch/ia64/kernel/mca_asm.S	2004-01-15 17:02:39.000000000 +0100
+++ linux-2.6.1-jan-15/arch/ia64/kernel/mca_asm.S	2004-01-15 16:19:16.000000000 +0100
@@ -501,6 +501,9 @@
 //EndStub//////////////////////////////////////////////////////////////////////
 
 
+#if !defined(CONFIG_DEBUG_KERNEL)
+
+
 #ifndef	CONFIG_KDB
 // ok, the issue here is that we need to save state information so
 // it can be useable by the kernel debugger and show regs routines.
@@ -730,3 +733,7 @@
 
 1:	br.sptk 1b
 END(ia64_slave_init_handler)
+
+
+#endif // #if !defined(CONFIG_DEBUG_KERNEL)
+
diff -ruN tmp/arch/ia64/kernel/mca_asm1.S linux-2.6.1-jan-15/arch/ia64/kernel/mca_asm1.S
--- tmp/arch/ia64/kernel/mca_asm1.S	2004-01-15 17:02:39.000000000 +0100
+++ linux-2.6.1-jan-15/arch/ia64/kernel/mca_asm1.S	2004-01-15 16:19:16.000000000 +0100
@@ -34,6 +34,8 @@
 //	r6:		Old PSR while we are in virtual mode
 //	r7:		KERNEL_START - <actual physical kernel load address>
 //	r13:		Saves ar.pfs
+//	p1:		Set for MCA processing (aliased as "mca")
+//	p2:		Set for INIT processing (aliased as "init")
 //
 // Scratch registers:
 //	r14...r16, r19...r21, r23...r31
@@ -65,6 +67,10 @@
 //////////////////////////////////////////////////////////////////////////////////////////////////
 
 
+#define	mca	p1					// Predicate indicating MCA processing
+#define	init	p2					// Predicate indicating INIT processing
+
+
 //
 // This macro converts a data virtual address to a physical address - use this macro before the
 // translation cache is repaired.
@@ -84,12 +90,14 @@
 //
 #define	HALT_THE_MACHINE_ON_ERROR(pr)								\
 (pr)	br		1f ;;									;\
+2:												;\
+(init)	br		2b ;;				/* INIT does not use "..._HALT" */	;\
 	mov		r9 = r10			/* GP for SAL */			;\
 	mov		b0 = r12			/* Return address */			;\
 	mov		r22 = r17			/* Min. state address */		;\
 	mov		r8 = MCA_INIT_HALT ;;							;\
 	mov		r10 = MCA_INIT_SAME_CONTEXT						;\
-	br		b0									;\
+	br		b0				/* Who cares for a broken "ar.pfs" ? */	;\
 1:
 
 
@@ -118,20 +126,24 @@
 							/*	"MCA page" of the current CPU */
 
 
-#if 0
-
-	movl		r31 = 1f ;;			// Cannot *call* as subroutine
-	add		r31 = r31, r7 ;;		// Physical address
-	mov		b0 = r31			// (would mess up ar.pfs, ar.ec,...)
-	add		r2 = MCA_state_dump_offset, r2	// r2 -> save area
-	br		ia64_os_mca_proc_state_restore ;;
-	.global	ia64_os_mca_proc_state_restore
-1:	//
-
-
+//
+// There are cases when we cannot *call* subroutines because it would mess up ar.pfs, ar.ec,...
+//
+// Register usage:
+//	r31:		Scratch
+// Output:
+//	b0:		Return address (physical) for the subroutine
+//
+// Note:
+//	The subroute must return bye use of "br b0" and not "br.ret.sptk b0".
+//
 #define	QCALL(subroutine)									\
-
-#endif
+	movl		r31 = 1f ;;			/* Return address for the subroutine */	;\
+	add		r31 = r31, r7 ;;		/* Physical address */			;\
+	mov		b0 = r31								;\
+	br		subroutine ;;								;\
+	.global		subroutine								;\
+1:
 
 
 	.text
@@ -143,20 +155,53 @@
 //      ia64_os_mca_dispatch()
 //
 // Description:
-//       Machine check abort starts here (a.k.a OS_MCA)
+//      Machine check abort starts here (a.k.a. "OS_MCA").
 //
-// Do not register "ia64_os_mca_dispatch" as OS_MCA before the "MCA page" is set up
+// Note:
+//	Do not register "ia64_os_mca_dispatch" as "OS_MCA" before the "MCA page" is set up
 //--
 ia64_os_mca_dispatch:
 	.global		ia64_os_mca_dispatch
+	cmp.eq		mca, init = r0, r0		// Predicates indicating MCA processing
+	br		mca_init
+
+
+#if defined(CONFIG_DEBUG_KERNEL)			// Temporary :-)
+
+//++
+// Name:
+//      ia64_os_init_dispatch()
+//
+// Description:
+//      INIT handling starts here (a.k.a. "OS_INIT").
+//	There are no separate monarch /slave handlers.
+//
+// Note:
+//	Do not register "ia64_init_handler" as "OS_INIT" before the "MCA page" is set up
+//--
+ia64_os_init_dispatch:
+	.global		ia64_os_init_dispatch
+	cmp.eq		init, mca = r0, r0		// Predicates indicating INIT processing
+	br		mca_init
 
+#endif // #if defined(CONFIG_DEBUG_KERNEL)
+
+
+//++
+// Name:
+//      mca_init()
+//
+// Description:
+//	Common MCA / INIT handler.
+//--
+mca_init:
 	// We cannot use the tpa instruction before the translation cache is repared.
 	// We can lop off bits 61...63 for the adresses 0xe000...
 	// For the first IA64_GRANULE of the addresses 0xa000..., r7 will hold
 	// KERNEL_START - <actual physical kernel load address> to help address conversion.
-	mov		r31 = ip
+1:	mov		r31 = ip
 	mov		r13 = ar.pfs
-	movl		r7 = ia64_os_mca_dispatch ;;
+	movl		r7 = 1b ;;
 	sub		r7 = r31, r7 ;;
 
 	br.call.sptk	b0 = get_cpu_number ;;		// r4 = logical CPU number: 0...NR_CPUS-1
@@ -171,38 +216,45 @@
 	HALT_THE_MACHINE_ON_ERROR(p31)			// If it is, then halt the machine
 
 	// Save the SAL to OS hand off state.
-	add		r3 = MCA_handoff_st_offset, r2	// r3 -> save area
+(mca)	add		r3 = MCA_handoff_st_offset, r2	// r3 -> MCA save area
+	;;						// Just to make the assembler happy
+(init)	add		r3 = INIT_handoff_st_offset, r2	// r3 -> INIT save area
 	br.call.sptk	b0 = save_handoff_st ;;
 	mov		ar.pfs = r13
 
 	// LOG PROCESSOR STATE INFO FROM HERE ON...
-	movl		r31 = 1f ;;			// Cannot *call* as subroutine
-	add		r31 = r31, r7 ;;		// Physical address
-	mov		b0 = r31			// (would mess up ar.pfs, ar.ec,...)
-	add		r2 = MCA_state_dump_offset, r2	// r2 -> save area
-	br		ia64_os_mca_proc_state_dump ;;
-	.global		ia64_os_mca_proc_state_dump
-1:
+(mca)	add		r2 = MCA_state_dump_offset, r2	// r2 -> MCA save area
+	;;						// Just to make the assembler happy
+(init)	add		r2 = INIT_state_dump_offset, r2	// r2 -> INIT save area
+	QCALL(ia64_os_mca_proc_state_dump)
+
 	// No control over what ia64_os_mca_proc_state_dump() does, reload r2, r4, r5 and r7.
 	RELOAD_R2_R4_R5_R7() ;;
 
-	// Setup new stack frame and the RSE stuff for OS_MCA handling.
-	add		r29 = MCA_bspstore_offset, r2	// r11-> local bspstore area location
-	add		r30 = MCA_stackframe_offset, r2
+	// Setup new stack frame and the RSE stuff for "OS_MCA" / "OS_INIT" handling.
+(mca)	add		r29 = MCA_bspstore_offset, r2	// -> local bspstore area location
+(mca)	add		r30 = MCA_stackframe_offset, r2
+	;;						// Just to make the assembler happy
+(init)	add		r29 = INIT_bspstore_offset, r2	// -> local bspstore area location
+(init)	add		r30 = INIT_stackframe_offset, r2
 	rse_switch_context(/* TMP */ r31, r30, r29)	// RSC management in this new context
 
 	// Unconditionally purge and re-load the TLBs to recover any resident errors.
-	br.call.sptk	b0 = ia64_mca_tlb_purge_reload ;;
+(mca)	br.call.sptk	b0 = ia64_mca_tlb_purge_reload ;;
 
 	// Stack top - allow 16 bytes of scratch (C calling convention).
-	add		r12 = MCA_stack_end_offset-16, r2
+(mca)	add		r12 = MCA_stack_end_offset-16, r2
+	;;						// Just to make the assembler happy
+(init)	add		r12 = INIT_stack_end_offset-16, r2
 
         // Enter virtual mode from physical mode.
 	VIRTUAL_MODE_ENTER(/* TMP */ r31, /* TMP */ r30, 1f, /* OUT: old PSR */ r6)
 1:
 	// Call virtual mode handler: ia64_mca_ucmc_handler();
-	movl		r31 = ia64_mca_ucmc_handler ;;
+(mca)	movl		r31 = ia64_mca_ucmc_handler ;;
+(init)	movl		r31 = ia64_hi_level_init_handler ;;
 	.global		ia64_mca_ucmc_handler
+	.global		ia64_hi_level_init_handler
 	mov		b6 = r31 ;;
 	br.call.sptk.many b0 = b6 ;;
 
@@ -216,36 +268,36 @@
 	PHYSICAL_MODE_ENTER(/* TMP */ r31, /* TMP */ r30, 1f, r6)
 1:
 	// Switch back to the original context for RSE.
-	add		r29 = MCA_stackframe_offset, r2
+(mca)	add		r29 = MCA_stackframe_offset, r2
+	;;						// Just to make the assembler happy
+(init)	add		r29 = INIT_stackframe_offset, r2
 	// movl		r30 = IA64_PSR_MC
 	mov		r30 = r0			// No reason for clearing the psr.mc bit
 	rse_return_context(r30, /* TMP */ r31, r29)
 
 	// Restore dumped processor state.
-	movl		r31 = 1f ;;			// Cannot *call* as subroutine
-	add		r31 = r31, r7 ;;		// Physical address
-	mov		b0 = r31			// (would mess up ar.pfs, ar.ec,...)
-	add		r2 = MCA_state_dump_offset, r2	// r2 -> save area
-	br		ia64_os_mca_proc_state_restore ;;
-	.global	ia64_os_mca_proc_state_restore
-1:
+(mca)	add		r2 = MCA_state_dump_offset, r2	// r2 -> MCA save area
+	;;						// Just to make the assembler happy
+(init)	add		r2 = INIT_state_dump_offset, r2	// r2 -> INIT save area
+	QCALL(ia64_os_mca_proc_state_restore)
+
 	// No control over what ia64_os_mca_proc_state_restore() does, reload r2, r4, r5 and r7.
 	mov		r13 = ar.pfs
 	RELOAD_R2_R4_R5_R7() ;;
 
 	// Establish the OS to SAL hand off state.
-	add		r3 = MCA_handoff_st_offset, r2	// r3 -> hand off state
+(mca)	add		r3 = MCA_handoff_st_offset, r2	// r3 -> MCA save area
+	;;						// Just to make the assembler happy
+(init)	add		r3 = INIT_handoff_st_offset, r2	// r3 -> INIT save area
 	br.call.sptk	b0 = load_handoff_st ;;
 	mov		ar.pfs = r13
 
-	// Return to SALE_CHECK.
+	// Return to the SAL; MCA and INIT use the same type of hand off structure
 	add		r31 = MCA_SAL_ret_adr_offset, r3 ;;
-	ld8		r31 = [r31] ;;			// SAL_CHECK return address
+	ld8		r31 = [r31] ;;			// SAL return address
 	mov		b0 = r31 ;;
 	br		b0 ;;
 
-ia64_os_mca_dispatch_end:
-	.global		ia64_os_mca_dispatch_end
 
 //EndMain//////////////////////////////////////////////////////////////////////
 
@@ -273,6 +325,9 @@
 // Additional registers from th PAL
 //	r17:		min-state save area address stored in XR0 from PAL_CHECK
 //	r18:		Processor State Parameter from PAL
+//
+// Note:
+//	MCA and INIT use the same hand off structure.
 //--
 save_handoff_st:
 	add		r31 = MCA_PAL_proc_offset, r3
@@ -317,6 +372,9 @@
 //	PSR:		Processor Status Register saved on SAL to OS handoff
 // Preserved:
 //	r3
+//
+// Note:
+//	MCA and INIT use the same hand off structure.
 //--
 load_handoff_st:
 	add		r31 = MCA_status_offset, r3
diff -ruN tmp/arch/ia64/kernel/mca_util.c linux-2.6.1-jan-15/arch/ia64/kernel/mca_util.c
--- tmp/arch/ia64/kernel/mca_util.c	2004-01-15 17:02:39.000000000 +0100
+++ linux-2.6.1-jan-15/arch/ia64/kernel/mca_util.c	2004-01-15 16:19:16.000000000 +0100
@@ -241,21 +241,23 @@
 /*
  * Clear the processor and platform information logged by SAL.
  *
+ * Inputs:	type:		SAL_INFO_TYPE_MCA, ...
+ *
  * Returns:	The status from SAL_CLEAR_STATE_INFO
  */
 int
-mca_sal_clear_state_info(void)
+mca_sal_clear_state_info(unsigned int type)
 {
 	s64	status;
 
 	KDBA_MCA_TRACE();
-	switch(status = ia64_sal_clear_state_info_no_lock(SAL_INFO_TYPE_MCA)){
+	switch(status = ia64_sal_clear_state_info_no_lock(type)){
 	case SAL_CALL_OK_MORE_ERR_REC_AVAILABLE:
 	case SAL_CALL_OK:
 		return (int) status;
 	default:
-		panic("\nMCA: apparently, I do not know how to call SAL_CLEAR_STATE_INFO, "
-								"status = %ld\n", status);
+		panic("\nApparently, I do not know how to call "
+				"SAL_CLEAR_STATE_INFO(%u), status = %ld\n", type, status);
 		return (int) status;
 	}
 	/*NOTREACHED*/
diff -ruN tmp/include/asm-ia64/mca.h linux-2.6.1-jan-15/include/asm-ia64/mca.h
--- tmp/include/asm-ia64/mca.h	2004-01-15 17:02:39.000000000 +0100
+++ linux-2.6.1-jan-15/include/asm-ia64/mca.h	2004-01-15 16:19:26.000000000 +0100
@@ -120,6 +120,11 @@
 	u64		proc_state_param;	/* from PAL in r18. See SDV 2:268 11.3.2.1 */
 } ia64_mca_sal_to_os_state_t;
 
+
+/*
+ * MCA and INIT return codes.
+ * (INIT does not use "IA64_MCA_COLD_BOOT" or "IA64_MCA_HALT".)
+ */
 enum {
 	IA64_MCA_CORRECTED	=	0x0,	/* Error has been corrected by OS_MCA */
 	IA64_MCA_WARM_BOOT	=	-1,	/* Warm boot of the system need from SAL */

--------------CACE70477455A39A70D8CAE1--

