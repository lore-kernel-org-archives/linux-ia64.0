From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 04 Feb 2004 23:27:25 +0000
Subject: Re: [patch] 0/5 2.4.25-pre7 mca.c cleanup
Message-Id: <200402041627.25963.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <6503.1075705201@kao2.melbourne.sgi.com>
In-Reply-To: <6503.1075705201@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 04 February 2004 1:59 pm, Keith Owens wrote:
> On Wed, 04 Feb 2004 16:18:22 +0900, 
> Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> wrote:
> >BTW, could you port these patches to 2.6.x, Keith?
> 
> I am waiting for feedback from Bjorn on the 2.4 patches before doing
> the 2.6 equivalent.

I applied the patches to 2.4 (building and pushing to BK now).  Since
we're doing all this cleanup, I added the attached patch to:

	IA64_MCA_DEBUG(): Move from mca.h to mca.c.
	In uses of IA64_MCA_DEBUG(), use __FUNCTION__ when appropriate.
	Remove function name from normal printk's.
	Report error status for failed SAL calls consistently.
	Tidy up capitalization & punctuation in printk's.

Keith, if you think this is reasonable, would you mind adding it
to your 2.6 patchset?

Bjorn


diff -Nru a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c	Wed Feb  4 16:22:38 2004
+++ b/arch/ia64/kernel/mca.c	Wed Feb  4 16:22:38 2004
@@ -75,6 +75,12 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
+#if defined(IA64_MCA_DEBUG_INFO)
+# define IA64_MCA_DEBUG(fmt...)	printk(fmt)
+#else
+# define IA64_MCA_DEBUG(fmt...)
+#endif
+
 extern void show_stack(struct task_struct *);
 
 typedef struct ia64_fptr {
@@ -215,8 +221,8 @@
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
@@ -267,8 +273,8 @@
 static void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n",
-		       smp_processor_id(), cpe_irq);
+	IA64_MCA_DEBUG("%s: received interrupt. CPU:%d vector = %#x\n",
+		       __FUNCTION__, smp_processor_id(), cpe_irq);
 
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
@@ -505,13 +511,13 @@
 
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
 
 #endif /* PLATFORM_MCA_HANDLERS */
@@ -538,12 +544,12 @@
 	cmcv.cmcv_vector	= IA64_CMC_VECTOR;
 	ia64_set_cmcv(cmcv.cmcv_regval);
 
-	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d corrected "
+	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x setup and enabled.\n",
-		       smp_processor_id(), IA64_CMC_VECTOR);
+		       __FUNCTION__, smp_processor_id(), IA64_CMC_VECTOR);
 
-	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d CMCV = %#016lx\n",
-		       smp_processor_id(), ia64_get_cmcv());
+	IA64_MCA_DEBUG("%s: CPU %d CMCV = %#016lx\n",
+		       __FUNCTION__, smp_processor_id(), ia64_get_cmcv());
 }
 
 /*
@@ -568,9 +574,9 @@
 	cmcv.cmcv_mask = 1; /* Mask/disable interrupt */
 	ia64_set_cmcv(cmcv.cmcv_regval);
 
-	IA64_MCA_DEBUG("ia64_mca_cmc_vector_disable: CPU %d corrected "
+	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x disabled.\n",
-		       smp_processor_id(), cmcv.cmcv_vector);
+		       __FUNCTION__, smp_processor_id(), cmcv.cmcv_vector);
 }
 
 /*
@@ -595,9 +601,9 @@
 	cmcv.cmcv_mask = 0; /* Unmask/enable interrupt */
 	ia64_set_cmcv(cmcv.cmcv_regval);
 
-	IA64_MCA_DEBUG("ia64_mca_cmc_vector_enable: CPU %d corrected "
+	IA64_MCA_DEBUG("%s: CPU %d corrected "
 		       "machine check vector %#x enabled.\n",
-		       smp_processor_id(), cmcv.cmcv_vector);
+		       __FUNCTION__, smp_processor_id(), cmcv.cmcv_vector);
 }
 
 /*
@@ -862,8 +868,8 @@
 	static int		index;
 	static spinlock_t	cmc_history_lock = SPIN_LOCK_UNLOCKED;
 
-	IA64_MCA_DEBUG("ia64_mca_cmc_int_handler: received interrupt vector = %#x on CPU %d\n",
-		       cmc_irq, smp_processor_id());
+	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
+		       __FUNCTION__, cmc_irq, smp_processor_id());
 
 	/* SAL spec states this should run w/ interrupts enabled */
 	local_irq_enable();
@@ -893,7 +899,7 @@
 			 * make sure there's a log somewhere that indicates
 			 * something is generating more than we can handle.
 			 */
-			printk(KERN_WARNING "%s: WARNING: Switching to polling CMC handler, error records may be lost\n", __FUNCTION__);
+			printk(KERN_WARNING "WARNING: Switching to polling CMC handler; error records may be lost\n");
 
 			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);
 
@@ -944,7 +950,7 @@
 		/* If no log recored, switch out of polling mode */
 		if (start_count = IA64_LOG_COUNT(SAL_INFO_TYPE_CMC)) {
 
-			printk(KERN_WARNING "%s: Returning to interrupt driven CMC handler\n", __FUNCTION__);
+			printk(KERN_WARNING "Returning to interrupt driven CMC handler\n");
 			schedule_task(&cmc_enable_tq);
 			cmc_polling_enabled = 0;
 
@@ -1146,7 +1152,7 @@
 	struct ia64_sal_retval isrv;
 	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
 
-	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
+	IA64_MCA_DEBUG("%s: begin\n", __FUNCTION__);
 
 	INIT_TQUEUE(&cmc_disable_tq, ia64_mca_cmc_vector_disable_keventd, NULL);
 	INIT_TQUEUE(&cmc_enable_tq, ia64_mca_cmc_vector_enable_keventd, NULL);
@@ -1170,13 +1176,13 @@
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
 
@@ -1187,12 +1193,12 @@
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
@@ -1208,12 +1214,12 @@
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
@@ -1225,7 +1231,7 @@
 	ia64_mc_info.imi_slave_init_handler		= ia64_tpa(slave_init_ptr->fp);
 	ia64_mc_info.imi_slave_init_handler_size	= 0;
 
-	IA64_MCA_DEBUG("ia64_mca_init: os init handler at %lx\n",
+	IA64_MCA_DEBUG("%s: OS INIT handler at %lx\n", __FUNCTION__,
 		       ia64_mc_info.imi_monarch_init_handler);
 
 	/* Register the os init handler with SAL */
@@ -1237,12 +1243,12 @@
 				       ia64_tpa(ia64_get_gp()),
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
@@ -1285,7 +1291,7 @@
 	ia64_log_init(SAL_INFO_TYPE_CMC);
 	ia64_log_init(SAL_INFO_TYPE_CPE);
 
-	printk(KERN_INFO "Mca related initialization done\n");
+	printk(KERN_INFO "MCA related initialization done\n");
 }
 
 /*
diff -Nru a/include/asm-ia64/mca.h b/include/asm-ia64/mca.h
--- a/include/asm-ia64/mca.h	Wed Feb  4 16:22:38 2004
+++ b/include/asm-ia64/mca.h	Wed Feb  4 16:22:38 2004
@@ -113,10 +113,5 @@
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
 
-#if defined(IA64_MCA_DEBUG_INFO)
-# define IA64_MCA_DEBUG(fmt...)	printk(fmt)
-#else
-# define IA64_MCA_DEBUG(fmt...)
-#endif
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_MCA_H */

