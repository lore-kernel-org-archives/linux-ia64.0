From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 25 Jan 2005 22:14:07 +0000
Subject: [RFC] Early ACPI init
Message-Id: <1106691248.13055.59.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel <acpi-devel@lists.sourceforge.net>
Cc: linux-ia64@vger.kernel.org


   We have a bit of an ordering problem today with ACPI initialization.
Platforms are being described entirely in ACPI namespace, but ACPI isn't
initialized until fairly late in boot.  For example, on hp ia64 systems
the only programmatic way to identify and locate the chipset components
is in ACPI namespace.  However, we'd really like to know for certain if
a hardware iommu is present in the system before the memory zones are
initialized.  The (non-)solution today is to guess based on a few
tidbits of data.

   Long, long ago in the 2.4 ia64 patches we used to have early ACPI
initialization to get the PCI routing table info.  The last trace of it
seemed to show up in the 2.4.17 ia64 patches.  Initializing ACPI twice
during a bootup certainly wasn't pretty, but the need for the
functionality still exists.

   Here's a pass at forward porting some of that old early ACPI
initialization to current 2.6 trees.  It's really not as bad as I
thought it might be.  I'd appreciate feedback from the ACPI gurus on
whether the boot time functions I'm providing are necessary and
sufficient.  I know that the stall routine is particularly ugly and the
non-ia64 version is pathetic.  That's hopefully just a place holder for
a better implementation.  I'd prefer not to use architecture specific
code there, but I don't know of any utility that provides a delay this
early in boot.  Would this functionality be useful for anyone else?  I'd
appreciate feedback.  BTW, a good portion of the changes in osl.c are
simply from moving functions around for better ordering.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

 arch/ia64/Kconfig                        |    5 
 arch/ia64/hp/common/sba_iommu.c          |   49 +++
 drivers/acpi/events/evxfevnt.c           |    2 
 drivers/acpi/osl.c                       |  454 ++++++++++++++++++++++++-------
 include/acpi/acpiosxf.h                  |   11 
 include/asm-ia64/machvec_hpzx1_swiotlb.h |    4 
 6 files changed, 422 insertions(+), 103 deletions(-)

=== arch/ia64/Kconfig 1.84 vs edited ==--- 1.84/arch/ia64/Kconfig	2005-01-18 13:06:17 -07:00
+++ edited/arch/ia64/Kconfig	2005-01-25 10:48:41 -07:00
@@ -360,6 +360,11 @@
 	depends on !IA64_HP_SIM
 	default y
 
+config ACPI_EARLY_BOOT
+	bool
+	depends on IA64_GENERIC
+	default y
+
 if !IA64_HP_SIM
 
 source "drivers/acpi/Kconfig"
=== arch/ia64/hp/common/sba_iommu.c 1.50 vs edited ==--- 1.50/arch/ia64/hp/common/sba_iommu.c	2005-01-11 17:10:37 -07:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2005-01-25 11:19:44 -07:00
@@ -2052,6 +2052,21 @@
 
 subsys_initcall(sba_init); /* must be initialized after ACPI etc., but before any drivers... */
 
+#if defined(CONFIG_ACPI_EARLY_BOOT) && defined(CONFIG_IA64_GENERIC)
+acpi_status __init
+find_sba_callback(
+	acpi_handle	handle,
+	u32		level,
+	void		*context,
+	void		**return_value)
+{
+	/* Indicate SBA Found */
+	*(int *)context = 1;
+
+	return AE_CTRL_TERMINATE;
+}
+#endif
+
 extern void dig_setup(char**);
 /*
  * MAX_DMA_ADDRESS needs to be setup prior to paging_init to do any good,
@@ -2060,7 +2075,39 @@
 void __init
 sba_setup(char **cmdline_p)
 {
-	MAX_DMA_ADDRESS = ~0UL;
+#if defined(CONFIG_ACPI_EARLY_BOOT) && defined(CONFIG_IA64_GENERIC)
+	acpi_status	status;
+	int		found = 0;
+
+	status = acpi_bt_init();
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_WARNING "%s(): acpi_bt_init() failed: %d\n",
+		       __FUNCTION__, status);
+		found = 1; /* fudge, old behavior */
+		goto normal_setup;
+	}
+
+	acpi_get_devices("HWP0001", find_sba_callback, &found, NULL);
+	if (!found)
+		acpi_get_devices("HWP0004", find_sba_callback, &found, NULL);
+
+	status = acpi_bt_terminate();
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_WARNING "%s(): acpi_bt_terminate() failed: %d\n",
+		       __FUNCTION__, status);
+	}
+
+normal_setup:
+	if (!found) {
+		printk(KERN_INFO PFX "No SBA IOMMU in namespace, "
+		                     "using DIG machvec\n");
+		machvec_init("dig");
+	}
+#endif /* CONFIG_ACPI_EARLY_BOOT && CONFIG_IA64_GENERIC */
+
+	if (ia64_platform_is("hpzx1"))
+		MAX_DMA_ADDRESS = ~0UL;
+
 	dig_setup(cmdline_p);
 }
 
=== drivers/acpi/osl.c 1.64 vs edited ==--- 1.64/drivers/acpi/osl.c	2004-12-23 06:09:11 -07:00
+++ edited/drivers/acpi/osl.c	2005-01-25 10:41:58 -07:00
@@ -25,6 +25,7 @@
  *
  */
 
+#include <linux/bootmem.h>
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -101,19 +102,6 @@
 	return AE_OK;
 }
 
-acpi_status
-acpi_os_terminate(void)
-{
-	if (acpi_irq_handler) {
-		acpi_os_remove_interrupt_handler(acpi_irq_irq,
-						 acpi_irq_handler);
-	}
-
-	destroy_workqueue(kacpid_wq);
-
-	return AE_OK;
-}
-
 void
 acpi_os_printf(const char *fmt,...)
 {
@@ -142,19 +130,371 @@
 #endif
 }
 
+/*
+ * Standard runtime OS interfaces
+ */
+static void *
+acpi_os_allocate_rt(acpi_size size)
+{
+	return kmalloc(size, GFP_KERNEL);
+}
+
+static void
+acpi_os_free_rt(void *ptr)
+{
+	kfree(ptr);
+}
+
+static void
+acpi_os_stall_rt(u32 us)
+{
+	while (us) {
+		u32 delay = 1000;
+
+		if (delay > us)
+			delay = us;
+		udelay(delay);
+		touch_nmi_watchdog();
+		us -= delay;
+	}
+}
+
+static void
+acpi_os_execute_deferred (
+	void *context)
+{
+	struct acpi_os_dpc	*dpc = NULL;
+
+	ACPI_FUNCTION_TRACE ("os_execute_deferred");
+
+	dpc = (struct acpi_os_dpc *) context;
+	if (!dpc) {
+		ACPI_DEBUG_PRINT ((ACPI_DB_ERROR, "Invalid (NULL) context.\n"));
+		return_VOID;
+	}
+
+	dpc->function(dpc->context);
+
+	kfree(dpc);
+
+	return_VOID;
+}
+
+static acpi_status
+acpi_os_queue_for_execution_rt(
+	u32			priority,
+	acpi_osd_exec_callback	function,
+	void			*context)
+{
+	acpi_status 		status = AE_OK;
+	struct acpi_os_dpc	*dpc;
+	struct work_struct	*task;
+
+	ACPI_FUNCTION_TRACE ("os_queue_for_execution");
+
+	ACPI_DEBUG_PRINT ((ACPI_DB_EXEC, "Scheduling function [%p(%p)] for deferred execution.\n", function, context));
+
+	if (!function)
+		return_ACPI_STATUS (AE_BAD_PARAMETER);
+
+	/*
+	 * Allocate/initialize DPC structure.  Note that this memory will be
+	 * freed by the callee.  The kernel handles the tq_struct list  in a
+	 * way that allows us to also free its memory inside the callee.
+	 * Because we may want to schedule several tasks with different
+	 * parameters we can't use the approach some kernel code uses of
+	 * having a static tq_struct.
+	 * We can save time and code by allocating the DPC and tq_structs
+	 * from the same memory.
+	 */
+
+	dpc = kmalloc(sizeof(struct acpi_os_dpc)+sizeof(struct work_struct), GFP_ATOMIC);
+	if (!dpc)
+		return_ACPI_STATUS (AE_NO_MEMORY);
+
+	dpc->function = function;
+	dpc->context = context;
+
+	task = (void *)(dpc+1);
+	INIT_WORK(task, acpi_os_execute_deferred, (void*)dpc);
+
+	if (!queue_work(kacpid_wq, task)) {
+		ACPI_DEBUG_PRINT ((ACPI_DB_ERROR, "Call to queue_work() failed.\n"));
+		kfree(dpc);
+		status = AE_ERROR;
+	}
+
+	return_ACPI_STATUS (status);
+}
+
+static acpi_status
+acpi_os_terminate_rt(void)
+{
+	if (acpi_irq_handler) {
+		acpi_os_remove_interrupt_handler(acpi_irq_irq,
+						 acpi_irq_handler);
+	}
+
+	destroy_workqueue(kacpid_wq);
+
+	return AE_OK;
+}
+
+struct acpi_osd {
+	void		*(*allocate)(acpi_size size);
+	void		(*free)(void *ptr);
+	acpi_status	(*queue_for_execution)(u32 priority,
+			                       acpi_osd_exec_callback function,
+			                       void *context);
+	void		(*stall)(u32 us);
+	acpi_status	(*terminate)(void);
+};
+
+static struct acpi_osd acpi_osd_rt = {
+	acpi_os_allocate_rt,
+	acpi_os_free_rt,
+	acpi_os_queue_for_execution_rt,
+	acpi_os_stall_rt,
+	acpi_os_terminate_rt
+};
+
+static struct acpi_osd *acpi_osd = &acpi_osd_rt;
+
 void *
 acpi_os_allocate(acpi_size size)
 {
-	return kmalloc(size, GFP_KERNEL);
+	return acpi_osd->allocate(size);
 }
 
 void
 acpi_os_free(void *ptr)
 {
-	kfree(ptr);
+	acpi_osd->free(ptr);
 }
 EXPORT_SYMBOL(acpi_os_free);
 
+void
+acpi_os_stall(u32 us)
+{
+	acpi_osd->stall(us);
+}
+EXPORT_SYMBOL(acpi_os_stall);
+
+acpi_status
+acpi_os_queue_for_execution(
+	u32			priority,
+	acpi_osd_exec_callback	function,
+	void			*context)
+{
+	return acpi_osd->queue_for_execution(priority, function, context);
+}
+EXPORT_SYMBOL(acpi_os_queue_for_execution);
+
+acpi_status
+acpi_os_terminate(void)
+{
+	return acpi_osd->terminate();
+}
+
+#ifdef CONFIG_ACPI_EARLY_BOOT
+/*
+ * Boot time OS interfaces
+ */
+static void * __init
+acpi_os_allocate_bt(acpi_size size)
+{
+	void	*ptr;
+
+	size += sizeof(unsigned long);
+	ptr = alloc_bootmem(size);
+
+	if (ptr) {
+		*((unsigned long *)ptr) = (unsigned long)size;
+		ptr += sizeof(unsigned long);
+	}
+
+	return ptr;
+}
+
+static void __init
+acpi_os_free_bt(void *ptr)
+{
+	unsigned long	size;
+
+	ptr -= sizeof(size);
+	size = *((unsigned long *)ptr);
+
+	free_bootmem(__pa((unsigned long)ptr), (u32)size);
+}
+
+static void __init
+acpi_os_fallback_stall_bt(u32 us)
+{
+	volatile unsigned long i, j;
+
+	/* FIXME: This really sucks */
+	for (i = 0 ; i < (us * 100000) ; i++)
+		j = i;
+}
+
+#ifdef CONFIG_IA64
+#include <asm/sal.h>
+#include <asm/pal.h>
+
+static void __init
+acpi_os_stall_bt(u32 us)
+{
+	unsigned long cycles, start = ia64_get_itc();
+	static unsigned long itc_freq = 0;
+
+	if (!itc_freq) {
+		unsigned long platform_base_freq;
+		struct pal_freq_ratio itc_ratio, proc_ratio;
+		long status, platform_base_drift;
+
+		status = ia64_sal_freq_base(SAL_FREQ_BASE_PLATFORM,
+		                            &platform_base_freq,
+					    &platform_base_drift);
+		if (status != 0)
+			return acpi_os_fallback_stall_bt(us);
+
+		status = ia64_pal_freq_ratios(&proc_ratio, NULL, &itc_ratio);
+		if (status != 0)
+			return acpi_os_fallback_stall_bt(us);
+
+		if (!itc_ratio.den)
+			itc_ratio.den = 1; /* avoid division by zero */
+
+		itc_freq = (platform_base_freq*itc_ratio.num)/itc_ratio.den;
+
+		itc_freq /= 1000; /* freq in us */
+	}
+
+	cycles = us * itc_freq;
+
+	while (ia64_get_itc() - start < cycles)
+		cpu_relax();
+}
+#else
+static void __init
+acpi_os_stall_bt(u32 us)
+{
+	acpi_os_fallback_stall_bt(us);
+}
+#endif
+
+static acpi_status __init
+acpi_os_queue_for_execution_bt(
+	u32			priority,
+	acpi_osd_exec_callback	function,
+	void			*context)
+{
+	/* run callback immediately */
+	(*function)(context);
+	return AE_OK;
+}
+
+static acpi_status __init
+acpi_os_terminate_bt(void)
+{
+	return AE_OK;
+}
+
+static struct acpi_osd acpi_osd_bt __initdata = {
+	acpi_os_allocate_bt,
+	acpi_os_free_bt,
+	acpi_os_queue_for_execution_bt,
+	acpi_os_stall_bt,
+	acpi_os_terminate_bt
+};
+
+#define ACPI_BT_PHASE_BOOTTIME  0x00
+#define ACPI_BT_PHASE_RUNTIME   0x01
+
+static void __init
+acpi_os_bind_osd(int acpi_phase)
+{
+	switch (acpi_phase) {
+		case ACPI_BT_PHASE_BOOTTIME:
+			acpi_osd = &acpi_osd_bt;
+			break;
+		default:
+			acpi_osd = &acpi_osd_rt;
+			break;
+	}
+}
+
+static int	acpi_bt_initialized __initdata = 0;
+
+#define ACPI_BT_INITIALIZED()   (acpi_bt_initialized > 0)
+
+acpi_status __init
+acpi_bt_init(void)
+{
+	acpi_status	status;
+
+	if (ACPI_BT_INITIALIZED())
+		return AE_OK;
+
+	acpi_os_bind_osd(ACPI_BT_PHASE_BOOTTIME);
+
+	status = acpi_initialize_subsystem();
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to initialize the boot time "
+		                       "ACPI Interpreter\n");
+		return status;
+	}
+
+	status = acpi_load_tables();
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to load the System Description "
+		                       "Tables\n");
+		return status;
+	}
+
+	status = acpi_enable_subsystem(ACPI_NO_HANDLER_INIT);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to enable ACPI subsystem\n");
+		return status;
+	}
+
+	status = acpi_initialize_objects(ACPI_FULL_INITIALIZATION);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to initialize ACPI objects\n");
+		return status;
+	}
+
+	acpi_bt_initialized++;
+
+	return AE_OK;
+}
+
+acpi_status __init
+acpi_bt_terminate(void)
+{
+	acpi_status	status;
+
+	if (!ACPI_BT_INITIALIZED())
+		return AE_OK;
+
+	status = acpi_disable();
+	if (ACPI_FAILURE(status)) {
+		/* fall thru... */
+	}
+
+	status = acpi_terminate();
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to terminate boot time ACPI\n");
+		/* fall thru... */
+	}
+
+	acpi_os_bind_osd(ACPI_BT_PHASE_RUNTIME);
+	acpi_bt_initialized--;
+
+	return status;
+}
+#endif /* CONFIG_ACPI_EARLY_BOOT */
+
 acpi_status
 acpi_os_get_root_pointer(u32 flags, struct acpi_pointer *addr)
 {
@@ -322,21 +662,6 @@
 }
 EXPORT_SYMBOL(acpi_os_sleep);
 
-void
-acpi_os_stall(u32 us)
-{
-	while (us) {
-		u32 delay = 1000;
-
-		if (delay > us)
-			delay = us;
-		udelay(delay);
-		touch_nmi_watchdog();
-		us -= delay;
-	}
-}
-EXPORT_SYMBOL(acpi_os_stall);
-
 /*
  * Support ACPI 3.0 AML Timer operand
  * Returns 64-bit free-running, monotonically increasing timer
@@ -658,75 +983,6 @@
 }
 
 #endif /*CONFIG_ACPI_PCI*/
-
-static void
-acpi_os_execute_deferred (
-	void *context)
-{
-	struct acpi_os_dpc	*dpc = NULL;
-
-	ACPI_FUNCTION_TRACE ("os_execute_deferred");
-
-	dpc = (struct acpi_os_dpc *) context;
-	if (!dpc) {
-		ACPI_DEBUG_PRINT ((ACPI_DB_ERROR, "Invalid (NULL) context.\n"));
-		return_VOID;
-	}
-
-	dpc->function(dpc->context);
-
-	kfree(dpc);
-
-	return_VOID;
-}
-
-acpi_status
-acpi_os_queue_for_execution(
-	u32			priority,
-	acpi_osd_exec_callback	function,
-	void			*context)
-{
-	acpi_status 		status = AE_OK;
-	struct acpi_os_dpc	*dpc;
-	struct work_struct	*task;
-
-	ACPI_FUNCTION_TRACE ("os_queue_for_execution");
-
-	ACPI_DEBUG_PRINT ((ACPI_DB_EXEC, "Scheduling function [%p(%p)] for deferred execution.\n", function, context));
-
-	if (!function)
-		return_ACPI_STATUS (AE_BAD_PARAMETER);
-
-	/*
-	 * Allocate/initialize DPC structure.  Note that this memory will be
-	 * freed by the callee.  The kernel handles the tq_struct list  in a
-	 * way that allows us to also free its memory inside the callee.
-	 * Because we may want to schedule several tasks with different
-	 * parameters we can't use the approach some kernel code uses of
-	 * having a static tq_struct.
-	 * We can save time and code by allocating the DPC and tq_structs
-	 * from the same memory.
-	 */
-
-	dpc = kmalloc(sizeof(struct acpi_os_dpc)+sizeof(struct work_struct), GFP_ATOMIC);
-	if (!dpc)
-		return_ACPI_STATUS (AE_NO_MEMORY);
-
-	dpc->function = function;
-	dpc->context = context;
-
-	task = (void *)(dpc+1);
-	INIT_WORK(task, acpi_os_execute_deferred, (void*)dpc);
-
-	if (!queue_work(kacpid_wq, task)) {
-		ACPI_DEBUG_PRINT ((ACPI_DB_ERROR, "Call to queue_work() failed.\n"));
-		kfree(dpc);
-		status = AE_ERROR;
-	}
-
-	return_ACPI_STATUS (status);
-}
-EXPORT_SYMBOL(acpi_os_queue_for_execution);
 
 void
 acpi_os_wait_events_complete(
=== drivers/acpi/events/evxfevnt.c 1.25 vs edited ==--- 1.25/drivers/acpi/events/evxfevnt.c	2004-12-05 22:09:54 -07:00
+++ edited/drivers/acpi/events/evxfevnt.c	2005-01-24 16:49:11 -07:00
@@ -127,7 +127,7 @@
 	if (acpi_hw_get_mode() = ACPI_SYS_MODE_LEGACY) {
 		ACPI_DEBUG_PRINT ((ACPI_DB_INIT, "System is already in legacy (non-ACPI) mode\n"));
 	}
-	else {
+	else if (acpi_gbl_FADT->smi_cmd) {
 		/* Transition to LEGACY mode */
 
 		status = acpi_hw_set_mode (ACPI_SYS_MODE_LEGACY);
=== include/acpi/acpiosxf.h 1.38 vs edited ==--- 1.38/include/acpi/acpiosxf.h	2004-11-11 23:29:47 -07:00
+++ edited/include/acpi/acpiosxf.h	2005-01-25 08:57:03 -07:00
@@ -385,5 +385,16 @@
 	u32                             line_number,
 	char                            *message);
 
+#ifdef CONFIG_ACPI_EARLY_BOOT
+
+acpi_status
+acpi_bt_init (
+	void);
+
+acpi_status
+acpi_bt_terminate (
+	void);
+
+#endif /* CONFIG_ACPI_EARLY_BOOT */
 
 #endif /* __ACPIOSXF_H__ */
=== include/asm-ia64/machvec_hpzx1_swiotlb.h 1.1 vs edited ==--- 1.1/include/asm-ia64/machvec_hpzx1_swiotlb.h	2005-01-12 10:10:35 -07:00
+++ edited/include/asm-ia64/machvec_hpzx1_swiotlb.h	2005-01-25 10:44:28 -07:00
@@ -1,7 +1,7 @@
 #ifndef _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h
 #define _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h
 
-extern ia64_mv_setup_t				dig_setup;
+extern ia64_mv_setup_t				sba_setup;
 extern ia64_mv_dma_init				hwsw_init;
 extern ia64_mv_dma_alloc_coherent		hwsw_alloc_coherent;
 extern ia64_mv_dma_free_coherent		hwsw_free_coherent;
@@ -25,7 +25,7 @@
  */
 #define platform_name				"hpzx1_swiotlb"
 
-#define platform_setup				dig_setup
+#define platform_setup				sba_setup
 #define platform_dma_init			hwsw_init
 #define platform_dma_alloc_coherent		hwsw_alloc_coherent
 #define platform_dma_free_coherent		hwsw_free_coherent


