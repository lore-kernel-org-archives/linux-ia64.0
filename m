From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 24 Mar 2006 06:45:48 +0000
Subject: [PATCH 1/2] correct some messages and fixes some minor typos
Message-Id: <87odzwfihv.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch corrects some wrong comments and a printk message.
It also fixes some minor typos.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

Index: linux-2.6.16/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.16.orig/arch/ia64/kernel/iosapic.c	2006-03-24 14:42:43.000000000 +0900
+++ linux-2.6.16/arch/ia64/kernel/iosapic.c	2006-03-24 14:42:44.000000000 +0900
@@ -39,7 +39,7 @@
  * Here is what the interrupt logic between a PCI device and the kernel looks like:
  *
  * (1) A PCI device raises one of the four interrupt pins (INTA, INTB, INTC, INTD).  The
- *     device is uniquely identified by its bus--, and slot-number (the function
+ *     device is uniquely identified by its bus-, and slot-number (the function
  *     number does not matter here because all functions share the same interrupt
  *     lines).
  *
@@ -90,7 +90,6 @@
 #include <asm/ptrace.h>
 #include <asm/system.h>
 
-
 #undef DEBUG_INTERRUPT_ROUTING
 
 #ifdef DEBUG_INTERRUPT_ROUTING
@@ -128,7 +127,7 @@
 static struct iosapic {
 	char __iomem	*addr;		/* base address of IOSAPIC */
 	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
-	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
+	unsigned short 	num_rte;	/* # of RTEs on this IOSAPIC */
 	int		rtes_inuse;	/* # of RTEs in use on this IOSAPIC */
 #ifdef CONFIG_NUMA
 	unsigned short	node;		/* numa node association via pxm */
@@ -185,7 +184,7 @@
 	unsigned long flags;
 	int irq;
 	/*
-	 * XXX fix me: this assumes an identity mapping vetween IA-64 vector and Linux irq
+	 * XXX fix me: this assumes an identity mapping between IA-64 vector and Linux irq
 	 * numbers...
 	 */
 	spin_lock_irqsave(&iosapic_lock, flags);
@@ -259,7 +258,7 @@
 }
 
 static void
-nop (unsigned int vector)
+nop (unsigned int irq)
 {
 	/* do nothing... */
 }
@@ -675,7 +674,7 @@
 		if (!num_cpus)
 			goto skip_numa_setup;
 
-		/* Use vector assigment to distribute across cpus in node */
+		/* Use vector assignment to distribute across cpus in node */
 		cpu_index = vector % num_cpus;
 
 		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
@@ -697,7 +696,7 @@
 	} while (!cpu_online(cpu));
 
 	return cpu_physical_id(cpu);
-#else
+#else  /* CONFIG_SMP */
 	return cpu_physical_id(smp_processor_id());
 #endif
 }
@@ -867,7 +866,6 @@
 
 /*
  * ACPI calls this when it finds an entry for a platform interrupt.
- * Note that the irq_base and IOSAPIC address must be set in iosapic_init().
  */
 int __init
 iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
@@ -901,7 +899,7 @@
 		mask = 1;
 		break;
 	      default:
-		printk(KERN_ERR "iosapic_register_platform_irq(): invalid int type 0x%x\n", int_type);
+		printk(KERN_ERR "%s: invalid int type 0x%x\n", __FUNCTION__, int_type);
 		return -1;
 	}
 
@@ -917,10 +915,8 @@
 	return vector;
 }
 
-
 /*
  * ACPI calls this when it finds an entry for a legacy ISA IRQ override.
- * Note that the gsi_base and IOSAPIC address must be set in iosapic_init().
  */
 void __init
 iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
