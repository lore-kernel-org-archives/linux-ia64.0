From: Erich Focht <focht@ess.nec.de>
Date: Tue, 08 Jan 2002 16:35:37 +0000
Subject: Re: [Linux-ia64] PATCH redirectable IRQs
Message-Id: <marc-linux-ia64-105590698805775@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Jan 2002, David Mosberger wrote:

> The patch looks good to me, except that it needs to be documented
> somewhere.  I suggest Documentation/ia64/irq-redir.txt or something
> along those lines.
> 
> Could you do this and also consider Andreas' comment and then resend
> the patch?

Ok, here's the next try.

The arrays irq_affinity and irq_redir are now set in both set_rte() and
iosapic_set_affinity(), i.e. the values are correctly initialized (wasn't
the case before).

An ugly little detail is that we keep using CPU masks when
reading/setting the IRQ target though they don't make sense on IA64. Would
be nicer to use just the plain logical CPU number.

Regards,
Erich


diff -urN 2.4.17/Documentation/ia64/IRQ-redir.txt 2.4.17-irqr/Documentation/ia64/IRQ-redir.txt
--- 2.4.17/Documentation/ia64/IRQ-redir.txt	Thu Jan  1 01:00:00 1970
+++ 2.4.17-irqr/Documentation/ia64/IRQ-redir.txt	Tue Jan  8 12:36:07 2002
@@ -0,0 +1,69 @@
+IRQ affinity on IA64 platforms
+------------------------------
+                           07.01.2002, Erich Focht <efocht@ess.nec.de>
+
+
+By writing to /proc/irq/IRQ#/smp_affinity the interrupt routing can be
+controlled. The behavior on IA64 platforms is slightly different from
+that described in Documentation/IRQ-affinity.txt for i386 systems.
+
+Because of the usage of SAPIC mode and physical destination mode the
+IRQ target is one particular CPU and cannot be a mask of several
+CPUs. Only the first non-zero bit is taken into account.
+
+
+Usage examples:
+
+The target CPU has to be specified as a hexadecimal CPU mask. The
+first non-zero bit is the selected CPU. This format has been kept for
+compatibility reasons with i386.
+
+Set the delivery mode of interrupt 41 to fixed and route the
+interrupts to CPU #3 (logical CPU number) (2^3=0x08):
+     echo "8" >/proc/irq/41/smp_affinity
+
+Set the default route for IRQ number 41 to CPU 6 in lowest priority
+delivery mode (redirectable):
+     echo "r 40" >/proc/irq/41/smp_affinity
+
+The output of the command
+     cat /proc/irq/IRQ#/smp_affinity
+gives the target CPU mask for the specified interrupt vector. If the CPU
+mask is preceeded by the character "r", the interrupt is redirectable
+(i.e. lowest priority mode routing is used), otherwise its route is
+fixed.
+
+
+
+Initialization and default behavior:
+
+If the platform features IRQ redirection (info provided by SAL) all
+IO-SAPIC interrupts are initialized with CPU#0 as their default target
+and the routing is the so called "lowest priority mode" (actually
+fixed SAPIC mode with hint). The XTP chipset registers are used as hints
+for the IRQ routing. Currently in Linux XTP registers can have three
+values:
+	- minimal for an idle task,
+	- normal if any other task runs,
+	- maximal if the CPU is going to be switched off.
+The IRQ is routed to the CPU with lowest XTP register value, the
+search begins at the default CPU. Therefore most of the interrupts
+will be handled by CPU #0.
+
+If the platform doesn't feature interrupt redirection IOSAPIC fixed
+routing is used. The target CPUs are distributed in a round robin
+manner. IRQs will be routed only to the selected target CPUs. Check
+with
+        cat /proc/interrupts
+
+
+
+Comments:
+
+On large (multi-node) systems it is recommended to route the IRQs to
+the node to which the corresponding device is connected.
+For systems like the NEC AzusA we get IRQ node-affinity for free. This
+is because usually the chipsets on each node redirect the interrupts
+only to their own CPUs (as they cannot see the XTP registers on the
+other nodes).
+
diff -urN 2.4.17/arch/ia64/kernel/iosapic.c 2.4.17-irqr/arch/ia64/kernel/iosapic.c
--- 2.4.17/arch/ia64/kernel/iosapic.c	Mon Jan  7 11:35:08 2002
+++ 2.4.17-irqr/arch/ia64/kernel/iosapic.c	Tue Jan  8 14:18:26 2002
@@ -15,6 +15,9 @@
  *				PCI to vector mapping, shared PCI interrupts.
  * 00/10/27	D. Mosberger	Document things a bit more to make them more understandable.
  *				Clean up much of the old IOSAPIC cruft.
+ * 02/01/07     E. Focht        <efocht@ess.nec.de> Redirectable interrupt vectors in
+ *                              iosapic_set_affinity(), initializations for
+ *                              /proc/irq/#/smp_affinity
  */
 /*
  * Here is what the interrupt logic between a PCI device and the CPU looks like:
@@ -121,6 +124,8 @@
 	u32 low32, high32;
 	char *addr;
 	int pin;
+	char redir;
+	extern void set_irq_affinity_info(int irq, int dest, char redir);
 
 	pin = iosapic_irq[vector].pin;
 	if (pin < 0)
@@ -131,6 +136,9 @@
 	trigger = iosapic_irq[vector].trigger;
 	dmode   = iosapic_irq[vector].dmode;
 
+	redir = (dmode = IOSAPIC_LOWEST_PRIORITY) ? 1 : 0;
+	set_irq_affinity_info(vector, (int)(dest & 0xffff), redir);
+
 	low32 = ((pol << IOSAPIC_POLARITY_SHIFT) |
 		 (trigger << IOSAPIC_TRIGGER_SHIFT) |
 		 (dmode << IOSAPIC_DELIVERY_SHIFT) |
@@ -204,13 +212,14 @@
 
 
 static void
-iosapic_set_affinity (unsigned int irq, unsigned long mask)
+iosapic_set_affinity (unsigned int irq, unsigned long mask, int redir)
 {
 #ifdef CONFIG_SMP
 	unsigned long flags;
 	u32 high32, low32;
 	int dest, pin;
 	char *addr;
+	extern void set_irq_affinity_info(int irq, int dest, char redir);
 
 	mask &= (1UL << smp_num_cpus) - 1;
 
@@ -225,6 +234,8 @@
 	if (pin < 0)
 		return;			/* not an IOSAPIC interrupt */
 
+	set_irq_affinity_info(irq,dest,(char)redir);
+
 	/* dest contains both id and eid */
 	high32 = dest << IOSAPIC_DEST_SHIFT;
 
@@ -234,9 +245,13 @@
 		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
 		low32 = readl(addr + IOSAPIC_WINDOW);
 
-		/* change delivery mode to fixed */
 		low32 &= ~(7 << IOSAPIC_DELIVERY_SHIFT);
-		low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
+		if (redir)
+		        /* change delivery mode to lowest priority */
+			low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
+		else
+		        /* change delivery mode to fixed */
+			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
 		writel(IOSAPIC_RTE_HIGH(pin), addr + IOSAPIC_REG_SELECT);
 		writel(high32, addr + IOSAPIC_WINDOW);
diff -urN 2.4.17/arch/ia64/kernel/irq.c 2.4.17-irqr/arch/ia64/kernel/irq.c
--- 2.4.17/arch/ia64/kernel/irq.c	Mon Jan  7 11:35:08 2002
+++ 2.4.17-irqr/arch/ia64/kernel/irq.c	Tue Jan  8 13:10:45 2002
@@ -1090,13 +1090,25 @@
 static struct proc_dir_entry * smp_affinity_entry [NR_IRQS];
 
 static unsigned long irq_affinity [NR_IRQS] = { [0 ... NR_IRQS-1] = ~0UL };
+static char irq_redir [NR_IRQS]; // = { [0 ... NR_IRQS-1] = 1 };
+
+void set_irq_affinity_info(int irq, int hwid, char redir)
+{
+	unsigned long mask = 1UL<<cpu_logical_id(hwid);
+
+	if (irq >= 0 && irq < NR_IRQS) {
+		irq_affinity[irq] = mask;
+		irq_redir[irq] = redir;
+	}
+}
 
 static int irq_affinity_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
-	if (count < HEX_DIGITS+1)
+	if (count < HEX_DIGITS+3)
 		return -EINVAL;
-	return sprintf (page, "%08lx\n", irq_affinity[(long)data]);
+	return sprintf (page, "%s%08lx\n", irq_redir[(long)data] ? "r " : "",
+			irq_affinity[(long)data]);
 }
 
 static int irq_affinity_write_proc (struct file *file, const char *buffer,
@@ -1104,11 +1116,20 @@
 {
 	int irq = (long) data, full_count = count, err;
 	unsigned long new_value;
+	char *buf = buffer;
+	int redir;
 
 	if (!irq_desc(irq)->handler->set_affinity)
 		return -EIO;
 
-	err = parse_hex_value(buffer, count, &new_value);
+	if (buf[0] = 'r' || buf[0] = 'R') {
+		++buf;
+		while (*buf = ' ') ++buf;
+		redir = 1;
+	} else
+		redir = 0;
+
+	err = parse_hex_value(buf, count, &new_value);
 
 	/*
 	 * Do not allow disabling IRQs completely - it's a too easy
@@ -1118,8 +1139,7 @@
 	if (!(new_value & cpu_online_map))
 		return -EINVAL;
 
-	irq_affinity[irq] = new_value;
-	irq_desc(irq)->handler->set_affinity(irq, new_value);
+	irq_desc(irq)->handler->set_affinity(irq, new_value, redir);
 
 	return full_count;
 }
diff -urN 2.4.17/include/linux/irq.h 2.4.17-irqr/include/linux/irq.h
--- 2.4.17/include/linux/irq.h	Mon Jan  7 11:35:11 2002
+++ 2.4.17-irqr/include/linux/irq.h	Tue Jan  8 11:08:43 2002
@@ -44,7 +44,7 @@
 	void (*disable)(unsigned int irq);
 	void (*ack)(unsigned int irq);
 	void (*end)(unsigned int irq);
-	void (*set_affinity)(unsigned int irq, unsigned long mask);
+	void (*set_affinity)(unsigned int irq, unsigned long mask, int redir);
 };
 
 typedef struct hw_interrupt_type  hw_irq_controller;


