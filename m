From: Keith Owens <kaos@sgi.com>
Date: Fri, 06 Feb 2004 06:20:09 +0000
Subject: [patch] 2.4.25-pre8 mca.c - sync with 2.6.2-rc2
Message-Id: <9170.1076048409@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Minimize the divergence between 2.4 and 2.6 in mca.c.  Mainly white
space, comment and #ifdef changes.  Plus a test for zero return from
ia64_sal_get_state_info_size().

Index: 25-pre8.3/arch/ia64/kernel/mca.c
--- 25-pre8.3/arch/ia64/kernel/mca.c Thu, 05 Feb 2004 10:53:36 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.3 644)
+++ 25-pre8.5/arch/ia64/kernel/mca.c Fri, 06 Feb 2004 17:15:40 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.5 644)
@@ -6,7 +6,7 @@
  * Copyright (C) 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
- * Copyright (C) 2002 Dell Computer Corporation
+ * Copyright (C) 2002 Dell Inc.
  * Copyright (C) Matt Domsch (Matt_Domsch@dell.com)
  *
  * Copyright (C) 2002 Intel
@@ -185,6 +185,9 @@ ia64_log_init(int sal_info_type)
 
 	// SAL will tell us the maximum size of any error record of this type
 	max_size = ia64_sal_get_state_info_size(sal_info_type);
+	if (!max_size)
+		/* alloc_bootmem() doesn't like zero-sized allocations! */
+		return;
 
 	// set up OS data structures to hold error info
 	IA64_LOG_ALLOCATE(sal_info_type, max_size);
@@ -474,7 +477,9 @@ init_handler_platform (pal_min_state_are
  *  ia64_mca_check_errors
  *
  *  External entry to check for error records which may have been posted by SAL
- *  for a prior failure.
+ *  for a prior failure which resulted in a machine shutdown before an the
+ *  error could be logged.  This function must be called after the filesystem
+ *  is initialized.
  *
  *  Inputs  :   None
  *
@@ -492,6 +497,7 @@ ia64_mca_check_errors (void)
 	return 0;
 }
 
+#ifdef CONFIG_ACPI
 /*
  * ia64_mca_register_cpev
  *
@@ -519,6 +525,7 @@ ia64_mca_register_cpev (int cpev)
 	IA64_MCA_DEBUG("%s: corrected platform error "
 		       "vector %#x setup and enabled\n", __FUNCTION__, cpev);
 }
+#endif /* CONFIG_ACPI */
 
 #endif /* PLATFORM_MCA_HANDLERS */
 
@@ -746,7 +753,6 @@ ia64_mca_rendez_int_handler(int rendez_i
 	local_irq_restore(flags);
 }
 
-
 /*
  * ia64_mca_wakeup_int_handler
  *
@@ -943,11 +949,11 @@ ia64_mca_cmc_int_caller(int cpe_irq, voi
 	ia64_mca_cmc_int_handler(cpe_irq, arg, ptregs);
 
 	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
-		
+
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
 	} else {
-		/* If no log recored, switch out of polling mode */
+		/* If no log record, switch out of polling mode */
 		if (start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
 
 			printk(KERN_WARNING "Returning to interrupt driven CMC handler\n");
@@ -1109,6 +1115,7 @@ static struct irqaction mca_wkup_irqacti
 	.name =		"mca_wkup"
 };
 
+#ifdef CONFIG_ACPI
 static struct irqaction mca_cpe_irqaction = {
 	.handler =	ia64_mca_cpe_int_handler,
 	.flags =	SA_INTERRUPT,
@@ -1120,6 +1127,7 @@ static struct irqaction mca_cpep_irqacti
 	.flags =	SA_INTERRUPT,
 	.name =		"cpe_poll"
 };
+#endif /* CONFIG_ACPI */
 
 /*
  * ia64_mca_init
@@ -1264,6 +1272,7 @@ ia64_mca_init(void)
 	/* Setup the MCA wakeup interrupt vector */
 	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, &mca_wkup_irqaction);
 
+#ifdef CONFIG_ACPI
 	/* Setup the CPE interrupt vector */
 	{
 		irq_desc_t *desc;
@@ -1281,6 +1290,7 @@ ia64_mca_init(void)
 			ia64_mca_register_cpev(cpev);
 		}
 	}
+#endif
 
 	/* Initialize the areas set aside by the OS to buffer the
 	 * platform/processor error states for MCA/INIT/CMC
@@ -1316,11 +1326,13 @@ ia64_mca_late_init(void)
 	init_timer(&cpe_poll_timer);
 	cpe_poll_timer.function = ia64_mca_cpe_poll;
 
+#ifdef CONFIG_ACPI
 	/* If platform doesn't support CPEI, get the timer going. */
 	if (acpi_request_vector(ACPI_INTERRUPT_CPEI) < 0 && cpe_poll_enabled) {
 		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
 		ia64_mca_cpe_poll(0UL);
 	}
+#endif
 
 	return 0;
 }

