From: Erich Focht <efocht@ess.nec.de>
Date: Mon, 07 Jan 2002 14:28:57 +0000
Subject: [Linux-ia64] PATCH redirectable IRQs
Message-Id: <marc-linux-ia64-105590698805756@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

could you please check whether anything speaks against including the
appended patch into the IA-64 kernel source? Thanks...


This small patch adds the possibility to change the default CPU to
which an IOSAPIC-IRQ is routed in lowest priority delivery mode.

Currently the iosapic_set_affinity() function allows the redirection
of IRQs by changing their routing from IOSAPIC_LOWEST_PRIORITY to
IOSAPIC_FIXED and selecting a target CPU. While on IA32 the target can
be a mask specifying multiple CPUs, on IA64 the target has to be one
particular CPU. There is no way to get back to IOSAPIC_LOWEST_PRIORITY
delivery mode or to specify another CPU than #0 for the default target
in lowest priority mode.

The patch extends the /proc/irq/NN/smp_affinity interface, for example:
     echo "r 6" >/proc/irq/41/smp_affinity
sets the default route for IRQ number 41 to CPU 6 in lowest priority
delivery mode.
     echo "3" >/proc/irq/41/smp_affinity
still leads to fixed delivery mode to CPU numer 3.

The benefits of beeing able to choose a target CPU in
IOSAPIC_LOWEST_PRIORITY delivery mode are:
- Administrators can switch back to the default IRQ delivery mode
without rebooting the machine.
- On large (multi-node) systems like the NEC AzusA we get IRQ
node-affinity for free. This is because usually the chipsets on each
node redirect the interrupts only to their own CPUs (as they cannot
see the XTP registers (used for the delivery hint) on the other
nodes). Pointing the IRQ to some CPU on the node to which the
corresponding device is connected and still keep the flexible lowest
priority routing is much better than leaving the default route to
CPU#0.


Best regards,

Erich


diff -ur 2.4.17/arch/ia64/kernel/iosapic.c 2.4.17-irqr/arch/ia64/kernel/iosapic.c
--- 2.4.17/arch/ia64/kernel/iosapic.c	Mon Jan  7 11:35:08 2002
+++ 2.4.17-irqr/arch/ia64/kernel/iosapic.c	Mon Jan  7 14:27:39 2002
@@ -204,7 +204,7 @@
 
 
 static void
-iosapic_set_affinity (unsigned int irq, unsigned long mask)
+iosapic_set_affinity (unsigned int irq, unsigned long mask, int redir)
 {
 #ifdef CONFIG_SMP
 	unsigned long flags;
@@ -234,9 +234,13 @@
 		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
 		low32 = readl(addr + IOSAPIC_WINDOW);
 
-		/* change delivery mode to fixed */
 		low32 &= ~(7 << IOSAPIC_DELIVERY_SHIFT);
-		low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
+		if (redir = 1)
+		        /* change delivery mode to lowest priority */
+			low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
+		else
+		        /* change delivery mode to fixed */
+			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
 		writel(IOSAPIC_RTE_HIGH(pin), addr + IOSAPIC_REG_SELECT);
 		writel(high32, addr + IOSAPIC_WINDOW);
diff -ur 2.4.17/arch/ia64/kernel/irq.c 2.4.17-irqr/arch/ia64/kernel/irq.c
--- 2.4.17/arch/ia64/kernel/irq.c	Mon Jan  7 11:35:08 2002
+++ 2.4.17-irqr/arch/ia64/kernel/irq.c	Mon Jan  7 12:45:17 2002
@@ -1090,13 +1090,15 @@
 static struct proc_dir_entry * smp_affinity_entry [NR_IRQS];
 
 static unsigned long irq_affinity [NR_IRQS] = { [0 ... NR_IRQS-1] = ~0UL };
+static char irq_redir [NR_IRQS] = { [0 ... NR_IRQS-1] = 1 };
 
 static int irq_affinity_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
 	if (count < HEX_DIGITS+1)
 		return -EINVAL;
-	return sprintf (page, "%08lx\n", irq_affinity[(long)data]);
+	return sprintf (page, "%s %08lx\n", irq_redir[(long)data] = 1 ? "r" : "f",
+			irq_affinity[(long)data]);
 }
 
 static int irq_affinity_write_proc (struct file *file, const char *buffer,
@@ -1104,11 +1106,20 @@
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
@@ -1119,7 +1130,8 @@
 		return -EINVAL;
 
 	irq_affinity[irq] = new_value;
-	irq_desc(irq)->handler->set_affinity(irq, new_value);
+	irq_redir[irq] = redir;
+	irq_desc(irq)->handler->set_affinity(irq, new_value, redir);
 
 	return full_count;
 }
diff -ur 2.4.17/include/linux/irq.h 2.4.17-irqr/include/linux/irq.h
--- 2.4.17/include/linux/irq.h	Mon Jan  7 11:35:11 2002
+++ 2.4.17-irqr/include/linux/irq.h	Mon Jan  7 12:45:17 2002
@@ -44,7 +44,7 @@
 	void (*disable)(unsigned int irq);
 	void (*ack)(unsigned int irq);
 	void (*end)(unsigned int irq);
-	void (*set_affinity)(unsigned int irq, unsigned long mask);
+	void (*set_affinity)(unsigned int irq, unsigned long mask, int redir);
 };
 
 typedef struct hw_interrupt_type  hw_irq_controller;


