From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 20 Apr 2000 06:44:28 +0000
Subject: [Linux-ia64] new kernel diff
Message-Id: <marc-linux-ia64-105590678205022@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

OK, here is a new kernel updated.  This one finally has the IDE irq
problem solved.  In the end, the real problem turned out to be due to
edge-triggered interrupts and had nothing to do with IDE in
particular.  Anyhow, since this is fixed now, all the ugly debug
printk are gone again.

This kernel has been booted on a Big Sur and should work fine on SMP
as well (with the caveats that Walt mentioned ealier on).  In fact, I
used our SMP box to build kernels for the last couple of days and
while there are some odd things going on, the system is surprisingl
stable (no kernel crashes so far).

What's new with this patch:

 - Walt's SMP fixes.

 - Kevin's sigsuspend fix that makes ptrace() work better (at
   least for UP)

 - Kevin's ptrace siginfo additions.  This is needed to make hardware
   watchpoints work with gdb.

 - Chuck's MCA INIT handler patch; as far as I can tell, INIT
   on Lion works now.  This is really cool as it will help
   with post-mortem debugging of the kernel.  Unfortunately
   Big Sur has no INIT switch...

 - Asit's ivt serialization cleanups.

 - the kernel now always gets PCI IRQ routing from the firmware/ACPI

 - updated iosapic code to properly handle edge-level triggered
   interrupts; I also added IPI support to the UP kernel since
   that's the cleanest way to implement the irq resending that is
   sometimes required for edge-triggered irqs

 - added DVloc hints in hand-coded assembly to avoid spurious
   DV warnings

 - change Errata 10 workaround into an Itanium-permanent fix as there
   there are no plans to have this fixed for Itanium (not a big issue
   as it's not performance critical and has an easy workaround).

 - Fix alternate tlb handlers to do the right thing for speculative
   accesses to the kernel regions.  This is fixed for real now.

Caveat: this hasn't been tested on SoftSDV and it's likely that the
iosapic code would need to be updated a bit to make SoftSDV work
again, but I can't test that easily so I didn't do this.  A patch
would be welcome though.

This should be the last diff relative to 2.3.51 as with the irq
problem out of the way, I want to sync up with Linus's latest kernel
asap.

	--david

diff -urN linux-davidm/arch/ia64/Makefile linux-2.3.51-lia/arch/ia64/Makefi=
le
--- linux-davidm/arch/ia64/Makefile	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/Makefile	Mon Apr 17 17:26:46 2000
@@ -9,6 +9,7 @@
 #
=20
 NM :=3D $(CROSS_COMPILE)nm -B
+AWK :=3D awk
=20
 LINKFLAGS =3D -static -T arch/$(ARCH)/vmlinux.lds
 # next line is for HP compiler backend:
diff -urN linux-davidm/arch/ia64/config.in linux-2.3.51-lia/arch/ia64/confi=
g.in
--- linux-davidm/arch/ia64/config.in	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/config.in	Wed Apr 19 09:32:33 2000
@@ -4,6 +4,7 @@
 comment 'General setup'
=20
 define_bool CONFIG_IA64 y
+define_bool CONFIG_ITANIUM y	# easy choice for now... ;-)
=20
 choice 'IA-64 system type'					\
 	"Generic		CONFIG_IA64_GENERIC		\
@@ -23,7 +24,6 @@
 	bool '  Enable BigSur hacks' CONFIG_IA64_BIGSUR_HACKS y
 	bool '  Enable Lion hacks' CONFIG_IA64_LION_HACKS n
 	bool '  Emulate PAL/SAL/EFI firmware' CONFIG_IA64_FW_EMU n
-	bool '  Get PCI IRQ routing from firmware/ACPI'	CONFIG_IA64_IRQ_ACPI y
 	bool '  Enable IA64 Machine Check Abort' CONFIG_IA64_MCA n
 fi
=20
diff -urN linux-davidm/arch/ia64/dig/iosapic.c linux-2.3.51-lia/arch/ia64/d=
ig/iosapic.c
--- linux-davidm/arch/ia64/dig/iosapic.c	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/dig/iosapic.c	Wed Apr 19 16:00:16 2000
@@ -7,6 +7,10 @@
  * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
+ *
+ * 00/04/19	D. Mosberger	Rewritten to mirror more closely the x86 I/O APIC=
 code.
+ *				In particular, we now have separate handlers for edge
+ *				and level triggered interrupts.
  */
 #include <linux/config.h>
=20
@@ -27,172 +31,19 @@
=20
 #undef DEBUG_IRQ_ROUTING
=20
-/*
- * IRQ vectors 0..15 are treated as the legacy interrupts of the PC-AT
- * platform.  No new drivers should ever ask for specific irqs, but we
- * provide compatibility here in case there is an old driver that does
- * ask for specific irqs (serial, keyboard, stuff like that).  Since
- * IA-64 doesn't allow irq 0..15 to be used for external interrupts
- * anyhow, this in no way prevents us from doing the Right Thing
- * with new drivers.
- */
+static spinlock_t iosapic_lock =3D SPIN_LOCK_UNLOCKED;
+
 struct iosapic_vector iosapic_vector[NR_IRQS] =3D {
 	[0 ... NR_IRQS-1] =3D { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 }
 };
=20
-#ifndef CONFIG_IA64_IRQ_ACPI
-/*
- * Defines the default interrupt routing information for the LION platform
- * XXX - this information should be obtained from the ACPI and hardcoded s=
ince
- * we do not have ACPI AML support.
- */
-
-struct intr_routing_entry intr_routing[] =3D {
-      {0,0,0,2,0,0,0,0},
-      {0,0,1,1,0,0,0,0},
-      {0,0,2,0xff,0,0,0,0},
-      {0,0,3,3,0,0,0,0},
-      {0,0,4,4,0,0,0,0},
-      {0,0,5,5,0,0,0,0},
-      {0,0,6,6,0,0,0,0},
-      {0,0,7,7,0,0,0,0},
-      {0,0,8,8,0,0,0,0},
-      {0,0,9,9,0,0,0,0},
-      {0,0,10,10,0,0,0,0},
-      {0,0,11,11,0,0,0,0},
-      {0,0,12,12,0,0,0,0},
-      {0,0,13,13,0,0,0,0},
-      {0,0,14,14,0,0,0,0},
-      {0,0,15,15,0,0,0,0},
-#ifdef CONFIG_IA64_LION_HACKS
-      {1, 0, 0x04, 16, 0, 0, 1, 1},	/* bus 0, device id 1, INTA */
-      {1, 0, 0x05, 26, 0, 0, 1, 1},	/* bus 0, device id 1, INTB */
-      {1, 0, 0x06, 36, 0, 0, 1, 1},	/* bus 0, device id 1, INTC */
-      {1, 0, 0x07, 42, 0, 0, 1, 1},	/* bus 0, device id 1, INTD */
-
-      {1, 0, 0x08, 17, 0, 0, 1, 1},	/* bus 0, device id 2, INTA */
-      {1, 0, 0x09, 27, 0, 0, 1, 1},	/* bus 0, device id 2, INTB */
-      {1, 0, 0x0a, 37, 0, 0, 1, 1},	/* bus 0, device id 2, INTC */
-      {1, 0, 0x0b, 42, 0, 0, 1, 1},	/* bus 0, device id 2, INTD */
-
-      {1, 0, 0x0f, 50, 0, 0, 1, 1},	/* bus 0, device id 3, INTD */
-
-      {1, 0, 0x14, 51, 0, 0, 1, 1},	/* bus 0, device id 5, INTA */
-
-      {1, 0, 0x18, 49, 0, 0, 1, 1},	/* bus 0, device id 6, INTA */
-
-      {1, 1, 0x04, 18, 0, 0, 1, 1},	/* bus 1, device id 1, INTA */
-      {1, 1, 0x05, 28, 0, 0, 1, 1},	/* bus 1, device id 1, INTB */
-      {1, 1, 0x06, 38, 0, 0, 1, 1},	/* bus 1, device id 1, INTC */
-      {1, 1, 0x07, 43, 0, 0, 1, 1},	/* bus 1, device id 1, INTD */
-
-      {1, 1, 0x08, 48, 0, 0, 1, 1},	/* bus 1, device id 2, INTA */
-
-      {1, 1, 0x0c, 19, 0, 0, 1, 1},	/* bus 1, device id 3, INTA */
-      {1, 1, 0x0d, 29, 0, 0, 1, 1},	/* bus 1, device id 3, INTB */
-      {1, 1, 0x0e, 38, 0, 0, 1, 1},	/* bus 1, device id 3, INTC */
-      {1, 1, 0x0f, 44, 0, 0, 1, 1},	/* bus 1, device id 3, INTD */
-
-      {1, 1, 0x10, 20, 0, 0, 1, 1},	/* bus 1, device id 4, INTA */
-      {1, 1, 0x11, 30, 0, 0, 1, 1},	/* bus 1, device id 4, INTB */
-      {1, 1, 0x12, 39, 0, 0, 1, 1},	/* bus 1, device id 4, INTC */
-      {1, 1, 0x13, 45, 0, 0, 1, 1},	/* bus 1, device id 4, INTD */
-
-      {1, 2, 0x04, 21, 0, 0, 1, 1},	/* bus 2, device id 1, INTA */
-      {1, 2, 0x05, 31, 0, 0, 1, 1},	/* bus 2, device id 1, INTB */
-      {1, 2, 0x06, 39, 0, 0, 1, 1},	/* bus 2, device id 1, INTC */
-      {1, 2, 0x07, 45, 0, 0, 1, 1},	/* bus 2, device id 1, INTD */
-
-      {1, 2, 0x08, 22, 0, 0, 1, 1},	/* bus 2, device id 2, INTA */
-      {1, 2, 0x09, 32, 0, 0, 1, 1},	/* bus 2, device id 2, INTB */
-      {1, 2, 0x0a, 40, 0, 0, 1, 1},	/* bus 2, device id 2, INTC */
-      {1, 2, 0x0b, 46, 0, 0, 1, 1},	/* bus 2, device id 2, INTD */
-
-      {1, 2, 0x0c, 23, 0, 0, 1, 1},	/* bus 2, device id 3, INTA */
-      {1, 2, 0x0d, 33, 0, 0, 1, 1},	/* bus 2, device id 3, INTB */
-      {1, 2, 0x0e, 40, 0, 0, 1, 1},	/* bus 2, device id 3, INTC */
-      {1, 2, 0x0f, 46, 0, 0, 1, 1},	/* bus 2, device id 3, INTD */
-
-      {1, 3, 0x04, 24, 0, 0, 1, 1},	/* bus 3, device id 1, INTA */
-      {1, 3, 0x05, 34, 0, 0, 1, 1},	/* bus 3, device id 1, INTB */
-      {1, 3, 0x06, 41, 0, 0, 1, 1},	/* bus 3, device id 1, INTC */
-      {1, 3, 0x07, 47, 0, 0, 1, 1},	/* bus 3, device id 1, INTD */
-
-      {1, 3, 0x08, 25, 0, 0, 1, 1},	/* bus 3, device id 2, INTA */
-      {1, 3, 0x09, 35, 0, 0, 1, 1},	/* bus 3, device id 2, INTB */
-      {1, 3, 0x0a, 41, 0, 0, 1, 1},	/* bus 3, device id 2, INTC */
-      {1, 3, 0x0b, 47, 0, 0, 1, 1},	/* bus 3, device id 2, INTD */
-#else
-      /*
-       * BigSur platform, bus 0, device 1,2,4 and bus 1 device 0-3
-       */
-      {1,1,0x0,19,0,0,1,1},		/* bus 1, device id 0, INTA */
-      {1,1,0x1,18,0,0,1,1},		/* bus 1, device id 0, INTB */
-      {1,1,0x2,17,0,0,1,1},		/* bus 1, device id 0, INTC */
-      {1,1,0x3,16,0,0,1,1},		/* bus 1, device id 0, INTD */
-
-      {1,1,0x4,23,0,0,1,1},		/* bus 1, device id 1, INTA */
-      {1,1,0x5,22,0,0,1,1},		/* bus 1, device id 1, INTB */
-      {1,1,0x6,21,0,0,1,1},		/* bus 1, device id 1, INTC */
-      {1,1,0x7,20,0,0,1,1},		/* bus 1, device id 1, INTD */
-
-      {1,1,0x8,27,0,0,1,1},		/* bus 1, device id 2, INTA */
-      {1,1,0x9,26,0,0,1,1},		/* bus 1, device id 2, INTB */
-      {1,1,0xa,25,0,0,1,1},		/* bus 1, device id 2, INTC */
-      {1,1,0xb,24,0,0,1,1},		/* bus 1, device id 2, INTD */
-
-      {1,1,0xc,31,0,0,1,1},		/* bus 1, device id 3, INTA */
-      {1,1,0xd,30,0,0,1,1},		/* bus 1, device id 3, INTB */
-      {1,1,0xe,29,0,0,1,1},		/* bus 1, device id 3, INTC */
-      {1,1,0xf,28,0,0,1,1},		/* bus 1, device id 3, INTD */
-
-      {1,0,0x4,35,0,0,1,1},		/* bus 0, device id 1, INTA */
-      {1,0,0x5,34,0,0,1,1},		/* bus 0, device id 1, INTB */
-      {1,0,0x6,33,0,0,1,1},		/* bus 0, device id 1, INTC */
-      {1,0,0x7,32,0,0,1,1},		/* bus 0, device id 1, INTD */
-
-      {1,0,0x8,39,0,0,1,1},		/* bus 0, device id 2, INTA */
-      {1,0,0x9,38,0,0,1,1},		/* bus 0, device id 2, INTB */
-      {1,0,0xa,37,0,0,1,1},		/* bus 0, device id 2, INTC */
-      {1,0,0xb,36,0,0,1,1},		/* bus 0, device id 2, INTD */
-
-      {1,0,0x10,43,0,0,1,1},		/* bus 0, device id 4, INTA */
-      {1,0,0x11,42,0,0,1,1},		/* bus 0, device id 4, INTB */
-      {1,0,0x12,41,0,0,1,1},		/* bus 0, device id 4, INTC */
-      {1,0,0x13,40,0,0,1,1},		/* bus 0, device id 4, INTD */
-
-      {1,0,0x14,17,0,0,1,1},		/* bus 0, device id 5, INTA */
-      {1,0,0x18,18,0,0,1,1},		/* bus 0, device id 6, INTA */
-      {1,0,0x1c,19,0,0,1,1},		/* bus 0, device id 7, INTA */
-#endif
-      {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff},
-};
-
-int
-iosapic_get_PCI_irq_vector(int bus, int slot, int pci_pin)
-{
-	int     i =3D -1;
-
-	while (intr_routing[++i].srcbus !=3D 0xff) {
-		if (intr_routing[i].srcbus =3D BUS_PCI) {
-			if ((intr_routing[i].srcbusirq =3D ((slot << 2) | pci_pin))=20
-			    && (intr_routing[i].srcbusno =3D bus)) {
-				return(intr_routing[i].iosapic_pin);
-			}
-		}
-	}
-	return -1;
-}
-
-#else /* CONFIG_IA64_IRQ_ACPI */
-
 /*
  * find the IRQ in the IOSAPIC map for the PCI device on bus/slot/pin
  */
 int
-iosapic_get_PCI_irq_vector(int bus, int slot, int pci_pin)
+iosapic_get_PCI_irq_vector (int bus, int slot, int pci_pin)
 {
-	int	i;
+	int i;
=20
 	for (i =3D 0; i < NR_IRQS; i++) {
 		if ((iosapic_bustype(i) =3D BUS_PCI) &&
@@ -201,10 +52,8 @@
 			return i;
 		}
 	}
-
 	return -1;
 }
-#endif /* !CONFIG_IA64_IRQ_ACPI */
=20
 static void
 set_rte (unsigned long iosapic_addr, int entry, int pol, int trigger, int =
delivery,
@@ -213,9 +62,6 @@
 	u32 low32;
 	u32 high32;
=20
-if (entry =3D 15) printk("set_rte(addr=3D%lx,entry=3D%d,pol=3D%d,trigger=
=3D%d,delivery=3D%d,dest=3D%lx,vector=3D%d)\n",
-			iosapic_addr, entry, pol, trigger, delivery, dest, vector);
-
 	low32 =3D ((pol << IO_SAPIC_POLARITY_SHIFT) |
 		 (trigger << IO_SAPIC_TRIGGER_SHIFT) |
 		 (delivery << IO_SAPIC_DELIVERY_SHIFT) |
@@ -224,83 +70,137 @@
 	/* dest contains both id and eid */
 	high32 =3D (dest << IO_SAPIC_DEST_SHIFT);=09
=20
-	/*
-	 * program the rte=20
-	 */
 	writel(IO_SAPIC_RTE_HIGH(entry), iosapic_addr + IO_SAPIC_REG_SELECT);
 	writel(high32, iosapic_addr + IO_SAPIC_WINDOW);
 	writel(IO_SAPIC_RTE_LOW(entry), iosapic_addr + IO_SAPIC_REG_SELECT);
 	writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
 }
=20
+static void
+nop (unsigned int irq)
+{
+	/* do nothing... */
+}
=20
 static void=20
-enable_pin (unsigned int pin, unsigned long iosapic_addr)
+mask_irq (unsigned int irq)
 {
-        u32 low32;
+	unsigned long flags, iosapic_addr =3D iosapic_addr(irq);
+	u32 low32;
=20
-        writel(IO_SAPIC_RTE_LOW(pin), iosapic_addr + IO_SAPIC_REG_SELECT);
-        low32 =3D readl(iosapic_addr + IO_SAPIC_WINDOW);
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		writel(IO_SAPIC_RTE_LOW(iosapic_pin(irq)), iosapic_addr + IO_SAPIC_REG_S=
ELECT);
+		low32 =3D readl(iosapic_addr + IO_SAPIC_WINDOW);
=20
-        low32 &=3D ~(1 << IO_SAPIC_MASK_SHIFT);    /* Zero only the mask b=
it */
-        writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
+		low32 |=3D (1 << IO_SAPIC_MASK_SHIFT);    /* Zero only the mask bit */
+		writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
=20
-
 static void=20
-disable_pin (unsigned int pin, unsigned long iosapic_addr)
+unmask_irq (unsigned int irq)
 {
-        u32 low32;
+	unsigned long flags, iosapic_addr =3D iosapic_addr(irq);
+	u32 low32;
=20
-        writel(IO_SAPIC_RTE_LOW(pin), iosapic_addr + IO_SAPIC_REG_SELECT);
-        low32 =3D readl(iosapic_addr + IO_SAPIC_WINDOW);
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		writel(IO_SAPIC_RTE_LOW(iosapic_pin(irq)), iosapic_addr + IO_SAPIC_REG_S=
ELECT);
+		low32 =3D readl(iosapic_addr + IO_SAPIC_WINDOW);
=20
-        low32 |=3D (1 << IO_SAPIC_MASK_SHIFT);     /* Set only the mask bi=
t */
-        writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
+		low32 &=3D ~(1 << IO_SAPIC_MASK_SHIFT);    /* Zero only the mask bit */
+		writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
=20
-static unsigned int
-iosapic_startup_irq (unsigned int irq)
+
+static void
+iosapic_set_affinity (unsigned int irq, unsigned long mask)
 {
-	int pin =3D iosapic_pin(irq);
+	printk("iosapic_set_affinity: not implemented yet\n");
+}
=20
-if (irq =3D 65) printk("iosapic_startup_irq(irqe,status=3D0x%x,pin=3D%d)\n=
",
-		      irq_desc[irq].status, pin);
-	if (pin < 0)
-		/* happens during irq auto probing... */
-		return 0;
-	set_rte(iosapic_addr(irq), pin, iosapic_polarity(irq), iosapic_trigger(ir=
q),=20
-		iosapic_dmode(irq), (ia64_get_lid() >> 16) & 0xffff, irq);
-	enable_pin(pin, iosapic_addr(irq));
+/*
+ * Handlers for level-triggered interrupts.
+ */
+
+static unsigned int
+iosapic_startup_level_irq (unsigned int irq)
+{
+	unmask_irq(irq);
 	return 0;
 }
=20
 static void
-iosapic_enable_irq (unsigned int irq)
+iosapic_end_level_irq (unsigned int irq)
 {
-	int pin =3D iosapic_pin(irq);
+	writel(irq, iosapic_addr(irq) + IO_SAPIC_EOI);
+}
=20
-if (irq =3D 65) printk("iosapic_enable_irq(irqe,status=3D0x%x,pin=3D%d)\n",
-		      irq_desc[irq].status, pin);
-	if (pin < 0)
-		/* happens during irq auto probing... */
-		return;
-	enable_pin(pin, iosapic_addr(irq));
+#define iosapic_shutdown_level_irq	mask_irq
+#define iosapic_enable_level_irq	unmask_irq
+#define iosapic_disable_level_irq	mask_irq
+#define iosapic_ack_level_irq		nop
+
+struct hw_interrupt_type irq_type_iosapic_level =3D {
+	typename:	"IO-SAPIC-level",
+	startup:	iosapic_startup_level_irq,
+	shutdown:	iosapic_shutdown_level_irq,
+	enable:		iosapic_enable_level_irq,
+	disable:	iosapic_disable_level_irq,
+	ack:		iosapic_ack_level_irq,
+	end:		iosapic_end_level_irq,
+	set_affinity:	iosapic_set_affinity
+};
+
+/*
+ * Handlers for edge-triggered interrupts.
+ */
+
+static unsigned int
+iosapic_startup_edge_irq (unsigned int irq)
+{
+	unmask_irq(irq);
+	/*
+	 * IOSAPIC simply drops interrupts pended while the
+	 * corresponding pin was masked, so we can't know if an
+	 * interrupt is pending already.  Let's hope not...
+	 */
+	return 0;
 }
=20
 static void
-iosapic_disable_irq (unsigned int irq)
+iosapic_ack_edge_irq (unsigned int irq)
 {
-	int pin =3D iosapic_pin(irq);
-
-if (irq =3D 65) printk("iosapic_disable_irq(irqe, status=3D0x%x)\n", irq_d=
esc[irq].status);
-	if (pin < 0)
-		return;
-	disable_pin(pin, iosapic_addr(irq));
+	/*
+	 * Once we have recorded IRQ_PENDING already, we can mask the
+	 * interrupt for real. This prevents IRQ storms from unhandled
+	 * devices.
+	 */
+	if ((irq_desc[irq].status & (IRQ_PENDING | IRQ_DISABLED)) =3D (IRQ_PENDIN=
G | IRQ_DISABLED))
+		mask_irq(irq);
 }
=20
+#define iosapic_enable_edge_irq		unmask_irq
+#define iosapic_disable_edge_irq	nop
+#define iosapic_end_edge_irq		nop
+
+struct hw_interrupt_type irq_type_iosapic_edge =3D {
+	typename:	"IO-SAPIC-edge",
+	startup:	iosapic_startup_edge_irq,
+	shutdown:	iosapic_disable_edge_irq,
+	enable:		iosapic_enable_edge_irq,
+	disable:	iosapic_disable_edge_irq,
+	ack:		iosapic_ack_edge_irq,
+	end:		iosapic_end_edge_irq,
+	set_affinity:	iosapic_set_affinity
+};
+
 unsigned int
-iosapic_version(unsigned long base_addr)=20
+iosapic_version (unsigned long base_addr)=20
 {
 	/*
 	 * IOSAPIC Version Register return 32 bit structure like:
@@ -315,97 +215,17 @@
 	return readl(IO_SAPIC_WINDOW + base_addr);
 }
=20
-static void
-iosapic_ack_irq (unsigned int irq)
-{
-}
-
-static void
-iosapic_end_irq (unsigned int irq)
-{
-	if (iosapic_trigger(irq) =3D IO_SAPIC_LEVEL)	/* ACK Level trigger interru=
pts */
-		writel(irq, iosapic_addr(irq) + IO_SAPIC_EOI);
-}
-
-static void
-iosapic_set_affinity (unsigned int irq, unsigned long mask)
-{
-	printk("iosapic_set_affinity: not implemented yet\n");
-}
-
 void
 iosapic_init (unsigned long address)
 {
-	int i;
-#ifdef CONFIG_IA64_IRQ_ACPI
+	struct hw_interrupt_type *irq_type;
 	struct pci_vector_struct *vectors;
-	int irq;
-#else=20
-	int vector;
-#endif
-
-	/*
-	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT s=
upport
-	 * enabled.
-	 */
-	outb(0xff, 0xA1);
-	outb(0xff, 0x21);
+	int i, irq;
=20
-#if defined(CONFIG_IA64_SOFTSDV_HACKS)
-	memset(iosapic_vector, 0x0, sizeof(iosapic_vector));
-	for (i =3D 0; i < NR_IRQS; i++) {
-		iosapic_pin(i) =3D 0xff;
-		iosapic_addr(i) =3D (unsigned long) ioremap(address, 0);
-	}
-	/* XXX this should come from systab or some such: */
-# if 0
-	/* this doesn't look right --davidm 00/03/07 */
-	iosapic_pin(TIMER_IRQ) =3D 5;	/* System Clock Interrupt */
-# endif
-	iosapic_pin(0x40) =3D 3;	/* Keyboard */
-	iosapic_pin(0x92) =3D 9;	/* COM1 Serial Port */
-	iosapic_pin(0x80) =3D 4;	/* Periodic Interrupt */
-	iosapic_pin(0xc0) =3D 2;	/* Mouse */
-	iosapic_pin(0xe0) =3D 1;	/* IDE Disk */
-	iosapic_pin(0xf0) =3D 6;	/* E-IDE CDROM */
-	iosapic_pin(0xa0) =3D 10;	/* Real PCI Interrupt */
-#elif !defined(CONFIG_IA64_IRQ_ACPI)
-	/*
-	 * For systems where the routing info in ACPI is
-	 * unavailable/wrong, use the intr_routing information to
-	 * initialize the iosapic array
-	 */
-	i =3D -1;
-	while (intr_routing[++i].srcbus !=3D 0xff) {
-		if (intr_routing[i].srcbus =3D BUS_ISA) {
-			vector =3D isa_irq_to_vector(intr_routing[i].srcbusirq);
-		} else if (intr_routing[i].srcbus =3D BUS_PCI) {
-			vector =3D intr_routing[i].iosapic_pin;
-		} else {
-			printk("unknown bus type %d for intr_routing[%d]\n",
-                               intr_routing[i].srcbus, i);
-			continue;
-		}
-		iosapic_pin(vector) =3D intr_routing[i].iosapic_pin;
-		iosapic_dmode(vector) =3D intr_routing[i].mode;
-		iosapic_polarity(vector) =3D intr_routing[i].polarity;
-		iosapic_trigger(vector) =3D intr_routing[i].trigger;
-# ifdef DEBUG_IRQ_ROUTING
-		printk("irq[0x%x(0x%x)]:0x%x, %d, %d, %d\n", vector, intr_routing[i].src=
busirq,
-		       iosapic_pin(vector), iosapic_dmode(vector), iosapic_polarity(vect=
or),
-		       iosapic_trigger(vector));
-# endif
-	}
-#else /* !defined(CONFIG_IA64_SOFTSDV_HACKS) && defined(CONFIG_IA64_IRQ_AC=
PI) */
 	/*=20
-	 * Map the legacy ISA devices into the IOSAPIC data; We'll override these
-	 * later with data from the ACPI Interrupt Source Override table.
-	 *
-	 * Huh, the Lion w/ FPSWA firmware has entries for _all_ of the legacy IR=
Qs,=20
-	 * including those that are not different from PC/AT standard.  I don't k=
now
-	 * if this is a bug in the other firmware or not.  I'm going to leave thi=
s code=20
-	 * here, so that this works on BigSur but will go ask Intel. --wfd 2000-J=
an-19
-	 *
+	 * Map the legacy ISA devices into the IOSAPIC data.  Some of
+	 * these may get reprogrammed later on with data from the ACPI
+	 * Interrupt Source Override table.
 	 */
 	for (i =3D 0; i < 16; i++) {
 		irq =3D isa_irq_to_vector(i);
@@ -450,38 +270,40 @@
 		       irq, iosapic_pin(irq));
 #endif
 	}
-#endif /* !CONFIG_IA64_IRQ_ACPI */
-}
=20
-struct hw_interrupt_type irq_type_iosapic =3D {
-	typename:	"IOSAPIC",
-	startup:	iosapic_startup_irq,
-	shutdown:	iosapic_disable_irq,
-	enable:		iosapic_enable_irq,
-	disable:	iosapic_disable_irq,
-	ack:		iosapic_ack_irq,
-	end:		iosapic_end_irq,
-	set_affinity:	iosapic_set_affinity
-};
+	for (i =3D 0; i < NR_IRQS; ++i) {
+		if (iosapic_pin(i) !=3D -1) {
+			if (iosapic_trigger(i) =3D IO_SAPIC_LEVEL)
+			  irq_type =3D &irq_type_iosapic_level;
+			else
+			  irq_type =3D &irq_type_iosapic_edge;
+			if (irq_desc[i].handler !=3D &no_irq_type)
+				printk("dig_irq_init: warning: changing vector %d from %s to %s\n",
+				       i, irq_desc[i].handler->typename,
+				       irq_type->typename);
+			irq_desc[i].handler =3D irq_type;
+
+			/* program the IOSAPIC routing table: */
+			set_rte(iosapic_addr(i), iosapic_pin(i), iosapic_polarity(i),
+				iosapic_trigger(i), iosapic_dmode(i),
+				(ia64_get_lid() >> 16) & 0xffff, i);
+		}
+	}
+}
=20
 void
 dig_irq_init (void)
 {
-	int i;
+	/*
+	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT s=
upport
+	 * enabled.
+	 */
+	outb(0xff, 0xA1);
+	outb(0xff, 0x21);
=20
 #ifndef CONFIG_IA64_DIG
 	iosapic_init(IO_SAPIC_DEFAULT_ADDR);
 #endif
-
-	for (i =3D 0; i < NR_IRQS; ++i) {
-		if (iosapic_pin(i) !=3D -1) {
-			if (irq_desc[i].handler !=3D &no_irq_type)
-				printk("dig_irq_init: warning: changing vector %d from %s to %s\n",
-				       i, irq_desc[i].handler->typename,
-				       irq_type_iosapic.typename);
-			irq_desc[i].handler =3D &irq_type_iosapic;
-		}
-	}
 }
=20
 void
diff -urN linux-davidm/arch/ia64/dig/setup.c linux-2.3.51-lia/arch/ia64/dig=
/setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Sun Feb  6 18:42:40 2000
+++ linux-2.3.51-lia/arch/ia64/dig/setup.c	Fri Apr 14 13:03:52 2000
@@ -47,17 +47,11 @@
 	unsigned int orig_x, orig_y, num_cols, num_rows, font_height;
=20
 	/*
-	 * This assumes that the EFI partition is physical disk 1
-	 * partition 1 and the Linux root disk is physical disk 1
-	 * partition 2.
+	 * Default to /dev/sda2.  This assumes that the EFI partition
+	 * is physical disk 1 partition 1 and the Linux root disk is
+	 * physical disk 1 partition 2.
 	 */
-#ifdef CONFIG_IA64_LION_HACKS
-	/* default to /dev/sda2 on Lion... */
 	ROOT_DEV =3D to_kdev_t(0x0802);		/* default to second partition on first =
drive */
-#else
-	/* default to /dev/dha2 on BigSur... */
-	ROOT_DEV =3D to_kdev_t(0x0302);		/* default to second partition on first =
drive */
-#endif
=20
 #ifdef CONFIG_SMP
 	init_smp_config();
diff -urN linux-davidm/arch/ia64/kernel/acpi.c linux-2.3.51-lia/arch/ia64/k=
ernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/kernel/acpi.c	Wed Apr 19 20:15:05 2000
@@ -27,13 +27,12 @@
 #undef ACPI_DEBUG		/* Guess what this does? */
=20
 #ifdef CONFIG_SMP
-extern unsigned long ipi_base_addr;
+extern struct smp_boot_data smp;
 #endif
=20
 /* These are ugly but will be reclaimed by the kernel */
-int __initdata acpi_cpus =3D 0;=09
-int __initdata acpi_apic_map[32];
-int __initdata cpu_cnt =3D 0;
+int __initdata available_cpus =3D 0;=09
+int __initdata total_cpus =3D 0;
=20
 void (*pm_idle) (void);
=20
@@ -50,7 +49,7 @@
 	if ((lsapic->flags & LSAPIC_PRESENT) =3D 0)=20
 		return;
=20
-	printk("      CPU %d (%.04x:%.04x): ", cpu_cnt, lsapic->eid, lsapic->id);
+	printk("      CPU %d (%.04x:%.04x): ", total_cpus, lsapic->eid, lsapic->i=
d);
=20
 	if ((lsapic->flags & LSAPIC_ENABLED) =3D 0) {
 		printk("Disabled.\n");
@@ -62,11 +61,17 @@
 =09
 	if (add) {
 		printk("Available.\n");
-		acpi_cpus++;
-		acpi_apic_map[cpu_cnt] =3D (lsapic->id << 8) | lsapic->eid;
+		available_cpus++;
+#ifdef CONFIG_SMP
+# if LARGE_CPU_ID_OK
+		smp.cpu_map[total_cpus] =3D (lsapic->id << 8) | lsapic->eid;
+# else
+		smp.cpu_map[total_cpus] =3D lsapic->id;
+# endif
+#endif
 	}
 =09
-	cpu_cnt++;
+	total_cpus++;
 }
=20
 /*
@@ -204,11 +209,11 @@
 {
 	char *p, *end;
=20
-	memset(&acpi_apic_map, -1, sizeof(acpi_apic_map));
-
-#ifdef CONFIG_SMP
 	/* Base address of IPI Message Block */
 	ipi_base_addr =3D (unsigned long) ioremap(msapic->interrupt_block, 0);
+
+#ifdef CONFIG_SMP
+	memset(&smp, -1, sizeof(smp));
 #endif
 =09
 	p =3D (char *) (msapic + 1);
@@ -253,7 +258,7 @@
 	}
=20
 	/* Make bootup pretty */
-	printk("      %d CPUs available, %d CPUs total\n", acpi_cpus, cpu_cnt);
+	printk("      %d CPUs available, %d CPUs total\n", available_cpus, total_=
cpus);
 }
=20
 int __init=20
@@ -292,12 +297,15 @@
 			continue;
=20
 		acpi_parse_msapic((acpi_sapic_t *) hdrp);
-	} /* while() */
+	}
=20
-	if (acpi_cpus =3D 0) {
+#ifdef CONFIG_SMP
+	if (available_cpus =3D 0) {
 		printk("ACPI: Found 0 CPUS; assuming 1\n");
-		acpi_cpus =3D 1; /* We've got at least one of these, no? */
+		available_cpus =3D 1; /* We've got at least one of these, no? */
 	}
+	smp.cpu_count =3D available_cpus;
+#endif
 	return 1;
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.3.51-lia/arch/ia64/=
kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/kernel/entry.S	Wed Apr 19 17:43:53 2000
@@ -229,11 +229,11 @@
 	stf.spill [r2]=F30,32
 	stf.spill [r3]=F31,24
 	;;
-	st8.spill [r2]=3Dr4,16
-	st8.spill [r3]=3Dr5,16
+.mem.offset 0,0;	st8.spill [r2]=3Dr4,16
+.mem.offset 8,0;	st8.spill [r3]=3Dr5,16
 	;;
-	st8.spill [r2]=3Dr6,16
-	st8.spill [r3]=3Dr7,16
+.mem.offset 0,0;	st8.spill [r2]=3Dr6,16
+.mem.offset 8,0;	st8.spill [r3]=3Dr7,16
 	;;
 	st8 [r2]=3Dr21,16		// save b0
 	st8 [r3]=3Dr22,16		// save b1
@@ -438,8 +438,8 @@
 (p6)	br.cond.sptk.few strace_error		// syscall failed ->
 	;;					// avoid RAW on r10
 strace_save_retval:
-	st8.spill [r2]=3Dr8			// store return value in slot for r8
-	st8.spill [r3]=3Dr10			// clear error indication in slot for r10
+.mem.offset 0,0;	st8.spill [r2]=3Dr8	// store return value in slot for r8
+.mem.offset 8,0;	st8.spill [r3]=3Dr10	// clear error indication in slot fo=
r r10
 ia64_strace_leave_kernel:
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch return value
 .ret6:	br.cond.sptk.many ia64_leave_kernel
@@ -492,7 +492,9 @@
 	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp	// r2 =3D &pt_regs.r8
 	adds r3=3DIA64_PT_REGS_R8_OFFSET+32,sp	// r3 =3D &pt_regs.r10
 	;;
+	.mem.offset 0,0
 (p6)	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat=
 bit
+	.mem.offset 8,0
 (p6)	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and set=
 unat bit
 (p7)	br.cond.spnt.few handle_syscall_error	// handle potential syscall fai=
lure
=20
@@ -553,6 +555,16 @@
 2:
 	// check & deliver pending signals:
 (p2)	br.call.spnt.few rp=3Dhandle_signal_delivery
+#if defined(CONFIG_SMP) || defined(CONFIG_IA64_SOFTSDV_HACKS)
+	// Check for lost ticks
+	mov r2 =3D ar.itc
+	mov r3 =3D cr.itm
+	;;
+	sub r2 =3D r2, r3
+	;;
+	cmp.ge p6,p7 =3D r2, r0
+(p6)	br.call.spnt.few rp=3Dinvoke_ia64_reset_itm
+#endif=20
 restore_all:
=20
 	// start restoring the state saved on the kernel stack (struct pt_regs):
@@ -738,8 +750,8 @@
 (p6)	mov r9=3Dr8
 (p6)	mov r10=3D0
 	;;
-	st8.spill [r2]=3Dr9	// store errno in pt_regs.r8 and set unat bit
-	st8.spill [r3]=3Dr10	// store error indication in pt_regs.r10 and set una=
t bit
+.mem.offset 0,0; st8.spill [r2]=3Dr9	// store errno in pt_regs.r8 and set =
unat bit
+.mem.offset 8,0; st8.spill [r3]=3Dr10	// store error indication in pt_regs=
.r10 and set unat bit
 	br.cond.sptk.many ia64_leave_kernel
 	.endp handle_syscall_error
=20
@@ -760,6 +772,19 @@
 	mov rp=3Dloc1
 	br.ret.sptk.many rp
 	.endp invoke_schedule_tail
+
+	.proc invoke_ia64_reset_itm
+invoke_ia64_reset_itm:
+	alloc loc0=3Dar.pfs,8,2,0,0
+	mov loc1=3Drp
+	;;
+	br.call.sptk.many rp=3Dia64_reset_itm
+	;;
+	mov ar.pfs=3Dloc0
+	mov rp=3Dloc1
+	br.ret.sptk.many rp
+	.endp invoke_ia64_reset_itm
+
 #endif /* CONFIG_SMP */
=20
 	/*
@@ -858,26 +883,22 @@
 	.global sys_rt_sigsuspend
 sys_rt_sigsuspend:
 	alloc loc0=3Dar.pfs,2,2,3,0
-	mov r9=3Dar.unat
=20
 	// If the process is being ptraced, the signal may not actually be delive=
red to
 	// the process.  Instead, SIGCHLD will be sent to the parent.  We need to
 	// setup a switch_stack so ptrace can inspect the processes state if nece=
ssary.
-	adds r2=3DIA64_TASK_FLAGS_OFFSET,r13
-	;;
-	ld8 r2=3D[r2]
+	// Also, the process might not ptraced until stopped in sigsuspend, so th=
is
+	// isn't something that we can do conditionally based upon the value of
+	// PF_PTRACED_BIT.
 	mov out0=3Din0				// mask
 	mov out1=3Din1				// sigsetsize
 	;;
 	adds out2=16,sp				// out1=3D&pt_regs
-	tbit.nz p16,p17=3Dr2,PF_PTRACED_BIT
-(p16)	br.cond.spnt.many sigsuspend_setup_switch_stack
+	movl r28=BAck_from_sigsuspend_setup_switch_stack
+	mov r16=3Dloc0
+	br.cond.sptk.many save_switch_stack
 	;;
 back_from_sigsuspend_setup_switch_stack:
-	adds r3=3D-IA64_SWITCH_STACK_SIZE+IA64_SWITCH_STACK_CALLER_UNAT_OFFSET+16=
,sp
-(p17)	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp	// make space for (dummy) switc=
h_stack
-	;;
-(p17)	st8 [r3]=3Dr9				// save ar.unat in sw->caller_unat
 	mov loc1=3Drp				// save return address
 	br.call.sptk.many rp=3Dia64_rt_sigsuspend
 .ret12:
@@ -886,23 +907,12 @@
 	ld8 r9=3D[r3]				// load new unat from sw->caller_unat
 	mov rp=3Dloc1
 	;;
-(p17)	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop (dummy) switch_stack
-(p17)	mov ar.unat=3Dr9
-(p17)	mov ar.pfs=3Dloc0
-(p17)	br.ret.sptk.many rp
=20
 	// restore the switch stack (ptrace may have modified it):
 	movl r28=1F
 	br.cond.sptk.many load_switch_stack
 1:	br.ret.sptk.many rp
 	// NOT REACHED
-
-sigsuspend_setup_switch_stack:
-	movl r28=BAck_from_sigsuspend_setup_switch_stack
-	mov r16=3Dloc0
-	br.cond.sptk.many save_switch_stack
-	// NOT REACHED
-
 	.endp sys_rt_sigsuspend
=20
 	.align 16
diff -urN linux-davidm/arch/ia64/kernel/irq.c linux-2.3.51-lia/arch/ia64/ke=
rnel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/kernel/irq.c	Wed Apr 19 20:48:52 2000
@@ -582,9 +582,7 @@
 	if (!(status & (IRQ_DISABLED | IRQ_INPROGRESS))) {
 		action =3D desc->action;
 		status &=3D ~IRQ_PENDING; /* we commit to handling */
-#ifdef CONFIG_SMP
 		status |=3D IRQ_INPROGRESS; /* we are handling it */
-#endif
 	}
 	desc->status =3D status;
=20
@@ -616,9 +614,7 @@
 			break;
 		desc->status &=3D ~IRQ_PENDING;
 	}
-#ifdef CONFIG_SMP
 	desc->status &=3D ~IRQ_INPROGRESS;
-#endif
 out:
 	/*
 	 * The ->end() handler has to deal with interrupts which got
@@ -732,7 +728,6 @@
 	unsigned long val;
 	unsigned long delay;
=20
-printk("probe_irq_on\n");
 	/*=20
 	 * something may have generated an irq long ago and we want to
 	 * flush such a longstanding irq before considering it as spurious.=20
@@ -860,7 +855,6 @@
=20
 	if (nr_irqs > 1)
 		irq_found =3D -irq_found;
-printk("probe_irq_off=3D%d\n", irq_found);
 	return irq_found;
 }
=20
@@ -872,7 +866,6 @@
 	struct irqaction *old, **p;
 	irq_desc_t *desc =3D irq_desc + irq;
=20
-printk("setup_irq(irq=3D%u,type=3D%s)\n", irq, desc->handler->typename);
 	/*
 	 * Some drivers like serial.c use request_irq() heavily,
 	 * so we have to be careful not to interfere with a
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.3.51-lia/arch/ia=
64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/kernel/irq_ia64.c	Wed Apr 19 20:34:14 2000
@@ -37,6 +37,8 @@
 spinlock_t ivr_read_lock;
 #endif
=20
+unsigned long ipi_base_addr =3D IPI_DEFAULT_BASE_ADDR;	/* default base add=
r of IPI table */
+
 /*
  * Legacy IRQ to IA-64 vector translation table.  Any vector not in
  * this table maps to itself (ie: irq 0x30 =3D> IA64 vector 0x30)
@@ -154,8 +156,10 @@
 		}
 	}
=20
+#if 0
 if (vector =3D 65 || vector < 16)
 	printk("ia64_handle_irq(vector=3D%lu, status=3D%x)\n", vector, irq_desc[v=
ector].status);
+#endif
=20
 	/*
 	 * The interrupt is now said to be in service
@@ -199,13 +203,6 @@
 	flags:		SA_INTERRUPT,
 	name:		"IPI"
 };
-
-void __init
-init_IRQ_SMP (void)
-{
-	setup_irq(IPI_IRQ, &ipi_irqaction);
-}
-
 #endif
=20
 void __init
@@ -225,7 +222,7 @@
 	 * Configure the IPI vector and handler
 	 */
 	irq_desc[IPI_IRQ].handler =3D &irq_type_ia64_sapic;
-	init_IRQ_SMP();
+	setup_irq(IPI_IRQ, &ipi_irqaction);
 #endif
=20
 	ia64_set_pmv(1 << 16);
@@ -237,16 +234,26 @@
 	ia64_set_tpr(0);
 }
=20
-/* TBD:
- * 	Certain IA64 platforms can have inter-processor interrupt support.
- * 	This interface is supposed to default to the IA64 IPI block-based
- * 	mechanism if the platform doesn't provide a separate mechanism
- *	for IPIs.
- *	Choices : (1) Extend hw_interrupt_type interfaces=20
- *		  (2) Use machine vector mechanism
- *	For now defining the following interface as a place holder.
- */
 void
-ipi_send (int cpu, int vector, int delivery_mode)
+ipi_send (int cpu, int vector, int delivery_mode, int redirect)
 {
+	unsigned long ipi_addr;
+	unsigned long ipi_data;
+#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+	unsigned long flags;
+#endif
+#	define EID	0
+
+	ipi_data =3D (delivery_mode << 8) | (vector & 0xff);
+	ipi_addr =3D ipi_base_addr | ((cpu << 8 | EID) << 4) | ((redirect & 1)  <=
< 3);
+
+#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+	spin_lock_irqsave(&ivr_read_lock, flags);
+#endif	/* CONFIG_ITANIUM_ASTEP_SPECIFIC */
+
+	writeq(ipi_data, ipi_addr);
+
+#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+	spin_unlock_irqrestore(&ivr_read_lock, flags);
+#endif
 }
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.3.51-lia/arch/ia64/ke=
rnel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/kernel/ivt.S	Tue Apr 18 19:06:36 2000
@@ -5,213 +5,6 @@
  * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1998-2000 David Mosberger <davidm@hpl.hp.com>
  */
-
-#include <linux/config.h>
-
-#include <asm/break.h>
-#include <asm/offsets.h>
-#include <asm/pgtable.h>
-#include <asm/processor.h>
-#include <asm/ptrace.h>
-#include <asm/system.h>
-#include <asm/unistd.h>
-
-#include "entry.h"
-
-/*
- * A couple of convenience macros that make writing and reading
- * SAVE_MIN and SAVE_REST easier.
- */
-#define rARPR		r31
-#define rCRIFS		r30
-#define rCRIPSR		r29
-#define rCRIIP		r28
-#define rARRSC		r27
-#define rARPFS		r26
-#define rARUNAT		r25
-#define rARRNAT		r24
-#define rARBSPSTORE	r23
-#define rKRBS		r22
-#define rB6		r21
-#define rR1		r20
-
-/*
- * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
- * the minimum state necessary that allows us to turn psr.ic back
- * on.
- *
- * Assumed state upon entry:
- *	psr.ic: off
- *	psr.dt: off
- *	r31:	contains saved predicates (pr)
- *
- * Upon exit, the state is as follows:
- *	psr.ic: off
- *	psr.dt: off
- *	r2 =3D points to &pt_regs.r16
- *	r12 =3D kernel sp (kernel virtual address)
- *	r13 =3D points to current task_struct (kernel virtual address)
- *	p15 =3D TRUE if psr.i is set in cr.ipsr
- *	predicate registers (other than p6, p7, and p15), b6, r3, r8, r9, r10, =
r11, r14, r15:
- *		preserved
- *
- * Note that psr.ic is NOT turned on by this macro.  This is so that
- * we can pass interruption state as arguments to a handler.
- */
-#define DO_SAVE_MIN(COVER,EXTRA)								  \
-	mov rARRSC=3Dar.rsc;									  \
-	mov rARPFS=3Dar.pfs;									  \
-	mov rR1=3Dr1;										  \
-	mov rARUNAT=3Dar.unat;									  \
-	mov rCRIPSR=3Dcr.ipsr;									  \
-	mov rB6=B6;		/* rB6 =3D branch reg 6 */					  \
-	mov rCRIIP=3Dcr.iip;									  \
-	mov r1=3Dar.k6;		/* r1 =3D current */						  \
-	;;											  \
-	invala;											  \
-	extr.u r16=3DrCRIPSR,32,2;		/* extract psr.cpl */				  \
-	;;											  \
-	cmp.eq pKern,p7=3Dr0,r16;			/* are we in kernel mode already? (psr.cpl=3D=
0) */ \
-	/* switch from user to kernel RBS: */							  \
-	COVER;											  \
-	;;											  \
-(p7)	mov ar.rsc=3Dr0;		/* set enforced lazy mode, pl 0, little-endian, loa=
drs=3D0 */	  \
-(p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register backing=
 store */	  \
-	;;											  \
-(p7)	mov rARRNAT=3Dar.rnat;									  \
-(pKern)	dep r1=3D0,sp,61,3;				/* compute physical addr of sp  */	  \
-(p7)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of me=
mory stack */	  \
-(p7)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			  \
-(p7)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS */=
  \
-	;;											  \
-(pKern)	addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		  \
-(p7)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			  \
-	;;											  \
-(p7)	mov r18=3Dar.bsp;										  \
-(p7)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=3D0=
 */		  \
-												  \
-	mov r16=3Dr1;		/* initialize first base pointer */				  \
-	adds r17=3D8,r1;		/* initialize second base pointer */				  \
-	;;											  \
-	st8 [r16]=3DrCRIPSR,16;	/* save cr.ipsr */						  \
-	st8 [r17]=3DrCRIIP,16;	/* save cr.iip */						  \
-(pKern)	mov r18=3Dr0;		/* make sure r18 isn't NaT */					  \
-	;;											  \
-	st8 [r16]=3DrCRIFS,16;	/* save cr.ifs */						  \
-	st8 [r17]=3DrARUNAT,16;	/* save ar.unat */						  \
-(p7)	sub r18=3Dr18,rKRBS;	/* r18=3DRSE.ndirty*8 */						  \
-	;;											  \
-	st8 [r16]=3DrARPFS,16;	/* save ar.pfs */						  \
-	st8 [r17]=3DrARRSC,16;	/* save ar.rsc */						  \
-	tbit.nz p15,p0=3DrCRIPSR,IA64_PSR_I_BIT							  \
-	;;			/* avoid RAW on r16 & r17 */					  \
-(pKern)	adds r16=16,r16;	/* skip over ar_rnat field */					  \
-(pKern)	adds r17=16,r17;	/* skip over ar_bspstore field */				  \
-(p7)	st8 [r16]=3DrARRNAT,16;	/* save ar.rnat */						  \
-(p7)	st8 [r17]=3DrARBSPSTORE,16;	/* save ar.bspstore */					  \
-	;;											  \
-	st8 [r16]=3DrARPR,16;	/* save predicates */						  \
-	st8 [r17]=3DrB6,16;	/* save b6 */							  \
-	shl r18=3Dr18,16;		/* compute ar.rsc to be used for "loadrs" */			  \
-	;;											  \
-	st8 [r16]=3Dr18,16;	/* save ar.rsc value for "loadrs" */				  \
-	st8.spill [r17]=3DrR1,16;	/* save original r1 */						  \
-	cmp.ne pEOI,p0=3Dr0,r0	/* clear pEOI by default */					  \
-	;;											  \
-	st8.spill [r16]=3Dr2,16;									  \
-	st8.spill [r17]=3Dr3,16;									  \
-	adds r2=3DIA64_PT_REGS_R16_OFFSET,r1;							  \
-	;;											  \
-	st8.spill [r16]=3Dr12,16;									  \
-	st8.spill [r17]=3Dr13,16;									  \
-	cmp.eq pNonSys,pSys=3Dr0,r0	/* initialize pSys=3D0, pNonSys=3D1 */			  \
-	;;											  \
-	st8.spill [r16]=3Dr14,16;									  \
-	st8.spill [r17]=3Dr15,16;									  \
-	dep r14=3D-1,r0,61,3;									  \
-	;;											  \
-	st8.spill [r16]=3Dr8,16;									  \
-	st8.spill [r17]=3Dr9,16;									  \
-	adds r12=3D-16,r1;	/* switch to kernel memory stack (with 16 bytes of scr=
atch) */	  \
-	;;											  \
-	st8.spill [r16]=3Dr10,16;									  \
-	st8.spill [r17]=3Dr11,16;									  \
-	mov r13=3Dar.k6;		/* establish `current' */					  \
-	;;											  \
-	or r2=3Dr2,r14;		/* make first base a kernel virtual address */			  \
-	EXTRA;											  \
-	movl r1=3D__gp;		/* establish kernel global pointer */				  \
-	;;											  \
-	or r12=3Dr12,r14;		/* make sp a kernel virtual address */				  \
-	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			  \
-	bsw.1;;			/* switch back to bank 1 (must be last in insn group) */
-
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-# define STOPS	nop.i 0x0;; nop.i 0x0;; nop.i 0x0;;
-#else
-# define STOPS
-#endif
-
-#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover;; mov rCRIFS=3Dcr.ifs,) STOPS
-#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover;; mov rCRIFS=3Dcr.ifs, m=
ov r15=3Dr19) STOPS
-#define SAVE_MIN		DO_SAVE_MIN(mov rCRIFS=3Dr0,) STOPS
-
-/*
- * SAVE_REST saves the remainder of pt_regs (with psr.ic on).  This
- * macro guarantees to preserve all predicate registers, r8, r9, r10,
- * r11, r14, and r15.
- *
- * Assumed state upon entry:
- *	psr.ic: on
- *	psr.dt: on
- *	r2:	points to &pt_regs.r16
- *	r3:	points to &pt_regs.r17
- */
-#define SAVE_REST				\
-	st8.spill [r2]=3Dr16,16;			\
-	st8.spill [r3]=3Dr17,16;			\
-	;;					\
-	st8.spill [r2]=3Dr18,16;			\
-	st8.spill [r3]=3Dr19,16;			\
-	;;					\
-	mov r16=3Dar.ccv;		/* M-unit */	\
-	movl r18=3DFPSR_DEFAULT	/* L-unit */	\
-	;;					\
-	mov r17=3Dar.fpsr;	/* M-unit */	\
-	mov ar.fpsr=3Dr18;	/* M-unit */	\
-	;;					\
-	st8.spill [r2]=3Dr20,16;			\
-	st8.spill [r3]=3Dr21,16;			\
-	mov r18=B0;				\
-	;;					\
-	st8.spill [r2]=3Dr22,16;			\
-	st8.spill [r3]=3Dr23,16;			\
-	mov r19=B7;				\
-	;;					\
-	st8.spill [r2]=3Dr24,16;			\
-	st8.spill [r3]=3Dr25,16;			\
-	;;					\
-	st8.spill [r2]=3Dr26,16;			\
-	st8.spill [r3]=3Dr27,16;			\
-	;;					\
-	st8.spill [r2]=3Dr28,16;			\
-	st8.spill [r3]=3Dr29,16;			\
-	;;					\
-	st8.spill [r2]=3Dr30,16;			\
-	st8.spill [r3]=3Dr31,16;			\
-	;;					\
-	st8 [r2]=3Dr16,16;	/* ar.ccv */	\
-	st8 [r3]=3Dr17,16;	/* ar.fpsr */	\
-	;;					\
-	st8 [r2]=3Dr18,16;	/* b0 */	\
-	st8 [r3]=3Dr19,16+8;	/* b7 */	\
-	;;					\
-	stf.spill [r2]=F6,32;			\
-	stf.spill [r3]=F7,32;			\
-	;;					\
-	stf.spill [r2]=F8,32;			\
-	stf.spill [r3]=F9,32
-
 /*
  * This file defines the interrupt vector table used by the CPU.
  * It does not include one entry per possible cause of interruption.
@@ -236,9 +29,29 @@
  * The table is 32KB in size and must be aligned on 32KB boundary.
  * (The CPU ignores the 15 lower bits of the address)
  *
- * Table is based upon EAS2.4 (June 1998)
+ * Table is based upon EAS2.6 (Oct 1999)
  */
=20
+#include <linux/config.h>
+
+#include <asm/break.h>
+#include <asm/offsets.h>
+#include <asm/pgtable.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+#include <asm/unistd.h>
+
+#define MINSTATE_START_SAVE_MIN	/* no special action needed */
+#define MINSTATE_END_SAVE_MIN									\
+	or r2=3Dr2,r14;		/* make first base a kernel virtual address */			\
+	or r12=3Dr12,r14;		/* make sp a kernel virtual address */				\
+	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			\
+	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
+	;;
+
+#include "minstate.h"
+
 #define FAULT(n)									\
 	rsm psr.dt;			/* avoid nested faults due to TLB misses... */	\
 	;;										\
@@ -336,8 +149,8 @@
 (p7)	tbit.nz.unc p10,p11=3Dr19,32		// is it an instruction TLB miss?
 	dep r17=3D0,r17,0,PAGE_SHIFT		// clear low bits to get page address
 	;;
-(p10)	itc.i r18;;	// insert the instruction TLB entry (EAS2.6: must be las=
t in insn group!)
-(p11)	itc.d r18;;	// insert the data TLB entry (EAS2.6: must be last in in=
sn group!)
+(p10)	itc.i r18				// insert the instruction TLB entry
+(p11)	itc.d r18				// insert the data TLB entry
 (p6)	br.spnt.few page_fault			// handle bad address/page not present (page=
 fault)
 	mov cr.ifa=3Dr21
=20
@@ -346,9 +159,9 @@
 	// the exception deferral bit.
 	adds r16=3D__DIRTY_BITS_NO_ED|_PAGE_PL_0|_PAGE_AR_RW,r17
 	;;
-(p7)	itc.d r16;;	// EAS2.6: must be last in insn group!
+(p7)	itc.d r16
 	mov pr=3Dr31,-1				// restore predicate registers
-	rfi;;					// must be last insn in an insn group
+	rfi
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -395,11 +208,11 @@
 	;;
 (p7)	tbit.z p6,p7=3Dr18,0			// page present bit cleared?
 	;;
-(p7)	itc.i r18;;	// insert the instruction TLB entry (EAS2.6: must be last=
 in insn group!)
+(p7)	itc.i r18				// insert the instruction TLB entry
 (p6)	br.spnt.few page_fault			// handle bad address/page not present (page=
 fault)
 	;;
 	mov pr=3Dr31,-1				// restore predicate registers
-	rfi;;					// must be last insn in an insn group
+	rfi
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -446,11 +259,11 @@
 	;;
 (p7)	tbit.z p6,p7=3Dr18,0			// page present bit cleared?
 	;;
-(p7)	itc.d r18;;	// insert the instruction TLB entry (EAS2.6: must be last=
 in insn group!)
+(p7)	itc.d r18				// insert the instruction TLB entry
 (p6)	br.spnt.few page_fault			// handle bad address/page not present (page=
 fault)
 	;;
 	mov pr=3Dr31,-1				// restore predicate registers
-	rfi;;					// must be last insn in an insn group
+	rfi
=20
 	//-----------------------------------------------------------------------=
------------
 	// call do_page_fault (predicates are in r31, psr.dt is off, r16 is fault=
ing address)
@@ -468,10 +281,9 @@
 	;;
 	ssm psr.ic | psr.dt
 	;;
-	srlz.d					// guarantee that interrupt collection is enabled
-(p15)	ssm psr.i				// restore psr.i
+	srlz.i					// guarantee that interrupt collection is enabled
 	;;
-	srlz.i					// must precede "alloc"! (srlz.i implies srlz.d)
+(p15)	ssm psr.i				// restore psr.i
 	movl r14=3Dia64_leave_kernel
 	;;
 	alloc r15=3Dar.pfs,0,0,3,0		// must be first in insn group
@@ -491,15 +303,15 @@
 	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX
 	;;
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
-	dep r16=3D0,r16,50,14	// clear top 14 bits of address
+	dep r16=3D0,r16,IA64_PHYS_BITS,(64-IA64_PHYS_BITS) // clear ed, resvd, an=
d unimpl. phys bits
 	;;
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
 	dep r16=3Dr17,r16,0,12	// insert PTE control bits into r16
 	;;
 	or r16=3Dr16,r18		// set bit 4 (uncached) if the access was to region 6
 	;;
-	itc.i r16;;		// insert the TLB entry (must be last in insn group)
-	rfi;;			// must be last insn in an insn group
+	itc.i r16		// insert the TLB entry
+	rfi
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -508,15 +320,15 @@
 	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RW
 	;;
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
-	dep r16=3D0,r16,50,14	// clear top 14 bits of address
+	dep r16=3D0,r16,IA64_PHYS_BITS,(64-IA64_PHYS_BITS) // clear ed, resvd, an=
d unimpl. phys bits
 	;;
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
 	dep r16=3Dr17,r16,0,12	// insert PTE control bits into r16
 	;;
 	or r16=3Dr16,r18		// set bit 4 (uncached) if the access was to region 6
 	;;
-	itc.d r16;;	// insert the TLB entry (EAS2.6: must be last in insn group!)
-	rfi;;			// must be last insn in an insn group
+	itc.d r16		// insert the TLB entry
+	rfi
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -609,27 +421,31 @@
 	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
-	itc.d r18;;		// install updated PTE (EAS2.6: must be last in insn group!)
-	rfi;;					// must be last insn in an insn group
+	itc.d r18				// install updated PTE
+	rfi
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
 	// Like Entry 8, except for instruction access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM
+	/*
+	 * Erratum 10 (IFA may contain incorrect address) now has
+	 * "NoFix" status.  There are no plans for fixing this.
+	 */
+	mov r17=3Dcr.ipsr
 	mov r31=3Dpr				// save predicates
-	mov r30=3Dcr.ipsr
-	;;
-	extr.u r17=3Dr30,IA64_PSR_IS_BIT,1	// get instruction arch. indicator
 	;;
-	cmp.eq p6,p0 =3D r17,r0			// check if IA64 instruction set
+	mov r18=3Dcr.iip
+	tbit.z p6,p0=3Dr17,IA64_PSR_IS_BIT	// IA64 instruction set?
 	;;
-(p6)	mov r16=3Dcr.iip				// get real faulting address
+(p6)	mov r16=3Dr18				// if so, use cr.iip instead of cr.ifa
+#if 0
 	;;
-(p6)	mov cr.ifa=3Dr16				// reset IFA
+#endif
 	mov pr=3Dr31,-1
-#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC */
+#endif /* CONFIG_ITANIUM */
 	movl r30=1F				// load continuation point in case of nested fault
 	;;
 	thash r17=3Dr16				// compute virtual address of L3 PTE
@@ -641,8 +457,8 @@
 	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
-	itc.i r18;;		// install updated PTE (EAS2.6: must be last in insn group!)
-	rfi;;					// must be last insn in an insn group
+	itc.i r18				// install updated PTE
+	rfi
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -660,8 +476,8 @@
 	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
-	itc.d r18;;		// install updated PTE (EAS2.6: must be last in insn group!)
-	rfi;;					// must be last insn in an insn group
+	itc.d r18				// install updated PTE
+	rfi
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -689,12 +505,11 @@
=20
 	// turn interrupt collection and data translation back on:
 	ssm psr.ic | psr.dt
-	srlz.d					// guarantee that interrupt collection is enabled
+	;;
+	srlz.i					// guarantee that interrupt collection is enabled
 	cmp.eq pSys,pNonSys=3Dr0,r0		// set pSys=3D1, pNonSys=3D0
 	;;
 (p15)	ssm psr.i		// restore psr.i
-	;;
-	srlz.i			// ensure everybody knows psr.ic and psr.dt are back on
 	adds r8=3D(IA64_PT_REGS_R8_OFFSET-IA64_PT_REGS_R16_OFFSET),r2
 	;;
 	stf8 [r8]=F1		// ensure pt_regs.r8 !=3D 0 (see handle_syscall_error)
@@ -813,11 +628,10 @@
 	;;
 	mov r14=3Dcr.isr
 	ssm psr.ic | psr.dt
-	srlz.d					// guarantee that interrupt collection is enabled
 	;;
-(p15)	ssm psr.i
+	srlz.i					// guarantee that interrupt collection is enabled
 	;;
-	srlz.d
+(p15)	ssm psr.i
 	adds r3=3D8,r2            // Base pointer for SAVE_REST
 	;;
 	SAVE_REST
@@ -858,12 +672,13 @@
 	ld8 r16=3D[r16]
 	tbit.z p8,p0=3Dr2,5	// (current->flags & PF_TRACESYS) =3D 0?
 	;;
-	movl r15=3Dia32_ret_from_syscall
 	mov b6=3Dr16
+	movl r15=3Dia32_ret_from_syscall
 	;;
 	mov rp=3Dr15
-(p8)	br.call.sptk.few b6=B6
-	br.call.sptk.few rp=3Dia32_trace_syscall	// rp will be overwritten (ignor=
ed)
+(p8)	br.call.sptk.many b6=B6
+	;;
+	br.call.sptk.many rp=3Dia32_trace_syscall	// rp will be overwritten (igno=
red)
=20
 non_ia32_syscall:      =20
 	alloc r15=3Dar.pfs,0,0,2,0
@@ -897,11 +712,10 @@
=20
 	// turn interrupt collection and data translation back on:
 	ssm psr.ic | psr.dt
-	srlz.d					// guarantee that interrupt collection is enabled
 	;;
-(p15)	ssm psr.i			// restore psr.i
+	srlz.i				// guarantee that interrupt collection is enabled
 	;;
-	srlz.i				// ensure everybody knows psr.ic and psr.dt are back on
+(p15)	ssm psr.i			// restore psr.i
 	movl r15=3Dia64_leave_kernel
 	;;
 	alloc r14=3Dar.pfs,0,0,2,0
@@ -935,11 +749,10 @@
 	//
 	mov r15=3Dcr.ifa
 	ssm psr.ic | psr.dt
-	srlz.d					// guarantee that interrupt collection is enabled
 	;;
-(p15)	ssm psr.i				// restore psr.i
+	srlz.i					// guarantee that interrupt collection is enabled
 	;;
-	srlz.i
+(p15)	ssm psr.i				// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer
 	;;
 	SAVE_REST
@@ -984,13 +797,12 @@
 	mov r11=3Dcr.itir
 	;;
 	ssm psr.ic | psr.dt
-	srlz.d					// guarantee that interrupt collection is enabled
+	;;
+	srlz.i					// guarantee that interrupt collection is enabled
 	;;
 (p15)	ssm psr.i				// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer for SAVE_REST
 	;;
-	srlz.i					// must precede "alloc"!
-	;;
 	alloc r14=3Dar.pfs,0,0,5,0		// must be first in insn group
 	mov out0=3Dr15
 	mov out1=3Dr8
@@ -1107,7 +919,7 @@
 	mov cr.ipsr=3Dr16
 	;;
=20
-	rfi;;				// and go back (must be last insn in group)
+	rfi				// and go back
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -1227,9 +1039,9 @@
 	;;
 	cmp.eq p2,p0=3D0,r17
 (p2)	br.cond.spnt 1f		// eflags.ac bit didn't change
+	;;
 	mov pr=3Dr31,-1		// restore predicate registers
 	rfi
-	;;
=20
 1:
 #endif	// CONFIG_IA32_SUPPORT
diff -urN linux-davidm/arch/ia64/kernel/mca.c linux-2.3.51-lia/arch/ia64/ke=
rnel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/kernel/mca.c	Wed Apr 19 20:49:08 2000
@@ -2,21 +2,21 @@
  * File: 	mca.c
  * Purpose: 	Generic MCA handling layer
  *
- *
  * Updated for latest kernel
  * Copyright (C) 2000 Intel
  * Copyright (C) Chuck Fleckenstein (cfleck@co.intel.com)
  * =20
- * =20
  * Copyright (C) 1999 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander(vijay@engr.sgi.com)
  *
+ * 00/03/29 C. Fleckenstein  Fixed PAL/SAL update issues, began MCA bug fi=
xes, logging issues,=20
+ *                           added min save state dump, added INIT handler=
.=20
  */
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/sched.h>
-#include <linux/smp_lock.h>
 #include <linux/irq.h>
+#include <linux/smp_lock.h>
=20
 #include <asm/page.h>
 #include <asm/ptrace.h>
@@ -27,6 +27,11 @@
 #include <asm/irq.h>
 #include <asm/machvec.h>
=20
+=20
+typedef struct ia64_fptr {
+	unsigned long fp;
+	unsigned long gp;
+} ia64_fptr_t;
=20
 ia64_mc_info_t			ia64_mc_info;
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
@@ -35,6 +40,11 @@
 u64				ia64_mca_stack[1024];
 u64				ia64_mca_stackframe[32];
 u64				ia64_mca_bspstore[1024];
+u64				ia64_init_stack[INIT_TASK_SIZE] __attribute__((aligned(16)));
+
+#if defined(SAL_MPINIT_WORKAROUND) && !defined(CONFIG_SMP)
+int bootstrap_processor =3D -1;
+#endif
=20
 static void			ia64_mca_cmc_vector_setup(int 		enable,=20
 							  int_vector_t 	cmc_vector);
@@ -44,33 +54,97 @@
 static void			ia64_log_init(int,int);
 static void			ia64_log_get(int,int, prfunc_t);
 static void			ia64_log_clear(int,int,int, prfunc_t);
+extern void		        ia64_monarch_init_handler (void);
+extern void		        ia64_slave_init_handler (void);
=20
 /*
  * hack for now, add platform dependent handlers
  * here
  */
 #ifndef PLATFORM_MCA_HANDLERS
-void mca_handler_platform (void)
+void
+mca_handler_platform (void)
 {
=20
 }
-void cmci_handler_platform (int cmc_irq, void *arg, struct pt_regs *ptregs)
+
+void
+cmci_handler_platform (int cmc_irq, void *arg, struct pt_regs *ptregs)
 {
=20
 }
-
-void log_print_platform ( void *cur_buff_ptr, prfunc_t prfunc)
+/*
+ * This routine will be used to deal with platform specific handling
+ * of the init, i.e. drop into the kernel debugger on server machine,
+ * or if the processor is part of some parallel machine without a
+ * console, then we would call the appropriate debug hooks here.
+ */
+void
+init_handler_platform (struct pt_regs *regs)=20
 {
+	/* if a kernel debugger is available call it here else just dump the regi=
sters */
+	show_regs(regs);		/* dump the state info */
+}
=20
+void
+log_print_platform ( void *cur_buff_ptr, prfunc_t prfunc)
+{
 }
 =09
-void ia64_mca_init_platform(void)
+void
+ia64_mca_init_platform (void)
 {
-
 }
+
 #endif /* PLATFORM_MCA_HANDLERS */
=20
-=20
+static char *min_state_labels[] =3D {
+	"nat",
+	"r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8",
+	"r9", "r10","r11", "r12","r13","r14", "r15",
+	"b0r16","b0r17", "b0r18", "b0r19", "b0r20",
+	"b0r21", "b0r22","b0R23", "b0r24", "b0r25",
+	"b0r26", "b0R27", "b0R28","b0r29", "b0r30", "b0r31",
+	"r16", "r17", "r18","r19", "r20", "r21","r22",
+	"r23", "r24","r25", "r26", "r27","r28", "r29", "r30","r31",
+	"Preds", "br0", "rsc",
+	"iip", "ipsr", "ifs",
+	"xip", "xpsr", "xfs"
+};
+
+int ia64_pmss_dump_bank0=3D0;  /* dump bank 0 ? */
+
+/*
+ * routine to process and prepare to dump min_state_save
+ * information for debugging purposes.
+ *
+ */
+void
+ia64_process_min_state_save (pal_min_state_area_t *pmss, struct pt_regs *p=
tregs)
+{
+	int i, maxW;
+	u64 *tpmss_ptr=3D(u64 *)pmss;
+
+	/* dump out the min_state_area information */
+
+	for (i=3D0;i<max;i++) {
+
+		if(!ia64_pmss_dump_bank0) {
+			if(strncmp("B0",min_state_labels[i],2)=3D0) {
+				tpmss_ptr++;  /* skip to next entry */
+				continue;
+			}
+		}=20
+
+		printk("%5s=3D0x%16.16lx ",min_state_labels[i],*tpmss_ptr++);
+
+		if (((i+1)%3)=3D0 || ((!strcmp("GR16",min_state_labels[i]))
+				     && !ia64_pmss_dump_bank0))
+			printk("\n");
+	}
+	/* hang city for now, until we include debugger or copy to ptregs to show=
: */
+	while (1);
+}
 =20
 /*
  * ia64_mca_cmc_vector_setup
@@ -142,9 +216,18 @@
 void __init
 ia64_mca_init(void)
 {
-	int	i;
+	ia64_fptr_t *mon_init_ptr =3D (ia64_fptr_t *)ia64_monarch_init_handler;
+	ia64_fptr_t *slave_init_ptr =3D (ia64_fptr_t *)ia64_slave_init_handler;
+	int i;
=20
 	IA64_MCA_DEBUG("ia64_mca_init : begin\n");
+
+#if defined(SAL_MPINIT_WORKAROUND) && !defined(CONFIG_SMP)
+	/* XXX -- workaround for SAL bug for running on MP system, but UP kernel =
*/
+
+	bootstrap_processor =3D hard_smp_processor_id();
+#endif
+
 	/* Clear the Rendez checkin flag for all cpus */
 	for(i =3D 0 ; i < IA64_MAXCPUS; i++)
 		ia64_mc_info.imi_rendez_checkin[i] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
@@ -194,10 +277,13 @@
=20
 	IA64_MCA_DEBUG("ia64_mca_init : registered os mca handler with SAL\n");
=20
-	ia64_mc_info.imi_monarch_init_handler 		=3D __pa(ia64_monarch_init_handle=
r);
+	ia64_mc_info.imi_monarch_init_handler 		=3D __pa(mon_init_ptr->fp);
 	ia64_mc_info.imi_monarch_init_handler_size	=3D IA64_INIT_HANDLER_SIZE;
-	ia64_mc_info.imi_slave_init_handler 		=3D __pa(ia64_slave_init_handler);
+	ia64_mc_info.imi_slave_init_handler 		=3D __pa(slave_init_ptr->fp);
 	ia64_mc_info.imi_slave_init_handler_size	=3D IA64_INIT_HANDLER_SIZE;
+
+	IA64_MCA_DEBUG("ia64_mca_init : os init handler at %lx\n",ia64_mc_info.im=
i_monarch_init_handler);
+
 	/* Register the os init handler with SAL */
 	if (ia64_sal_set_vectors(SAL_VECTOR_OS_INIT,
 				 ia64_mc_info.imi_monarch_init_handler,
@@ -281,7 +367,7 @@
 void
 ia64_mca_wakeup(int cpu)
 {
-	ipi_send(cpu, IA64_MCA_WAKEUP_INT_VECTOR, IA64_IPI_DM_INT);
+	ipi_send(cpu, IA64_MCA_WAKEUP_INT_VECTOR, IA64_IPI_DM_INT, 0);
 	ia64_mc_info.imi_rendez_checkin[cpu] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 =09
 }
@@ -433,25 +519,6 @@
 	ia64_return_to_sal_check();
 }
=20
-/*
- * SAL to OS entry point for INIT on the monarch processor
- * This has been defined for registration purposes with SAL=20
- * as a part of ia64_mca_init.
- */
-void
-ia64_monarch_init_handler()
-{
-}
-/*
- * SAL to OS entry point for INIT on the slave processor
- * This has been defined for registration purposes with SAL=20
- * as a part of ia64_mca_init.
- */
-
-void
-ia64_slave_init_handler()
-{
-}
 /*=20
  * ia64_mca_cmc_int_handler
  *	This is correctable machine check interrupt handler.
@@ -487,10 +554,9 @@
 #define IA64_MAX_LOG_SUBTYPES	2	/* Processor, Platform */
=20
 typedef struct ia64_state_log_s {
-	spinlock_t		isl_lock;
-	int			isl_index;
-	sal_log_header_t	isl_log[IA64_MAX_LOGS];
-
+	spinlock_t	isl_lock;
+	int		isl_index;
+	ia64_psilog_t	isl_log[IA64_MAX_LOGS];	/* need space to store header + err=
or log */
 } ia64_state_log_t;
=20
 static ia64_state_log_t	ia64_state_log[IA64_MAX_LOG_TYPES][IA64_MAX_LOG_SU=
BTYPES];
@@ -509,6 +575,53 @@
 #define IA64_LOG_CURR_BUFFER(it, sit) 	(void *)(&(ia64_state_log[it][sit].=
isl_log[IA64_LOG_CURR_INDEX(it,sit)]))
=20
 /*
+ * C portion of the OS INIT handler
+ *
+ * Called from ia64_<monarch/slave>_init_handler
+ *
+ * Inputs: pointer to pt_regs where processor info was saved.
+ *
+ * Returns:=20
+ *   0 if SAL must warm boot the System
+ *   1 if SAL must retrun to interrupted context using PAL_MC_RESUME
+ *
+ */
+
+void
+ia64_init_handler (struct pt_regs *regs)
+{
+	sal_log_processor_info_t *proc_ptr;
+	ia64_psilog_t *plog_ptr;
+
+	printk("Entered OS INIT handler\n");
+
+	/* Get the INIT processor log */
+	ia64_log_get(SAL_INFO_TYPE_INIT, SAL_SUB_INFO_TYPE_PROCESSOR, (prfunc_t)p=
rintk);
+	/* Get the INIT platform log */
+	ia64_log_get(SAL_INFO_TYPE_INIT, SAL_SUB_INFO_TYPE_PLATFORM, (prfunc_t)pr=
intk);
+
+#ifdef IA64_DUMP_ALL_PROC_INFO=20
+	ia64_log_print(SAL_INFO_TYPE_INIT, SAL_SUB_INFO_TYPE_PROCESSOR, (prfunc_t=
)printk);
+#endif=20
+
+	/*=20
+	 * get pointer to min state save area
+	 *
+	 */
+	plog_ptr=3D(ia64_psilog_t *)IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_INIT,
+						       SAL_SUB_INFO_TYPE_PROCESSOR);
+	proc_ptr =3D &plog_ptr->devlog.proclog;
+=09
+	ia64_process_min_state_save(&proc_ptr->slpi_min_state_area,regs);
+
+	init_handler_platform(regs);              /* call platform specific routi=
nes */
+
+	/* Clear the INIT SAL logs now that they have been saved in the OS buffer=
 */
+	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT, SAL_SUB_INFO_TYPE_PROCESSOR=
);
+	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT, SAL_SUB_INFO_TYPE_PLATFORM);
+}
+
+/*
  * ia64_log_init
  * 	Reset the OS ia64 log buffer
  * Inputs 	:	info_type 	(SAL_INFO_TYPE_{MCA,INIT,CMC})
@@ -521,7 +634,7 @@
 	IA64_LOG_LOCK_INIT(sal_info_type, sal_sub_info_type);
 	IA64_LOG_NEXT_INDEX(sal_info_type, sal_sub_info_type) =3D 0;
 	memset(IA64_LOG_NEXT_BUFFER(sal_info_type, sal_sub_info_type), 0,=20
-	       sizeof(sal_log_header_t) * IA64_MAX_LOGS);
+	       sizeof(ia64_psilog_t) * IA64_MAX_LOGS);
 }
=20
 /*=20
@@ -536,7 +649,7 @@
 ia64_log_get(int sal_info_type, int sal_sub_info_type, prfunc_t prfunc)
 {
 	sal_log_header_t	*log_buffer;
-	int			s;
+	int			s,total_len=3D0;
=20
 	IA64_LOG_LOCK(sal_info_type, sal_sub_info_type);
=20
@@ -544,9 +657,11 @@
 	/* Get the process state information */
 	log_buffer =3D IA64_LOG_NEXT_BUFFER(sal_info_type, sal_sub_info_type);
=20
-	if (ia64_sal_get_state_info(sal_info_type, sal_sub_info_type ,(u64 *)log_=
buffer))
+	if (!(total_len=3Dia64_sal_get_state_info(sal_info_type, sal_sub_info_typ=
e ,(u64 *)log_buffer)))
 		prfunc("ia64_mca_log_get : Getting processor log failed\n");
=20
+	IA64_MCA_DEBUG("ia64_log_get: retrieved %d bytes of error information\n",=
total_len);
+
 	IA64_LOG_INDEX_INC(sal_info_type, sal_sub_info_type);
=20
 	IA64_LOG_UNLOCK(sal_info_type, sal_sub_info_type);
@@ -579,7 +694,7 @@
 		/* Get the process state information */
 		log_buffer =3D IA64_LOG_CURR_BUFFER(sal_info_type, sal_sub_info_type);
=20
-		memset(log_buffer, 0, sizeof(sal_log_header_t));
+		memset(log_buffer, 0, sizeof(ia64_psilog_t));
=20
 		IA64_LOG_INDEX_DEC(sal_info_type, sal_sub_info_type);
 =09
@@ -768,11 +883,7 @@
 	if (lh->slh_log_type !=3D SAL_SUB_INFO_TYPE_PROCESSOR)
 		return;
=20
-#if defined(MCA_TEST)
-	slpi =3D &slpi_buf;
-#else
-	slpi =3D (sal_log_processor_info_t *)lh->slh_log_dev_spec_info;
-#endif /#if defined(MCA_TEST) */
+	slpi =3D (sal_log_processor_info_t *)((char *)lh+sizeof(sal_log_header_t)=
);  /* point to proc info */
=20
 	if (!slpi) {
 		prfunc("No Processor Error Log found\n");
@@ -798,14 +909,6 @@
 	/* Print floating-point register contents if valid */
 	if (slpi->slpi_valid.slpi_fr)=20
 		ia64_log_processor_regs_print(slpi->slpi_fr, 128, "Floating-point", "fr"=
,=20
-					      prfunc);
-
-	/* Print bank1-gr NAT register contents if valid */
-	ia64_log_processor_regs_print(&slpi->slpi_bank1_nat_bits, 1, "NAT", "nat"=
, prfunc);
-
-	/* Print bank 1 register contents if valid */
-	if (slpi->slpi_valid.slpi_bank1_gr)=20
-		ia64_log_processor_regs_print(slpi->slpi_bank1_gr, 16, "Bank1-General", =
"gr",
 					      prfunc);
=20
 	/* Print the cache check information if any*/
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.3.51-lia/arch/ia6=
4/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Wed Apr 19 20:55:46 2000
+++ linux-2.3.51-lia/arch/ia64/kernel/mca_asm.S	Thu Apr 13 17:13:36 2000
@@ -1,12 +1,31 @@
 //=20
 // assembly portion of the IA64 MCA handling
 //
-// Mods by cfleck for current kernel build
+// Mods by cfleck to integrate into kernel build
 // 00/03/15 davidm Added various stop bits to get a clean compile
+// 00/03/29 cfleck Added code to save INIT handoff state in pt_regs format=
, switch to temp kstack,
+//		   switch modes, jump to C INIT handler
+//
 #include <asm/offsets.h>
+#include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/mca_asm.h>
+#include <asm/mca.h>
+
+/*
+ * When we get an machine check, the kernel stack pointer is no longer
+ * valid, so we need to set a new stack pointer.
+ */
+#define MINSTATE_START_SAVE_MIN							\
+(pKern) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;		\
+	;;
+
+#define MINSTATE_END_SAVE_MIN							\
+	or r12=3Dr12,r14;		/* make sp a kernel virtual address */		\
+	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */	\
+	;;
=20
+#include "minstate.h"
 =09
 	.psr abi64
 	.psr lsb
@@ -75,6 +94,7 @@
 	.global	ia64_mca_stack
 	.global	ia64_mca_stackframe
 	.global	ia64_mca_bspstore
+	.global ia64_init_stack=09
 		=09
 	.text
 	.align 16
@@ -628,3 +648,146 @@
 	BRANCH(ia64_os_mca_done_restore, r2, p0, -0x20)
 	;;=20
 //EndStub/////////////////////////////////////////////////////////////////=
/////
+
+// ok, the issue here is that we need to save state information so
+// it can be useable by the kernel debugger and show regs routines.
+// In order to do this, our best bet is save the current state (plus
+// the state information obtain from the MIN_STATE_AREA) into a pt_regs
+// format.  This way we can pass it on in a useable format.
+//			=09
+
+//
+// SAL to OS entry point for INIT on the monarch processor
+// This has been defined for registration purposes with SAL=20
+// as a part of ia64_mca_init.
+//
+// When we get here, the follow registers have been
+// set by the SAL for our use
+//	=09
+//		1. GR1 =3D OS INIT GP
+//		2. GR8 =3D PAL_PROC physical address
+//		3. GR9 =3D SAL_PROC physical address
+//		4. GR10 =3D SAL GP (physical)
+//		5. GR11 =3D Init Reason
+//			0 =3D Received INIT for event other than crash dump switch
+//			1 =3D Received wakeup at the end of an OS_MCA corrected machine check
+//			2 =3D Received INIT dude to CrashDump switch assertion
+//=09
+//		6. GR12 =3D Return address to location within SAL_INIT procedure
+
+			=09
+	.text
+	.align 16
+.global ia64_monarch_init_handler      =20
+.proc ia64_monarch_init_handler      =20
+ia64_monarch_init_handler:
+
+#if defined(SAL_MPINIT_WORKAROUND)
+	//
+	// work around SAL bug that sends all processors to monarch entry
+	//
+	.global bootstrap_processor
+
+	movl	r21$
+	movl	r20=16
+	mov	r17=3Dcr.lid
+	movl	r18=3Dbootstrap_processor
+	;;
+	dep	r18=3D0,r18,61,3		// convert bsp to physical address
+	;;
+	shr	r19=3Dr17,r20
+	shr	r22=3Dr17,r21
+	ld4	r18=3D[r18]		// get the BSP ID
+	;;
+	and	r19=3D0xf, r19
+	and	r22=3D0xf, r22
+	;;
+	shl	r19=3Dr19,8		// get them in the right order
+	;;
+	or	r22=3Dr22,r19		// combine EID and LID
+	;;
+	cmp.eq	p6,p7=3Dr22,r18		// Am I the BSP ?
+(p7)	br.cond.spnt slave_init_spin_me
+	;;
+#endif
+
+=09
+//
+// ok, the first thing we do is stash the information
+// the SAL passed to os
+//
+_tmp =3D r2
+	movl	_tmp=3Dia64_sal_to_os_
