From: Keith Owens <kaos@sgi.com>
Date: Mon, 02 Feb 2004 07:06:29 +0000
Subject: [patch] 5/5 2.4.25-pre7 mca.c cleanup - Reorder to remove the need for forward declarations and to c
Message-Id: <6808.1075705589@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Reorder to remove the need for forward declarations and to consolidate related code

Index: 25-pre7.8/arch/ia64/kernel/mca.c
--- 25-pre7.8/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 17:31:42 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.11 644)
+++ 25-pre7.9/arch/ia64/kernel/mca.c Mon, 02 Feb 2004 17:36:04 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.12 644)
@@ -46,6 +46,8 @@
  *            Delete all record printing code, moved to salinfo_decode in user space.
  *            Mark variables and functions static where possible.
  *            Delete dead variables and functions.
+ *            Reorder to remove the need for forward declarations and to consolidate
+ *            related code.
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -100,55 +102,6 @@ extern struct hw_interrupt_type	irq_type
 
 struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
 
-/* Forward declarations, the code is not in a nice order */
-static void			ia64_mca_wakeup_ipi_wait(void);
-static void			ia64_mca_wakeup(int cpu);
-static void			ia64_mca_wakeup_all(void);
-static void			ia64_log_init(int);
-static void			ia64_mca_rendez_int_handler(int,void *,struct pt_regs *);
-static void			ia64_mca_wakeup_int_handler(int,void *,struct pt_regs *);
-static void			ia64_mca_cmc_int_handler(int,void *,struct pt_regs *);
-static void			ia64_mca_cpe_int_handler(int, void *, struct pt_regs *);
-static void			ia64_mca_cmc_int_caller(int,void *,struct pt_regs *);
-static void			ia64_mca_cpe_int_caller(int,void *,struct pt_regs *);
-static u64			ia64_log_get(int sal_info_type, u8 **buffer);
-
-static struct irqaction cmci_irqaction = {
-	.handler =	ia64_mca_cmc_int_handler,
-	.flags =	SA_INTERRUPT,
-	.name =		"cmc_hndlr"
-};
-
-static struct irqaction cmcp_irqaction = {
-	.handler =	ia64_mca_cmc_int_caller,
-	.flags =	SA_INTERRUPT,
-	.name =		"cmc_poll"
-};
-
-static struct irqaction mca_rdzv_irqaction = {
-	.handler =	ia64_mca_rendez_int_handler,
-	.flags =	SA_INTERRUPT,
-	.name =		"mca_rdzv"
-};
-
-static struct irqaction mca_wkup_irqaction = {
-	.handler =	ia64_mca_wakeup_int_handler,
-	.flags =	SA_INTERRUPT,
-	.name =		"mca_wkup"
-};
-
-static struct irqaction mca_cpe_irqaction = {
-	.handler =	ia64_mca_cpe_int_handler,
-	.flags =	SA_INTERRUPT,
-	.name =		"cpe_hndlr"
-};
-
-static struct irqaction mca_cpep_irqaction = {
-	.handler =	ia64_mca_cpe_int_caller,
-	.flags =	SA_INTERRUPT,
-	.name =		"cpe_poll"
-};
-
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
 #define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
 #define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
@@ -176,6 +129,104 @@ extern void salinfo_log_wakeup(int type,
 static struct tq_struct	cmc_disable_tq, cmc_enable_tq;
 
 /*
+ * IA64_MCA log support
+ */
+#define IA64_MAX_LOGS		2	/* Double-buffering for nested MCAs */
+#define IA64_MAX_LOG_TYPES      4   /* MCA, INIT, CMC, CPE */
+
+typedef struct ia64_state_log_s
+{
+	spinlock_t	isl_lock;
+	int		isl_index;
+	unsigned long	isl_count;
+	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
+} ia64_state_log_t;
+
+static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
+
+#define IA64_LOG_ALLOCATE(it, size) \
+	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
+		(ia64_err_rec_t *)alloc_bootmem(size); \
+	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
+		(ia64_err_rec_t *)alloc_bootmem(size);}
+#define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
+#define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
+#define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
+#define IA64_LOG_NEXT_INDEX(it)    ia64_state_log[it].isl_index
+#define IA64_LOG_CURR_INDEX(it)    1 - ia64_state_log[it].isl_index
+#define IA64_LOG_INDEX_INC(it) \
+    {ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index; \
+    ia64_state_log[it].isl_count++;}
+#define IA64_LOG_INDEX_DEC(it) \
+    ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index
+#define IA64_LOG_NEXT_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)]))
+#define IA64_LOG_CURR_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
+#define IA64_LOG_COUNT(it)         ia64_state_log[it].isl_count
+
+/*
+ * ia64_log_init
+ *	Reset the OS ia64 log buffer
+ * Inputs   :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
+ * Outputs	:	None
+ */
+static void
+ia64_log_init(int sal_info_type)
+{
+	u64	max_size = 0;
+
+	IA64_LOG_NEXT_INDEX(sal_info_type) = 0;
+	IA64_LOG_LOCK_INIT(sal_info_type);
+
+	// SAL will tell us the maximum size of any error record of this type
+	max_size = ia64_sal_get_state_info_size(sal_info_type);
+
+	// set up OS data structures to hold error info
+	IA64_LOG_ALLOCATE(sal_info_type, max_size);
+	memset(IA64_LOG_CURR_BUFFER(sal_info_type), 0, max_size);
+	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0, max_size);
+}
+
+/*
+ * ia64_log_get
+ *
+ *	Get the current MCA log from SAL and copy it into the OS log buffer.
+ *
+ *  Inputs  :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
+ *  Outputs :   size        (total record length)
+ *              *buffer     (ptr to error record)
+ *
+ */
+static u64
+ia64_log_get(int sal_info_type, u8 **buffer)
+{
+	sal_log_record_header_t     *log_buffer;
+	u64                         total_len = 0;
+	int                         s;
+	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
+
+	IA64_LOG_LOCK(sal_info_type);
+
+	/* Get the process state information */
+	log_buffer = IA64_LOG_NEXT_BUFFER(sal_info_type);
+
+	total_len = ia64_sal_get_state_info(sal_info_type, (u64 *)log_buffer);
+
+	if (total_len) {
+		IA64_LOG_INDEX_INC(sal_info_type);
+		IA64_LOG_UNLOCK(sal_info_type);
+		if (irq_safe) {
+			IA64_MCA_DEBUG("ia64_log_get: SAL error record type %d retrieved. "
+				       "Record length = %ld\n", sal_info_type, total_len);
+		}
+		*buffer = (u8 *) log_buffer;
+		return total_len;
+	} else {
+		IA64_LOG_UNLOCK(sal_info_type);
+		return 0;
+	}
+}
+
+/*
  *  ia64_mca_log_sal_error_record
  *
  *  This function retrieves a specified error record type from SAL
@@ -580,252 +631,79 @@ ia64_mca_cmc_vector_enable_keventd(void 
 }
 
 /*
- * ia64_mca_init
- *
- *  Do all the system level mca specific initialization.
+ * ia64_mca_wakeup_ipi_wait
  *
- *	1. Register spinloop and wakeup request interrupt vectors
+ *	Wait for the inter-cpu interrupt to be sent by the
+ *	monarch processor once it is done with handling the
+ *	MCA.
  *
- *	2. Register OS_MCA handler entry point
+ *  Inputs  :   None
+ *  Outputs :   None
+ */
+static void
+ia64_mca_wakeup_ipi_wait(void)
+{
+	int	irr_num = (IA64_MCA_WAKEUP_VECTOR >> 6);
+	int	irr_bit = (IA64_MCA_WAKEUP_VECTOR & 0x3f);
+	u64	irr = 0;
+
+	do {
+		switch(irr_num) {
+		      case 0:
+			irr = ia64_get_irr0();
+			break;
+		      case 1:
+			irr = ia64_get_irr1();
+			break;
+		      case 2:
+			irr = ia64_get_irr2();
+			break;
+		      case 3:
+			irr = ia64_get_irr3();
+			break;
+		}
+	} while (!(irr & (1UL << irr_bit))) ;
+}
+
+/*
+ * ia64_mca_wakeup
  *
- *	3. Register OS_INIT handler entry point
+ *	Send an inter-cpu interrupt to wake-up a particular cpu
+ *	and mark that cpu to be out of rendez.
  *
- *  4. Initialize MCA/CMC/INIT related log buffers maintained by the OS.
+ *  Inputs  :   cpuid
+ *  Outputs :   None
+ */
+static void
+ia64_mca_wakeup(int cpu)
+{
+	platform_send_ipi(cpu, IA64_MCA_WAKEUP_VECTOR, IA64_IPI_DM_INT, 0);
+	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
+
+}
+
+/*
+ * ia64_mca_wakeup_all
  *
- *  Note that this initialization is done very early before some kernel
- *  services are available.
+ *	Wakeup all the cpus which have rendez'ed previously.
  *
  *  Inputs  :   None
- *
  *  Outputs :   None
  */
-void __init
-ia64_mca_init(void)
+static void
+ia64_mca_wakeup_all(void)
 {
-	ia64_fptr_t *mon_init_ptr = (ia64_fptr_t *)ia64_monarch_init_handler;
-	ia64_fptr_t *slave_init_ptr = (ia64_fptr_t *)ia64_slave_init_handler;
-	ia64_fptr_t *mca_hldlr_ptr = (ia64_fptr_t *)ia64_os_mca_dispatch;
-	int i;
-	s64 rc;
-	struct ia64_sal_retval isrv;
-	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
-
-	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
-
-	INIT_TQUEUE(&cmc_disable_tq, ia64_mca_cmc_vector_disable_keventd, NULL);
-	INIT_TQUEUE(&cmc_enable_tq, ia64_mca_cmc_vector_enable_keventd, NULL);
+	int cpu;
 
 	/* Clear the Rendez checkin flag for all cpus */
-	for(i = 0 ; i < NR_CPUS; i++)
-		ia64_mc_info.imi_rendez_checkin[i] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
-
-	/*
-	 * Register the rendezvous spinloop and wakeup mechanism with SAL
-	 */
-
-	/* Register the rendezvous interrupt vector with SAL */
-	while (1) {
-		isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
-					      SAL_MC_PARAM_MECHANISM_INT,
-					      IA64_MCA_RENDEZ_VECTOR,
-					      timeout,
-					      SAL_MC_PARAM_RZ_ALWAYS);
-		rc = isrv.status;
-		if (rc = 0)
-			break;
-		if (rc = -2) {
-			printk(KERN_INFO "ia64_mca_init: increasing MCA rendezvous timeout from "
-				"%ld to %ld\n", timeout, isrv.v0);
-			timeout = isrv.v0;
+	for(cpu = 0; cpu < NR_CPUS; cpu++) {
+		if (!cpu_online(cpu))
 			continue;
-		}
-		printk(KERN_ERR "ia64_mca_init: Failed to register rendezvous interrupt "
-		       "with SAL.  rc = %ld\n", rc);
-		return;
-	}
-
-	/* Register the wakeup interrupt vector with SAL */
-	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
-				      SAL_MC_PARAM_MECHANISM_INT,
-				      IA64_MCA_WAKEUP_VECTOR,
-				      0, 0);
-	rc = isrv.status;
-	if (rc) {
-		printk(KERN_ERR "ia64_mca_init: Failed to register wakeup interrupt with SAL.  "
-		       "rc = %ld\n", rc);
-		return;
+		if (ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE)
+			ia64_mca_wakeup(cpu);
 	}
 
-	IA64_MCA_DEBUG("ia64_mca_init: registered mca rendezvous spinloop and wakeup mech.\n");
-
-	ia64_mc_info.imi_mca_handler        = ia64_tpa(mca_hldlr_ptr->fp);
-	/*
-	 * XXX - disable SAL checksum by setting size to 0; should be
-	 *	ia64_tpa(ia64_os_mca_dispatch_end) - ia64_tpa(ia64_os_mca_dispatch);
-	 */
-	ia64_mc_info.imi_mca_handler_size	= 0;
-
-	/* Register the os mca handler with SAL */
-	if ((rc = ia64_sal_set_vectors(SAL_VECTOR_OS_MCA,
-				       ia64_mc_info.imi_mca_handler,
-				       ia64_tpa(mca_hldlr_ptr->gp),
-				       ia64_mc_info.imi_mca_handler_size,
-				       0, 0, 0)))
-	{
-		printk(KERN_ERR "ia64_mca_init: Failed to register os mca handler with SAL.  "
-		       "rc = %ld\n", rc);
-		return;
-	}
-
-	IA64_MCA_DEBUG("ia64_mca_init: registered os mca handler with SAL at 0x%lx, gp = 0x%lx\n",
-		       ia64_mc_info.imi_mca_handler, ia64_tpa(mca_hldlr_ptr->gp));
-
-	/*
-	 * XXX - disable SAL checksum by setting size to 0, should be
-	 * size of the actual init handler in mca_asm.S.
-	 */
-	ia64_mc_info.imi_monarch_init_handler		= ia64_tpa(mon_init_ptr->fp);
-	ia64_mc_info.imi_monarch_init_handler_size	= 0;
-	ia64_mc_info.imi_slave_init_handler		= ia64_tpa(slave_init_ptr->fp);
-	ia64_mc_info.imi_slave_init_handler_size	= 0;
-
-	IA64_MCA_DEBUG("ia64_mca_init: os init handler at %lx\n",
-		       ia64_mc_info.imi_monarch_init_handler);
-
-	/* Register the os init handler with SAL */
-	if ((rc = ia64_sal_set_vectors(SAL_VECTOR_OS_INIT,
-				       ia64_mc_info.imi_monarch_init_handler,
-				       ia64_tpa(ia64_get_gp()),
-				       ia64_mc_info.imi_monarch_init_handler_size,
-				       ia64_mc_info.imi_slave_init_handler,
-				       ia64_tpa(ia64_get_gp()),
-				       ia64_mc_info.imi_slave_init_handler_size)))
-	{
-		printk(KERN_ERR "ia64_mca_init: Failed to register m/s init handlers with SAL. "
-		       "rc = %ld\n", rc);
-		return;
-	}
-
-	IA64_MCA_DEBUG("ia64_mca_init: registered os init handler with SAL\n");
-
-	/*
-	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
-	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
-	 */
-	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
-	register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
-	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP & enable */
-
-	/* Setup the MCA rendezvous interrupt vector */
-	register_percpu_irq(IA64_MCA_RENDEZ_VECTOR, &mca_rdzv_irqaction);
-
-	/* Setup the MCA wakeup interrupt vector */
-	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, &mca_wkup_irqaction);
-
-	/* Setup the CPE interrupt vector */
-	{
-		irq_desc_t *desc;
-		unsigned int irq;
-		int cpev = acpi_request_vector(ACPI_INTERRUPT_CPEI);
-
-		if (cpev >= 0) {
-			for (irq = 0; irq < NR_IRQS; ++irq)
-				if (irq_to_vector(irq) = cpev) {
-					desc = irq_desc(irq);
-					desc->status |= IRQ_PER_CPU;
-					desc->handler = &irq_type_iosapic_level;
-					setup_irq(irq, &mca_cpe_irqaction);
-				}
-			ia64_mca_register_cpev(cpev);
-		}
-	}
-
-	/* Initialize the areas set aside by the OS to buffer the
-	 * platform/processor error states for MCA/INIT/CMC
-	 * handling.
-	 */
-	ia64_log_init(SAL_INFO_TYPE_MCA);
-	ia64_log_init(SAL_INFO_TYPE_INIT);
-	ia64_log_init(SAL_INFO_TYPE_CMC);
-	ia64_log_init(SAL_INFO_TYPE_CPE);
-
-	printk(KERN_INFO "Mca related initialization done\n");
-}
-
-/*
- * ia64_mca_wakeup_ipi_wait
- *
- *	Wait for the inter-cpu interrupt to be sent by the
- *	monarch processor once it is done with handling the
- *	MCA.
- *
- *  Inputs  :   None
- *  Outputs :   None
- */
-static void
-ia64_mca_wakeup_ipi_wait(void)
-{
-	int	irr_num = (IA64_MCA_WAKEUP_VECTOR >> 6);
-	int	irr_bit = (IA64_MCA_WAKEUP_VECTOR & 0x3f);
-	u64	irr = 0;
-
-	do {
-		switch(irr_num) {
-		      case 0:
-			irr = ia64_get_irr0();
-			break;
-		      case 1:
-			irr = ia64_get_irr1();
-			break;
-		      case 2:
-			irr = ia64_get_irr2();
-			break;
-		      case 3:
-			irr = ia64_get_irr3();
-			break;
-		}
-	} while (!(irr & (1UL << irr_bit))) ;
-}
-
-/*
- * ia64_mca_wakeup
- *
- *	Send an inter-cpu interrupt to wake-up a particular cpu
- *	and mark that cpu to be out of rendez.
- *
- *  Inputs  :   cpuid
- *  Outputs :   None
- */
-static void
-ia64_mca_wakeup(int cpu)
-{
-	platform_send_ipi(cpu, IA64_MCA_WAKEUP_VECTOR, IA64_IPI_DM_INT, 0);
-	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
-
-}
-
-/*
- * ia64_mca_wakeup_all
- *
- *	Wakeup all the cpus which have rendez'ed previously.
- *
- *  Inputs  :   None
- *  Outputs :   None
- */
-static void
-ia64_mca_wakeup_all(void)
-{
-	int cpu;
-
-	/* Clear the Rendez checkin flag for all cpus */
-	for(cpu = 0; cpu < NR_CPUS; cpu++) {
-		if (!cpu_online(cpu))
-			continue;
-		if (ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE)
-			ia64_mca_wakeup(cpu);
-	}
-
-}
+}
 
 /*
  * ia64_mca_rendez_interrupt_handler
@@ -1031,41 +909,6 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 }
 
 /*
- * IA64_MCA log support
- */
-#define IA64_MAX_LOGS		2	/* Double-buffering for nested MCAs */
-#define IA64_MAX_LOG_TYPES      4   /* MCA, INIT, CMC, CPE */
-
-typedef struct ia64_state_log_s
-{
-	spinlock_t	isl_lock;
-	int		isl_index;
-	unsigned long	isl_count;
-	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
-} ia64_state_log_t;
-
-static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
-
-#define IA64_LOG_ALLOCATE(it, size) \
-	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
-		(ia64_err_rec_t *)alloc_bootmem(size); \
-	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
-		(ia64_err_rec_t *)alloc_bootmem(size);}
-#define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
-#define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
-#define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
-#define IA64_LOG_NEXT_INDEX(it)    ia64_state_log[it].isl_index
-#define IA64_LOG_CURR_INDEX(it)    1 - ia64_state_log[it].isl_index
-#define IA64_LOG_INDEX_INC(it) \
-    {ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index; \
-    ia64_state_log[it].isl_count++;}
-#define IA64_LOG_INDEX_DEC(it) \
-    ia64_state_log[it].isl_index = 1 - ia64_state_log[it].isl_index
-#define IA64_LOG_NEXT_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)]))
-#define IA64_LOG_CURR_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
-#define IA64_LOG_COUNT(it)         ia64_state_log[it].isl_count
-
-/*
  *  ia64_mca_cmc_int_caller
  *
  * 	Triggered by sw interrupt from CMC polling routine.  Calls
@@ -1196,39 +1039,6 @@ ia64_mca_cpe_poll (unsigned long dummy)
 }
 
 /*
- * ia64_mca_late_init
- *
- *	Opportunity to setup things that require initialization later
- *	than ia64_mca_init.  Setup a timer to poll for CPEs if the
- *	platform doesn't support an interrupt driven mechanism.
- *
- *  Inputs  :   None
- *  Outputs :   Status
- */
-static int __init
-ia64_mca_late_init(void)
-{
-	init_timer(&cmc_poll_timer);
-	cmc_poll_timer.function = ia64_mca_cmc_poll;
-
-	/* Reset to the correct state */
-	cmc_polling_enabled = 0;
-
-	init_timer(&cpe_poll_timer);
-	cpe_poll_timer.function = ia64_mca_cpe_poll;
-
-	/* If platform doesn't support CPEI, get the timer going. */
-	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0 && cpe_poll_enabled) {
-		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
-		ia64_mca_cpe_poll(0UL);
-	}
-
-	return 0;
-}
-
-module_init(ia64_mca_late_init);
-
-/*
  * C portion of the OS INIT handler
  *
  * Called from ia64_monarch_init_handler
@@ -1260,74 +1070,253 @@ ia64_init_handler (struct pt_regs *pt, s
 	init_handler_platform(ms, pt, sw);	/* call platform specific routines */
 }
 
-/*
- * ia64_log_init
- *	Reset the OS ia64 log buffer
- * Inputs   :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
- * Outputs	:	None
- */
-static void
-ia64_log_init(int sal_info_type)
+static int __init
+ia64_mca_disable_cpe_polling(char *str)
 {
-	u64	max_size = 0;
+	cpe_poll_enabled = 0;
+	return 1;
+}
 
-	IA64_LOG_NEXT_INDEX(sal_info_type) = 0;
-	IA64_LOG_LOCK_INIT(sal_info_type);
+__setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);
 
-	// SAL will tell us the maximum size of any error record of this type
-	max_size = ia64_sal_get_state_info_size(sal_info_type);
+static struct irqaction cmci_irqaction = {
+	.handler =	ia64_mca_cmc_int_handler,
+	.flags =	SA_INTERRUPT,
+	.name =		"cmc_hndlr"
+};
 
-	// set up OS data structures to hold error info
-	IA64_LOG_ALLOCATE(sal_info_type, max_size);
-	memset(IA64_LOG_CURR_BUFFER(sal_info_type), 0, max_size);
-	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0, max_size);
-}
+static struct irqaction cmcp_irqaction = {
+	.handler =	ia64_mca_cmc_int_caller,
+	.flags =	SA_INTERRUPT,
+	.name =		"cmc_poll"
+};
+
+static struct irqaction mca_rdzv_irqaction = {
+	.handler =	ia64_mca_rendez_int_handler,
+	.flags =	SA_INTERRUPT,
+	.name =		"mca_rdzv"
+};
+
+static struct irqaction mca_wkup_irqaction = {
+	.handler =	ia64_mca_wakeup_int_handler,
+	.flags =	SA_INTERRUPT,
+	.name =		"mca_wkup"
+};
+
+static struct irqaction mca_cpe_irqaction = {
+	.handler =	ia64_mca_cpe_int_handler,
+	.flags =	SA_INTERRUPT,
+	.name =		"cpe_hndlr"
+};
+
+static struct irqaction mca_cpep_irqaction = {
+	.handler =	ia64_mca_cpe_int_caller,
+	.flags =	SA_INTERRUPT,
+	.name =		"cpe_poll"
+};
 
 /*
- * ia64_log_get
+ * ia64_mca_init
  *
- *	Get the current MCA log from SAL and copy it into the OS log buffer.
+ *  Do all the system level mca specific initialization.
  *
- *  Inputs  :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
- *  Outputs :   size        (total record length)
- *              *buffer     (ptr to error record)
+ *	1. Register spinloop and wakeup request interrupt vectors
+ *
+ *	2. Register OS_MCA handler entry point
  *
+ *	3. Register OS_INIT handler entry point
+ *
+ *  4. Initialize MCA/CMC/INIT related log buffers maintained by the OS.
+ *
+ *  Note that this initialization is done very early before some kernel
+ *  services are available.
+ *
+ *  Inputs  :   None
+ *
+ *  Outputs :   None
  */
-static u64
-ia64_log_get(int sal_info_type, u8 **buffer)
+void __init
+ia64_mca_init(void)
 {
-	sal_log_record_header_t     *log_buffer;
-	u64                         total_len = 0;
-	int                         s;
-	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
+	ia64_fptr_t *mon_init_ptr = (ia64_fptr_t *)ia64_monarch_init_handler;
+	ia64_fptr_t *slave_init_ptr = (ia64_fptr_t *)ia64_slave_init_handler;
+	ia64_fptr_t *mca_hldlr_ptr = (ia64_fptr_t *)ia64_os_mca_dispatch;
+	int i;
+	s64 rc;
+	struct ia64_sal_retval isrv;
+	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
 
-	IA64_LOG_LOCK(sal_info_type);
+	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
-	/* Get the process state information */
-	log_buffer = IA64_LOG_NEXT_BUFFER(sal_info_type);
+	INIT_TQUEUE(&cmc_disable_tq, ia64_mca_cmc_vector_disable_keventd, NULL);
+	INIT_TQUEUE(&cmc_enable_tq, ia64_mca_cmc_vector_enable_keventd, NULL);
 
-	total_len = ia64_sal_get_state_info(sal_info_type, (u64 *)log_buffer);
+	/* Clear the Rendez checkin flag for all cpus */
+	for(i = 0 ; i < NR_CPUS; i++)
+		ia64_mc_info.imi_rendez_checkin[i] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 
-	if (total_len) {
-		IA64_LOG_INDEX_INC(sal_info_type);
-		IA64_LOG_UNLOCK(sal_info_type);
-		if (irq_safe) {
-			IA64_MCA_DEBUG("ia64_log_get: SAL error record type %d retrieved. "
-				       "Record length = %ld\n", sal_info_type, total_len);
+	/*
+	 * Register the rendezvous spinloop and wakeup mechanism with SAL
+	 */
+
+	/* Register the rendezvous interrupt vector with SAL */
+	while (1) {
+		isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
+					      SAL_MC_PARAM_MECHANISM_INT,
+					      IA64_MCA_RENDEZ_VECTOR,
+					      timeout,
+					      SAL_MC_PARAM_RZ_ALWAYS);
+		rc = isrv.status;
+		if (rc = 0)
+			break;
+		if (rc = -2) {
+			printk(KERN_INFO "ia64_mca_init: increasing MCA rendezvous timeout from "
+				"%ld to %ld\n", timeout, isrv.v0);
+			timeout = isrv.v0;
+			continue;
 		}
-		*buffer = (u8 *) log_buffer;
-		return total_len;
-	} else {
-		IA64_LOG_UNLOCK(sal_info_type);
-		return 0;
+		printk(KERN_ERR "ia64_mca_init: Failed to register rendezvous interrupt "
+		       "with SAL.  rc = %ld\n", rc);
+		return;
+	}
+
+	/* Register the wakeup interrupt vector with SAL */
+	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
+				      SAL_MC_PARAM_MECHANISM_INT,
+				      IA64_MCA_WAKEUP_VECTOR,
+				      0, 0);
+	rc = isrv.status;
+	if (rc) {
+		printk(KERN_ERR "ia64_mca_init: Failed to register wakeup interrupt with SAL.  "
+		       "rc = %ld\n", rc);
+		return;
 	}
+
+	IA64_MCA_DEBUG("ia64_mca_init: registered mca rendezvous spinloop and wakeup mech.\n");
+
+	ia64_mc_info.imi_mca_handler        = ia64_tpa(mca_hldlr_ptr->fp);
+	/*
+	 * XXX - disable SAL checksum by setting size to 0; should be
+	 *	ia64_tpa(ia64_os_mca_dispatch_end) - ia64_tpa(ia64_os_mca_dispatch);
+	 */
+	ia64_mc_info.imi_mca_handler_size	= 0;
+
+	/* Register the os mca handler with SAL */
+	if ((rc = ia64_sal_set_vectors(SAL_VECTOR_OS_MCA,
+				       ia64_mc_info.imi_mca_handler,
+				       ia64_tpa(mca_hldlr_ptr->gp),
+				       ia64_mc_info.imi_mca_handler_size,
+				       0, 0, 0)))
+	{
+		printk(KERN_ERR "ia64_mca_init: Failed to register os mca handler with SAL.  "
+		       "rc = %ld\n", rc);
+		return;
+	}
+
+	IA64_MCA_DEBUG("ia64_mca_init: registered os mca handler with SAL at 0x%lx, gp = 0x%lx\n",
+		       ia64_mc_info.imi_mca_handler, ia64_tpa(mca_hldlr_ptr->gp));
+
+	/*
+	 * XXX - disable SAL checksum by setting size to 0, should be
+	 * size of the actual init handler in mca_asm.S.
+	 */
+	ia64_mc_info.imi_monarch_init_handler		= ia64_tpa(mon_init_ptr->fp);
+	ia64_mc_info.imi_monarch_init_handler_size	= 0;
+	ia64_mc_info.imi_slave_init_handler		= ia64_tpa(slave_init_ptr->fp);
+	ia64_mc_info.imi_slave_init_handler_size	= 0;
+
+	IA64_MCA_DEBUG("ia64_mca_init: os init handler at %lx\n",
+		       ia64_mc_info.imi_monarch_init_handler);
+
+	/* Register the os init handler with SAL */
+	if ((rc = ia64_sal_set_vectors(SAL_VECTOR_OS_INIT,
+				       ia64_mc_info.imi_monarch_init_handler,
+				       ia64_tpa(ia64_get_gp()),
+				       ia64_mc_info.imi_monarch_init_handler_size,
+				       ia64_mc_info.imi_slave_init_handler,
+				       ia64_tpa(ia64_get_gp()),
+				       ia64_mc_info.imi_slave_init_handler_size)))
+	{
+		printk(KERN_ERR "ia64_mca_init: Failed to register m/s init handlers with SAL. "
+		       "rc = %ld\n", rc);
+		return;
+	}
+
+	IA64_MCA_DEBUG("ia64_mca_init: registered os init handler with SAL\n");
+
+	/*
+	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
+	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
+	 */
+	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
+	register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
+	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP & enable */
+
+	/* Setup the MCA rendezvous interrupt vector */
+	register_percpu_irq(IA64_MCA_RENDEZ_VECTOR, &mca_rdzv_irqaction);
+
+	/* Setup the MCA wakeup interrupt vector */
+	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, &mca_wkup_irqaction);
+
+	/* Setup the CPE interrupt vector */
+	{
+		irq_desc_t *desc;
+		unsigned int irq;
+		int cpev = acpi_request_vector(ACPI_INTERRUPT_CPEI);
+
+		if (cpev >= 0) {
+			for (irq = 0; irq < NR_IRQS; ++irq)
+				if (irq_to_vector(irq) = cpev) {
+					desc = irq_desc(irq);
+					desc->status |= IRQ_PER_CPU;
+					desc->handler = &irq_type_iosapic_level;
+					setup_irq(irq, &mca_cpe_irqaction);
+				}
+			ia64_mca_register_cpev(cpev);
+		}
+	}
+
+	/* Initialize the areas set aside by the OS to buffer the
+	 * platform/processor error states for MCA/INIT/CMC
+	 * handling.
+	 */
+	ia64_log_init(SAL_INFO_TYPE_MCA);
+	ia64_log_init(SAL_INFO_TYPE_INIT);
+	ia64_log_init(SAL_INFO_TYPE_CMC);
+	ia64_log_init(SAL_INFO_TYPE_CPE);
+
+	printk(KERN_INFO "Mca related initialization done\n");
 }
 
+/*
+ * ia64_mca_late_init
+ *
+ *	Opportunity to setup things that require initialization later
+ *	than ia64_mca_init.  Setup a timer to poll for CPEs if the
+ *	platform doesn't support an interrupt driven mechanism.
+ *
+ *  Inputs  :   None
+ *  Outputs :   Status
+ */
 static int __init
-ia64_mca_disable_cpe_polling(char *str)
+ia64_mca_late_init(void)
 {
-	cpe_poll_enabled = 0;
-	return 1;
+	init_timer(&cmc_poll_timer);
+	cmc_poll_timer.function = ia64_mca_cmc_poll;
+
+	/* Reset to the correct state */
+	cmc_polling_enabled = 0;
+
+	init_timer(&cpe_poll_timer);
+	cpe_poll_timer.function = ia64_mca_cpe_poll;
+
+	/* If platform doesn't support CPEI, get the timer going. */
+	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0 && cpe_poll_enabled) {
+		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
+		ia64_mca_cpe_poll(0UL);
+	}
+
+	return 0;
 }
 
-__setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);
+module_init(ia64_mca_late_init);

