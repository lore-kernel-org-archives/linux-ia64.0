From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 25 Jan 2007 05:48:04 +0000
Subject: [PATCH] Clear IRQ affinity when unregistered
Message-Id: <1169704084.1216.97.camel@bling>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  When we offline a CPU, migrate_irqs() tries to determine whether the
affinity bits of the IRQ descriptor match any of the remaining online
CPUs.  If not, it fixes up the interrupt to point somewhere else.
Unfortunately, if an IRQ is unregistered the IRQ descriptor may still
have affinity to the CPU being offlined, but the no_irq_chip handler
doesn't provide a set_affinity function.  This causes us to hit the
WARN_ON in migrate_irqs().

   The easiest solution seems to be setting all the bits in the affinity
mask when the last interrupt is removed from the vector.  I hit this on
an older kernel with Xen/ia64 using driver domains (so it probably needs
more testing on upstream).  Xen essentially uses the bind/unbind
interface in sysfs to unregister a device from a driver and thus
unregister the interrupt.  Thanks,

	Alex

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

diff -r c73faa796cbf arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c	Thu Jan 25 03:00:04 2007 +0000
+++ b/arch/ia64/kernel/iosapic.c	Wed Jan 24 22:22:00 2007 -0700
@@ -925,6 +925,11 @@ iosapic_unregister_intr (unsigned int gs
 			/* Clear the interrupt controller descriptor */
 			idesc->chip = &no_irq_type;
 
+#ifdef CONFIG_SMP
+			/* Clear affinity */
+			cpus_setall(idesc->affinity);
+#endif
+
 			/* Clear the interrupt information */
 			memset(&iosapic_intr_info[vector], 0,
 			       sizeof(struct iosapic_intr_info));


