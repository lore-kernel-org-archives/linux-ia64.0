From: Keith Owens <kaos@sgi.com>
Date: Thu, 05 Feb 2004 02:34:29 +0000
Subject: [patch] 6/6 2.6.2-rc2 mca.c cleanup - Born's printk cleanup
Message-Id: <4710.1075948469@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Born's printk cleanup

Index: 2-rc2.7/include/asm-ia64/mca.h
--- 2-rc2.7/include/asm-ia64/mca.h Thu, 05 Feb 2004 12:01:04 +1100 kaos (linux-2.6/V/b/0_mca.h 1.1.1.4 644)
+++ 2-rc2.8/include/asm-ia64/mca.h Thu, 05 Feb 2004 13:12:39 +1100 kaos (linux-2.6/V/b/0_mca.h 1.1.1.5 644)
@@ -116,10 +116,5 @@ extern void ia64_slave_init_handler(void
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
 
-#if defined(IA64_MCA_DEBUG_INFO)
-# define IA64_MCA_DEBUG(fmt...)	printk(fmt)
-#else
-# define IA64_MCA_DEBUG(fmt...)
-#endif
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_MCA_H */
Index: 2-rc2.7/arch/ia64/kernel/mca.c
--- 2-rc2.7/arch/ia64/kernel/mca.c Thu, 05 Feb 2004 12:56:08 +1100 kaos (linux-2.6/Z/c/43_mca.c 1.1.1.6 644)
+++ 2-rc2.8/arch/ia64/kernel/mca.c Thu, 05 Feb 2004 13:12:39 +1100 kaos (linux-2.6/Z/c/43_mca.c 1.1.1.7 644)
@@ -76,6 +76,12 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
+#if defined(IA64_MCA_DEBUG_INFO)
+# define IA64_MCA_DEBUG(fmt...)	printk(fmt)
+#else
+# define IA64_MCA_DEBUG(fmt...)
+#endif
+
 typedef struct ia64_fptr {
 	unsigned long fp;
 	unsigned long gp;
@@ -215,8 +221,8 @@ ia64_log_get(int sal_info_type, u8 **buf
 		IA64_LOG_INDEX_INC(sal_info_type);
 		IA64_LOG_UNLOCK(sal_info_type);
 		if (irq_safe) {
-			IA64_MCA_DEBUG("ia64_log_get: SAL error record type %d retrieved. "
-				       "Record length = %ld\n", sal_info_type, total_len);
+			IA64_MCA_DEBUG("%s: SAL error record type %d retrieved. "
+				       "Record length = %ld\n", __FUNCTION__, sal_info_type, total_len);
 		}
 		*buffer = (u8 *) log_buffer;
 		return total_len;
@@ -267,8 +273,8 @@ ia64_mca_log_sal_error_record(int sal_in
 static irqreturn_t
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n",
-		       smp_processor_id(), cpe_irq);
+	IA64_MCA_DEBUG("%s: received interrupt. CPU:%d vector = %#x\n",
+		       __FUNCTION__, smp_processor_id(), cpe_irq);
 
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
@@ -509,13 +515,13 @@ ia64_mca_register_cpev (int cpev)
 
 	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_INT, cpev, 0, 0);
 	if (isrv.status) {
-		printk(KERN_ERR "ia64_mca_platform_init: failed to register Corrected "
-		       "Platform Error interrupt vector with SAL.\n");
+		printk(KERN_ERR "Failed to register Corrected Platform "
+		       "Error interrupt vector with SAL (status %ld)\n", isrv.status);
 		return;
 	}
 
-	IA64_MCA_DEBUG("ia64_mca_platform_init: corrected platform error "
-		       "vector %#x setup and enabled\n", cpev);
+	IA64_MCA_DEBUG("%s: corrected platform error "
+		       "vector %#x setup and enabled\n", __FUNCTION__, cpev);
 }
 #endif /* CONFIG_ACPI */
 
@@ -543,12 +549,12 @@ ia64_mca_cmc_vector_setup (void)
 	cmcv.cmcv_vector	= IA64_CMC_VECTOR;
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);
 
-	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d corrected "
+	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x setup and enabled.\n",
-		       smp_processor_id(), IA64_CMC_VECTOR);
+		       __FUNCTION__, smp_processor_id(), IA64_CMC_VECTOR);
 
-	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d CMCV = %#016lx\n",
-		       smp_processor_id(), ia64_getreg(_IA64_REG_CR_CMCV));
+	IA64_MCA_DEBUG("%s: CPU %d CMCV = %#016lx\n",
+		       __FUNCTION__, smp_processor_id(), ia64_getreg(_IA64_REG_CR_CMCV));
 }
 
 /*
@@ -573,9 +579,9 @@ ia64_mca_cmc_vector_disable (void *dummy
 	cmcv.cmcv_mask = 1; /* Mask/disable interrupt */
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval)
 
-	IA64_MCA_DEBUG("ia64_mca_cmc_vector_disable: CPU %d corrected "
+	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x disabled.\n",
-		       smp_processor_id(), cmcv.cmcv_vector);
+		       __FUNCTION__, smp_processor_id(), cmcv.cmcv_vector);
 }
 
 /*
@@ -600,9 +606,9 @@ ia64_mca_cmc_vector_enable (void *dummy)
 	cmcv.cmcv_mask = 0; /* Unmask/enable interrupt */
 	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval)
 
-	IA64_MCA_DEBUG("ia64_mca_cmc_vector_enable: CPU %d corrected "
+	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x enabled.\n",
-		       smp_processor_id(), cmcv.cmcv_vector);
+		       __FUNCTION__, smp_processor_id(), cmcv.cmcv_vector);
 }
 
 /*
@@ -865,8 +871,8 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 	static int		index;
 	static spinlock_t	cmc_history_lock = SPIN_LOCK_UNLOCKED;
 
-	IA64_MCA_DEBUG("ia64_mca_cmc_int_handler: received interrupt vector = %#x on CPU %d\n",
-		       cmc_irq, smp_processor_id());
+	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
+		       __FUNCTION__, cmc_irq, smp_processor_id());
 
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
@@ -896,7 +902,7 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 			 * make sure there's a log somewhere that indicates
 			 * something is generating more than we can handle.
 			 */
-			printk(KERN_WARNING "%s: WARNING: Switching to polling CMC handler, error records may be lost\n", __FUNCTION__);
+			printk(KERN_WARNING "WARNING: Switching to polling CMC handler; error records may be lost\n");
 
 			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
 
@@ -948,7 +954,7 @@ ia64_mca_cmc_int_caller(int cpe_irq, voi
 		/* If no log record, switch out of polling mode */
 		if (start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
 
-			printk(KERN_WARNING "%s: Returning to interrupt driven CMC handler\n", __FUNCTION__);
+			printk(KERN_WARNING "Returning to interrupt driven CMC handler\n");
 			schedule_work(&cmc_enable_work);
 			cmc_polling_enabled = 0;
 
@@ -1156,7 +1162,7 @@ ia64_mca_init(void)
 	struct ia64_sal_retval isrv;
 	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
 
-	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
+	IA64_MCA_DEBUG("%s: begin\n", __FUNCTION__);
 
 	/* Clear the Rendez checkin flag for all cpus */
 	for(i = 0 ; i < NR_CPUS; i++)
@@ -1177,13 +1183,13 @@ ia64_mca_init(void)
 		if (rc = 0)
 			break;
 		if (rc = -2) {
-			printk(KERN_INFO "ia64_mca_init: increasing MCA rendezvous timeout from "
-				"%ld to %ld\n", timeout, isrv.v0);
+			printk(KERN_INFO "Increasing MCA rendezvous timeout from "
+				"%ld to %ld milliseconds\n", timeout, isrv.v0);
 			timeout = isrv.v0;
 			continue;
 		}
-		printk(KERN_ERR "ia64_mca_init: Failed to register rendezvous interrupt "
-		       "with SAL.  rc = %ld\n", rc);
+		printk(KERN_ERR "Failed to register rendezvous interrupt "
+		       "with SAL (status %ld)\n", rc);
 		return;
 	}
 
@@ -1194,12 +1200,12 @@ ia64_mca_init(void)
 				      0, 0);
 	rc = isrv.status;
 	if (rc) {
-		printk(KERN_ERR "ia64_mca_init: Failed to register wakeup interrupt with SAL.  "
-		       "rc = %ld\n", rc);
+		printk(KERN_ERR "Failed to register wakeup interrupt with SAL "
+		       "(status %ld)\n", rc);
 		return;
 	}
 
-	IA64_MCA_DEBUG("ia64_mca_init: registered mca rendezvous spinloop and wakeup mech.\n");
+	IA64_MCA_DEBUG("%s: registered MCA rendezvous spinloop and wakeup mech.\n", __FUNCTION__);
 
 	ia64_mc_info.imi_mca_handler        = ia64_tpa(mca_hldlr_ptr->fp);
 	/*
@@ -1215,12 +1221,12 @@ ia64_mca_init(void)
 				       ia64_mc_info.imi_mca_handler_size,
 				       0, 0, 0)))
 	{
-		printk(KERN_ERR "ia64_mca_init: Failed to register os mca handler with SAL.  "
-		       "rc = %ld\n", rc);
+		printk(KERN_ERR "Failed to register OS MCA handler with SAL "
+		       "(status %ld)\n", rc);
 		return;
 	}
 
-	IA64_MCA_DEBUG("ia64_mca_init: registered os mca handler with SAL at 0x%lx, gp = 0x%lx\n",
+	IA64_MCA_DEBUG("%s: registered OS MCA handler with SAL at 0x%lx, gp = 0x%lx\n", __FUNCTION__,
 		       ia64_mc_info.imi_mca_handler, ia64_tpa(mca_hldlr_ptr->gp));
 
 	/*
@@ -1232,7 +1238,7 @@ ia64_mca_init(void)
 	ia64_mc_info.imi_slave_init_handler		= ia64_tpa(slave_init_ptr->fp);
 	ia64_mc_info.imi_slave_init_handler_size	= 0;
 
-	IA64_MCA_DEBUG("ia64_mca_init: os init handler at %lx\n",
+	IA64_MCA_DEBUG("%s: OS INIT handler at %lx\n", __FUNCTION__,
 		       ia64_mc_info.imi_monarch_init_handler);
 
 	/* Register the os init handler with SAL */
@@ -1244,12 +1250,12 @@ ia64_mca_init(void)
 				       ia64_tpa(ia64_getreg(_IA64_REG_GP)),
 				       ia64_mc_info.imi_slave_init_handler_size)))
 	{
-		printk(KERN_ERR "ia64_mca_init: Failed to register m/s init handlers with SAL. "
-		       "rc = %ld\n", rc);
+		printk(KERN_ERR "Failed to register m/s INIT handlers with SAL "
+		       "(status %ld)\n", rc);
 		return;
 	}
 
-	IA64_MCA_DEBUG("ia64_mca_init: registered os init handler with SAL\n");
+	IA64_MCA_DEBUG("%s: registered OS INIT handler with SAL\n", __FUNCTION__);
 
 	/*
 	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
@@ -1294,7 +1300,7 @@ ia64_mca_init(void)
 	ia64_log_init(SAL_INFO_TYPE_CMC);
 	ia64_log_init(SAL_INFO_TYPE_CPE);
 
-	printk(KERN_INFO "Mca related initialization done\n");
+	printk(KERN_INFO "MCA related initialization done\n");
 }
 
 /*

