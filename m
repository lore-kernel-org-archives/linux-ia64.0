From: "Hartnett, Fred" <fred.hartnett@hp.com>
Date: Thu, 21 Mar 2013 14:26:46 +0000
Subject: RE: [RFC/PATCH] Fix initialization of CMCI/CMCP interrupts
Message-Id: <D8D957864D852146A97B866681B1DF2F0D17A034@G4W3207.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <5149f5b79838184a0@agluck-desk.sc.intel.com>
In-Reply-To: <5149f5b79838184a0@agluck-desk.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Tony - the patch does the job from what I can tell. All CPUs now have their CMCI vector initialized properly and the mask bit is cleared. I also did not experience any extraneous boot or /var/log/messages events either.

I will continue to test this out and let you know if I encounter any issues.

Thanks for the patch!!

Fred


-----Original Message-----
From: Luck, Tony [mailto:tony.luck@intel.com] 
Sent: Wednesday, March 20, 2013 11:19 PM
To: Hartnett, Fred
Subject: RE: [RFC/PATCH] Fix initialization of CMCI/CMCP interrupts

Attached.

-Tony

-----Original Message-----
From: Hartnett, Fred [mailto:fred.hartnett@hp.com]
Sent: Wednesday, March 20, 2013 7:06 PM
To: Luck, Tony
Subject: RE: [RFC/PATCH] Fix initialization of CMCI/CMCP interrupts

Hi Tony - can you resend that patch as an attachment. Outlook munged it and patch is complaining. I want to make sure I get this applied properly.

Thanks - Fred


-----Original Message-----
From: Luck, Tony [mailto:tony.luck@intel.com]
Sent: Wednesday, March 20, 2013 12:45 PM
To: Hartnett, Fred
Cc: linux-ia64@vger.kernel.org
Subject: [RFC/PATCH] Fix initialization of CMCI/CMCP interrupts

Back 2010 during a revamp of the irq code some initializations were moved from ia64_mca_init() to ia64_mca_late_init() in

	commit c75f2aa13f5b268aba369b5dc566088b5194377c
	Cannot use register_percpu_irq() from ia64_mca_init()

But this was hideously wrong. First of all these initializations are now down far too late. Specifically after all the other cpus have been brought up and initialized their own CMC vectors from smp_callin(). Also ia64_mca_late_init() may be called from any cpu so the line:
	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP */
is generally not executed on the BSP, and so the CMC vector isn't setup at all on that processor.

Make use of the arch_early_irq_init() hook to get this code executed at just the right moment: not too early, not too late.

Reported-by: Fred Hartnett <fred.hartnett@hp.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Fred: Tinkering with where ia64_mca_late_init() runs doesn't solve the real problem.  Can you test out this patch - I think it deals with the underlying problem.

diff --git a/arch/ia64/include/asm/mca.h b/arch/ia64/include/asm/mca.h index 43f96ab..8c70961 100644
--- a/arch/ia64/include/asm/mca.h
+++ b/arch/ia64/include/asm/mca.h
@@ -143,6 +143,7 @@ extern unsigned long __per_cpu_mca[NR_CPUS];  extern int cpe_vector;  extern int ia64_cpe_irq;  extern void ia64_mca_init(void);
+extern void ia64_mca_irq_init(void);
 extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);  extern void ia64_os_mca_dispatch_end(void); diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c index ad69606..f2c41828 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -23,6 +23,8 @@
 #include <linux/interrupt.h>
 #include <linux/kernel_stat.h>
 
+#include <asm/mca.h>
+
 /*
  * 'what should we do if we get a hw irq event on an illegal vector'.
  * each architecture has to answer this themselves.
@@ -83,6 +85,12 @@ bool is_affinity_mask_valid(const struct cpumask *cpumask)
 
 #endif /* CONFIG_SMP */
 
+int __init arch_early_irq_init(void)
+{
+	ia64_mca_irq_init();
+	return 0;
+}
+
 #ifdef CONFIG_HOTPLUG_CPU
 unsigned int vectors_in_migration[NR_IRQS];
 
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c index 65bf9cd..d7396db 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -2074,22 +2074,16 @@ ia64_mca_init(void)
 	printk(KERN_INFO "MCA related initialization done\n");  }
 
+
 /*
- * ia64_mca_late_init
- *
- *	Opportunity to setup things that require initialization later
- *	than ia64_mca_init.  Setup a timer to poll for CPEs if the
- *	platform doesn't support an interrupt driven mechanism.
- *
- *  Inputs  :   None
- *  Outputs :   Status
+ * These pieces cannot be done in ia64_mca_init() because it is called 
+ before
+ * early_irq_init() which would wipe out our percpu irq registrations. 
+ But we
+ * cannot leave them until ia64_mca_late_init() because by then all the 
+ other
+ * processors have been brought online and have set their own CMC 
+ vectors to
+ * point at a non-existant action. Called from arch_early_irq_init().
  */
-static int __init
-ia64_mca_late_init(void)
+void __init ia64_mca_irq_init(void)
 {
-	if (!mca_init)
-		return 0;
-
 	/*
 	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
 	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
@@ -2108,6 +2102,23 @@ ia64_mca_late_init(void)
 	/* Setup the CPEI/P handler */
 	register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);  #endif
+}
+
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
+static int __init
+ia64_mca_late_init(void)
+{
+	if (!mca_init)
+		return 0;
 
 	register_hotcpu_notifier(&mca_cpu_notifier);
 

