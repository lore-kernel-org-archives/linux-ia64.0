From: Keith Owens <kaos@sgi.com>
Date: Thu, 05 Feb 2004 02:32:59 +0000
Subject: [patch] 4/6 2.6.2-rc2 mca.c cleanup - Delete dead variables and functions
Message-Id: <4682.1075948379@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Delete dead variables and functions

Index: 2-rc2.5/include/asm-ia64/mca.h
--- 2-rc2.5/include/asm-ia64/mca.h Thu, 05 Feb 2004 11:53:36 +1100 kaos (linux-2.6/V/b/0_mca.h 1.1.1.3 644)
+++ 2-rc2.6/include/asm-ia64/mca.h Thu, 05 Feb 2004 12:01:04 +1100 kaos (linux-2.6/V/b/0_mca.h 1.1.1.4 644)
@@ -20,23 +20,8 @@
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
@@ -53,10 +38,6 @@ typedef union cmcv_reg_u {
 #define cmcv_mask		cmcv_reg_s.cmcr_mask
 #define cmcv_vector		cmcv_reg_s.cmcr_vector
 
-
-#define IA64_MCA_UCMC_HANDLER_SIZE	0x10
-#define IA64_INIT_HANDLER_SIZE		0x10
-
 enum {
 	IA64_MCA_RENDEZ_CHECKIN_NOTDONE	=	0x0,
 	IA64_MCA_RENDEZ_CHECKIN_DONE	=	0x1
@@ -85,16 +66,6 @@ typedef struct ia64_mc_info_s {
 
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
@@ -145,10 +116,6 @@ extern void ia64_slave_init_handler(void
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
 
-#undef	MCA_TEST
-
-#undef IA64_MCA_DEBUG_INFO
-
 #if defined(IA64_MCA_DEBUG_INFO)
 # define IA64_MCA_DEBUG(fmt...)	printk(fmt)
 #else
Index: 2-rc2.5/arch/ia64/kernel/mca.c
--- 2-rc2.5/arch/ia64/kernel/mca.c Thu, 05 Feb 2004 11:53:36 +1100 kaos (linux-2.6/Z/c/43_mca.c 1.1.1.4 644)
+++ 2-rc2.6/arch/ia64/kernel/mca.c Thu, 05 Feb 2004 12:01:04 +1100 kaos (linux-2.6/Z/c/43_mca.c 1.1.1.5 644)
@@ -45,6 +45,7 @@
  *            Avoid deadlock when using printk() for MCA and INIT records.
  *            Delete all record printing code, moved to salinfo_decode in user space.
  *            Mark variables and functions static where possible.
+ *            Delete dead variables and functions.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -73,14 +74,12 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
-#undef MCA_PRT_XTRA_DATA
-
 typedef struct ia64_fptr {
 	unsigned long fp;
 	unsigned long gp;
 } ia64_fptr_t;
 
-static ia64_mc_info_t		ia64_mc_info;
+/* Used by mca_asm.S */
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
 u64				ia64_mca_proc_state_dump[512];
@@ -88,25 +87,31 @@ u64				ia64_mca_stack[1024] __attribute_
 u64				ia64_mca_stackframe[32];
 u64				ia64_mca_bspstore[1024];
 u64				ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
-u64				ia64_os_mca_recovery_successful;
 u64				ia64_mca_serialize;
-static void			ia64_mca_wakeup_ipi_wait(void);
-static void			ia64_mca_wakeup(int cpu);
-static void			ia64_mca_wakeup_all(void);
-static void			ia64_log_init(int);
-static irqreturn_t		ia64_mca_rendez_int_handler(int,void *,struct pt_regs *);
-static irqreturn_t		ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
-static irqreturn_t		ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
-static irqreturn_t		ia64_mca_cpe_int_handler(int, void *, struct pt_regs *);
-static irqreturn_t		ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
-static irqreturn_t		ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
+
+/* In mca_asm.S */
 extern void			ia64_monarch_init_handler (void);
 extern void			ia64_slave_init_handler (void);
-static u64			ia64_log_get(int sal_info_type, u8 **buffer);
+
+static ia64_mc_info_t		ia64_mc_info;
+
 extern struct hw_interrupt_type	irq_type_iosapic_level;
 
 struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
 
+/* Forward declarations, the code is not in a nice order */
+static void			ia64_mca_wakeup_ipi_wait(void);
+static void			ia64_mca_wakeup(int cpu);
+static void			ia64_mca_wakeup_all(void);
+static void			ia64_log_init(int);
+static irqreturn_t		ia64_mca_rendez_int_handler(int,void *,struct pt_regs *);
+static irqreturn_t		ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
+static irqreturn_t		ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
+static irqreturn_t		ia64_mca_cpe_int_handler(int, void *, struct pt_regs *);
+static irqreturn_t		ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
+static irqreturn_t		ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
+static u64			ia64_log_get(int sal_info_type, u8 **buffer);
+
 static struct irqaction cmci_irqaction = {
 	.handler =	ia64_mca_cmc_int_handler,
 	.flags =	SA_INTERRUPT,
@@ -206,11 +211,6 @@ ia64_mca_log_sal_error_record(int sal_in
  * platform dependent error handling
  */
 #ifndef PLATFORM_MCA_HANDLERS
-static void
-mca_handler_platform (void)
-{
-
-}
 
 static irqreturn_t
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
@@ -412,23 +412,6 @@ init_handler_platform (pal_min_state_are
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
@@ -627,9 +610,6 @@ ia64_mca_init(void)
 
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
-	/* initialize recovery success indicator */
-	ia64_os_mca_recovery_successful = 0;
-
 	/* Clear the Rendez checkin flag for all cpus */
 	for(i = 0 ; i < NR_CPUS; i++)
 		ia64_mc_info.imi_rendez_checkin[i] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
@@ -697,7 +677,7 @@ ia64_mca_init(void)
 
 	/*
 	 * XXX - disable SAL checksum by setting size to 0, should be
-	 * IA64_INIT_HANDLER_SIZE
+	 * size of the actual init handler in mca_asm.S.
 	 */
 	ia64_mc_info.imi_monarch_init_handler		= ia64_tpa(mon_init_ptr->fp);
 	ia64_mc_info.imi_monarch_init_handler_size	= 0;
@@ -766,17 +746,7 @@ ia64_mca_init(void)
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

