From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Oct 2003 20:55:30 +0000
Subject: [PATCH 2.6] MCA min_state area must be uncacheable
Message-Id: <marc-linux-ia64-106633799429227@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Software Developer's Manual page 2:270, section 11.3.2.3
says that the processor min-state save area must be in an
uncacheable region ... but current MCA recovery code
allocates the min-state area "ia64_mca_min_state_save_info"
in regular kernel data/bss.

This patch re-uses the same min-state area that the PAL/SAL
used to report the error to Linux ... which mostly requires
deleting code and declarations (some of which were wrong,
MIN_STATE_AREA_SIZE ought to have been 58).  The real "work"
is copying the pointer to the min-state area from the
sal_to_os handoff structure into the os_to_sal structure.

-Tony

diff -ru mosberger-bk/arch/ia64/kernel/mca.c mca-uncache/arch/ia64/kernel/mca.c
--- mosberger-bk/arch/ia64/kernel/mca.c	Thu Oct 16 10:39:33 2003
+++ mca-uncache/arch/ia64/kernel/mca.c	Thu Oct 16 12:04:47 2003
@@ -81,8 +81,6 @@
 u64				ia64_mca_sal_data_area[1356];
 u64				ia64_tlb_functional;
 u64				ia64_os_mca_recovery_successful;
-/* TODO: need to assign min-state structure to UC memory */
-u64				ia64_mca_min_state_save_info[MIN_STATE_AREA_SIZE] __attribute__((aligned(512)));
 static void			ia64_mca_wakeup_ipi_wait(void);
 static void			ia64_mca_wakeup(int cpu);
 static void			ia64_mca_wakeup_all(void);
@@ -466,26 +464,6 @@
 #endif /* PLATFORM_MCA_HANDLERS */
 
 /*
- * routine to process and prepare to dump min_state_save
- * information for debugging purposes.
- */
-void
-ia64_process_min_state_save (pal_min_state_area_t *pmss)
-{
-	int i, max = MIN_STATE_AREA_SIZE;
-	u64 *tpmss_ptr = (u64 *)pmss;
-	u64 *return_min_state_ptr = ia64_mca_min_state_save_info;
-
-	for (i=0;i<max;i++) {
-
-		/* copy min-state register info for eventual return to PAL */
-		*return_min_state_ptr++ = *tpmss_ptr;
-
-		tpmss_ptr++;  /* skip to next entry */
-	}
-}
-
-/*
  * ia64_mca_cmc_vector_setup
  *
  *  Setup the corrected machine check vector register in the processor and
@@ -961,9 +939,8 @@
 	/* Default = tell SAL to return to same context */
 	ia64_os_to_sal_handoff_state.imots_context = IA64_MCA_SAME_CONTEXT;
 
-	/* Register pointer to new min state values */
 	ia64_os_to_sal_handoff_state.imots_new_min_state -		ia64_mca_min_state_save_info;
+		(u64 *)ia64_sal_to_os_handoff_state.pal_min_state;
 }
 
 /*
@@ -2154,9 +2131,6 @@
 	if (slpi->valid.psi_static_struct) {
 		spsi = (sal_processor_static_info_t *)p_data;
 
-		/* copy interrupted context PAL min-state info */
-		ia64_process_min_state_save(&spsi->min_state_area);
-
 		/* Print branch register contents if valid */
 		if (spsi->valid.br)
 			ia64_log_processor_regs_print(spsi->br, 8, "Branch", "br",
diff -ru mosberger-bk/arch/ia64/kernel/mca_asm.S mca-uncache/arch/ia64/kernel/mca_asm.S
--- mosberger-bk/arch/ia64/kernel/mca_asm.S	Thu Oct 16 10:39:33 2003
+++ mca-uncache/arch/ia64/kernel/mca_asm.S	Thu Oct 16 12:06:32 2003
@@ -77,12 +77,11 @@
 (p6)	movl	r10=IA64_MCA_SAME_CONTEXT;		\
 (p6)	add     _tmp=0x18,_tmp;;			\
 (p6)	ld8	r9=[_tmp],0x10;				\
-(p6)	movl	r22=ia64_mca_min_state_save_info;;	\
+(p6)	mov	r22=r0;;				\
 (p7)	ld8	r8=[_tmp],0x08;;			\
 (p7)	ld8	r9=[_tmp],0x08;;			\
 (p7)	ld8     r10=[_tmp],0x08;;			\
-(p7)	ld8     r22=[_tmp],0x08;;			\
-	DATA_VA_TO_PA(r22)
+(p7)	ld8     r22=[_tmp],0x08;;
 	// now _tmp is pointing to SAL rtn save location
 
 
@@ -97,7 +96,6 @@
 	.global ia64_init_stack
 	.global ia64_mca_sal_data_area
 	.global ia64_tlb_functional
-	.global ia64_mca_min_state_save_info
 
 	.text
 	.align 16
diff -ru mosberger-bk/include/asm-ia64/mca.h mca-uncache/include/asm-ia64/mca.h
--- mosberger-bk/include/asm-ia64/mca.h	Thu Oct 16 10:40:25 2003
+++ mca-uncache/include/asm-ia64/mca.h	Thu Oct 16 12:07:22 2003
@@ -108,8 +108,6 @@
 	IA64_MCA_NEW_CONTEXT	=	-1	/* SAL to return to new context */
 };
 
-#define MIN_STATE_AREA_SIZE     57
-
 typedef struct ia64_mca_os_to_sal_state_s {
 	u64		imots_os_status;	/*   OS status to SAL as to what happened
 						 *   with the MCA handling.
