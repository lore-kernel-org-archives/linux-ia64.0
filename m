From: Keith Owens <kaos@sgi.com>
Date: Mon, 02 Feb 2004 07:04:50 +0000
Subject: [patch] 3/5 2.4.25-pre7 mca.c cleanup - Mark variables and functions static where possible
Message-Id: <6772.1075705490@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mark variables and functions static where possible

Index: 25-pre7.5/include/asm-ia64/mca.h
--- 25-pre7.5/include/asm-ia64/mca.h Mon, 02 Feb 2004 16:52:37 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.1.1.1.1.1.1.4 644)
+++ 25-pre7.6/include/asm-ia64/mca.h Mon, 02 Feb 2004 17:13:41 +1100 kaos (linux-2.4/t/19_mca.h 1.1.3.1.1.1.1.1.1.1.1.1.1.5 644)
@@ -2,7 +2,7 @@
  * File:	mca.h
  * Purpose:	Machine check handling specific defines
  *
- * Copyright (C) 1999 Silicon Graphics, Inc.
+ * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
  * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
  */
@@ -139,12 +139,6 @@ extern void ia64_os_mca_dispatch_end(voi
 extern void ia64_mca_ucmc_handler(void);
 extern void ia64_monarch_init_handler(void);
 extern void ia64_slave_init_handler(void);
-extern void ia64_mca_rendez_int_handler(int,void *,struct pt_regs *);
-extern void ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
-extern void ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
-extern void ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
-extern void ia64_mca_cpe_int_handler(int,void *,struct pt_regs *);
-extern void ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
 
Index: 25-pre7.5/arch/ia64/kernel/mca.c
--- 25-pre7.5/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 16:52:37 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.8 644)
+++ 25-pre7.6/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 17:13:41 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.9 644)
@@ -44,6 +44,7 @@
  * 2004-02-01 Keith Owens <kaos@sgi.com>
  *            Avoid deadlock when using printk() for MCA and INIT records.
  *            Delete all record printing code, moved to salinfo_decode in user space.
+ *            Mark variables and functions static where possible.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -81,7 +82,7 @@ typedef struct ia64_fptr {
 	unsigned long gp;
 } ia64_fptr_t;
 
-ia64_mc_info_t			ia64_mc_info;
+static ia64_mc_info_t		ia64_mc_info;
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
 u64				ia64_mca_proc_state_dump[512];
@@ -95,6 +96,12 @@ static void			ia64_mca_wakeup_ipi_wait(v
 static void			ia64_mca_wakeup(int cpu);
 static void			ia64_mca_wakeup_all(void);
 static void			ia64_log_init(int);
+static void			ia64_mca_rendez_int_handler(int,void *,struct pt_regs *);
+static void			ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
+static void			ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
+static void			ia64_mca_cpe_int_handler(int, void *, struct pt_regs *);
+static void			ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
+static void			ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
 extern void			ia64_monarch_init_handler (void);
 extern void			ia64_slave_init_handler (void);
 static u64			ia64_log_get(int sal_info_type, u8 **buffer);
@@ -201,13 +208,13 @@ ia64_mca_log_sal_error_record(int sal_in
  * platform dependent error handling
  */
 #ifndef PLATFORM_MCA_HANDLERS
-void
+static void
 mca_handler_platform (void)
 {
 
 }
 
-void
+static void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
 	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n",
@@ -358,7 +365,7 @@ fetch_min_state (pal_min_state_area_t *m
 	PUT_NAT_BIT(sw->caller_unat, &pt->r30);	PUT_NAT_BIT(sw->caller_unat, &pt->r31);
 }
 
-void
+static void
 init_handler_platform (pal_min_state_area_t *ms,
 		       struct pt_regs *pt, struct switch_stack *sw)
 {
@@ -416,7 +423,7 @@ init_handler_platform (pal_min_state_are
  *  Outputs
  *      None
  */
-void
+static void
 ia64_mca_init_platform (void)
 {
 
@@ -516,7 +523,7 @@ ia64_mca_cmc_vector_setup (void)
  * Outputs
  *	None
  */
-void
+static void
 ia64_mca_cmc_vector_disable (void *dummy)
 {
 	cmcv_reg_t	cmcv;
@@ -543,7 +550,7 @@ ia64_mca_cmc_vector_disable (void *dummy
  * Outputs
  *	None
  */
-void
+static void
 ia64_mca_cmc_vector_enable (void *dummy)
 {
 	cmcv_reg_t	cmcv;
@@ -784,7 +791,7 @@ ia64_mca_init(void)
  *  Inputs  :   None
  *  Outputs :   None
  */
-void
+static void
 ia64_mca_wakeup_ipi_wait(void)
 {
 	int	irr_num = (IA64_MCA_WAKEUP_VECTOR >> 6);
@@ -818,7 +825,7 @@ ia64_mca_wakeup_ipi_wait(void)
  *  Inputs  :   cpuid
  *  Outputs :   None
  */
-void
+static void
 ia64_mca_wakeup(int cpu)
 {
 	platform_send_ipi(cpu, IA64_MCA_WAKEUP_VECTOR, IA64_IPI_DM_INT, 0);
@@ -834,7 +841,7 @@ ia64_mca_wakeup(int cpu)
  *  Inputs  :   None
  *  Outputs :   None
  */
-void
+static void
 ia64_mca_wakeup_all(void)
 {
 	int cpu;
@@ -859,7 +866,7 @@ ia64_mca_wakeup_all(void)
  *  Inputs  :   None
  *  Outputs :   None
  */
-void
+static void
 ia64_mca_rendez_int_handler(int rendez_irq, void *arg, struct pt_regs *ptregs)
 {
 	unsigned long flags;
@@ -900,7 +907,7 @@ ia64_mca_rendez_int_handler(int rendez_i
  *  Outputs :   None
  *
  */
-void
+static void
 ia64_mca_wakeup_int_handler(int wakeup_irq, void *arg, struct pt_regs *ptregs)
 {
 }
@@ -919,7 +926,7 @@ ia64_mca_wakeup_int_handler(int wakeup_i
  *  Outputs :   None
  */
 
-void
+static void
 ia64_return_to_sal_check(void)
 {
 	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
@@ -999,7 +1006,7 @@ ia64_mca_ucmc_handler(void)
  * Outputs
  *	None
  */
-void
+static void
 ia64_mca_cmc_int_handler(int cmc_irq, void *arg, struct pt_regs *ptregs)
 {
 	static unsigned long	cmc_history[CMC_HISTORY_LENGTH];
@@ -1101,7 +1108,7 @@ static ia64_state_log_t ia64_state_log[I
  * Outputs
  *	None
  */
-void
+static void
 ia64_mca_cmc_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
 	static int start_count = -1;
@@ -1166,7 +1173,7 @@ ia64_mca_cmc_poll (unsigned long dummy)
  * Outputs
  *	None
  */
-void
+static void
 ia64_mca_cpe_int_caller(int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
 	static int start_count = -1;
@@ -1288,7 +1295,7 @@ ia64_init_handler (struct pt_regs *pt, s
  * Inputs   :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
  * Outputs	:	None
  */
-void
+static void
 ia64_log_init(int sal_info_type)
 {
 	u64	max_size = 0;
@@ -1315,7 +1322,7 @@ ia64_log_init(int sal_info_type)
  *              *buffer     (ptr to error record)
  *
  */
-u64
+static u64
 ia64_log_get(int sal_info_type, u8 **buffer)
 {
 	sal_log_record_header_t     *log_buffer;

