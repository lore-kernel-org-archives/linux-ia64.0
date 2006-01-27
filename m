From: Mark Maule <maule@sgi.com>
Date: Fri, 27 Jan 2006 17:55:34 +0000
Subject: [PATCH] altix:  fix smp_affinity redirection when using CONFIG_PCI_MSI
Message-Id: <20060127175534.22765.94743.33870@lnx-maule.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Redirecting interrupts using smp_affinity on altix does not work on kernels
built with CONFIG_PCI_MSI.  The problem is that move_irq() turns into a noop
if MSI is built in.  This patch calls move_native_irq() instead of move_irq()
to get around that.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: linux-maule/arch/ia64/sn/kernel/irq.c
=================================--- linux-maule.orig/arch/ia64/sn/kernel/irq.c	2006-01-02 21:21:10.000000000 -0600
+++ linux-maule/arch/ia64/sn/kernel/irq.c	2006-01-27 11:04:55.546979933 -0600
@@ -86,7 +86,7 @@
 	      mask);
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
 
-	move_irq(irq);
+	move_native_irq(irq);
 }
 
 static void sn_end_irq(unsigned int irq)
