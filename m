From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 28 Jul 2004 12:17:14 +0000
Subject: [PATCH] Aviod a problem caused by CMCI/CPEI flood on boot
Message-Id: <4107994A.10805@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a problem that if CMCI/CPEIs flood on boottime, the system
can't make the switching between interrupt&polling(CMCI/P,CPEI/P)
work correctly.

The root cause is that the setup of interruptions(CMCI/CPEI) come
before the setup of pollings(CMCP/CPEP).  There is a certain period
that the interruptions are enabled but the pollings are not.  i.g.

   1: Power on - Interrupt...disabled, Poll...disabled
	The flood of correct error is just ignored.

   2: Setup "I" - Interrupt...enabled, Poll...disabled
	The errors are reported by Interrupt. If there are enough
	(over threshold) errors, the vector will be disabled and
	polling timer will be kicked. ...But in this time, the
	timer isn't initialized yet, so this timer will do nothing.
	->> Interrupt...disabled(masked), Poll...disabled

   3: Setup "P" - Interrupt...disabled, Poll...enabled(inactive)
	Polling timer is initialized, and the timer starts to
	wait activating from the interrupt.  In fact, the
	interrupt was already disabled... so no one will kick
	the timer, no one will report coming new errors.

The solution is very simple: Setup "I" after "P".  This patch does:

   CMCI/P:
	mask the CMCI vector before init it to each cpu.
	unmask the vector after the setup of CMCP finished.
   CPEI/P:
	move registering CPEI vector to after the setup of CPEP.

As a result, this fix groups concerning codes into ia64_mca_late_init,
and increases the code visibility.

Tony, could you apply this patch?

Thanks,
H.Seto
-----

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>


diff -Nur linux-2.6.7-ia64-040619/arch/ia64/kernel/mca.c linux-2.6.7-ia64-040619-cpe/arch/ia64/kernel/mca.c
--- linux-2.6.7-ia64-040619/arch/ia64/kernel/mca.c	2004-06-28 15:53:02.000000000 +0900
+++ linux-2.6.7-ia64-040619-cpe/arch/ia64/kernel/mca.c	2004-06-28 22:40:50.000000000 +0900
@@ -540,7 +540,7 @@
  	}

  	IA64_MCA_DEBUG("%s: corrected platform error "
-		       "vector %#x setup and enabled\n", __FUNCTION__, cpev);
+		       "vector %#x registered\n", __FUNCTION__, cpev);
  }
  #endif /* CONFIG_ACPI */

@@ -549,8 +549,9 @@
  /*
   * ia64_mca_cmc_vector_setup
   *
- *  Setup the corrected machine check vector register in the processor and
- *  unmask interrupt.  This function is invoked on a per-processor basis.
+ *  Setup the corrected machine check vector register in the processor.
+ *  (The interrupt is masked on boot. ia64_mca_late_init unmask this.)
+ *  This function is invoked on a per-processor basis.
   *
   * Inputs
   *      None
@@ -564,12 +565,12 @@
  	cmcv_reg_t	cmcv;

  	cmcv.cmcv_regval	= 0;
-	cmcv.cmcv_mask		= 0;        /* Unmask/enable interrupt */
+	cmcv.cmcv_mask		= 1;        /* Mask/disable interrupt at first */
  	cmcv.cmcv_vector	= IA64_CMC_VECTOR;
  	ia64_setreg(_IA64_REG_CR_CMCV, cmcv.cmcv_regval);

  	IA64_MCA_DEBUG("%s: CPU %d corrected "
-		       "machine check vector %#x setup and enabled.\n",
+		       "machine check vector %#x registered.\n",
  		       __FUNCTION__, smp_processor_id(), IA64_CMC_VECTOR);

  	IA64_MCA_DEBUG("%s: CPU %d CMCV = %#016lx\n",
@@ -1291,7 +1292,7 @@
  	 */
  	register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
  	register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
-	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP & enable */
+	ia64_mca_cmc_vector_setup();       /* Setup vector on BSP */

  	/* Setup the MCA rendezvous interrupt vector */
  	register_percpu_irq(IA64_MCA_RENDEZ_VECTOR, &mca_rdzv_irqaction);
@@ -1301,23 +1302,8 @@

  #ifdef CONFIG_ACPI
  	/* Setup the CPEI/P vector and handler */
-	{
-		irq_desc_t *desc;
-		unsigned int irq;
-
-		cpe_vector = acpi_request_vector(ACPI_INTERRUPT_CPEI);
-
-		if (cpe_vector >= 0) {
-			for (irq = 0; irq < NR_IRQS; ++irq)
-				if (irq_to_vector(irq) = cpe_vector) {
-					desc = irq_descp(irq);
-					desc->status |= IRQ_PER_CPU;
-					setup_irq(irq, &mca_cpe_irqaction);
-				}
-			ia64_mca_register_cpev(cpe_vector);
-		}
-		register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
-	}
+	cpe_vector = acpi_request_vector(ACPI_INTERRUPT_CPEI);
+	register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
  #endif

  	/* Initialize the areas set aside by the OS to buffer the
@@ -1345,21 +1331,43 @@
  static int __init
  ia64_mca_late_init(void)
  {
+	/* Setup the CMCI/P vector and handler */
  	init_timer(&cmc_poll_timer);
  	cmc_poll_timer.function = ia64_mca_cmc_poll;

-	/* Reset to the correct state */
+	/* Unmask/enable the vector */
  	cmc_polling_enabled = 0;
+	schedule_work(&cmc_enable_work);

+	IA64_MCA_DEBUG("%s: CMCI/P setup and enabled.\n", __FUNCTION__);
+
+#ifdef CONFIG_ACPI
+	/* Setup the CPEI/P vector and handler */
  	init_timer(&cpe_poll_timer);
  	cpe_poll_timer.function = ia64_mca_cpe_poll;

-#ifdef CONFIG_ACPI
-	/* If platform doesn't support CPEI, get the timer going. */
-	if (cpe_vector < 0 && cpe_poll_enabled) {
-		ia64_mca_cpe_poll(0UL);
-	} else {
-		cpe_poll_enabled = 0;
+	{
+		irq_desc_t *desc;
+		unsigned int irq;
+
+		if (cpe_vector >= 0) {
+			/* If platform supports CPEI, enable the irq. */
+			cpe_poll_enabled = 0;
+			for (irq = 0; irq < NR_IRQS; ++irq)
+				if (irq_to_vector(irq) = cpe_vector) {
+					desc = irq_descp(irq);
+					desc->status |= IRQ_PER_CPU;
+					setup_irq(irq, &mca_cpe_irqaction);
+				}
+			ia64_mca_register_cpev(cpe_vector);
+			IA64_MCA_DEBUG("%s: CPEI/P setup and enabled.\n", __FUNCTION__);
+		} else {
+			/* If platform doesn't support CPEI, get the timer going. */
+			if (cpe_poll_enabled) {
+				ia64_mca_cpe_poll(0UL);
+				IA64_MCA_DEBUG("%s: CPEP setup and enabled.\n", __FUNCTION__);
+			}
+		}
  	}
  #endif

diff -Nur linux-2.6.7-ia64-040619/arch/ia64/kernel/smpboot.c linux-2.6.7-ia64-040619-cpe/arch/ia64/kernel/smpboot.c
--- linux-2.6.7-ia64-040619/arch/ia64/kernel/smpboot.c	2004-06-28 22:36:40.000000000 +0900
+++ linux-2.6.7-ia64-040619-cpe/arch/ia64/kernel/smpboot.c	2004-06-28 22:37:38.000000000 +0900
@@ -299,7 +299,7 @@

  	smp_setup_percpu_timer();

-	ia64_mca_cmc_vector_setup();	/* Setup vector on AP & enable */
+	ia64_mca_cmc_vector_setup();	/* Setup vector on AP */

  #ifdef CONFIG_PERFMON
  	pfm_init_percpu();

