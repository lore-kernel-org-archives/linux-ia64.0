From: Keith Owens <kaos@sgi.com>
Date: Mon, 02 Feb 2004 07:05:39 +0000
Subject: [patch] 4/5 2.4.25-pre7 mca.c cleanup - Delete dead variables and functions
Message-Id: <6790.1075705539@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Delete dead variables and functions.

Index: 25-pre7.6/include/asm-ia64/mca.h
--- 25-pre7.6/include/asm-ia64/mca.h Mon, 02 Feb 2004 17:13:41 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.1.1.1.1.1.1.5 644)
+++ 25-pre7.8/include/asm-ia64/mca.h Mon, 02 Feb 2004 17:22:18 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.1.1.1.1.1.1.6 644)
@@ -17,23 +17,8 @@
 #include <asm/processor.h>
 #include <asm/mca_asm.h>
 
-/* These are the return codes from all the IA64_MCA specific interfaces */
-typedef	int ia64_mca_return_code_t;
-
-enum {
-	IA64_MCA_SUCCESS	=	0,
-	IA64_MCA_FAILURE	=	1
-};
-
 #define IA64_MCA_RENDEZ_TIMEOUT		(20 * 1000)	/* value in milliseconds - 20 seconds */
 
-#define IA64_CMC_INT_DISABLE		0
-#define IA64_CMC_INT_ENABLE		1
-
-
-typedef u32 int_vector_t;
-typedef u64 millisec_t;
-
 typedef union cmcv_reg_u {
 	u64	cmcv_regval;
 	struct	{
@@ -50,10 +35,6 @@ typedef union cmcv_reg_u {
 #define cmcv_mask		cmcv_reg_s.cmcr_mask
 #define cmcv_vector		cmcv_reg_s.cmcr_vector
 
-
-#define IA64_MCA_UCMC_HANDLER_SIZE	0x10
-#define IA64_INIT_HANDLER_SIZE		0x10
-
 enum {
 	IA64_MCA_RENDEZ_CHECKIN_NOTDONE	=	0x0,
 	IA64_MCA_RENDEZ_CHECKIN_DONE	=	0x1
@@ -82,16 +63,6 @@ typedef struct ia64_mc_info_s {
 
 } ia64_mc_info_t;
 
-/* Possible rendez states passed from SAL to OS during MCA
- * handoff
- */
-enum {
-	IA64_MCA_RENDEZ_NOT_RQD		=	0x0,
-	IA64_MCA_RENDEZ_DONE_WITHOUT_INIT	=	0x1,
-	IA64_MCA_RENDEZ_DONE_WITH_INIT		=	0x2,
-	IA64_MCA_RENDEZ_FAILURE			=	-1
-};
-
 typedef struct ia64_mca_sal_to_os_state_s {
 	u64		imsto_os_gp;		/* GP of the os registered with the SAL */
 	u64		imsto_pal_proc;		/* PAL_PROC entry point - physical addr */
@@ -142,10 +113,6 @@ extern void ia64_slave_init_handler(void
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
 
-#undef	MCA_TEST
-
-#undef IA64_MCA_DEBUG_INFO
-
 #if defined(IA64_MCA_DEBUG_INFO)
 # define IA64_MCA_DEBUG(fmt...)	printk(fmt)
 #else
Index: 25-pre7.6/arch/ia64/kernel/mca.c
--- 25-pre7.6/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 17:13:41 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.9 644)
+++ 25-pre7.8/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 17:31:42 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.11 644)
@@ -45,6 +45,7 @@
  *            Avoid deadlock when using printk() for MCA and INIT records.
  *            Delete all record printing code, moved to salinfo_decode in user space.
  *            Mark variables and functions static where possible.
+ *            Delete dead variables and functions.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -72,9 +73,6 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
-#undef MCA_PRT_XTRA_DATA
-
-#define print_symbol(fmt, addr)	printk(fmt, "(no symbol)");
 extern void show_stack(struct task_struct *);
 
 typedef struct ia64_fptr {
@@ -82,7 +80,7 @@ typedef struct ia64_fptr {
 	unsigned long gp;
 } ia64_fptr_t;
 
-static ia64_mc_info_t		ia64_mc_info;
+/* Used by mca_asm.S */
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
 u64				ia64_mca_proc_state_dump[512];
@@ -90,8 +88,19 @@ u64				ia64_mca_stack[1024] __attribute_
 u64				ia64_mca_stackframe[32];
 u64				ia64_mca_bspstore[1024];
 u64				ia64_init_stack[INIT_TASK_SIZE/8] __attribute__((aligned(16)));
-u64				ia64_os_mca_recovery_successful;
 u64				ia64_mca_serialize;
+
+/* In mca_asm.S */
+extern void			ia64_monarch_init_handler (void);
+extern void			ia64_slave_init_handler (void);
+
+static ia64_mc_info_t		ia64_mc_info;
+
+extern struct hw_interrupt_type	irq_type_iosapic_level;
+
+struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
+
+/* Forward declarations, the code is not in a nice order */
 static void			ia64_mca_wakeup_ipi_wait(void);
 static void			ia64_mca_wakeup(int cpu);
 static void			ia64_mca_wakeup_all(void);
@@ -102,12 +111,7 @@ static void			ia64_mca_cmc_int_handler(i
 static void			ia64_mca_cpe_int_handler(int, void *, struct pt_regs *);
 static void			ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
 static void			ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
-extern void			ia64_monarch_init_handler (void);
-extern void			ia64_slave_init_handler (void);
 static u64			ia64_log_get(int sal_info_type, u8 **buffer);
-extern struct hw_interrupt_type	irq_type_iosapic_level;
-
-struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
 
 static struct irqaction cmci_irqaction = {
 	.handler =	ia64_mca_cmc_int_handler,
@@ -208,11 +212,6 @@ ia64_mca_log_sal_error_record(int sal_in
  * platform dependent error handling
  */
 #ifndef PLATFORM_MCA_HANDLERS
-static void
-mca_handler_platform (void)
-{
-
-}
 
 static void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
@@ -227,6 +226,8 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
 }
 
+#define print_symbol(fmt, addr)	printk(fmt, "(no symbol)");
+
 static void
 show_min_state (pal_min_state_area_t *minstate)
 {
@@ -413,23 +414,6 @@ init_handler_platform (pal_min_state_are
 }
 
 /*
- * ia64_mca_init_platform
- *
- *  External entry for platform specific MCA initialization.
- *
- *  Inputs
- *      None
- *
- *  Outputs
- *      None
- */
-static void
-ia64_mca_init_platform (void)
-{
-
-}
-
-/*
  *  ia64_mca_check_errors
  *
  *  External entry to check for error records which may have been posted by SAL
@@ -631,9 +615,6 @@ ia64_mca_init(void)
 	INIT_TQUEUE(&cmc_disable_tq, ia64_mca_cmc_vector_disable_keventd, NULL);
 	INIT_TQUEUE(&cmc_enable_tq, ia64_mca_cmc_vector_enable_keventd, NULL);
 
-	/* initialize recovery success indicator */
-	ia64_os_mca_recovery_successful = 0;
-
 	/* Clear the Rendez checkin flag for all cpus */
 	for(i = 0 ; i < NR_CPUS; i++)
 		ia64_mc_info.imi_rendez_checkin[i] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
@@ -701,7 +682,7 @@ ia64_mca_init(void)
 
 	/*
 	 * XXX - disable SAL checksum by setting size to 0, should be
-	 * IA64_INIT_HANDLER_SIZE
+	 * size of the actual init handler in mca_asm.S.
 	 */
 	ia64_mc_info.imi_monarch_init_handler		= ia64_tpa(mon_init_ptr->fp);
 	ia64_mc_info.imi_monarch_init_handler_size	= 0;
@@ -768,17 +749,7 @@ ia64_mca_init(void)
 	ia64_log_init(SAL_INFO_TYPE_CMC);
 	ia64_log_init(SAL_INFO_TYPE_CPE);
 
-#if defined(MCA_TEST)
-	mca_test();
-#endif /* #if defined(MCA_TEST) */
-
 	printk(KERN_INFO "Mca related initialization done\n");
-
-	/* commented out because this is done elsewhere */
-#if 0
-	/* Do post-failure MCA error logging */
-	ia64_mca_check_errors();
-#endif
 }
 
 /*

