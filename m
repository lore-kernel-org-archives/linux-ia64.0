From: dann frazier <dannf@debian.org>
Date: Thu, 06 Jan 2005 20:26:18 +0000
Subject: sn/kernel/irq.o link failure in 2.6.10
Message-Id: <20050106202618.GC6009@jale>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/sn/built-in.o(.text+0x1ee2): In function `sn_set_affinity_irq':
: undefined reference to `set_irq_affinity_info'

We probably need to wrap the set_irq_affinity_info in an #ifdef CONFIG_SMP -
but should other code be ifdef'd out as well?

--- kernel-source-2.6.10/arch/ia64/sn/kernel/irq.c.orig	2005-01-06 12:40:30.170327564 -0700
+++ kernel-source-2.6.10/arch/ia64/sn/kernel/irq.c	2005-01-06 13:25:36.521856911 -0700
@@ -183,7 +183,9 @@
 
 			sn_irq_info = sn_irq_info->irq_next;
 
+#ifdef CONFIG_SMP
 			set_irq_affinity_info((irq & 0xff), cpuphys, 0);
+#endif
 		} else {
 			break;	/* snp_affinity failed the intr_alloc */
 		}
