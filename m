From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 28 Jan 2005 21:10:11 +0000
Subject: [PATCH] fix IOSAPIC destinations when CONFIG_SMP=n
Message-Id: <1106946611.9150.34.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Always use cpu_physical_id() (which is really the ID/EID of
a processor's Local SAPIC) when programming IOSAPIC entries.

Previously we sometimes used hard_smp_processor_id(), which
is correct when CONFIG_SMP=y but wrong otherwise.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/kernel/iosapic.c 1.51 vs edited ==--- 1.51/arch/ia64/kernel/iosapic.c	2005-01-20 22:02:13 -07:00
+++ edited/arch/ia64/kernel/iosapic.c	2005-01-28 13:16:05 -07:00
@@ -91,7 +91,6 @@
 
 
 #undef DEBUG_INTERRUPT_ROUTING
-#undef OVERRIDE_DEBUG
 
 #ifdef DEBUG_INTERRUPT_ROUTING
 #define DBG(fmt...)	printk(fmt)
@@ -499,14 +498,14 @@
 	 * distribute interrupts.
 	 */
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
-		return hard_smp_processor_id();
+		return cpu_physical_id(smp_processor_id());
 
 	/*
 	 * Some interrupts (ACPI SCI, for instance) are registered
 	 * before the BSP is marked as online.
 	 */
 	if (!cpu_online(smp_processor_id()))
-		return hard_smp_processor_id();
+		return cpu_physical_id(smp_processor_id());
 
 #ifdef CONFIG_NUMA
 	{
@@ -553,7 +552,7 @@
 
 	return cpu_physical_id(cpu);
 #else
-	return hard_smp_processor_id();
+	return cpu_physical_id(smp_processor_id());
 #endif
 }
 
@@ -740,7 +739,7 @@
 			  unsigned long trigger)
 {
 	int vector;
-	unsigned int dest = hard_smp_processor_id();
+	unsigned int dest = cpu_physical_id(smp_processor_id());
 
 	vector = isa_irq_to_vector(isa_irq);
 
=== include/asm-ia64/smp.h 1.19 vs edited ==--- 1.19/include/asm-ia64/smp.h	2004-10-05 12:30:39 -06:00
+++ edited/include/asm-ia64/smp.h	2005-01-28 13:16:06 -07:00
@@ -3,16 +3,14 @@
  *
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 2001-2003 Hewlett-Packard Co
+ * (c) Copyright 2001-2003, 2005 Hewlett-Packard Development Company, L.P.
  *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  */
 #ifndef _ASM_IA64_SMP_H
 #define _ASM_IA64_SMP_H
 
 #include <linux/config.h>
-
-#ifdef CONFIG_SMP
-
 #include <linux/init.h>
 #include <linux/threads.h>
 #include <linux/kernel.h>
@@ -24,6 +22,25 @@
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 
+static inline unsigned int
+ia64_get_lid (void)
+{
+	union {
+		struct {
+			unsigned long reserved : 16;
+			unsigned long eid : 8;
+			unsigned long id : 8;
+			unsigned long ignored : 32;
+		} f;
+		unsigned long bits;
+	} lid;
+
+	lid.bits = ia64_getreg(_IA64_REG_CR_LID);
+	return lid.f.id << 8 | lid.f.eid;
+}
+
+#ifdef CONFIG_SMP
+
 #define XTP_OFFSET		0x1e0008
 
 #define SMP_IRQ_REDIRECTION	(1 << 0)
@@ -90,22 +107,7 @@
 		writeb(0x0f, ipi_base_addr + XTP_OFFSET); /* Set XTP to max */
 }
 
-static inline unsigned int
-hard_smp_processor_id (void)
-{
-	union {
-		struct {
-			unsigned long reserved : 16;
-			unsigned long eid : 8;
-			unsigned long id : 8;
-			unsigned long ignored : 32;
-		} f;
-		unsigned long bits;
-	} lid;
-
-	lid.bits = ia64_getreg(_IA64_REG_CR_LID);
-	return lid.f.id << 8 | lid.f.eid;
-}
+#define hard_smp_processor_id()		ia64_get_lid()
 
 /* Upping and downing of CPUs */
 extern int __cpu_disable (void);
@@ -125,7 +127,8 @@
 
 #else
 
-#define cpu_logical_id(cpuid)		0
+#define cpu_logical_id(i)		0
+#define cpu_physical_id(i)		ia64_get_lid()
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */


