From: John Keller <jpk@sgi.com>
Date: Tue, 08 May 2007 15:23:15 +0000
Subject: [PATCH Resend] - SN: validate smp_affinity mask on intr redirect
Message-Id: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, steiner@sgi.com, linux-ia64@vger.kernel.org, John Keller <jpk@sgi.com>

On SN, only allow one bit to be set in the smp_affinty mask
when redirecting an interrupt. Currently setting multiple
bits is allowed, but only the first bit is used in
determining the CPU to redirect to. This has caused confusion
among some customers.

Signed-off-by: John Keller <jpk@sgi.com>
---

Patch reworked as per Andrew's option "b".


 arch/ia64/kernel/irq.c |   11 +++++++++++
 include/asm-ia64/irq.h |    2 ++
 kernel/irq/proc.c      |    7 +++++++
 3 files changed, 20 insertions(+)


Index: linux-2.6/kernel/irq/proc.c
=================================--- linux-2.6.orig/kernel/irq/proc.c	2007-05-02 09:03:14.440820500 -0500
+++ linux-2.6/kernel/irq/proc.c	2007-05-03 16:00:46.746068614 -0500
@@ -27,6 +27,10 @@ static int irq_affinity_read_proc(char *
 	return len;
 }
 
+#ifndef is_affinity_mask_valid
+#define is_affinity_mask_valid() 1
+#endif
+
 int no_irq_affinity;
 static int irq_affinity_write_proc(struct file *file, const char __user *buffer,
 				   unsigned long count, void *data)
@@ -42,6 +46,9 @@ static int irq_affinity_write_proc(struc
 	if (err)
 		return err;
 
+	if (!is_affinity_mask_valid(new_value))
+		return -EINVAL;
+
 	/*
 	 * Do not allow disabling IRQs completely - it's a too easy
 	 * way to make the system unusable accidentally :-) At least
Index: linux-2.6/arch/ia64/kernel/irq.c
=================================--- linux-2.6.orig/arch/ia64/kernel/irq.c	2007-05-02 09:03:14.504828433 -0500
+++ linux-2.6/arch/ia64/kernel/irq.c	2007-05-03 16:15:47.604740039 -0500
@@ -104,6 +104,17 @@ void set_irq_affinity_info (unsigned int
 		irq_redir[irq] = (char) (redir & 0xff);
 	}
 }
+
+bool is_affinity_mask_valid(cpumask_t cpumask)
+{
+	if (ia64_platform_is("sn2")) {
+		/* Only allow one CPU to be specified in the smp_affinity mask */
+		if (cpus_weight(cpumask) != 1)
+			return false;
+	}
+	return true;
+}
+
 #endif /* CONFIG_SMP */
 
 #ifdef CONFIG_HOTPLUG_CPU
Index: linux-2.6/include/asm-ia64/irq.h
=================================--- linux-2.6.orig/include/asm-ia64/irq.h	2007-05-02 09:03:14.640845292 -0500
+++ linux-2.6/include/asm-ia64/irq.h	2007-05-03 16:02:31.934991908 -0500
@@ -30,4 +30,6 @@ extern void disable_irq_nosync (unsigned
 extern void enable_irq (unsigned int);
 extern void set_irq_affinity_info (unsigned int irq, int dest, int redir);
 
+#define is_affinity_mask_valid is_affinity_mask_valid
+
 #endif /* _ASM_IA64_IRQ_H */
