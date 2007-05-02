From: John Keller <jpk@sgi.com>
Date: Wed, 02 May 2007 14:09:18 +0000
Subject: [PATCH] - Altix: hotplug after intr redirect can crash system
Message-Id: <20070502140918.11022.65956.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When redirecting a device interrupt on SN, not all links
between platform specific structures are being updated.
This can result in a system crash if an interrupt
redirection is followed by an unplug of that device.

The complete fix also requires a prom update. Though,
this patch is backward compatable and not dependent on
the prom patch.

Signed-off-by: John Keller <jpk@sgi.com>
---

 arch/ia64/sn/kernel/irq.c    |   58 ++++++++++++++++++++++++---------
 include/asm-ia64/sn/sn_sal.h |    1 
 2 files changed, 44 insertions(+), 15 deletions(-)


Index: linux-2.6/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/irq.c	2007-05-01 15:01:26.472284737 -0500
+++ linux-2.6/arch/ia64/sn/kernel/irq.c	2007-05-02 09:04:31.370355274 -0500
@@ -59,6 +59,22 @@ void sn_intr_free(nasid_t local_nasid, i
 			(u64) sn_irq_info->irq_cookie, 0, 0);
 }
 
+u64 sn_intr_redirect(nasid_t local_nasid, int local_widget,
+		      struct sn_irq_info *sn_irq_info,
+		      nasid_t req_nasid, int req_slice)
+{
+	struct ia64_sal_retval ret_stuff;
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+
+	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_INTERRUPT,
+			(u64) SAL_INTR_REDIRECT, (u64) local_nasid,
+			(u64) local_widget, __pa(sn_irq_info),
+			(u64) req_nasid, (u64) req_slice, 0);
+
+	return ret_stuff.status;
+}
+
 static unsigned int sn_startup_irq(unsigned int irq)
 {
 	return 0;
@@ -127,15 +143,8 @@ struct sn_irq_info *sn_retarget_vector(s
 	struct sn_irq_info *new_irq_info;
 	struct sn_pcibus_provider *pci_provider;
 
-	new_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_ATOMIC);
-	if (new_irq_info = NULL)
-		return NULL;
-
-	memcpy(new_irq_info, sn_irq_info, sizeof(struct sn_irq_info));
-
-	bridge = (u64) new_irq_info->irq_bridge;
+	bridge = (u64) sn_irq_info->irq_bridge;
 	if (!bridge) {
-		kfree(new_irq_info);
 		return NULL; /* irq is not a device interrupt */
 	}
 
@@ -145,8 +154,25 @@ struct sn_irq_info *sn_retarget_vector(s
 		local_widget = TIO_SWIN_WIDGETNUM(bridge);
 	else
 		local_widget = SWIN_WIDGETNUM(bridge);
-
 	vector = sn_irq_info->irq_irq;
+
+	/* Make use of SAL_INTR_REDIRECT if PROM supports it */
+	status = sn_intr_redirect(local_nasid, local_widget, sn_irq_info, nasid, slice);
+	if (!status) {
+		new_irq_info = sn_irq_info;
+		goto finish_up;
+	}
+
+	/*
+	 * PROM does not support SAL_INTR_REDIRECT, or it failed.
+	 * Revert to old method.
+	 */
+	new_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_ATOMIC);
+	if (new_irq_info = NULL)
+		return NULL;
+
+	memcpy(new_irq_info, sn_irq_info, sizeof(struct sn_irq_info));
+
 	/* Free the old PROM new_irq_info structure */
 	sn_intr_free(local_nasid, local_widget, new_irq_info);
 	unregister_intr_pda(new_irq_info);
@@ -162,11 +188,18 @@ struct sn_irq_info *sn_retarget_vector(s
 		return NULL;
 	}
 
+	register_intr_pda(new_irq_info);
+	spin_lock(&sn_irq_info_lock);
+	list_replace_rcu(&sn_irq_info->list, &new_irq_info->list);
+	spin_unlock(&sn_irq_info_lock);
+	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
+
+
+finish_up:
 	/* Update kernels new_irq_info with new target info */
 	cpuid = nasid_slice_to_cpuid(new_irq_info->irq_nasid,
 				     new_irq_info->irq_slice);
 	new_irq_info->irq_cpuid = cpuid;
-	register_intr_pda(new_irq_info);
 
 	pci_provider = sn_pci_provider[new_irq_info->irq_bridge_type];
 
@@ -178,11 +211,6 @@ struct sn_irq_info *sn_retarget_vector(s
 	    pci_provider && pci_provider->target_interrupt)
 		(pci_provider->target_interrupt)(new_irq_info);
 
-	spin_lock(&sn_irq_info_lock);
-	list_replace_rcu(&sn_irq_info->list, &new_irq_info->list);
-	spin_unlock(&sn_irq_info_lock);
-	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
-
 #ifdef CONFIG_SMP
 	cpuphys = cpu_physical_id(cpuid);
 	set_irq_affinity_info((vector & 0xff), cpuphys, 0);
Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2007-05-01 15:01:26.472284737 -0500
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h	2007-05-01 15:01:28.564529663 -0500
@@ -106,6 +106,7 @@
 /* interrupt handling */
 #define SAL_INTR_ALLOC		1
 #define SAL_INTR_FREE		2
+#define SAL_INTR_REDIRECT	3
 
 /*
  * operations available on the generic SN_SAL_SYSCTL_OP
