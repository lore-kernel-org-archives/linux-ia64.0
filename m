From: Hirofumi Fujita <h-fujita@ebina.hitachi.co.jp>
Date: Thu, 21 Dec 2000 08:20:12 +0000
Subject: [Linux-ia64] CR[TPR] initialization in test12 kernel
Message-Id: <marc-linux-ia64-105590678205871@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

In test12 kernel,
CR[TPR] is not initialized for APs (application processors).

SAL spec says nothing about it's value at SAL to OS handoff,
but we cannot expect it has been set to 0.
So it should be set to 0 when interrupts are enabled in smp_callin().

BSP's CR[TPR] is correctly initialized in init_IRQ().

--- linux-2.4.0-test12-ia64-001214/arch/ia64/kernel/smp.c.org	Fri Dec 15 14:27:12 2000
+++ linux-2.4.0-test12-ia64-001214/arch/ia64/kernel/smp.c	Tue Dec 19 17:45:25 2000
@@ -532,6 +532,7 @@
 	ia64_set_lrr0(0, 1);	
 	ia64_set_lrr1(0, 1);	
 
+	ia64_set_tpr(0);
 	local_irq_enable();		/* Interrupts have been off until now */
 
 	calibrate_delay();


And, here is another patch for init_IRQ().
CR[CMCV] is already initialized to correct value in ia64_mca_init().

--- linux-2.4.0-test12-ia64-001214/arch/ia64/kernel/irq_ia64.c.org	Fri Dec 15 14:23:21 2000
+++ linux-2.4.0-test12-ia64-001214/arch/ia64/kernel/irq_ia64.c	Tue Dec 19 17:54:32 2000
@@ -165,7 +165,6 @@
 #endif
 
 	ia64_set_pmv(1 << 16);
-	ia64_set_cmcv(CMC_IRQ);			/* XXX fix me */
 
 	platform_irq_init();
 

Thanks,

Hirofumi Fujita
Hitachi, Ltd.

