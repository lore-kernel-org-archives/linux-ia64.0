From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Oct 2000 08:55:03 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.0-test9)
Message-Id: <marc-linux-ia64-105590678205642@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a quick kernel update.  I anticipate another update shortly
after Linus releases test10.  Thus, this patch hasn't received as much
testing as I usually do.  The kernel is known to work fine on 2P Big
Sur and a slightly earlier version also worked fine on Lion and the
simulator.  As usual, YMMV.

Summary of changes:

	- Asit & Goutham: fixed IOSAPIC support to work correctly when
	  irq lines are shared by PCI devices
	- Asit: fix to unaligned access handler
	- Goutham: workaround for lost IPI problem
	- Don: IA-32 fixes & updates, in particular the beginnings of
          DRM support
	- Takayoshi: early-printk fixes to kernel startup code
	- Jun: optimized copy_user() for case where pointers are not co-aligned
	- Johannes: add VM_NONCACHED and VM_WRITECOMBINE for /dev/mem
	- Christophe: fixed unaligned accesses in Tulip (21140) NIC
	- BJ: update qla1280 driver to v3.19
	- Intel: huge ACPI update (it's not in the diff below; go get the
	  full patch to get this part)
	- Stephane: many performance related updates & fixes; in particular,
	  the API is now entirely perfmonctl() based (no more ptrace() hacks
	  needed)
	- drop platform_register_iosapic()---it's no longer needed
	- add workaround for potential ITC discontiguity
	- "backported" ftruncate() fix that caused kernel crash
	  with certain filesystem stress tests
	- memcpy: tuned it some more
	- remove off workaround for unsorted unwind tables---it's no longer
	  needed with the latest toolchain (thanks to Rich!)
	- separated IOSAPIC support from DIG, added some documentation,
	  and restructured the code to make it (hopefully) more readable;
	  also removed all (hard) IOSAPIC dependencies from acpi code
	- dropped BAD_ACPI_TABLE workaround; if you're still running
	  old Lion firmware, this might bite you; if so, please upgrade
	  the firmware (I don't think very many systems were shipped
	  with the broken firmware, so I expect few if any people to
	  be affected by this)
	- added AT_CLKTCK support for ELF binaries

I hope I didn't miss anything.  For the full patch, see:

	ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

as usual.

	--david

diff -urN linux-davidm/arch/ia64/dig/dig_irq.c lia64/arch/ia64/dig/dig_irq.c
--- linux-davidm/arch/ia64/dig/dig_irq.c	Wed Dec 31 16:00:00 1969
+++ lia64/arch/ia64/dig/dig_irq.c	Mon Oct 30 23:40:05 2000
@@ -0,0 +1,10 @@
+void
+dig_irq_init (void)
+{
+	/*
+	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT support
+	 * enabled.
+	 */
+	outb(0xff, 0xA1);
+	outb(0xff, 0x21);
+}
diff -urN linux-davidm/arch/ia64/dig/iosapic.c lia64/arch/ia64/dig/iosapic.c
--- linux-davidm/arch/ia64/dig/iosapic.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/dig/iosapic.c	Wed Dec 31 16:00:00 1969
@@ -1,409 +0,0 @@
-/*
- * Streamlined APIC support.
- *
- * Copyright (C) 1999 Intel Corp.
- * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
- * Copyright (C) 1999-2000 Hewlett-Packard Co.
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 VA Linux Systems
- * Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
- *
- * 00/04/19	D. Mosberger	Rewritten to mirror more closely the x86 I/O APIC code.
- *				In particular, we now have separate handlers for edge
- *				and level triggered interrupts.
- */
-#include <linux/config.h>
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/pci.h>
-#include <linux/smp.h>
-#include <linux/smp_lock.h>
-#include <linux/string.h>
-#include <linux/irq.h>
-
-#include <asm/acpi-ext.h>
-#include <asm/delay.h>
-#include <asm/io.h>
-#include <asm/iosapic.h>
-#include <asm/machvec.h>
-#include <asm/processor.h>
-#include <asm/ptrace.h>
-#include <asm/system.h>
-
-#ifdef	CONFIG_ACPI_KERNEL_CONFIG
-# include <asm/acpikcfg.h>
-#endif
-
-#undef DEBUG_IRQ_ROUTING
-
-static spinlock_t iosapic_lock = SPIN_LOCK_UNLOCKED;
-
-struct iosapic_vector iosapic_vector[NR_IRQS] = {
-	[0 ... NR_IRQS-1] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 }
-};
-
-/*
- * find the IRQ in the IOSAPIC map for the PCI device on bus/slot/pin
- */
-int
-iosapic_get_PCI_irq_vector (int bus, int slot, int pci_pin)
-{
-	int i;
-
-	for (i = 0; i < NR_IRQS; i++) {
-		if ((iosapic_bustype(i) = BUS_PCI) &&
-		    (iosapic_bus(i) = bus) &&
-		    (iosapic_busdata(i) = ((slot << 16) | pci_pin))) {
-			return i;
-		}
-	}
-	return -1;
-}
-
-static void
-set_rte (unsigned long iosapic_addr, int entry, int pol, int trigger, int delivery,
-	 long dest, int vector)
-{
-	u32 low32;
-	u32 high32;
-
-	low32 = ((pol << IO_SAPIC_POLARITY_SHIFT) |
-		 (trigger << IO_SAPIC_TRIGGER_SHIFT) |
-		 (delivery << IO_SAPIC_DELIVERY_SHIFT) |
-		 vector);
-
-#ifdef CONFIG_IA64_AZUSA_HACKS
-	/* set Flush Disable bit */
-	if (iosapic_addr != 0xc0000000fec00000)
-		low32 |= (1 << 17);
-#endif
-
-	/* dest contains both id and eid */
-	high32 = (dest << IO_SAPIC_DEST_SHIFT);	
-
-	writel(IO_SAPIC_RTE_HIGH(entry), iosapic_addr + IO_SAPIC_REG_SELECT);
-	writel(high32, iosapic_addr + IO_SAPIC_WINDOW);
-	writel(IO_SAPIC_RTE_LOW(entry), iosapic_addr + IO_SAPIC_REG_SELECT);
-	writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
-}
-
-static void
-nop (unsigned int irq)
-{
-	/* do nothing... */
-}
-
-static void 
-mask_irq (unsigned int irq)
-{
-	unsigned long flags, iosapic_addr = iosapic_addr(irq);
-	u32 low32;
-
-	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		writel(IO_SAPIC_RTE_LOW(iosapic_pin(irq)), iosapic_addr + IO_SAPIC_REG_SELECT);
-		low32 = readl(iosapic_addr + IO_SAPIC_WINDOW);
-
-		low32 |= (1 << IO_SAPIC_MASK_SHIFT);    /* Zero only the mask bit */
-		writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
-	}
-	spin_unlock_irqrestore(&iosapic_lock, flags);
-}
-
-static void 
-unmask_irq (unsigned int irq)
-{
-	unsigned long flags, iosapic_addr = iosapic_addr(irq);
-	u32 low32;
-
-	spin_lock_irqsave(&iosapic_lock, flags);
-	{
-		writel(IO_SAPIC_RTE_LOW(iosapic_pin(irq)), iosapic_addr + IO_SAPIC_REG_SELECT);
-		low32 = readl(iosapic_addr + IO_SAPIC_WINDOW);
-
-		low32 &= ~(1 << IO_SAPIC_MASK_SHIFT);    /* Zero only the mask bit */
-		writel(low32, iosapic_addr + IO_SAPIC_WINDOW);
-	}
-	spin_unlock_irqrestore(&iosapic_lock, flags);
-}
-
-
-static void
-iosapic_set_affinity (unsigned int irq, unsigned long mask)
-{
-	printk("iosapic_set_affinity: not implemented yet\n");
-}
-
-/*
- * Handlers for level-triggered interrupts.
- */
-
-static unsigned int
-iosapic_startup_level_irq (unsigned int irq)
-{
-	unmask_irq(irq);
-	return 0;
-}
-
-static void
-iosapic_end_level_irq (unsigned int irq)
-{
-	writel(irq, iosapic_addr(irq) + IO_SAPIC_EOI);
-}
-
-#define iosapic_shutdown_level_irq	mask_irq
-#define iosapic_enable_level_irq	unmask_irq
-#define iosapic_disable_level_irq	mask_irq
-#define iosapic_ack_level_irq		nop
-
-struct hw_interrupt_type irq_type_iosapic_level = {
-	typename:	"IO-SAPIC-level",
-	startup:	iosapic_startup_level_irq,
-	shutdown:	iosapic_shutdown_level_irq,
-	enable:		iosapic_enable_level_irq,
-	disable:	iosapic_disable_level_irq,
-	ack:		iosapic_ack_level_irq,
-	end:		iosapic_end_level_irq,
-	set_affinity:	iosapic_set_affinity
-};
-
-/*
- * Handlers for edge-triggered interrupts.
- */
-
-static unsigned int
-iosapic_startup_edge_irq (unsigned int irq)
-{
-	unmask_irq(irq);
-	/*
-	 * IOSAPIC simply drops interrupts pended while the
-	 * corresponding pin was masked, so we can't know if an
-	 * interrupt is pending already.  Let's hope not...
-	 */
-	return 0;
-}
-
-static void
-iosapic_ack_edge_irq (unsigned int irq)
-{
-	/*
-	 * Once we have recorded IRQ_PENDING already, we can mask the
-	 * interrupt for real. This prevents IRQ storms from unhandled
-	 * devices.
-	 */
-	if ((irq_desc[irq].status & (IRQ_PENDING | IRQ_DISABLED)) = (IRQ_PENDING | IRQ_DISABLED))
-		mask_irq(irq);
-}
-
-#define iosapic_enable_edge_irq		unmask_irq
-#define iosapic_disable_edge_irq	nop
-#define iosapic_end_edge_irq		nop
-
-struct hw_interrupt_type irq_type_iosapic_edge = {
-	typename:	"IO-SAPIC-edge",
-	startup:	iosapic_startup_edge_irq,
-	shutdown:	iosapic_disable_edge_irq,
-	enable:		iosapic_enable_edge_irq,
-	disable:	iosapic_disable_edge_irq,
-	ack:		iosapic_ack_edge_irq,
-	end:		iosapic_end_edge_irq,
-	set_affinity:	iosapic_set_affinity
-};
-
-unsigned int
-iosapic_version (unsigned long base_addr) 
-{
-	/*
-	 * IOSAPIC Version Register return 32 bit structure like:
-	 * {
-	 *	unsigned int version   : 8;
-	 *	unsigned int reserved1 : 8;
-	 *	unsigned int pins      : 8;
-	 *	unsigned int reserved2 : 8;
-	 * }
-	 */
-	writel(IO_SAPIC_VERSION, base_addr + IO_SAPIC_REG_SELECT);
-	return readl(IO_SAPIC_WINDOW + base_addr);
-}
-
-void
-iosapic_init (unsigned long address, int irqbase)
-{
-	struct hw_interrupt_type *irq_type;
-	struct pci_vector_struct *vectors;
-	int i, irq, num_pci_vectors;
-
-	if (irqbase = 0)
-		/* 
-		 * Map the legacy ISA devices into the IOSAPIC data.
-		 * Some of these may get reprogrammed later on with
-		 * data from the ACPI Interrupt Source Override table.
-		 */
-		for (i = 0; i < 16; i++) {
-			irq = isa_irq_to_vector(i);
-			iosapic_pin(irq) = i; 
-			iosapic_bus(irq) = BUS_ISA;
-			iosapic_busdata(irq) = 0;
-			iosapic_dmode(irq) = IO_SAPIC_LOWEST_PRIORITY;
-			iosapic_trigger(irq)  = IO_SAPIC_EDGE;
-			iosapic_polarity(irq) = IO_SAPIC_POL_HIGH;
-#ifdef DEBUG_IRQ_ROUTING
-			printk("ISA: IRQ %02x -> Vector %02x IOSAPIC Pin %d\n",
-			       i, irq, iosapic_pin(irq));
-#endif
-		}
-
-#ifndef CONFIG_IA64_SOFTSDV_HACKS
-	/* 
-	 * Map the PCI Interrupt data into the ACPI IOSAPIC data using
-	 * the info that the bootstrap loader passed to us.
-	 */
-# ifdef CONFIG_ACPI_KERNEL_CONFIG
-	acpi_cf_get_pci_vectors(&vectors, &num_pci_vectors);
-# else
-	ia64_boot_param.pci_vectors = (__u64) __va(ia64_boot_param.pci_vectors);
-	vectors = (struct pci_vector_struct *) ia64_boot_param.pci_vectors;
-	num_pci_vectors = ia64_boot_param.num_pci_vectors;
-# endif
-	for (i = 0; i < num_pci_vectors; i++) {
-		irq = vectors[i].irq;
-		if (irq < 16)
-			irq = isa_irq_to_vector(irq);
-		if (iosapic_baseirq(irq) != irqbase)
-			continue;
-
-		iosapic_bustype(irq) = BUS_PCI;
-		iosapic_pin(irq) = irq - iosapic_baseirq(irq);
-		iosapic_bus(irq) = vectors[i].bus;
-		/*
-		 * Map the PCI slot and pin data into iosapic_busdata()
-		 */
-		iosapic_busdata(irq) = (vectors[i].pci_id & 0xffff0000) | vectors[i].pin;
-
-		/* Default settings for PCI */
-		iosapic_dmode(irq) = IO_SAPIC_LOWEST_PRIORITY;
-		iosapic_trigger(irq)  = IO_SAPIC_LEVEL;
-		iosapic_polarity(irq) = IO_SAPIC_POL_LOW;
-
-# ifdef DEBUG_IRQ_ROUTING
-		printk("PCI: BUS %d Slot %x Pin %x IRQ %02x --> Vector %02x IOSAPIC Pin %d\n", 
-		       vectors[i].bus, vectors[i].pci_id>>16, vectors[i].pin, vectors[i].irq, 
-		       irq, iosapic_pin(irq));
-# endif
-	}
-#endif /* CONFIG_IA64_SOFTSDV_HACKS */
-
-	for (i = 0; i < NR_IRQS; ++i) {
-		if (iosapic_baseirq(i) != irqbase)
-			continue;
-
-		if (iosapic_pin(i) != -1) {
-			if (iosapic_trigger(i) = IO_SAPIC_LEVEL)
-			  irq_type = &irq_type_iosapic_level;
-			else
-			  irq_type = &irq_type_iosapic_edge;
-			if (irq_desc[i].handler != &no_irq_type)
-				printk("dig_irq_init: warning: changing vector %d from %s to %s\n",
-				       i, irq_desc[i].handler->typename,
-				       irq_type->typename);
-			irq_desc[i].handler = irq_type;
-
-			/* program the IOSAPIC routing table: */
-			set_rte(iosapic_addr(i), iosapic_pin(i), iosapic_polarity(i),
-				iosapic_trigger(i), iosapic_dmode(i),
-				(ia64_get_lid() >> 16) & 0xffff, i);
-		}
-	}
-}
-
-void
-dig_irq_init (void)
-{
-	/*
-	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT support
-	 * enabled.
-	 */
-	outb(0xff, 0xA1);
-	outb(0xff, 0x21);
-}
-
-void
-dig_pci_fixup (void)
-{
-	struct	pci_dev	*dev;
-	int		irq;
-	unsigned char 	pin;
-
-	pci_for_each_dev(dev) {
-		pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pin);
-		if (pin) {
-			pin--;          /* interrupt pins are numbered starting from 1 */
-			irq = iosapic_get_PCI_irq_vector(dev->bus->number, PCI_SLOT(dev->devfn),
-							 pin);
-			if (irq < 0 && dev->bus->parent) { /* go back to the bridge */
-				struct pci_dev * bridge = dev->bus->self;
-
-				/* allow for multiple bridges on an adapter */
-				do {
-					/* do the bridge swizzle... */
-					pin = (pin + PCI_SLOT(dev->devfn)) % 4;
-					irq = iosapic_get_PCI_irq_vector(bridge->bus->number,
-									 PCI_SLOT(bridge->devfn), pin);
-				} while (irq < 0 && (bridge = bridge->bus->self));
-				if (irq >= 0)
-					printk(KERN_WARNING
-					       "PCI: using PPB(B%d,I%d,P%d) to get irq %02x\n",
-					       bridge->bus->number, PCI_SLOT(bridge->devfn),
-					       pin, irq);
-				else
-					printk(KERN_WARNING
-					       "PCI: Couldn't map irq for B%d,I%d,P%d\n",
-					       bridge->bus->number, PCI_SLOT(bridge->devfn),
-					       pin);
-			}
-			if (irq >= 0) {
-				printk("PCI->APIC IRQ transform: (B%d,I%d,P%d) -> %02x\n",
-				       dev->bus->number, PCI_SLOT(dev->devfn), pin, irq);
-				dev->irq = irq;
-			}
-		}
-		/*
-		 * Nothing to fixup
-		 * Fix out-of-range IRQ numbers
-		 */
-		if (dev->irq >= NR_IRQS)
-			dev->irq = 15;	/* Spurious interrupts */
-	}
-}
-
-/*
- * Register an IOSAPIC discovered via ACPI.
- */
-void __init
-dig_register_iosapic (acpi_entry_iosapic_t *iosapic)
-{
-	unsigned int ver, v;
-	int l, max_pin;
-
-	ver = iosapic_version((unsigned long) ioremap(iosapic->address, 0));
-	max_pin = (ver >> 16) & 0xff;
-	
-	printk("IOSAPIC Version %x.%x: address 0x%lx IRQs 0x%x - 0x%x\n", 
-	       (ver & 0xf0) >> 4, (ver & 0x0f), iosapic->address, 
-	       iosapic->irq_base, iosapic->irq_base + max_pin);
-	
-	for (l = 0; l <= max_pin; l++) {
-		v = iosapic->irq_base + l;
-		if (v < 16)
-			v = isa_irq_to_vector(v);
-		if (v > IA64_MAX_VECTORED_IRQ) {
-			printk("    !!! bad IOSAPIC interrupt vector: %u\n", v);
-			continue;
-		}
-		/* XXX Check for IOSAPIC collisions */
-		iosapic_addr(v) = (unsigned long) ioremap(iosapic->address, 0);
-		iosapic_baseirq(v) = iosapic->irq_base;
-	}
-	iosapic_init(iosapic->address, iosapic->irq_base);
-}
diff -urN linux-davidm/arch/ia64/dig/setup.c lia64/arch/ia64/dig/setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/dig/setup.c	Mon Oct 30 22:28:55 2000
@@ -84,3 +84,14 @@
 	screen_info.orig_video_isVGA = 1;	/* XXX fake */
 	screen_info.orig_video_ega_bx = 3;	/* XXX fake */
 }
+
+void
+dig_irq_init (void)
+{
+	/*
+	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT support
+	 * enabled.
+	 */
+	outb(0xff, 0xA1);
+	outb(0xff, 0x21);
+}
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c lia64/arch/ia64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/ia32/binfmt_elf32.c	Mon Oct 30 22:29:21 2000
@@ -9,6 +9,7 @@
 
 #include <linux/types.h>
 
+#include <asm/param.h>
 #include <asm/signal.h>
 #include <asm/ia32.h>
 
@@ -31,6 +32,9 @@
 # define CONFIG_BINFMT_ELF_MODULE	CONFIG_BINFMT_ELF32_MODULE
 #endif
 
+#undef CLOCKS_PER_SEC
+#define CLOCKS_PER_SEC	IA32_CLOCKS_PER_SEC
+
 extern void ia64_elf32_init(struct pt_regs *regs);
 extern void put_dirty_page(struct task_struct * tsk, struct page *page, unsigned long address);
 
@@ -239,6 +243,12 @@
 	if (eppnt->p_memsz >= (1UL<<32) || addr > (1UL<<32) - eppnt->p_memsz)
 		return -EINVAL;
 
+	/*
+	 *  Make sure the elf interpreter doesn't get loaded at location 0
+	 *    so that NULL pointers correctly cause segfaults.
+	 */
+	if (addr = 0)
+		addr += PAGE_SIZE;
 #if 1
 	set_brk(ia32_mm_addr(addr), addr + eppnt->p_memsz);
 	memset((char *) addr + eppnt->p_filesz, 0, eppnt->p_memsz - eppnt->p_filesz);
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S lia64/arch/ia64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Fri Sep  8 14:34:53 2000
+++ lia64/arch/ia64/ia32/ia32_entry.S	Mon Oct 30 22:29:33 2000
@@ -291,11 +291,43 @@
 	data8 sys_getcwd
 	data8 sys_capget
 	data8 sys_capset	  /* 185 */
-	data8 sys_sigaltstack
+	data8 sys32_sigaltstack
 	data8 sys_sendfile
 	data8 sys32_ni_syscall		  /* streams1 */
 	data8 sys32_ni_syscall		  /* streams2 */
 	data8 sys32_vfork	  /* 190 */
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall	  /* 195 */
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall	  /* 200 */
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall	  /* 205 */
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall	  /* 210 */
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall	  /* 215 */
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall	  /* 220 */
+	data8 sys_ni_syscall
+	data8 sys_ni_syscall
 	/*
 	 *  CAUTION: If any system calls are added beyond this point
 	 *	then the check in `arch/ia64/kernel/ivt.S' will have
diff -urN linux-davidm/arch/ia64/ia32/ia32_ioctl.c lia64/arch/ia64/ia32/ia32_ioctl.c
--- linux-davidm/arch/ia64/ia32/ia32_ioctl.c	Wed Aug  2 18:54:01 2000
+++ lia64/arch/ia64/ia32/ia32_ioctl.c	Mon Oct 30 22:29:51 2000
@@ -22,81 +22,158 @@
 #include <linux/if_ppp.h>
 #include <linux/ixjuser.h>
 #include <linux/i2o-dev.h>
+#include <../drivers/char/drm/drm.h>
+
+#define IOCTL_NR(a)	((a) & ~(_IOC_SIZEMASK << _IOC_SIZESHIFT))
+
+#define DO_IOCTL(fd, cmd, arg) ({			\
+	int _ret;					\
+	mm_segment_t _old_fs = get_fs();		\
+							\
+	set_fs(KERNEL_DS);				\
+	_ret = sys_ioctl(fd, cmd, (unsigned long)arg);	\
+	set_fs(_old_fs);				\
+	_ret;						\
+})
+
+#define P(i)	((void *)(long)(i))
+
 
 asmlinkage long sys_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg);
 
 asmlinkage long ia32_ioctl(unsigned int fd, unsigned int cmd, unsigned int arg)
 {
+	long ret;
+
+	switch (IOCTL_NR(cmd)) {
+
+	case IOCTL_NR(DRM_IOCTL_VERSION):
+		break;
+	case IOCTL_NR(DRM_IOCTL_GET_UNIQUE):
+		{
+			drm_unique_t un;
+			struct {
+				unsigned int unique_len;
+				unsigned int unique;
+			} un32;
+
+			if (copy_from_user(&un32, P(arg), sizeof(un32)))
+				return -EFAULT;
+			un.unique_len = un32.unique_len;
+			un.unique = P(un32.unique);
+			ret = DO_IOCTL(fd, cmd, &un);
+			if (ret >= 0) {
+				un32.unique_len = un.unique_len;
+				if (copy_to_user(P(arg), &un32, sizeof(un32)))
+					return -EFAULT;
+			}
+			return(ret);
+		}
+	case IOCTL_NR(DRM_IOCTL_SET_UNIQUE):
+	case IOCTL_NR(DRM_IOCTL_ADD_MAP):
+	case IOCTL_NR(DRM_IOCTL_ADD_BUFS):
+	case IOCTL_NR(DRM_IOCTL_MARK_BUFS):
+	case IOCTL_NR(DRM_IOCTL_INFO_BUFS):
+	case IOCTL_NR(DRM_IOCTL_MAP_BUFS):
+	case IOCTL_NR(DRM_IOCTL_FREE_BUFS):
+	case IOCTL_NR(DRM_IOCTL_ADD_CTX):
+	case IOCTL_NR(DRM_IOCTL_RM_CTX):
+	case IOCTL_NR(DRM_IOCTL_MOD_CTX):
+	case IOCTL_NR(DRM_IOCTL_GET_CTX):
+	case IOCTL_NR(DRM_IOCTL_SWITCH_CTX):
+	case IOCTL_NR(DRM_IOCTL_NEW_CTX):
+	case IOCTL_NR(DRM_IOCTL_RES_CTX):
+
+	case IOCTL_NR(DRM_IOCTL_AGP_ACQUIRE):
+	case IOCTL_NR(DRM_IOCTL_AGP_RELEASE):
+	case IOCTL_NR(DRM_IOCTL_AGP_ENABLE):
+	case IOCTL_NR(DRM_IOCTL_AGP_INFO):
+	case IOCTL_NR(DRM_IOCTL_AGP_ALLOC):
+	case IOCTL_NR(DRM_IOCTL_AGP_FREE):
+	case IOCTL_NR(DRM_IOCTL_AGP_BIND):
+	case IOCTL_NR(DRM_IOCTL_AGP_UNBIND):
+
+	/* Mga specific ioctls */
+
+	case IOCTL_NR(DRM_IOCTL_MGA_INIT):
+
+	/* I810 specific ioctls */
+
+	case IOCTL_NR(DRM_IOCTL_I810_GETBUF):
+	case IOCTL_NR(DRM_IOCTL_I810_COPY):
+
+	/* Rage 128 specific ioctls */
 
-	switch (cmd) {
+	case IOCTL_NR(DRM_IOCTL_R128_PACKET):
 
-	case VFAT_IOCTL_READDIR_BOTH:
-	case VFAT_IOCTL_READDIR_SHORT:
-	case MTIOCGET:
-	case MTIOCPOS:
-	case MTIOCGETCONFIG:
-	case MTIOCSETCONFIG:
-	case PPPIOCSCOMPRESS:
-	case PPPIOCGIDLE:
-	case NCP_IOC_GET_FS_INFO_V2:
-	case NCP_IOC_GETOBJECTNAME:
-	case NCP_IOC_SETOBJECTNAME:
-	case NCP_IOC_GETPRIVATEDATA:
-	case NCP_IOC_SETPRIVATEDATA:
-	case NCP_IOC_GETMOUNTUID2:
-	case CAPI_MANUFACTURER_CMD:
-	case VIDIOCGTUNER:
-	case VIDIOCSTUNER:
-	case VIDIOCGWIN:
-	case VIDIOCSWIN:
-	case VIDIOCGFBUF:
-	case VIDIOCSFBUF:
-	case MGSL_IOCSPARAMS:
-	case MGSL_IOCGPARAMS:
-	case ATM_GETNAMES:
-	case ATM_GETLINKRATE:
-	case ATM_GETTYPE:
-	case ATM_GETESI:
-	case ATM_GETADDR:
-	case ATM_RSTADDR:
-	case ATM_ADDADDR:
-	case ATM_DELADDR:
-	case ATM_GETCIRANGE:
-	case ATM_SETCIRANGE:
-	case ATM_SETESI:
-	case ATM_SETESIF:
-	case ATM_GETSTAT:
-	case ATM_GETSTATZ:
-	case ATM_GETLOOP:
-	case ATM_SETLOOP:
-	case ATM_QUERYLOOP:
-	case ENI_SETMULT:
-	case NS_GETPSTAT:
-	/* case NS_SETBUFLEV: This is a duplicate case with ZATM_GETPOOLZ */
-	case ZATM_GETPOOLZ:
-	case ZATM_GETPOOL:
-	case ZATM_SETPOOL:
-	case ZATM_GETTHIST:
-	case IDT77105_GETSTAT:
-	case IDT77105_GETSTATZ:
-	case IXJCTL_TONE_CADENCE:
-	case IXJCTL_FRAMES_READ:
-	case IXJCTL_FRAMES_WRITTEN:
-	case IXJCTL_READ_WAIT:
-	case IXJCTL_WRITE_WAIT:
-	case IXJCTL_DRYBUFFER_READ:
-	case I2OHRTGET:
-	case I2OLCTGET:
-	case I2OPARMSET:
-	case I2OPARMGET:
-	case I2OSWDL:
-	case I2OSWUL:
-	case I2OSWDEL:
-	case I2OHTML:
-		printk("%x:unimplemented IA32 ioctl system call\n", cmd);
-		return(-EINVAL);
+	case IOCTL_NR(VFAT_IOCTL_READDIR_BOTH):
+	case IOCTL_NR(VFAT_IOCTL_READDIR_SHORT):
+	case IOCTL_NR(MTIOCGET):
+	case IOCTL_NR(MTIOCPOS):
+	case IOCTL_NR(MTIOCGETCONFIG):
+	case IOCTL_NR(MTIOCSETCONFIG):
+	case IOCTL_NR(PPPIOCSCOMPRESS):
+	case IOCTL_NR(PPPIOCGIDLE):
+	case IOCTL_NR(NCP_IOC_GET_FS_INFO_V2):
+	case IOCTL_NR(NCP_IOC_GETOBJECTNAME):
+	case IOCTL_NR(NCP_IOC_SETOBJECTNAME):
+	case IOCTL_NR(NCP_IOC_GETPRIVATEDATA):
+	case IOCTL_NR(NCP_IOC_SETPRIVATEDATA):
+	case IOCTL_NR(NCP_IOC_GETMOUNTUID2):
+	case IOCTL_NR(CAPI_MANUFACTURER_CMD):
+	case IOCTL_NR(VIDIOCGTUNER):
+	case IOCTL_NR(VIDIOCSTUNER):
+	case IOCTL_NR(VIDIOCGWIN):
+	case IOCTL_NR(VIDIOCSWIN):
+	case IOCTL_NR(VIDIOCGFBUF):
+	case IOCTL_NR(VIDIOCSFBUF):
+	case IOCTL_NR(MGSL_IOCSPARAMS):
+	case IOCTL_NR(MGSL_IOCGPARAMS):
+	case IOCTL_NR(ATM_GETNAMES):
+	case IOCTL_NR(ATM_GETLINKRATE):
+	case IOCTL_NR(ATM_GETTYPE):
+	case IOCTL_NR(ATM_GETESI):
+	case IOCTL_NR(ATM_GETADDR):
+	case IOCTL_NR(ATM_RSTADDR):
+	case IOCTL_NR(ATM_ADDADDR):
+	case IOCTL_NR(ATM_DELADDR):
+	case IOCTL_NR(ATM_GETCIRANGE):
+	case IOCTL_NR(ATM_SETCIRANGE):
+	case IOCTL_NR(ATM_SETESI):
+	case IOCTL_NR(ATM_SETESIF):
+	case IOCTL_NR(ATM_GETSTAT):
+	case IOCTL_NR(ATM_GETSTATZ):
+	case IOCTL_NR(ATM_GETLOOP):
+	case IOCTL_NR(ATM_SETLOOP):
+	case IOCTL_NR(ATM_QUERYLOOP):
+	case IOCTL_NR(ENI_SETMULT):
+	case IOCTL_NR(NS_GETPSTAT):
+	/* case IOCTL_NR(NS_SETBUFLEV): This is a duplicate case with ZATM_GETPOOLZ */
+	case IOCTL_NR(ZATM_GETPOOLZ):
+	case IOCTL_NR(ZATM_GETPOOL):
+	case IOCTL_NR(ZATM_SETPOOL):
+	case IOCTL_NR(ZATM_GETTHIST):
+	case IOCTL_NR(IDT77105_GETSTAT):
+	case IOCTL_NR(IDT77105_GETSTATZ):
+	case IOCTL_NR(IXJCTL_TONE_CADENCE):
+	case IOCTL_NR(IXJCTL_FRAMES_READ):
+	case IOCTL_NR(IXJCTL_FRAMES_WRITTEN):
+	case IOCTL_NR(IXJCTL_READ_WAIT):
+	case IOCTL_NR(IXJCTL_WRITE_WAIT):
+	case IOCTL_NR(IXJCTL_DRYBUFFER_READ):
+	case IOCTL_NR(I2OHRTGET):
+	case IOCTL_NR(I2OLCTGET):
+	case IOCTL_NR(I2OPARMSET):
+	case IOCTL_NR(I2OPARMGET):
+	case IOCTL_NR(I2OSWDL):
+	case IOCTL_NR(I2OSWUL):
+	case IOCTL_NR(I2OSWDEL):
+	case IOCTL_NR(I2OHTML):
+		break;
 	default:
 		return(sys_ioctl(fd, cmd, (unsigned long)arg));
 
 	}
+	printk("%x:unimplemented IA32 ioctl system call\n", cmd);
+	return(-EINVAL);
 }
diff -urN linux-davidm/arch/ia64/ia32/ia32_traps.c lia64/arch/ia64/ia32/ia32_traps.c
--- linux-davidm/arch/ia64/ia32/ia32_traps.c	Thu Jun 22 07:09:44 2000
+++ lia64/arch/ia64/ia32/ia32_traps.c	Mon Oct 30 22:30:04 2000
@@ -119,6 +119,6 @@
 	      default:
 		return -1;
 	}
-	force_sig_info(SIGTRAP, &siginfo, current);
+	force_sig_info(siginfo.si_signo, &siginfo, current);
 	return 0;
 }
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c lia64/arch/ia64/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/ia32/sys_ia32.c	Mon Oct 30 22:32:34 2000
@@ -236,8 +236,6 @@
 
 	if (OFFSET4K(addr) || OFFSET4K(off))
 		return -EINVAL;
-	if (prot & PROT_WRITE)
-		prot |= PROT_EXEC;
 	prot |= PROT_WRITE;
 	front = NULL;
 	back = NULL;
@@ -287,23 +285,20 @@
 	unsigned int poff;
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+	prot |= PROT_EXEC;
 
  	if ((flags & MAP_FIXED) && ((addr & ~PAGE_MASK) || (offset & ~PAGE_MASK)))
  		error = do_mmap_fake(file, addr, len, prot, flags, (loff_t)offset);
- 	else if (!addr && (offset & ~PAGE_MASK)) {
+	else {
  		poff = offset & PAGE_MASK;
  		len += offset - poff;
 
  		down(&current->mm->mmap_sem);
- 		error = do_mmap(file, addr, len, prot, flags, poff);
+ 		error = do_mmap_pgoff(file, addr, len, prot, flags, poff >> PAGE_SHIFT);
   		up(&current->mm->mmap_sem);
 
  		if (!IS_ERR((void *) error))
  			error += offset - poff;
- 	} else {
-  		down(&current->mm->mmap_sem);
-  		error = do_mmap(file, addr, len, prot, flags, offset);
- 		up(&current->mm->mmap_sem);
  	}
 	return error;
 }
@@ -2032,14 +2027,14 @@
 	ret = sys_times(tbuf ? &t : NULL);
 	set_fs (old_fs);
 	if (tbuf) {
-		err = put_user (t.tms_utime, &tbuf->tms_utime);
-		err |= __put_user (t.tms_stime, &tbuf->tms_stime);
-		err |= __put_user (t.tms_cutime, &tbuf->tms_cutime);
-		err |= __put_user (t.tms_cstime, &tbuf->tms_cstime);
+		err = put_user (IA32_TICK(t.tms_utime), &tbuf->tms_utime);
+		err |= __put_user (IA32_TICK(t.tms_stime), &tbuf->tms_stime);
+		err |= __put_user (IA32_TICK(t.tms_cutime), &tbuf->tms_cutime);
+		err |= __put_user (IA32_TICK(t.tms_cstime), &tbuf->tms_cstime);
 		if (err)
 			ret = -EFAULT;
 	}
-	return ret;
+	return IA32_TICK(ret);
 }
 
 unsigned int
@@ -2617,6 +2612,45 @@
 	 *	manipulating the page protections...
 	 */
 	return(sys_iopl(3, 0, 0, 0));
+}
+
+typedef struct {
+	unsigned int	ss_sp;
+	unsigned int	ss_flags;
+	unsigned int	ss_size;
+} ia32_stack_t;
+
+asmlinkage long
+sys32_sigaltstack (const ia32_stack_t *uss32, ia32_stack_t *uoss32,
+long arg2, long arg3, long arg4,
+long arg5, long arg6, long arg7,
+long stack)
+{
+	struct pt_regs *pt = (struct pt_regs *) &stack;
+	stack_t uss, uoss;
+	ia32_stack_t buf32;
+	int ret;
+	mm_segment_t old_fs = get_fs();
+
+	if (uss32)
+		if (copy_from_user(&buf32, (void *)A(uss32), sizeof(ia32_stack_t)))
+			return(-EFAULT);
+	uss.ss_sp = buf32.ss_sp;
+	uss.ss_flags = buf32.ss_flags;
+	uss.ss_size = buf32.ss_size;
+	set_fs(KERNEL_DS);
+	ret = do_sigaltstack(uss32 ? &uss : NULL, &uoss, pt->r12);
+	set_fs(old_fs);
+	if (ret < 0)
+		return(ret);
+	if (uoss32) {
+		buf32.ss_sp = uoss.ss_sp;
+		buf32.ss_flags = uoss.ss_flags;
+		buf32.ss_size = uoss.ss_size;
+		if (copy_to_user((void*)A(uoss32), &buf32, sizeof(ia32_stack_t)))
+			return(-EFAULT);
+	}
+	return(ret);
 }
 
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
diff -urN linux-davidm/arch/ia64/kernel/Makefile lia64/arch/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/Makefile	Mon Oct 30 22:33:15 2000
@@ -13,7 +13,8 @@
 	 machvec.o pal.o pci-dma.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
 
-obj-$(CONFIG_IA64_GENERIC) += machvec.o
+obj-$(CONFIG_IA64_GENERIC) += machvec.o iosapic.o
+obj-$(CONFIG_IA64_DIG) += iosapic.o
 obj-$(CONFIG_IA64_PALINFO) += palinfo.o
 obj-$(CONFIG_PCI) += pci.o
 obj-$(CONFIG_SMP) += smp.o smpboot.o
@@ -21,7 +22,7 @@
 obj-$(CONFIG_IA64_BRL_EMU) += brl_emu.o
 
 O_TARGET := kernel.o
-O_OBJS	 :=  $(obj-y)
+O_OBJS	 := $(obj-y)
 OX_OBJS  := ia64_ksyms.o
 
 clean::
diff -urN linux-davidm/arch/ia64/kernel/acpi.c lia64/arch/ia64/kernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/acpi.c	Mon Oct 30 22:33:27 2000
@@ -6,6 +6,8 @@
  * 
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
+ * Copyright (C) 2000 Hewlett-Packard Co.
+ * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 #include <linux/config.h>
@@ -36,11 +38,14 @@
 
 void (*pm_idle)(void);
 
+asm (".weak iosapic_register_legacy_irq");
+asm (".weak iosapic_init");
+
 /*
  * Identify usable CPU's and remember them for SMP bringup later.
  */
 static void __init
-acpi_lsapic(char *p) 
+acpi_lsapic (char *p) 
 {
 	int add = 1;
 
@@ -58,7 +63,7 @@
 		printk("Performance Restricted; ignoring.\n");
 		add = 0;
 	}
-	
+
 #ifdef CONFIG_SMP
 	smp_boot_data.cpu_phys_id[total_cpus] = -1;
 #endif
@@ -73,83 +78,40 @@
 }
 
 /*
- * Configure legacy IRQ information in iosapic_vector
+ * Configure legacy IRQ information.
  */
 static void __init
-acpi_legacy_irq(char *p)
+acpi_legacy_irq (char *p)
 {
-	/*
-	 * This is not good.  ACPI is not necessarily limited to CONFIG_IA64_DIG, yet
-	 * ACPI does not necessarily imply IOSAPIC either.  Perhaps there should be
-	 * a means for platform_setup() to register ACPI handlers?
-	 */
-#ifdef CONFIG_IA64_IRQ_ACPI
 	acpi_entry_int_override_t *legacy = (acpi_entry_int_override_t *) p;
-	unsigned char vector; 
-	int i;
-
-	vector = isa_irq_to_vector(legacy->isa_irq);
+	unsigned long polarity = 0, edge_triggered = 0;
 
 	/*
-	 * Clobber any old pin mapping.  It may be that it gets replaced later on
+	 * If the platform we're running doesn't define
+	 * iosapic_register_legacy_irq(), we ignore this info...
 	 */
-	for (i = 0; i < IA64_MAX_VECTORED_IRQ; i++) {
-		if (i = vector) 
-			continue;
-		if (iosapic_pin(i) = iosapic_pin(vector))
-			iosapic_pin(i) = 0xff;
-        }
-
-	iosapic_pin(vector) = legacy->pin;
-	iosapic_bus(vector) = BUS_ISA;	/* This table only overrides the ISA devices */
-	iosapic_busdata(vector) = 0;
-	
-	/* 
-	 * External timer tick is special... 
-	 */
-	if (vector != TIMER_IRQ)
-		iosapic_dmode(vector) = IO_SAPIC_LOWEST_PRIORITY;
-	else 
-		iosapic_dmode(vector) = IO_SAPIC_FIXED;
-	
+	if (!iosapic_register_legacy_irq)
+		return;
+
 	/* See MPS 1.4 section 4.3.4 */
 	switch (legacy->flags) {
-	case 0x5:
-		iosapic_polarity(vector) = IO_SAPIC_POL_HIGH;
-		iosapic_trigger(vector) = IO_SAPIC_EDGE;
-		break;
-	case 0x8:
-		iosapic_polarity(vector) = IO_SAPIC_POL_LOW;
-		iosapic_trigger(vector) = IO_SAPIC_EDGE;
-		break;
-	case 0xd:
-		iosapic_polarity(vector) = IO_SAPIC_POL_HIGH;
-		iosapic_trigger(vector) = IO_SAPIC_LEVEL;
-		break;
-	case 0xf:
-		iosapic_polarity(vector) = IO_SAPIC_POL_LOW;
-		iosapic_trigger(vector) = IO_SAPIC_LEVEL;
-		break;
-	default:
+	      case 0x5:	polarity = 1; edge_triggered = 1; break;
+	      case 0x8: polarity = 0; edge_triggered = 1; break;
+	      case 0xd: polarity = 1; edge_triggered = 0; break;
+	      case 0xf: polarity = 0; edge_triggered = 0; break;
+	      default:
 		printk("    ACPI Legacy IRQ 0x%02x: Unknown flags 0x%x\n", legacy->isa_irq,
 		       legacy->flags);
 		break;
 	}
-
-# ifdef ACPI_DEBUG
-	printk("Legacy ISA IRQ %x -> IA64 Vector %x IOSAPIC Pin %x Active %s %s Trigger\n", 
-	       legacy->isa_irq, vector, iosapic_pin(vector), 
-	       ((iosapic_polarity(vector) = IO_SAPIC_POL_LOW) ? "Low" : "High"),
-	       ((iosapic_trigger(vector) = IO_SAPIC_LEVEL) ? "Level" : "Edge"));
-# endif /* ACPI_DEBUG */
-#endif /* CONFIG_IA64_IRQ_ACPI */
+	iosapic_register_legacy_irq(legacy->isa_irq, legacy->pin, polarity, edge_triggered);
 }
 
 /*
  * Info on platform interrupt sources: NMI. PMI, INIT, etc.
  */
 static void __init
-acpi_platform(char *p)
+acpi_platform (char *p)
 {
 	acpi_entry_platform_src_t *plat = (acpi_entry_platform_src_t *) p;
 
@@ -161,8 +123,9 @@
  * Parse the ACPI Multiple SAPIC Table
  */
 static void __init
-acpi_parse_msapic(acpi_sapic_t *msapic)
+acpi_parse_msapic (acpi_sapic_t *msapic)
 {
+	acpi_entry_iosapic_t *iosapic;
 	char *p, *end;
 
 	/* Base address of IPI Message Block */
@@ -172,41 +135,31 @@
 	end = p + (msapic->header.length - sizeof(acpi_sapic_t));
 
 	while (p < end) {
-		
 		switch (*p) {
-		case ACPI_ENTRY_LOCAL_SAPIC:
+		      case ACPI_ENTRY_LOCAL_SAPIC:
 			acpi_lsapic(p);
 			break;
 	
-		case ACPI_ENTRY_IO_SAPIC:
-			platform_register_iosapic((acpi_entry_iosapic_t *) p);
+		      case ACPI_ENTRY_IO_SAPIC:
+			iosapic = (acpi_entry_iosapic_t *) p;
+			if (iosapic_init)
+				iosapic_init(iosapic->address, iosapic->irq_base);
 			break;
 
-		case ACPI_ENTRY_INT_SRC_OVERRIDE:
+		      case ACPI_ENTRY_INT_SRC_OVERRIDE:
 			acpi_legacy_irq(p);
 			break;
-		
-		case ACPI_ENTRY_PLATFORM_INT_SOURCE:
+
+		      case ACPI_ENTRY_PLATFORM_INT_SOURCE:
 			acpi_platform(p);
 			break;
-		
-		default:
+
+		      default:
 			break;
 		}
 
 		/* Move to next table entry. */
-#define BAD_ACPI_TABLE
-#ifdef BAD_ACPI_TABLE
-		/*
-		 * Some prototype Lion's have a bad ACPI table
-		 * requiring this fix.  Without this fix, those
-		 * machines crash during bootup.
-		 */
-		if (p[1] = 0)
-			p = end;
-		else
-#endif
-			p += p[1];
+		p += p[1];
 	}
 
 	/* Make bootup pretty */
@@ -214,7 +167,7 @@
 }
 
 int __init 
-acpi_parse(acpi_rsdp_t *rsdp)
+acpi_parse (acpi_rsdp_t *rsdp)
 {
 	acpi_rsdt_t *rsdt;
 	acpi_desc_table_hdr_t *hdrp;
@@ -256,7 +209,7 @@
 	}
 
 #ifdef CONFIG_ACPI_KERNEL_CONFIG
-       acpi_cf_terminate();
+	acpi_cf_terminate();
 #endif
 
 #ifdef CONFIG_SMP
diff -urN linux-davidm/arch/ia64/kernel/efi.c lia64/arch/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/efi.c	Mon Oct 30 22:33:51 2000
@@ -363,7 +363,7 @@
 #if EFI_DEBUG
 	/* print EFI memory map: */
 	{
-		efi_memory_desc_t *md = p;
+		efi_memory_desc_t *md;
 		void *p;
 
 		for (i = 0, p = efi_map_start; p < efi_map_end; ++i, p += efi_desc_size) {
diff -urN linux-davidm/arch/ia64/kernel/head.S lia64/arch/ia64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/head.S	Mon Oct 30 22:34:49 2000
@@ -74,8 +74,8 @@
 	;;
 
 #ifdef CONFIG_IA64_EARLY_PRINTK
-	mov r2=6
-	mov r3=(8<<8) | (28<<2)
+	mov r3=(6<<8) | (28<<2)
+	movl r2=6<<61
 	;;
 	mov rr[r2]=r3
 	;;
@@ -181,7 +181,8 @@
 
 GLOBAL_ENTRY(ia64_load_debug_regs)
 	alloc r16=ar.pfs,1,0,0,0
-#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
+   || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPECIFIC))
 	lfetch.nta [in0]
 #endif
 	mov r20=ar.lc			// preserve ar.lc
@@ -754,7 +755,7 @@
 	mov tmp=ar.itc
 (p15)	br.cond.sptk .wait
 	;;
-	ld1 tmp=[r31]
+	ld4 tmp=[r31]
 	;;
 	cmp.ne p15,p0=tmp,r0
 	mov tmp=ar.itc
@@ -764,7 +765,7 @@
 	mov tmp=1
 	;;
 	IA64_SEMFIX_INSN
-	cmpxchg1.acq tmp=[r31],tmp,ar.ccv
+	cmpxchg4.acq tmp=[r31],tmp,ar.ccv
 	;;
 	cmp.eq p15,p0=tmp,r0
 
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c lia64/arch/ia64/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Wed Dec 31 16:00:00 1969
+++ lia64/arch/ia64/kernel/iosapic.c	Mon Oct 30 22:28:42 2000
@@ -0,0 +1,495 @@
+/*
+ * I/O SAPIC support.
+ *
+ * Copyright (C) 1999 Intel Corp.
+ * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
+ * Copyright (C) 1999-2000 Hewlett-Packard Co.
+ * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 VA Linux Systems
+ * Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
+ *
+ * 00/04/19	D. Mosberger	Rewritten to mirror more closely the x86 I/O APIC code.
+ *				In particular, we now have separate handlers for edge
+ *				and level triggered interrupts.
+ * 00/10/27	Asit Mallick, Goutham Rao <goutham.rao@intel.com> IRQ vector allocation 
+ *				PCI to vector mapping, shared PCI interrupts.
+ * 00/10/27	D. Mosberger	Document things a bit more to make them more understandable.
+ *				Clean up much of the old IOSAPIC cruft.
+ */
+/*
+ * Here is what the interrupt logic between a PCI device and the CPU looks like:
+ *
+ * (1) A PCI device raises one of the four interrupt pins (INTA, INTB, INTC, INTD).  The
+ *     device is uniquely identified by its bus-, device-, and slot-number (the function
+ *     number does not matter here because all functions share the same interrupt
+ *     lines).
+ *
+ * (2) The motherboard routes the interrupt line to a pin on a IOSAPIC controller.
+ *     Multiple interrupt lines may have to share the same IOSAPIC pin (if they're level
+ *     triggered and use the same polarity).  Each interrupt line has a unique IOSAPIC
+ *     irq number which can be calculated as the sum of the controller's base irq number
+ *     and the IOSAPIC pin number to which the line connects.
+ *
+ * (3) The IOSAPIC uses an internal table to map the IOSAPIC pin into the IA-64 interrupt
+ *     vector.  This interrupt vector is then sent to the CPU.
+ *
+ * In other words, there are two levels of indirections involved:
+ *
+ *	pci pin -> iosapic irq -> IA-64 vector
+ *
+ * Note: outside this module, IA-64 vectors are called "irqs".  This is because that's
+ * the traditional name Linux uses for interrupt vectors.
+ */
+#include <linux/config.h>
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/smp.h>
+#include <linux/smp_lock.h>
+#include <linux/string.h>
+#include <linux/irq.h>
+
+#include <asm/acpi-ext.h>
+#include <asm/delay.h>
+#include <asm/io.h>
+#include <asm/iosapic.h>
+#include <asm/machvec.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+
+#ifdef	CONFIG_ACPI_KERNEL_CONFIG
+# include <asm/acpikcfg.h>
+#endif
+
+#undef DEBUG_IRQ_ROUTING
+
+static spinlock_t iosapic_lock = SPIN_LOCK_UNLOCKED;
+
+/* PCI pin to IOSAPIC irq routing information.  This info typically comes from ACPI. */
+
+static struct {
+	int num_routes;
+	struct pci_vector_struct *route;
+} pci_irq;
+
+/* This tables maps IA-64 vectors to the IOSAPIC pin that generates this vector. */
+
+static struct iosapic_irq {
+	char *addr;			/* base address of IOSAPIC */
+	unsigned char base_irq;		/* first irq assigned to this IOSAPIC */
+        char pin;			/* IOSAPIC pin (-1 => not an IOSAPIC irq) */
+	unsigned char dmode 	: 3;	/* delivery mode (see iosapic.h) */
+	unsigned char polarity	: 1;	/* interrupt polarity (see iosapic.h) */
+	unsigned char trigger	: 1;	/* trigger mode (see iosapic.h) */
+} iosapic_irq[NR_IRQS];
+
+/*
+ * Translate IOSAPIC irq number to the corresponding IA-64 interrupt vector.  If no
+ * entry exists, return -1.
+ */
+static int 
+iosapic_irq_to_vector (int irq)
+{
+	int vector;
+
+	for (vector = 0; vector < NR_IRQS; ++vector)
+		if (iosapic_irq[vector].base_irq + iosapic_irq[vector].pin = irq)
+			return vector;
+	return -1;
+}
+		
+/*
+ * Map PCI pin to the corresponding IA-64 interrupt vector.  If no such mapping exists,
+ * return -1.
+ */
+static int
+pci_pin_to_vector (int bus, int slot, int pci_pin)
+{
+	struct pci_vector_struct *r;
+
+	for (r = pci_irq.route; r < pci_irq.route + pci_irq.num_routes; ++r)
+		if (r->bus = bus && (r->pci_id >> 16) = slot && r->pin = pci_pin)
+			return iosapic_irq_to_vector(r->irq);
+	return -1;
+}
+
+static void
+set_rte (unsigned int vector, unsigned long dest)
+{
+	unsigned long pol, trigger, dmode;
+	u32 low32, high32;
+	char *addr;
+	int pin;
+
+	pin = iosapic_irq[vector].pin;
+	if (pin < 0)
+		return;		/* not an IOSAPIC interrupt */
+
+	addr    = iosapic_irq[vector].addr;
+	pol     = iosapic_irq[vector].polarity;
+	trigger = iosapic_irq[vector].trigger;
+	dmode   = iosapic_irq[vector].dmode;
+
+	low32 = ((pol << IOSAPIC_POLARITY_SHIFT) |
+		 (trigger << IOSAPIC_TRIGGER_SHIFT) |
+		 (dmode << IOSAPIC_DELIVERY_SHIFT) |
+		 vector);
+
+#ifdef CONFIG_IA64_AZUSA_HACKS
+	/* set Flush Disable bit */
+	if (addr != (char *) 0xc0000000fec00000)
+		low32 |= (1 << 17);
+#endif
+
+	/* dest contains both id and eid */
+	high32 = (dest << IOSAPIC_DEST_SHIFT);	
+
+	writel(IOSAPIC_RTE_HIGH(pin), addr + IOSAPIC_REG_SELECT);
+	writel(high32, addr + IOSAPIC_WINDOW);
+	writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+	writel(low32, addr + IOSAPIC_WINDOW);
+}
+
+static void
+nop (unsigned int vector)
+{
+	/* do nothing... */
+}
+
+static void 
+mask_irq (unsigned int vector)
+{
+	unsigned long flags;
+	char *addr;
+	u32 low32;
+	int pin;
+
+	addr = iosapic_irq[vector].addr;
+	pin = iosapic_irq[vector].pin;
+
+	if (pin < 0)
+		return;			/* not an IOSAPIC interrupt! */
+
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		low32 = readl(addr + IOSAPIC_WINDOW);
+
+		low32 |= (1 << IOSAPIC_MASK_SHIFT);    /* set only the mask bit */
+		writel(low32, addr + IOSAPIC_WINDOW);
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
+}
+
+static void 
+unmask_irq (unsigned int vector)
+{
+	unsigned long flags;
+	char *addr;
+	u32 low32;
+	int pin;
+
+	addr = iosapic_irq[vector].addr;
+	pin = iosapic_irq[vector].pin;
+	if (pin < 0)
+		return;			/* not an IOSAPIC interrupt! */
+
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		low32 = readl(addr + IOSAPIC_WINDOW);
+
+		low32 &= ~(1 << IOSAPIC_MASK_SHIFT);    /* clear only the mask bit */
+		writel(low32, addr + IOSAPIC_WINDOW);
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
+}
+
+
+static void
+iosapic_set_affinity (unsigned int vector, unsigned long mask)
+{
+	printk("iosapic_set_affinity: not implemented yet\n");
+}
+
+/*
+ * Handlers for level-triggered interrupts.
+ */
+
+static unsigned int
+iosapic_startup_level_irq (unsigned int vector)
+{
+	unmask_irq(vector);
+	return 0;
+}
+
+static void
+iosapic_end_level_irq (unsigned int vector)
+{
+	writel(vector, iosapic_irq[vector].addr + IOSAPIC_EOI);
+}
+
+#define iosapic_shutdown_level_irq	mask_irq
+#define iosapic_enable_level_irq	unmask_irq
+#define iosapic_disable_level_irq	mask_irq
+#define iosapic_ack_level_irq		nop
+
+struct hw_interrupt_type irq_type_iosapic_level = {
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
+iosapic_startup_edge_irq (unsigned int vector)
+{
+	unmask_irq(vector);
+	/*
+	 * IOSAPIC simply drops interrupts pended while the
+	 * corresponding pin was masked, so we can't know if an
+	 * interrupt is pending already.  Let's hope not...
+	 */
+	return 0;
+}
+
+static void
+iosapic_ack_edge_irq (unsigned int vector)
+{
+	/*
+	 * Once we have recorded IRQ_PENDING already, we can mask the
+	 * interrupt for real. This prevents IRQ storms from unhandled
+	 * devices.
+	 */
+	if ((irq_desc[vector].status & (IRQ_PENDING|IRQ_DISABLED)) = (IRQ_PENDING|IRQ_DISABLED))
+		mask_irq(vector);
+}
+
+#define iosapic_enable_edge_irq		unmask_irq
+#define iosapic_disable_edge_irq	nop
+#define iosapic_end_edge_irq		nop
+
+struct hw_interrupt_type irq_type_iosapic_edge = {
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
+static unsigned int
+iosapic_version (char *addr) 
+{
+	/*
+	 * IOSAPIC Version Register return 32 bit structure like:
+	 * {
+	 *	unsigned int version   : 8;
+	 *	unsigned int reserved1 : 8;
+	 *	unsigned int pins      : 8;
+	 *	unsigned int reserved2 : 8;
+	 * }
+	 */
+	writel(IOSAPIC_VERSION, addr + IOSAPIC_REG_SELECT);
+	return readl(IOSAPIC_WINDOW + addr);
+}
+
+/*
+ * ACPI calls this when it finds an entry for a legacy ISA interrupt.  Note that the
+ * irq_base and IOSAPIC address must be set in iosapic_init().
+ */
+void
+iosapic_register_legacy_irq (unsigned long irq,
+			     unsigned long pin, unsigned long polarity,
+			     unsigned long edge_triggered)
+{
+	unsigned int vector = isa_irq_to_vector(irq);
+
+#ifdef DEBUG_IRQ_ROUTING
+	printk("ISA: IRQ %u -> IOSAPIC irq 0x%02x (%s, %s) -> vector %02x\n",
+	       (unsigned) irq, (unsigned) pin,
+	       polarity ? "high" : "low", edge_triggered ? "edge" : "level",
+	       vector);
+#endif
+
+	iosapic_irq[vector].pin = pin;
+	iosapic_irq[vector].dmode = IOSAPIC_LOWEST_PRIORITY;
+	iosapic_irq[vector].polarity = polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW;
+	iosapic_irq[vector].trigger = edge_triggered ? IOSAPIC_EDGE : IOSAPIC_LEVEL;
+}
+
+void __init
+iosapic_init (unsigned long phys_addr, unsigned int base_irq)
+{
+	struct hw_interrupt_type *irq_type;
+	int i, irq, max_pin, vector;
+	unsigned int ver;
+	char *addr;
+	static int first_time = 1;
+
+	if (first_time) {
+		first_time = 0;
+
+		for (vector = 0; vector < NR_IRQS; ++vector)
+			iosapic_irq[vector].pin = -1;	/* mark as unused */
+
+		/* 
+		 * Fetch the PCI interrupt routing table:
+		 */
+#ifdef CONFIG_ACPI_KERNEL_CONFIG
+		acpi_cf_get_pci_vectors(&pci_irq.route, &pci_irq.num_routes);
+#else
+		pci_irq.route +			(struct pci_vector_struct *) __va(ia64_boot_param.pci_vectors);
+		pci_irq.num_routes = ia64_boot_param.num_pci_vectors;
+#endif
+	}
+
+	addr = ioremap(phys_addr, 0);
+
+	ver = iosapic_version(addr);
+	max_pin = (ver >> 16) & 0xff;
+	
+	printk("IOSAPIC: version %x.%x, address 0x%lx, IRQs 0x%02x-0x%02x\n", 
+	       (ver & 0xf0) >> 4, (ver & 0x0f), phys_addr, base_irq, base_irq + max_pin);
+
+	if (base_irq = 0)
+		/*
+		 * Map the legacy ISA devices into the IOSAPIC data.  Some of these may
+		 * get reprogrammed later on with data from the ACPI Interrupt Source
+		 * Override table.
+		 */
+		for (irq = 0; irq < 16; ++irq) {
+			vector = isa_irq_to_vector(irq);
+			iosapic_irq[vector].addr = addr;
+			iosapic_irq[vector].base_irq = 0;
+			if (iosapic_irq[vector].pin = -1)
+				iosapic_irq[vector].pin = irq;
+			iosapic_irq[vector].dmode = IOSAPIC_LOWEST_PRIORITY;
+			iosapic_irq[vector].trigger  = IOSAPIC_EDGE;
+			iosapic_irq[vector].polarity = IOSAPIC_POL_HIGH;
+#ifdef DEBUG_IRQ_ROUTING
+			printk("ISA: IRQ %u -> IOSAPIC irq 0x%02x (high, edge) -> vector 0x%02x\n",
+			       irq, iosapic_irq[vector].base_irq + iosapic_irq[vector].pin,
+			       vector);
+#endif
+		  	irq_type = &irq_type_iosapic_edge;
+			if (irq_desc[vector].handler != irq_type) {
+				if (irq_desc[vector].handler != &no_irq_type)
+					printk("iosapic_init: changing vector 0x%02x from %s to "
+					       "%s\n", irq, irq_desc[vector].handler->typename,
+					       irq_type->typename);
+				irq_desc[vector].handler = irq_type;
+			}
+
+			/* program the IOSAPIC routing table: */
+			set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+		}
+
+#ifndef CONFIG_IA64_SOFTSDV_HACKS
+	for (i = 0; i < pci_irq.num_routes; i++) {
+		irq = pci_irq.route[i].irq;
+
+		if ((unsigned) (irq - base_irq) > max_pin)
+			/* the interrupt route is for another controller... */
+			continue;
+
+		if (irq < 16)
+			vector = isa_irq_to_vector(irq);
+		else {
+			vector = iosapic_irq_to_vector(irq);
+			if (vector < 0)
+				/* new iosapic irq: allocate a vector for it */
+				vector = ia64_alloc_irq();
+		}
+
+		iosapic_irq[vector].addr     = addr;
+		iosapic_irq[vector].base_irq = base_irq;
+		iosapic_irq[vector].pin	     = (irq - base_irq);
+		iosapic_irq[vector].dmode    = IOSAPIC_LOWEST_PRIORITY;
+		iosapic_irq[vector].trigger  = IOSAPIC_LEVEL;
+		iosapic_irq[vector].polarity = IOSAPIC_POL_LOW;
+
+# ifdef DEBUG_IRQ_ROUTING
+		printk("PCI: (B%d,I%d,P%d) -> IOSAPIC irq 0x%02x -> vector 0x%02x\n",
+		       pci_irq.route[i].bus, pci_irq.route[i].pci_id>>16, pci_irq.route[i].pin,
+		       iosapic_irq[vector].base_irq + iosapic_irq[vector].pin, vector);
+# endif
+		irq_type = &irq_type_iosapic_level;
+		if (irq_desc[vector].handler != irq_type){
+			if (irq_desc[vector].handler != &no_irq_type)
+				printk("iosapic_init: changing vector 0x%02x from %s to %s\n",
+				       vector, irq_desc[vector].handler->typename,
+				       irq_type->typename);
+			irq_desc[vector].handler = irq_type;
+		}
+
+		/* program the IOSAPIC routing table: */
+		set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+	}
+#endif /* !CONFIG_IA64_SOFTSDV_HACKS */
+}
+
+void
+iosapic_pci_fixup (void)
+{
+	struct	pci_dev	*dev;
+	unsigned char pin;
+	int vector;
+
+	pci_for_each_dev(dev) {
+		pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pin);
+		if (pin) {
+			pin--;          /* interrupt pins are numbered starting from 1 */
+			vector = pci_pin_to_vector(dev->bus->number, PCI_SLOT(dev->devfn), pin);
+			if (vector < 0 && dev->bus->parent) {
+				/* go back to the bridge */
+				struct pci_dev *bridge = dev->bus->self;
+
+				if (bridge) {
+					/* allow for multiple bridges on an adapter */
+					do {
+						/* do the bridge swizzle... */
+						pin = (pin + PCI_SLOT(dev->devfn)) % 4;
+						vector = pci_pin_to_vector(bridge->bus->number,
+									   PCI_SLOT(bridge->devfn),
+									   pin);
+					} while (vector < 0 && (bridge = bridge->bus->self));
+				}
+				if (vector >= 0)
+					printk(KERN_WARNING
+					       "PCI: using PPB(B%d,I%d,P%d) to get vector %02x\n",
+					       bridge->bus->number, PCI_SLOT(bridge->devfn),
+					       pin, vector);
+				else
+					printk(KERN_WARNING
+					       "PCI: Couldn't map irq for (B%d,I%d,P%d)o\n",
+					       bridge->bus->number, PCI_SLOT(bridge->devfn),
+					       pin);
+			}
+			if (vector >= 0) {
+				printk("PCI->APIC IRQ transform: (B%d,I%d,P%d) -> 0x%02x\n",
+				       dev->bus->number, PCI_SLOT(dev->devfn), pin, vector);
+				dev->irq = vector;
+			}
+		}
+		/*
+		 * Nothing to fixup
+		 * Fix out-of-range IRQ numbers
+		 */
+		if (dev->irq >= NR_IRQS)
+			dev->irq = 15;	/* Spurious interrupts */
+	}
+}
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c lia64/arch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/irq_ia64.c	Mon Oct 30 22:35:56 2000
@@ -7,6 +7,9 @@
  *
  *  6/10/99: Updated to bring in sync with x86 version to facilitate
  *	     support for SMP and different interrupt controllers.
+ *
+ * 09/15/00 Goutham Rao <goutham.rao@intel.com> Implemented pci_irq_to_vector
+ *                      PCI to vector allocation routine.
  */
 
 #include <linux/config.h>
@@ -43,15 +46,25 @@
 unsigned long ipi_base_addr = (__IA64_UNCACHED_OFFSET | IPI_DEFAULT_BASE_ADDR);	
 
 /*
- * Legacy IRQ to IA-64 vector translation table.  Any vector not in
- * this table maps to itself (ie: irq 0x30 => IA64 vector 0x30)
+ * Legacy IRQ to IA-64 vector translation table.
  */
 __u8 isa_irq_to_vector_map[16] = {
 	/* 8259 IRQ translation, first 16 entries */
-	0x60, 0x50, 0x10, 0x51, 0x52, 0x53, 0x43, 0x54,
-	0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x40, 0x41
+	0x2f, 0x20, 0x2e, 0x2d, 0x2c, 0x2b, 0x2a, 0x29,
+	0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21
 };
 
+int
+ia64_alloc_irq (void)
+{
+	static int next_irq = FIRST_DEVICE_IRQ;
+
+	if (next_irq > LAST_DEVICE_IRQ)
+		/* XXX could look for sharable vectors instead of panic'ing... */
+		panic("ia64_alloc_irq: out of interrupt vectors!");
+	return next_irq++;
+}
+
 #ifdef CONFIG_ITANIUM_A1_SPECIFIC
 
 int usbfix;
@@ -217,7 +230,7 @@
 }
 
 void
-ipi_send (int cpu, int vector, int delivery_mode, int redirect)
+ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect)
 {
 	unsigned long ipi_addr;
 	unsigned long ipi_data;
diff -urN linux-davidm/arch/ia64/kernel/ivt.S lia64/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/ivt.S	Tue Oct 31 00:02:02 2000
@@ -924,7 +924,7 @@
 	alloc r15=ar.pfs,0,0,6,0	// must first in an insn group
 	;; 
 	ld4 r8=[r14],8          // r8 = EAX (syscall number)
-	mov r150		// sys_vfork - last implemented system call
+	mov r15"2		// sys_vfork - last implemented system call
 	;;
 	cmp.leu.unc p6,p7=r8,r15
 	ld4 out1=[r14],8        // r9 = ecx
diff -urN linux-davidm/arch/ia64/kernel/mca.c lia64/arch/ia64/kernel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/mca.c	Mon Oct 30 23:56:26 2000
@@ -19,6 +19,7 @@
 #include <linux/irq.h>
 #include <linux/smp_lock.h>
 
+#include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
@@ -365,7 +366,7 @@
 void
 ia64_mca_wakeup(int cpu)
 {
-	ipi_send(cpu, IA64_MCA_WAKEUP_INT_VECTOR, IA64_IPI_DM_INT, 0);
+	ia64_send_ipi(cpu, IA64_MCA_WAKEUP_INT_VECTOR, IA64_IPI_DM_INT, 0);
 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
 	
 }
diff -urN linux-davidm/arch/ia64/kernel/pci.c lia64/arch/ia64/kernel/pci.c
--- linux-davidm/arch/ia64/kernel/pci.c	Thu Jun 22 07:09:44 2000
+++ lia64/arch/ia64/kernel/pci.c	Mon Oct 30 22:36:54 2000
@@ -56,7 +56,8 @@
 
 /* Macro to build a PCI configuration address to be passed as a parameter to SAL. */
 
-#define PCI_CONFIG_ADDRESS(dev, where) (((u64) dev->bus->number << 16) | ((u64) (dev->devfn & 0xff) << 8) | (where & 0xff))
+#define PCI_CONFIG_ADDRESS(dev, where) \
+	(((u64) dev->bus->number << 16) | ((u64) (dev->devfn & 0xff) << 8) | (where & 0xff))
 
 static int 
 pci_conf_read_config_byte(struct pci_dev *dev, int where, u8 *value)
@@ -109,7 +110,6 @@
 	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS(dev, where), 4, value);
 }
 
-
 static struct pci_ops pci_conf = {
       pci_conf_read_config_byte,
       pci_conf_read_config_word,
@@ -120,35 +120,18 @@
 };
 
 /*
- * Try to find PCI BIOS.  This will always work for IA64.
- */
-
-static struct pci_ops * __init
-pci_find_bios(void)
-{
-	return &pci_conf;
-}
-
-/*
  * Initialization. Uses the SAL interface
  */
-
-#define PCI_BUSES_TO_SCAN 255
-
 void __init 
 pcibios_init(void)
 {
+#	define PCI_BUSES_TO_SCAN 255
 	struct pci_ops *ops = NULL;
 	int i;
 
-	if ((ops = pci_find_bios()) = NULL) {
-		printk("PCI: No PCI bus detected\n");
-		return;
-	}
-
 	printk("PCI: Probing PCI hardware\n");
 	for (i = 0; i < PCI_BUSES_TO_SCAN; i++) 
-		pci_scan_bus(i, ops, NULL);
+		pci_scan_bus(i, &pci_conf, NULL);
 	platform_pci_fixup();
 	return;
 }
@@ -157,7 +140,6 @@
  *  Called after each bus is probed, but before its children
  *  are examined.
  */
-
 void __init
 pcibios_fixup_bus(struct pci_bus *b)
 {
@@ -207,7 +189,6 @@
 /*
  * PCI BIOS setup, always defaults to SAL interface
  */
-
 char * __init 
 pcibios_setup(char *str)
 {
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c lia64/arch/ia64/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/perfmon.c	Mon Oct 30 22:37:23 2000
@@ -4,18 +4,20 @@
  *
  * Originaly Written by Ganesh Venkitachalam, IBM Corp.
  * Modifications by David Mosberger-Tang, Hewlett-Packard Co.
+ * Modifications by Stephane Eranian, Hewlett-Packard Co.
  * Copyright (C) 1999 Ganesh Venkitachalam <venkitac@us.ibm.com>
  * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
  */
 
 #include <linux/config.h>
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
 #include <linux/smp_lock.h>
 #include <linux/proc_fs.h>
-#include <linux/ptrace.h>
 
 #include <asm/errno.h>
 #include <asm/hw_irq.h>
@@ -58,19 +60,51 @@
 #define MAX_PERF_COUNTER	4	/* true for Itanium, at least */
 #define PMU_FIRST_COUNTER	4	/* first generic counter */
 
-#define WRITE_PMCS_AND_START	0xa0
-#define WRITE_PMCS		0xa1
-#define READ_PMDS		0xa2
-#define STOP_PMCS		0xa3
+#define PFM_WRITE_PMCS		0xa0
+#define PFM_WRITE_PMDS		0xa1
+#define PFM_READ_PMDS		0xa2
+#define PFM_STOP		0xa3
+#define PFM_START		0xa4
+#define PFM_ENABLE		0xa5	/* unfreeze only */
+#define PFM_DISABLE		0xa6	/* freeze only */
+/* 
+ * Those 2 are just meant for debugging. I considered using sysctl() for
+ * that but it is a little bit too pervasive. This solution is at least
+ * self-contained.
+ */
+#define PFM_DEBUG_ON		0xe0	
+#define PFM_DEBUG_OFF		0xe1
+
+#ifdef CONFIG_SMP
+#define cpu_is_online(i) (cpu_online_map & (1UL << i))
+#else
+#define cpu_is_online(i)	1
+#endif
 
+#define PMC_IS_IMPL(i)		(pmu_conf.impl_regs[i>>6] & (1<< (i&~(64-1))))
+#define PMD_IS_IMPL(i)  	(pmu_conf.impl_regs[4+(i>>6)] & (1<< (i&~(64-1))))
+#define PMD_IS_COUNTER(i)	(i>=PMU_FIRST_COUNTER && i < (PMU_FIRST_COUNTER+pmu_conf.max_counters))
+#define PMC_IS_COUNTER(i)	(i>=PMU_FIRST_COUNTER && i < (PMU_FIRST_COUNTER+pmu_conf.max_counters))
 
 /*
  * this structure needs to be enhanced
  */
 typedef struct {
+	unsigned long	pfr_reg_num;	/* which register */
+	unsigned long	pfr_reg_value;	/* configuration (PMC) or initial value (PMD) */
+	unsigned long	pfr_reg_reset;	/* reset value on overflow (PMD) */
+	void		*pfr_smpl_buf;	/* pointer to user buffer for EAR/BTB */
+	unsigned long	pfr_smpl_size;	/* size of user buffer for EAR/BTB */
+	pid_t		pfr_notify_pid;	/* process to notify */
+	int		pfr_notify_sig;	/* signal for notification, 0=no notification */
+} perfmon_req_t;
+
+#if 0
+typedef struct {
 	unsigned long pmu_reg_data;	/* generic PMD register */
 	unsigned long pmu_reg_num;	/* which register number */
 } perfmon_reg_t; 
+#endif
 
 /*
  * This structure is initialize at boot time and contains
@@ -78,86 +112,141 @@
  * by PAL
  */
 typedef struct {
-	unsigned long perf_ovfl_val;	/* overflow value for generic counters */
-	unsigned long max_pmc;		/* highest PMC */
-	unsigned long max_pmd;		/* highest PMD */
-	unsigned long max_counters;	/* number of generic counter pairs (PMC/PMD) */
+	unsigned long perf_ovfl_val;	/* overflow value for generic counters   */
+	unsigned long max_counters;	/* upper limit on counter pair (PMC/PMD) */
+	unsigned long impl_regs[16];	/* buffer used to hold implememted PMC/PMD mask */
 } pmu_config_t;
 
-/* XXX will go static when ptrace() is cleaned */
-unsigned long perf_ovfl_val;	/* overflow value for generic counters */
-
 static pmu_config_t pmu_conf;
 
+/* for debug only */
+static unsigned long pfm_debug=1;	/* 0= nodebug, >0= debug output on */
+#define DBprintk(a)	{\
+	if (pfm_debug >0) { printk a; } \
+}
+
 /*
- * could optimize to avoid cache conflicts in SMP
+ * could optimize to avoid cache line conflicts in SMP
  */
-unsigned long pmds[NR_CPUS][MAX_PERF_COUNTER];
+static struct task_struct *pmu_owners[NR_CPUS];
 
-asmlinkage unsigned long
-sys_perfmonctl (int cmd, int count, void *ptr, long arg4, long arg5, long arg6, long arg7, long arg8, long stack)
+static int
+do_perfmonctl (struct task_struct *task, int cmd, int flags, perfmon_req_t *req, int count, struct pt_regs *regs)
 {
-	struct pt_regs *regs = (struct pt_regs *) &stack;
-        perfmon_reg_t tmp, *cptr = ptr;
-        unsigned long cnum;
+        perfmon_req_t tmp;
         int i;
 
         switch (cmd) {
-	      case WRITE_PMCS:           /* Writes to PMC's and clears PMDs */
-	      case WRITE_PMCS_AND_START: /* Also starts counting */
+		case PFM_WRITE_PMCS:          
+			/* we don't quite support this right now */
+			if (task != current) return -EINVAL;
+
+			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
+
+			for (i = 0; i < count; i++, req++) {
+				copy_from_user(&tmp, req, sizeof(tmp));
+
+				/* XXX needs to check validity of the data maybe */
+
+				if (!PMC_IS_IMPL(tmp.pfr_reg_num)) {
+					DBprintk((__FUNCTION__ " invalid pmc[%ld]\n", tmp.pfr_reg_num));
+					return -EINVAL;
+				}
+
+				/* XXX: for counters, need to some checks */
+				if (PMC_IS_COUNTER(tmp.pfr_reg_num)) {
+					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].sig = tmp.pfr_notify_sig;
+					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].pid = tmp.pfr_notify_pid;
+
+					DBprintk((__FUNCTION__" setting PMC[%ld] send sig %d to %d\n",tmp.pfr_reg_num, tmp.pfr_notify_sig, tmp.pfr_notify_pid));
+				}
+				ia64_set_pmc(tmp.pfr_reg_num, tmp.pfr_reg_value);
+
+				DBprintk((__FUNCTION__" setting PMC[%ld]=0x%lx\n", tmp.pfr_reg_num, tmp.pfr_reg_value));
+			}
+			/*
+			 * we have to set this here event hough we haven't necessarily started monitoring
+			 * because we may be context switched out
+			 */
+			current->thread.flags |= IA64_THREAD_PM_VALID;
+                	break;
+
+		case PFM_WRITE_PMDS:
+			/* we don't quite support this right now */
+			if (task != current) return -EINVAL;
+
+			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
+
+			for (i = 0; i < count; i++, req++) {
+				copy_from_user(&tmp, req, sizeof(tmp));
+
+				if (!PMD_IS_IMPL(tmp.pfr_reg_num)) return -EINVAL;
+
+				/* update virtualized (64bits) counter */
+				if (PMD_IS_COUNTER(tmp.pfr_reg_num)) {
+					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].val  = tmp.pfr_reg_value & ~pmu_conf.perf_ovfl_val;
+					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].rval = tmp.pfr_reg_reset;
+				}
+				/* writes to unimplemented part is ignored, so this is safe */
+				ia64_set_pmd(tmp.pfr_reg_num, tmp.pfr_reg_value);
+				/* to go away */
+				ia64_srlz_d();
+				DBprintk((__FUNCTION__" setting PMD[%ld]:  pmod.val=0x%lx pmd=0x%lx rval=0x%lx\n", tmp.pfr_reg_num, current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].val, ia64_get_pmd(tmp.pfr_reg_num),current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].rval));
+			}
+			/*
+			 * we have to set this here event hough we haven't necessarily started monitoring
+			 * because we may be context switched out
+			 */
+			current->thread.flags |= IA64_THREAD_PM_VALID;
+                	break;
+
+		case PFM_START:
+			/* we don't quite support this right now */
+			if (task != current) return -EINVAL;
 
-		if (!access_ok(VERIFY_READ, cptr, sizeof(struct perfmon_reg_t)*count))
-			return -EFAULT;
+			pmu_owners[smp_processor_id()] = current;
 
-		for (i = 0; i < count; i++, cptr++) {
+			/* will start monitoring right after rfi */
+			ia64_psr(regs)->up = 1;
 
-			copy_from_user(&tmp, cptr, sizeof(tmp));
+			/* 
+		 	 * mark the state as valid.
+		 	 * this will trigger save/restore at context switch
+		 	 */
+			current->thread.flags |= IA64_THREAD_PM_VALID;
 
-			/* XXX need to check validity of pmu_reg_num and perhaps data!! */
+			ia64_set_pmc(0, 0);
 
-			if (tmp.pmu_reg_num > pmu_conf.max_pmc || tmp.pmu_reg_num = 0) return -EFAULT;
+                	break;
 
-			ia64_set_pmc(tmp.pmu_reg_num, tmp.pmu_reg_data);
+		case PFM_ENABLE:
+			/* we don't quite support this right now */
+			if (task != current) return -EINVAL;
 
-			/* to go away */
-			if (tmp.pmu_reg_num >= PMU_FIRST_COUNTER && tmp.pmu_reg_num < PMU_FIRST_COUNTER+pmu_conf.max_counters) {
-				ia64_set_pmd(tmp.pmu_reg_num, 0);
-				pmds[smp_processor_id()][tmp.pmu_reg_num - PMU_FIRST_COUNTER] = 0;
+			pmu_owners[smp_processor_id()] = current;
 
-				printk(__FUNCTION__" setting PMC/PMD[%ld] es=0x%lx pmd[%ld]=%lx\n", tmp.pmu_reg_num, (tmp.pmu_reg_data>>8) & 0x7f, tmp.pmu_reg_num, ia64_get_pmd(tmp.pmu_reg_num));
-			} else
-				printk(__FUNCTION__" setting PMC[%ld]=0x%lx\n", tmp.pmu_reg_num, tmp.pmu_reg_data);
-		}
-
-		if (cmd = WRITE_PMCS_AND_START) {
-#if 0
-/* irrelevant with user monitors */
-			local_irq_save(flags);
-
-			dcr = ia64_get_dcr();
-			dcr |= IA64_DCR_PP;
-			ia64_set_dcr(dcr);
-
-			local_irq_restore(flags);
-#endif
+			/* 
+		 	 * mark the state as valid.
+		 	 * this will trigger save/restore at context switch
+		 	 */
+			current->thread.flags |= IA64_THREAD_PM_VALID;
 
+			/* simply unfreeze */
 			ia64_set_pmc(0, 0);
+			break;
 
-			/* will start monitoring right after rfi */
-			ia64_psr(regs)->up = 1;
-		}
-		/* 
-		 * mark the state as valid.
-		 * this will trigger save/restore at context switch
-		 */
-		current->thread.flags |= IA64_THREAD_PM_VALID;
-                break;
-
-	      case READ_PMDS:
-		if (count <= 0 || count > MAX_PERF_COUNTER)
-			return -EINVAL;
-		if (!access_ok(VERIFY_WRITE, cptr, sizeof(struct perfmon_reg_t)*count))
-			return -EFAULT;
+		case PFM_DISABLE:
+			/* we don't quite support this right now */
+			if (task != current) return -EINVAL;
+
+			/* simply unfreeze */
+			ia64_set_pmc(0, 1);
+			ia64_srlz_d();
+			break;
+
+	        case PFM_READ_PMDS:
+			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
+			if (!access_ok(VERIFY_WRITE, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
 
 		/* This looks shady, but IMHO this will work fine. This is  
 		 * the sequence that I could come up with to avoid races
@@ -187,16 +276,31 @@
 		 * is the irq_save/restore needed?
 		 */
 
+		for (i = 0; i < count; i++, req++) {
+			unsigned long val=0;
 
-		/* XXX: This needs to change to read more than just the counters */
-		for (i = 0, cnum = PMU_FIRST_COUNTER;i < count; i++, cnum++, cptr++) {
+			copy_from_user(&tmp, req, sizeof(tmp));
 
-			tmp.pmu_reg_data = (pmds[smp_processor_id()][i]
-				    + (ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val));
+			if (!PMD_IS_IMPL(tmp.pfr_reg_num)) return -EINVAL;
 
-			tmp.pmu_reg_num = cnum;
+			if (PMD_IS_COUNTER(tmp.pfr_reg_num)) {
+				if (task = current){
+					val = ia64_get_pmd(tmp.pfr_reg_num) & pmu_conf.perf_ovfl_val;
+				} else {
+					val = task->thread.pmd[tmp.pfr_reg_num - PMU_FIRST_COUNTER] & pmu_conf.perf_ovfl_val;
+				}
+				val += task->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].val;
+			} else {
+				/* for now */
+				if (task != current) return -EINVAL;
+
+				val = ia64_get_pmd(tmp.pfr_reg_num);
+			}
+			tmp.pfr_reg_value = val;
 
-			if (copy_to_user(cptr, &tmp, sizeof(tmp))) return -EFAULT;
+DBprintk((__FUNCTION__" reading PMD[%ld]=0x%lx\n", tmp.pfr_reg_num, val));
+
+			if (copy_to_user(req, &tmp, sizeof(tmp))) return -EFAULT;
 		}
 #if 0
 /* irrelevant with user monitors */
@@ -209,11 +313,18 @@
 #endif
                 break;
 
-	      case STOP_PMCS:
+	      case PFM_STOP:
+		/* we don't quite support this right now */
+		if (task != current) return -EINVAL;
+
 		ia64_set_pmc(0, 1);
 		ia64_srlz_d();
-		for (i = 0; i < MAX_PERF_COUNTER; ++i)
-			ia64_set_pmc(4+i, 0);
+
+		ia64_psr(regs)->up = 0;
+
+		current->thread.flags &= ~IA64_THREAD_PM_VALID;
+
+		pmu_owners[smp_processor_id()] = NULL;
 
 #if 0
 /* irrelevant with user monitors */
@@ -225,48 +336,140 @@
 		ia64_psr(regs)->up = 0;
 #endif
 
-		current->thread.flags &= ~(IA64_THREAD_PM_VALID);
-
 		break;
 
+	      case PFM_DEBUG_ON:
+			printk(__FUNCTION__" debuggin on\n");
+			pfm_debug = 1;
+			break;
+
+	      case PFM_DEBUG_OFF:
+			printk(__FUNCTION__" debuggin off\n");
+			pfm_debug = 0;
+			break;
+
 	      default:
+		DBprintk((__FUNCTION__" UNknown command 0x%x\n", cmd));
 		return -EINVAL;
 		break;
         }
         return 0;
 }
 
-static inline void
-update_counters (void)
+asmlinkage int
+sys_perfmonctl (int pid, int cmd, int flags, perfmon_req_t *req, int count, long arg6, long arg7, long arg8, long stack)
 {
-	unsigned long mask, i, cnum, val;
+	struct pt_regs *regs = (struct pt_regs *) &stack;
+	struct task_struct *child = current;
+	int ret;
 
-	mask = ia64_get_pmc(0) >> 4;
-	for (i = 0, cnum = PMU_FIRST_COUNTER ; i < pmu_conf.max_counters; cnum++, i++, mask >>= 1) {
+	if (pid != current->pid) {
+		read_lock(&tasklist_lock);
+		{
+			child = find_task_by_pid(pid);
+			if (child)
+				get_task_struct(child);
+		}
+		if (!child) { 
+			read_unlock(&tasklist_lock);
+			return -ESRCH;
+		}
+		/*
+		 * XXX: need to do more checking here
+		 */
+		if (child->state != TASK_ZOMBIE) {
+			DBprintk((__FUNCTION__" warning process %d not in stable state %ld\n", pid, child->state));
+		}
+	} 
+	ret = do_perfmonctl(child, cmd, flags, req, count, regs);
 
+	if (child != current) read_unlock(&tasklist_lock);
 
-		val = mask & 0x1 ? pmu_conf.perf_ovfl_val + 1 : 0;
+	return ret;
+}
 
-		if (mask & 0x1) 
-			printk(__FUNCTION__ " PMD%ld overflowed pmd=%lx pmod=%lx\n", cnum, ia64_get_pmd(cnum), pmds[smp_processor_id()][i]); 
 
-		/* since we got an interrupt, might as well clear every pmd. */
-		val += ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val;
+static inline int
+update_counters (u64 pmc0)
+{
+	unsigned long mask, i, cnum;
+	struct thread_struct *th;
+	struct task_struct *ta;
+
+	if (pmu_owners[smp_processor_id()] = NULL) {
+		DBprintk((__FUNCTION__" Spurious overflow interrupt: PMU not owned\n"));
+		return 0;
+	}
+	
+	/*
+	 * It is never safe to access the task for which the overflow interrupt is destinated
+	 * using the current variable as the interrupt may occur in the middle of a context switch
+	 * where current does not hold the task that is running yet.
+	 *
+	 * For monitoring, however, we do need to get access to the task which caused the overflow
+	 * to account for overflow on the counters.
+	 * We accomplish this by maintaining a current owner of the PMU per CPU. During context
+	 * switch the ownership is changed in a way such that the reflected owner is always the 
+	 * valid one, i.e. the one that caused the interrupt.
+	 */
+	ta = pmu_owners[smp_processor_id()];
+	th = &pmu_owners[smp_processor_id()]->thread;
 
-		printk(__FUNCTION__ " adding val=%lx to pmod[%ld]=%lx \n", val, i, pmds[smp_processor_id()][i]); 
+	/*
+	 * Don't think this could happen given first test. Keep as sanity check
+	 */
+	if ((th->flags & IA64_THREAD_PM_VALID) = 0) {
+		DBprintk((__FUNCTION__" Spurious overflow interrupt: process %d not using perfmon\n", ta->pid));
+		return 0;
+	}
+
+	/*
+	 * if PMU not frozen: spurious from previous context 
+	 * if PMC[0] = 0x1 : frozen but no overflow reported: leftover from previous context
+	 *
+	 * in either case we don't touch the state upon return from handler
+	 */
+	if ((pmc0 & 0x1) = 0 || pmc0 = 0x1) { 
+		DBprintk((__FUNCTION__" Spurious overflow interrupt: process %d freeze=0\n",ta->pid));
+		return 0;
+	}
 
-		pmds[smp_processor_id()][i] += val;
+	mask = pmc0 >> 4;
 
-		ia64_set_pmd(cnum, 0);
+	for (i = 0, cnum = PMU_FIRST_COUNTER; i < pmu_conf.max_counters; cnum++, i++, mask >>= 1) {
+
+		if (mask & 0x1) {
+			DBprintk((__FUNCTION__ " PMD[%ld] overflowed pmd=0x%lx pmod.val=0x%lx\n", cnum, ia64_get_pmd(cnum), th->pmu_counters[i].val)); 
+			
+			/*
+			 * Because we somtimes (EARS/BTB) reset to a specific value, we cannot simply use 
+			 * val to count the number of times we overflowed. Otherwise we would loose the value
+			 * current in the PMD (which can be >0). So to make sure we don't loose
+			 * the residual counts we set val to contain full 64bits value of the counter.
+			 */
+			th->pmu_counters[i].val += 1+pmu_conf.perf_ovfl_val+(ia64_get_pmd(cnum) &pmu_conf.perf_ovfl_val);
+
+			/* writes to upper part are ignored, so this is safe */
+			ia64_set_pmd(cnum, th->pmu_counters[i].rval);
+
+			DBprintk((__FUNCTION__ " pmod[%ld].val=0x%lx pmd=0x%lx\n", i, th->pmu_counters[i].val, ia64_get_pmd(cnum)&pmu_conf.perf_ovfl_val)); 
+
+			if (th->pmu_counters[i].pid != 0 && th->pmu_counters[i].sig>0) {
+				DBprintk((__FUNCTION__ " shouild notify process %d with signal %d\n",th->pmu_counters[i].pid, th->pmu_counters[i].sig)); 
+			}
+		}
 	}
+	return 1;
 }
 
 static void
 perfmon_interrupt (int irq, void *arg, struct pt_regs *regs)
 {
-	update_counters();
-	ia64_set_pmc(0, 0);
-	ia64_srlz_d();
+	/* unfreeze if not spurious */
+	if ( update_counters(ia64_get_pmc(0)) ) {
+		ia64_set_pmc(0, 0);
+		ia64_srlz_d();
+	}
 }
 
 static struct irqaction perfmon_irqaction = {
@@ -280,9 +483,13 @@
 {
 	char *p = page;
 	u64 pmc0 = ia64_get_pmc(0);
+	int i;
 
-	p += sprintf(p, "PMC[0]=%lx\n", pmc0);
-
+	p += sprintf(p, "PMC[0]=%lx\nPerfmon debug: %s\n", pmc0, pfm_debug ? "On" : "Off");
+	for(i=0; i < NR_CPUS; i++) {
+		if (cpu_is_online(i)) 
+			p += sprintf(p, "CPU%d.PMU %d\n", i, pmu_owners[i] ? pmu_owners[i]->pid: -1);
+	}
 	return p - page;
 }
 
@@ -308,7 +515,6 @@
 perfmon_init (void)
 {
 	pal_perf_mon_info_u_t pm_info;
-	u64 pm_buffer[16];
 	s64 status;
 	
 	irq_desc[PERFMON_IRQ].status |= IRQ_PER_CPU;
@@ -320,15 +526,13 @@
 
 	printk("perfmon: Initialized vector to %u\n",PERFMON_IRQ);
 
-	if ((status=ia64_pal_perf_mon_info(pm_buffer, &pm_info)) != 0) {
+	if ((status=ia64_pal_perf_mon_info(pmu_conf.impl_regs, &pm_info)) != 0) {
 		printk(__FUNCTION__ " pal call failed (%ld)\n", status);
 		return;
 	} 
-	pmu_conf.perf_ovfl_val = perf_ovfl_val = (1L << pm_info.pal_perf_mon_info_s.width) - 1; 
+	pmu_conf.perf_ovfl_val = (1L << pm_info.pal_perf_mon_info_s.width) - 1; 
 
 	/* XXX need to use PAL instead */
-	pmu_conf.max_pmc       = 13;
-	pmu_conf.max_pmd       = 17;
 	pmu_conf.max_counters  = pm_info.pal_perf_mon_info_s.generic;
 
 	printk("perfmon: Counters are %d bits\n", pm_info.pal_perf_mon_info_s.width);
@@ -347,36 +551,137 @@
 	ia64_srlz_d();
 }
 
+/*
+ * XXX: for system wide this function MUST never be called
+ */
 void
-ia64_save_pm_regs (struct thread_struct *t)
+ia64_save_pm_regs (struct task_struct *ta)
 {
-	int i;
+	struct thread_struct *t = &ta->thread;
+	u64 pmc0, psr;
+	int i,j;
+
+	/*
+	 * We must maek sure that we don't loose any potential overflow
+	 * interrupt while saving PMU context. In this code, external
+	 * interrupts are always enabled.
+	 */
+
+	/*
+	 * save current PSR: needed because we modify it
+	 */
+	__asm__ __volatile__ ("mov %0=psr;;": "=r"(psr) :: "memory");
+
+	/*
+	 * stop monitoring:
+	 * This is the only way to stop monitoring without destroying overflow
+	 * information in PMC[0..3].
+	 * This is the last instruction which can cause overflow when monitoring
+	 * in kernel.
+	 * By now, we could still have an overflow interrupt in flight.
+	 */
+	__asm__ __volatile__ ("rsm psr.up;;"::: "memory");
+	
+	/*
+	 * read current overflow status:
+	 *
+	 * We may be reading stale information at this point, if we got interrupt
+	 * just before the read(pmc0) but that's all right. However, if we did
+	 * not get the interrupt before, this read reflects LAST state.
+	 *
+	 */
+	pmc0 = ia64_get_pmc(0);
 
+	/*
+	 * freeze PMU:
+	 *
+	 * This destroys the overflow information. This is required to make sure
+	 * next process does not start with monitoring on if not requested
+	 * (PSR.up may not be enough).
+	 *
+	 * We could still get an overflow interrupt by now. However the handler
+	 * will not do anything if is sees PMC[0].fr=1 but no overflow bits
+	 * are set. So PMU will stay in frozen state. This implies that pmc0
+	 * will still be holding the correct unprocessed information.
+	 *
+	 */
 	ia64_set_pmc(0, 1);
 	ia64_srlz_d();
+
+	/*
+	 * check for overflow bits set:
+	 *
+	 * If pmc0 reports PMU frozen, this means we have a pending overflow,
+	 * therefore we invoke the handler. Handler is reentrant with regards
+	 * to PMC[0] so it is safe to call it twice.
+	 *
+	 * IF pmc0 reports overflow, we need to reread current PMC[0] value
+	 * in case the handler was invoked right after the first pmc0 read.
+	 * it is was not invoked then pmc0=PMC[0], otherwise it's been invoked
+	 * and overflow information has been processed, so we don't need to call.
+	 *
+	 * Test breakdown:
+	 *	- pmc0 & ~0x1: test if overflow happened
+	 * 	- second part: check if current register reflects this as well.
+	 *
+	 * NOTE: testing for pmc0 & 0x1 is not enough has it would trigger call
+	 * when PM_VALID and PMU.fr which is common when setting up registers
+	 * just before actually starting monitors.
+	 *
+	 */
+	if ((pmc0 & ~0x1) && ((pmc0=ia64_get_pmc(0)) &~0x1) ) {
+		printk(__FUNCTION__" Warning: pmc[0]=0x%lx\n", pmc0);
+		update_counters(pmc0);
+		/* 
+		 * XXX: not sure that's enough. the next task may still get the
+		 * interrupt.
+		 */
+	}
+
+	/*
+	 * restore PSR for context switch to save
+	 */
+	__asm__ __volatile__ ("mov psr.l=%0;;"::"r"(psr): "memory");
+
 	/*
 	 * XXX: this will need to be extended beyong just counters
 	 */
-	for (i=0; i< IA64_NUM_PM_REGS; i++) {
-		t->pmd[i]  = ia64_get_pmd(4+i);
-		t->pmod[i] = pmds[smp_processor_id()][i];
-		t->pmc[i]  = ia64_get_pmc(4+i);
+	for (i=0,j=4; i< IA64_NUM_PMD_COUNTERS; i++,j++) {
+		t->pmd[i] = ia64_get_pmd(j);
+		t->pmc[i] = ia64_get_pmc(j);
 	}
+	/*
+	 * PMU is frozen, PMU context is saved: nobody owns the PMU on this CPU
+	 * At this point, we should not receive any pending interrupt from the 
+	 * 'switched out' task
+	 */
+	pmu_owners[smp_processor_id()] = NULL;
 }
 
 void
-ia64_load_pm_regs (struct thread_struct *t)
+ia64_load_pm_regs (struct task_struct *ta)
 {
-	int i;
+	struct thread_struct *t = &ta->thread;
+	int i,j;
+
+	/*
+	 * we first restore ownership of the PMU to the 'soon to be current'
+	 * context. This way, if, as soon as we unfreeze the PMU at the end
+	 * of this function, we get an interrupt, we attribute it to the correct
+	 * task
+	 */
+	pmu_owners[smp_processor_id()] = ta;
 
 	/*
 	 * XXX: this will need to be extended beyong just counters 
 	 */
-	for (i=0; i< IA64_NUM_PM_REGS ; i++) {
-		ia64_set_pmd(4+i, t->pmd[i]);
-		pmds[smp_processor_id()][i] = t->pmod[i];
-		ia64_set_pmc(4+i, t->pmc[i]);
+	for (i=0,j=4; i< IA64_NUM_PMD_COUNTERS; i++,j++) {
+		ia64_set_pmd(j, t->pmd[i]);
+		ia64_set_pmc(j, t->pmc[i]);
 	}
+	/*
+	 * unfreeze PMU
+	 */
 	ia64_set_pmc(0, 0);
 	ia64_srlz_d();
 }
diff -urN linux-davidm/arch/ia64/kernel/process.c lia64/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/process.c	Mon Oct 30 22:38:03 2000
@@ -164,7 +164,7 @@
 		ia64_save_debug_regs(&task->thread.dbr[0]);
 #ifdef CONFIG_PERFMON
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) != 0)
-		ia64_save_pm_regs(&task->thread);
+		ia64_save_pm_regs(task);
 #endif
 	if (IS_IA32_PROCESS(ia64_task_regs(task)))
 		ia32_save_state(&task->thread);
@@ -177,7 +177,7 @@
 		ia64_load_debug_regs(&task->thread.dbr[0]);
 #ifdef CONFIG_PERFMON
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) != 0)
-		ia64_load_pm_regs(&task->thread);
+		ia64_load_pm_regs(task);
 #endif
 	if (IS_IA32_PROCESS(ia64_task_regs(task)))
 		ia32_load_state(&task->thread);
@@ -299,6 +299,14 @@
 #	define THREAD_FLAGS_TO_SET	0
 	p->thread.flags = ((current->thread.flags & ~THREAD_FLAGS_TO_CLEAR)
 			   | THREAD_FLAGS_TO_SET);
+#ifdef CONFIG_IA32_SUPPORT
+	/*
+	 * If we're cloning an IA32 task then save the IA32 extra
+	 * state from the current task to the new task
+	 */
+	if (IS_IA32_PROCESS(ia64_task_regs(current)))
+		ia32_save_state(&p->thread);
+#endif
 	return 0;
 }
 
@@ -554,7 +562,7 @@
 		 * we garantee no race.  this call we also stop
 		 * monitoring
 		 */
-		ia64_save_pm_regs(&current->thread);
+		ia64_save_pm_regs(current);
 		/*
 		 * make sure that switch_to() will not save context again
 		 */
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c lia64/arch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/ptrace.c	Mon Oct 30 22:38:17 2000
@@ -794,11 +794,7 @@
 				addr);
 			return -1;
 		}
-	} else 
-#ifdef CONFIG_PERFMON
-		if (addr < PT_PMD) 
-#endif
-		{
+	} else {
 		/* access debug registers */
 
 		if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
@@ -820,33 +816,14 @@
 		}
 
 		ptr += regnum;
-	}
-#ifdef CONFIG_PERFMON
-	else {
-		/*
-		 * XXX: will eventually move back to perfmonctl()
-		 */
-		unsigned long pmd = (addr - PT_PMD) >> 3;
-		extern unsigned long perf_ovfl_val;
-
-		/* we just use ptrace to read */
-		if (write_access) return -1;
-
-		if (pmd > 3) {
-			printk("ptrace: rejecting access to PMD[%ld] address 0x%lx\n", pmd, addr);
-			return -1;
-		}
 
-		/* 
-		 * We always need to mask upper 32bits of pmd because value is random
-		 */
-		pmd_tmp = child->thread.pmod[pmd]+(child->thread.pmd[pmd]& perf_ovfl_val);
-
-		/*printk(__FUNCTION__" child=%d reading pmd[%ld]=%lx\n", child->pid, pmd, pmd_tmp);*/
-
-		ptr = &pmd_tmp;
+		if (write_access)
+			/* don't let the user set kernel-level breakpoints... */
+			*ptr = *data & ~(7UL << 56);
+		else
+			*data = *ptr;
+		return 0;
 	}
-#endif
 	if (write_access)
 		*ptr = *data;
 	else
@@ -977,11 +954,7 @@
 			/* disallow accessing anything else... */
 			return -1;
 		}
-	} else 
-#ifdef CONFIG_PERFMON
-		if (addr < PT_PMD) 
-#endif
-		{
+	} else {
 
 		/* access debug registers */
 
@@ -1002,34 +975,14 @@
 			return -1;
 
 		ptr += regnum;
-	}
-#ifdef CONFIG_PERFMON
-	else {
-		/*
-		 * XXX: will eventually move back to perfmonctl()
-		 */
-		unsigned long pmd = (addr - PT_PMD) >> 3;
-		extern unsigned long perf_ovfl_val;
 
-		/* we just use ptrace to read */
-		if (write_access) return -1;
-
-		if (pmd > 3) {
-			printk("ptrace: rejecting access to PMD[%ld] address 0x%lx\n", pmd, addr);
-			return -1;
-		}
-
-		/* 
-		 * We always need to mask upper 32bits of pmd because value is random
-		 */
-		pmd_tmp = child->thread.pmod[pmd]+(child->thread.pmd[pmd]& perf_ovfl_val);
-
-		/*printk(__FUNCTION__" child=%d reading pmd[%ld]=%lx\n", child->pid, pmd, pmd_tmp);*/
-
-		ptr = &pmd_tmp;
+		if (write_access)
+			/* don't let the user set kernel-level breakpoints... */
+			*ptr = *data & ~(7UL << 56);
+		else
+			*data = *ptr;
+		return 0;
 	}
-#endif
-
 	if (write_access)
 		*ptr = *data;
 	else
diff -urN linux-davidm/arch/ia64/kernel/smp.c lia64/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/smp.c	Mon Oct 30 23:57:04 2000
@@ -11,6 +11,8 @@
  *  00/03/31 Rohit Seth <rohit.seth@intel.com>	Fixes for Bootstrap Processor & cpu_online_map
  *			now gets done here (instead of setup.c)
  *  99/10/05 davidm	Update to bring it in sync with new command-line processing scheme.
+ *  10/13/00 Goutham Rao <goutham.rao@intel.com> Updated smp_call_function and
+ *		smp_call_function_single to resend IPI on timeouts
  */
 #define __KERNEL_SYSCALLS__
 
@@ -30,6 +32,7 @@
 #include <asm/current.h>
 #include <asm/delay.h>
 #include <asm/efi.h>
+#include <asm/machvec.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -276,7 +279,7 @@
                 return;
         
 	set_bit(op, &ipi_op[dest_cpu]);
-	ipi_send(dest_cpu, IPI_IRQ, IA64_IPI_DM_INT, 0);
+	ia64_send_ipi(dest_cpu, IPI_IRQ, IA64_IPI_DM_INT, 0);
 }
 
 static inline void
@@ -358,6 +361,7 @@
 	if (pointer_lock(&smp_call_function_data, &data, retry))
 		return -EBUSY;
 
+resend:
 	/*  Send a message to all other CPUs and wait for them to respond  */
 	send_IPI_single(cpuid, IPI_CALL_FUNC);
 
@@ -366,8 +370,12 @@
 	while ((atomic_read(&data.unstarted_count) > 0) && time_before(jiffies, timeout))
 		barrier();
 	if (atomic_read(&data.unstarted_count) > 0) {
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+		goto resend;
+#else
 		smp_call_function_data = NULL;
 		return -ETIMEDOUT;
+#endif
 	}
 	if (wait)
 		while (atomic_read(&data.unfinished_count) > 0)
@@ -411,13 +419,23 @@
 	/*  Send a message to all other CPUs and wait for them to respond  */
 	send_IPI_allbutself(IPI_CALL_FUNC);
 
+retry:
 	/*  Wait for response  */
 	timeout = jiffies + HZ;
 	while ((atomic_read(&data.unstarted_count) > 0) && time_before(jiffies, timeout))
 		barrier();
 	if (atomic_read(&data.unstarted_count) > 0) {
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+		int i;
+		for (i = 0; i < smp_num_cpus; i++) {
+			if (i != smp_processor_id())
+				ia64_send_ipi(i, IPI_IRQ, IA64_IPI_DM_INT, 0);
+		}
+		goto retry;
+#else
 		smp_call_function_data = NULL;
 		return -ETIMEDOUT;
+#endif
 	}
 	if (wait)
 		while (atomic_read(&data.unfinished_count) > 0)
@@ -569,7 +587,7 @@
 	cpu_now_booting = cpu;
 
 	/* Kick the AP in the butt */
-	ipi_send(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
+	ia64_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
 
 	/* wait up to 10s for the AP to start  */
 	for (timeout = 0; timeout < 100000; timeout++) {
diff -urN linux-davidm/arch/ia64/kernel/traps.c lia64/arch/ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/traps.c	Mon Oct 30 22:40:14 2000
@@ -544,7 +544,7 @@
 
 	      case 46:
 		printk("Unexpected IA-32 intercept trap (Trap 46)\n");
-		printk("  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx\n", regs->cr_iip, ifa, isr);
+		printk("  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx, iim - 0x%lx\n", regs->cr_iip, ifa, isr, iim);
 		force_sig(SIGSEGV, current);
 		return;
 
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c lia64/arch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/unaligned.c	Mon Oct 30 22:40:27 2000
@@ -572,7 +572,8 @@
 	 */
 	if (regnum = 0) {
 		*val = 0;
-		*nat = 0;
+		if (nat)
+			*nat = 0;
 		return;
 	}
 
diff -urN linux-davidm/arch/ia64/kernel/unwind.c lia64/arch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Mon Oct 30 23:54:13 2000
+++ lia64/arch/ia64/kernel/unwind.c	Mon Oct 30 22:40:45 2000
@@ -46,16 +46,6 @@
 #define MIN(a,b)	((a) < (b) ? (a) : (b))
 #define p5		5
 
-/*
- * The unwind tables are supposed to be sorted, but the GNU toolchain
- * currently fails to produce a sorted table in the presence of
- * functions that go into sections other than .text.  For example, the
- * kernel likes to put initialization code into .text.init, which
- * messes up the sort order.  Hopefully, this will get fixed sometime
- * soon.  --davidm 00/05/23
- */
-#define UNWIND_TABLE_SORT_BUG
-
 #define UNW_LOG_CACHE_SIZE	7	/* each unw_script is ~256 bytes in size */
 #define UNW_CACHE_SIZE		(1 << UNW_LOG_CACHE_SIZE)
 
@@ -63,7 +53,7 @@
 #define UNW_HASH_SIZE		(1 << UNW_LOG_HASH_SIZE)
 
 #define UNW_DEBUG	0
-#define UNW_STATS	0	/* WARNING: this disabled interrupts for long time-spans!! */
+#define UNW_STATS	1	/* WARNING: this disabled interrupts for long time-spans!! */
 
 #if UNW_DEBUG
   static long unw_debug_level = 255;
@@ -1964,23 +1954,6 @@
 {
 	struct unw_table_entry *start = table_start, *end = table_end;
 
-#ifdef UNWIND_TABLE_SORT_BUG
-	{
-		struct unw_table_entry *e1, *e2, tmp;
-
-		/* stupid bubble sort... */
-
-		for (e1 = start; e1 < end; ++e1) {
-			for (e2 = e1 + 1; e2 < end; ++e2) {
-				if (e2->start_offset < e1->start_offset) {
-					tmp = *e1;
-					*e1 = *e2;
-					*e2 = tmp;
-				}
-			}
-		}
-	}
-#endif
 	table->name = name;
 	table->segment_base = segment_base;
 	table->gp = gp;
diff -urN linux-davidm/arch/ia64/lib/copy_user.S lia64/arch/ia64/lib/copy_user.S
--- linux-davidm/arch/ia64/lib/copy_user.S	Wed Aug  2 18:54:02 2000
+++ lia64/arch/ia64/lib/copy_user.S	Mon Oct 30 23:45:16 2000
@@ -65,6 +65,12 @@
 //
 // local registers
 //
+#define t1		r2	// rshift in bytes
+#define t2		r3	// lshift in bytes
+#define rshift		r14	// right shift in bits
+#define lshift		r15	// left shift in bits
+#define word1		r16
+#define word2		r17
 #define cnt		r18
 #define len2		r19
 #define saved_lc	r20
@@ -134,6 +140,190 @@
 	br.ret.sptk.few rp	// end of short memcpy
 
 	//
+	// Not 8-byte aligned
+	//
+diff_align_copy_user:
+	// At this point we know we have more than 16 bytes to copy
+	// and also that src and dest do _not_ have the same alignment.
+	and src2=0x7,src1				// src offset
+	and dst2=0x7,dst1				// dst offset
+	;;
+	// The basic idea is that we copy byte-by-byte at the head so 
+	// that we can reach 8-byte alignment for both src1 and dst1. 
+	// Then copy the body using software pipelined 8-byte copy, 
+	// shifting the two back-to-back words right and left, then copy 
+	// the tail by copying byte-by-byte.
+	//
+	// Fault handling. If the byte-by-byte at the head fails on the
+	// load, then restart and finish the pipleline by copying zeros
+	// to the dst1. Then copy zeros for the rest of dst1.
+	// If 8-byte software pipeline fails on the load, do the same as
+	// failure_in3 does. If the byte-by-byte at the tail fails, it is
+	// handled simply by failure_in_pipe1.
+	//
+	// The case p14 represents the source has more bytes in the
+	// the first word (by the shifted part), whereas the p15 needs to 
+	// copy some bytes from the 2nd word of the source that has the 
+	// tail of the 1st of the destination.
+	//
+
+	//
+	// Optimization. If dst1 is 8-byte aligned (not rarely), we don't need 
+	// to copy the head to dst1, to start 8-byte copy software pipleline. 
+	// We know src1 is not 8-byte aligned in this case.
+	//
+	cmp.eq p14,p15=r0,dst2
+(p15)	br.cond.spnt.few 1f				
+	;;
+	sub t1=8,src2
+	mov t2=src2
+	;;
+	shl rshift=t2,3
+	sub len1=len,t1					// set len1
+	;;
+	sub lshiftd,rshift
+	;; 
+	br.cond.spnt.few word_copy_user
+	;; 
+1:			
+	cmp.leu	p14,p15=src2,dst2
+	sub t1=dst2,src2
+	;;
+	.pred.rel "mutex", p14, p15
+(p14)	sub word1=8,src2				// (8 - src offset)
+(p15)	sub t1=r0,t1					// absolute value
+(p15)	sub word1=8,dst2				// (8 - dst offset)
+	;;
+	// For the case p14, we don't need to copy the shifted part to
+	// the 1st word of destination.
+	sub t2=8,t1	
+(p14)	sub word1=word1,t1
+	;;
+	sub len1=len,word1				// resulting len
+(p15)	shl rshift=t1,3					// in bits
+(p14)	shl rshift=t2,3
+	;; 
+(p14)	sub len1=len1,t1
+	adds cnt=-1,word1
+	;; 
+	sub lshiftd,rshift
+	mov ar.ec=PIPE_DEPTH
+	mov pr.rot=1<<16	// p16=true all others are false
+	mov ar.lc=cnt
+	;; 
+2:	
+	EX(failure_in_pipe2,(p16) ld1 val1[0]=[src1],1)
+	;; 
+	EX(failure_out,(EPI) st1 [dst1]=val1[PIPE_DEPTH-1],1)
+	br.ctop.dptk.few 2b
+	;;
+	clrrrb	
+	;; 
+word_copy_user:		
+	cmp.gtu p9,p0,len1
+(p9)	br.cond.spnt.few 4f		// if (16 > len1) skip 8-byte copy
+	;;
+	shr.u cnt=len1,3		// number of 64-bit words
+	;;
+	adds cnt=-1,cnt
+	;;
+	.pred.rel "mutex", p14, p15	
+(p14)	sub src1=src1,t2
+(p15)	sub src1=src1,t1
+	//
+	// Now both src1 and dst1 point to an 8-byte aligned address. And
+	// we have more than 8 bytes to copy.
+	//
+	mov ar.lc=cnt
+	mov ar.ec=PIPE_DEPTH
+	mov pr.rot=1<<16	// p16=true all others are false
+	;; 
+3:
+	//
+	// The pipleline consists of 3 stages:	
+	// 1 (p16):	Load a word from src1
+	// 2 (EPI_1):	Shift right pair, saving to tmp
+	// 3 (EPI):	Store tmp to dst1
+	//
+	// To make it simple, use at least 2 (p16) loops to set up val1[n] 
+	// because we need 2 back-to-back val1[] to get tmp.
+	// Note that this implies EPI_2 must be p18 or greater.
+	// 
+
+#define EPI_1		p[PIPE_DEPTH-2]
+#define SWITCH(pred, shift)	cmp.eq pred,p0=shift,rshift
+#define CASE(pred, shift)	\
+	(pred)	br.cond.spnt.few copy_user_bit##shift	
+#define BODY(rshift)							\
+copy_user_bit##rshift:							\
+1:									\
+	EX(failure_out,(EPI) st8 [dst1]=tmp,8);				\
+(EPI_1) shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;		\
+	EX(failure_in2,(p16) ld8 val1[0]=[src1],8);			\
+	br.ctop.dptk.few 1b;						\
+	;;								\
+	br.cond.spnt.few .diff_align_do_tail
+
+	//
+	// Since the instruction 'shrp' requires a fixed 128-bit value
+	// specifying the bits to shift, we need to provide 7 cases
+	// below. 
+	//
+	SWITCH(p6, 8)
+	SWITCH(p7, 16)
+	SWITCH(p8, 24)	
+	SWITCH(p9, 32)
+	SWITCH(p10, 40)
+	SWITCH(p11, 48)
+	SWITCH(p12, 56)
+	;;
+	CASE(p6, 8)
+	CASE(p7, 16)
+	CASE(p8, 24)
+	CASE(p9, 32)
+	CASE(p10, 40)
+	CASE(p11, 48)
+	CASE(p12, 56)
+	;;
+	BODY(8)
+	BODY(16)
+	BODY(24)
+	BODY(32)
+	BODY(40)		
+	BODY(48)
+	BODY(56)
+	;; 
+.diff_align_do_tail:	
+	.pred.rel "mutex", p14, p15		
+(p14)	sub src1=src1,t1
+(p14)	adds dst1=-8,dst1			
+(p15)	sub dst1=dst1,t1
+	;; 
+4:	
+	// Tail correction.
+	//
+	// The problem with this piplelined loop is that the last word is not
+	// loaded and thus parf of the last word written is not correct. 
+	// To fix that, we simply copy the tail byte by byte.
+	
+	sub len1=endsrc,src1,1
+	clrrrb
+	;; 
+	mov ar.ec=PIPE_DEPTH
+	mov pr.rot=1<<16	// p16=true all others are false
+	mov ar.lc=len1
+	;;
+5:		
+	EX(failure_in_pipe1,(p16) ld1 val1[0]=[src1],1)
+	
+	EX(failure_out,(EPI) st1 [dst1]=val1[PIPE_DEPTH-1],1)
+	br.ctop.dptk.few 5b
+	;;
+	mov pr=saved_pr,0xffffffffffff0000
+	mov ar.pfs=saved_pfs
+	br.ret.dptk.few rp
+	
+	//
 	// Beginning of long mempcy (i.e. > 16 bytes)
 	//
 long_copy_user:
@@ -142,7 +332,7 @@
 	;;
 	cmp.eq p10,p8=r0,tmp
 	mov len1=len		// copy because of rotation
-(p8)	br.cond.dpnt.few 1b	// XXX Fixme. memcpy_diff_align 
+(p8)	br.cond.dpnt.few diff_align_copy_user
 	;;
 	// At this point we know we have more than 16 bytes to copy
 	// and also that both src and dest have the same alignment
@@ -267,6 +457,21 @@
 	mov ar.pfs=saved_pfs
 	br.ret.dptk.few rp
 
+	//
+	// This is the case where the byte by byte copy fails on the load
+	// when we copy the head. We need to finish the pipeline and copy 
+	// zeros for the rest of the destination. Since this happens
+	// at the top we still need to fill the body and tail.
+failure_in_pipe2:
+	sub ret0=endsrc,src1	// number of bytes to zero, i.e. not copied
+2:
+(p16)	mov val1[0]=r0
+(EPI)	st1 [dst1]=val1[PIPE_DEPTH-1],1
+	br.ctop.dptk.few 2b
+	;;
+	sub len=enddst,dst1,1		// precompute len
+	br.cond.dptk.few failure_in1bis
+	;; 
 
 	//
 	// Here we handle the head & tail part when we check for alignment.
@@ -395,6 +600,23 @@
 	mov ar.pfs=saved_pfs
 	br.ret.dptk.few rp
 
+failure_in2:
+	sub ret0=endsrc,src1	// number of bytes to zero, i.e. not copied
+	;;
+3:
+(p16)	mov val1[0]=r0
+(EPI)	st8 [dst1]=val1[PIPE_DEPTH-1],8
+	br.ctop.dptk.few 3b
+	;;
+	cmp.ne p6,p0=dst1,enddst	// Do we need to finish the tail ?
+	sub len=enddst,dst1,1		// precompute len
+(p6)	br.cond.dptk.few failure_in1bis	
+	;;
+	mov pr=saved_pr,0xffffffffffff0000
+	mov ar.lc=saved_lc
+	mov ar.pfs=saved_pfs
+	br.ret.dptk.few rp
+	
 	//
 	// handling of failures on stores: that's the easy part
 	//
diff -urN linux-davidm/arch/ia64/lib/memcpy.S lia64/arch/ia64/lib/memcpy.S
--- linux-davidm/arch/ia64/lib/memcpy.S	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/lib/memcpy.S	Mon Oct 30 22:45:50 2000
@@ -17,17 +17,24 @@
 
 #include <asm/asmmacro.h>
 
+#if defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPECIFIC)
+# define BRP(args...)	nop.b 0
+#else
+# define BRP(args...)	brp.loop.imp args
+#endif
+
 GLOBAL_ENTRY(bcopy)
 	.regstk 3,0,0,0
 	mov r8=in0
 	mov in0=in1
 	;;
 	mov in1=r8
+	;;
 END(bcopy)
 	// FALL THROUGH
 GLOBAL_ENTRY(memcpy)
 
-#	define MEM_LAT	2		/* latency to L1 cache */
+#	define MEM_LAT	21		/* latency to memory */
 
 #	define dst	r2
 #	define src	r3
@@ -57,20 +64,17 @@
 	UNW(.prologue)
 	UNW(.save ar.pfs, saved_pfs)
 	alloc saved_pfs=ar.pfs,3,Nrot,0,Nrot
-#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
-	lfetch [in1]
-#else
-	nop.m 0
-#endif
+	UNW(.save ar.lc, saved_lc)
+	mov saved_lc=ar.lc
 	or t0=in0,in1
 	;;
 
 	or t0=t0,in2
-	UNW(.save ar.lc, saved_lc)
-	mov saved_lc=ar.lc
 	UNW(.save pr, saved_pr)
 	mov saved_pr=pr
 
+	UNW(.body)
+
 	cmp.eq p6,p0=in2,r0	// zero length?
 	mov retval=in0		// return dst
 (p6)	br.ret.spnt.many rp	// zero length, return immediately
@@ -83,7 +87,6 @@
 
 	adds cnt=-1,cnt		// br.ctop is repeat/until
 	cmp.gtu p7,p0,in2	// copying less than 16 bytes?
-	UNW(.body)
 	mov ar.ec=N
 	;;
 
@@ -98,10 +101,17 @@
 	;;
 	.rotr val[N]
 	.rotp p[N]
-1:
+	.align 32
+1: { .mib
 (p[0])	ld8 val[0]=[src],8
+	nop.i 0
+	BRP(1b, 2f)
+}
+2: { .mfb
 (p[N-1])st8 [dst]=val[N-1],8
+	nop.f 0
 	br.ctop.dptk.few 1b
+}
 	;;
 	mov ar.lc=saved_lc
 	mov pr=saved_pr,-1
@@ -118,6 +128,7 @@
 memcpy_short:
 	adds cnt=-1,in2		// br.ctop is repeat/until
 	mov ar.ec=MEM_LAT
+	BRP(1f, 2f)
 	;;
 	mov ar.lc=cnt
 	;;
@@ -125,12 +136,17 @@
 	 * It is faster to put a stop bit in the loop here because it makes
 	 * the pipeline shorter (and latency is what matters on short copies).
 	 */
-1:
+	.align 32
+1: { .mib
 (p[0])	ld1 val[0]=[src],1
-	;;
+	nop.i 0
+	BRP(1b, 2f)
+} ;;
+2: { .mfb
 (p[MEM_LAT-1])st1 [dst]=val[MEM_LAT-1],1
+	nop.f 0
 	br.ctop.dptk.few 1b
-	;;
+} ;;
 	mov ar.lc=saved_lc
 	mov pr=saved_pr,-1
 	mov ar.pfs=saved_pfs
@@ -251,17 +267,16 @@
 	.align 64
 
 #define COPY(shift,index)									\
- 1:												\
-  { .mfi											\
+ 1: { .mib											\
 	(p[0])		ld8 val[0]=[src2],8;							\
-			nop.f 0;								\
 	(p[MEM_LAT+3])	shrp w[0]=val[MEM_LAT+3],val[MEM_LAT+4-index],shift;			\
-  };												\
-  { .mbb											\
+			BRP(1b, 2f)								\
+    };												\
+ 2: { .mfb											\
 	(p[MEM_LAT+4])	st8 [dst]=w[1],8;							\
-			nop.b 0;								\
+			nop.f 0;								\
 			br.ctop.dptk.few 1b;							\
-  };												\
+    };												\
 			;;									\
 			ld8 val[N-1]=[src_end];	/* load last word (may be same as val[N]) */	\
 			;;									\
diff -urN linux-davidm/arch/ia64/mm/tlb.c lia64/arch/ia64/mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/mm/tlb.c	Mon Oct 30 22:46:48 2000
@@ -6,6 +6,8 @@
  *
  * 08/02/00 A. Mallick <asit.k.mallick@intel.com>	
  *		Modified RID allocation for SMP 
+ *          Goutham Rao <goutham.rao@intel.com>
+ *              IPI based ptc implementation and A-step IPI implementation.
  */
 #include <linux/config.h>
 #include <linux/init.h>
@@ -17,6 +19,7 @@
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 #include <asm/pal.h>
+#include <asm/delay.h>
 
 #define SUPPORTED_PGBITS (			\
 		1 << _PAGE_SIZE_256M |		\
@@ -99,9 +102,22 @@
 	/*
 	 * Wait for other CPUs to finish purging entries.
 	 */
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+	{
+		unsigned long start = ia64_get_itc();
+		while (atomic_read(&flush_cpu_count) > 0) {
+			if ((ia64_get_itc() - start) > 40000UL) {
+				atomic_set(&flush_cpu_count, smp_num_cpus - 1);
+				smp_send_flush_tlb();
+				start = ia64_get_itc();
+			}
+		}
+	}
+#else
 	while (atomic_read(&flush_cpu_count)) {
 		/* Nothing */
 	}
+#endif
 	if (!(flags & IA64_PSR_I)) {
 		local_irq_disable();
 		ia64_set_tpr(saved_tpr);
diff -urN linux-davidm/drivers/char/drm/vm.c lia64/drivers/char/drm/vm.c
--- linux-davidm/drivers/char/drm/vm.c	Wed Oct  4 16:53:20 2000
+++ lia64/drivers/char/drm/vm.c	Mon Oct 30 22:48:30 2000
@@ -272,6 +272,7 @@
 	drm_file_t	*priv	= filp->private_data;
 	drm_device_t	*dev	= priv->dev;
 	drm_map_t	*map	= NULL;
+	unsigned long	off;
 	int		i;
 	
 	DRM_DEBUG("start = 0x%lx, end = 0x%lx, offset = 0x%lx\n",
@@ -288,7 +289,16 @@
 				   bit longer. */
 	for (i = 0; i < dev->map_count; i++) {
 		map = dev->maplist[i];
-		if (map->offset = VM_OFFSET(vma)) break;
+		off = map->offset ^ VM_OFFSET(vma);
+#ifdef	__ia64__
+		/*
+		 * Ignore region bits, makes IA32 processes happier
+		 * XXX This is a hack...
+		 */
+		off &= ~0xe000000000000000;
+#endif	// __ia64__
+		if (off = 0)
+			break;
 	}
 	
 	if (i >= dev->map_count) return -EINVAL;
diff -urN linux-davidm/drivers/char/mem.c lia64/drivers/char/mem.c
--- linux-davidm/drivers/char/mem.c	Wed Oct  4 16:53:21 2000
+++ lia64/drivers/char/mem.c	Tue Oct 31 00:13:05 2000
@@ -198,8 +198,12 @@
 	 * through a file pointer that was marked O_SYNC will be
 	 * done non-cached.
 	 */
-	if (noncached_address(offset) || (file->f_flags & O_SYNC))
+	if (noncached_address(offset) || (file->f_flags & O_SYNC)
+	    || vma->vm_flags & VM_NONCACHED)
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+
+	if (vma->vm_flags & VM_WRITECOMBINED)
+		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 
 	/*
 	 * Don't dump addresses that are not real memory to a core file.
diff -urN linux-davidm/drivers/net/tulip/tulip_core.c lia64/drivers/net/tulip/tulip_core.c
--- linux-davidm/drivers/net/tulip/tulip_core.c	Wed Oct  4 16:53:25 2000
+++ lia64/drivers/net/tulip/tulip_core.c	Mon Oct 30 22:49:57 2000
@@ -52,7 +52,7 @@
 
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
-	|| defined(__sparc_)
+	|| defined(__sparc_) || defined(__ia64__)
 static int rx_copybreak = 1518;
 #else
 static int rx_copybreak = 100;
@@ -71,7 +71,7 @@
 	ToDo: Non-Intel setting could be better.
 */
 
-#if defined(__alpha__)
+#if defined(__alpha__) || defined(__ia64__)
 static int csr0 = 0x01A00000 | 0xE000;
 #elif defined(__i386__) || defined(__powerpc__) || defined(__hppa__)
 static int csr0 = 0x01A00000 | 0x8000;
diff -urN linux-davidm/drivers/scsi/qla1280.c lia64/drivers/scsi/qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Mon Oct 30 23:54:14 2000
+++ lia64/drivers/scsi/qla1280.c	Mon Oct 30 22:50:11 2000
@@ -16,9 +16,17 @@
 * General Public License for more details.
 **
 ******************************************************************************/
-
+#define QLA1280_VERSION      "3.19 Beta"
 /****************************************************************************
     Revision History:
+    Rev  3.19 Beta October 13, 2000 BN Qlogic
+        - Declare driver_template for new kernel
+          (2.4.0 and greater) scsi initialization scheme.
+        - Update /proc/scsi entry for 2.3.18 kernels and
+          above as qla1280
+    Rev  3.18 Beta October 10, 2000 BN Qlogic
+        - Changed scan order of adapters to map 
+          the QLA12160 followed by the QLA1280.
     Rev  3.17 Beta September 18, 2000 BN Qlogic
         - Removed warnings for 32 bit 2.4.x compiles
         - Corrected declared size for request and response
@@ -102,8 +110,6 @@
 #include <linux/module.h>
 #endif
 
-#define QLA1280_VERSION      "3.17 Beta"
-
 #include <stdarg.h>
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -408,14 +414,14 @@
 struct _qlaboards   QL1280BoardTbl[NUM_OF_ISP_DEVICES] = 
 {
    /* Name ,  Board PCI Device ID,         Number of ports */
+  {"QLA12160 ", QLA12160_DEVICE_ID,          2,      
+               &fw12160i_code01[0],  (unsigned long *)&fw12160i_length01,&fw12160i_addr01, &fw12160i_version_str[0] },       
   {"QLA1080 ", QLA1080_DEVICE_ID,           1,        
                &fw1280ei_code01[0],  (unsigned long *)&fw1280ei_length01,&fw1280ei_addr01, &fw1280ei_version_str[0] },       
   {"QLA1240 ", QLA1240_DEVICE_ID,           2,       
                &fw1280ei_code01[0],  (unsigned long *)&fw1280ei_length01,&fw1280ei_addr01, &fw1280ei_version_str[0] },       
   {"QLA1280 ", QLA1280_DEVICE_ID,           2,      
                &fw1280ei_code01[0],  (unsigned long *)&fw1280ei_length01,&fw1280ei_addr01, &fw1280ei_version_str[0] },       
-  {"QLA12160 ", QLA12160_DEVICE_ID,          2,      
-               &fw12160i_code01[0],  (unsigned long *)&fw12160i_length01,&fw12160i_addr01, &fw12160i_version_str[0] },       
   {"QLA10160 ", QLA10160_DEVICE_ID,          1,      
                &fw12160i_code01[0],  (unsigned long *)&fw12160i_length01,&fw12160i_addr01, &fw12160i_version_str[0] },       
   {"        ",                 0,           0}
@@ -739,7 +745,7 @@
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
     template->proc_dir = &proc_scsi_qla1280;
 #else
-    template->proc_name = "qla1x80";
+    template->proc_name = "qla1280";
 #endif
 	/* Try and find each different type of adapter we support */
 	for( i=0; bdp->device_id != 0 && i < NUM_OF_ISP_DEVICES; i++, bdp++ ) {
@@ -6342,13 +6348,15 @@
     return(ret);
 }
 
-
-/*
- * Declarations for load module
- */
-static Scsi_Host_Template driver_template = QLA1280_LINUX_TEMPLATE;
-
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,4,0)
+#ifdef MODULE
+Scsi_Host_Template driver_template = QLA1280_LINUX_TEMPLATE;
 #include "scsi_module.c"
+#endif
+#else   /* new kernel scsi initialization scheme */
+static  Scsi_Host_Template driver_template = QLA1280_LINUX_TEMPLATE;
+#include "scsi_module.c"
+#endif
 
 /************************************************************************
  * qla1280_check_for_dead_scsi_bus                                      *
diff -urN linux-davidm/fs/binfmt_elf.c lia64/fs/binfmt_elf.c
--- linux-davidm/fs/binfmt_elf.c	Mon Oct 30 23:54:14 2000
+++ lia64/fs/binfmt_elf.c	Mon Oct 30 22:50:33 2000
@@ -33,6 +33,7 @@
 #include <linux/smp_lock.h>
 
 #include <asm/uaccess.h>
+#include <asm/param.h>
 #include <asm/pgalloc.h>
 
 #define DLINFO_ITEMS 13
@@ -159,23 +160,27 @@
 		sp -= 2;
 		NEW_AUX_ENT(0, AT_PLATFORM, (elf_addr_t)(unsigned long) u_platform);
 	}
-	sp -= 2;
+	sp -= 2*2;
 	NEW_AUX_ENT(0, AT_HWCAP, hwcap);
+	NEW_AUX_ENT(1, AT_PAGESZ, ELF_EXEC_PAGESIZE);
+#ifdef CLOCKS_PER_SEC
+	sp -= 2;
+	NEW_AUX_ENT(0, AT_CLKTCK, CLOCKS_PER_SEC);
+#endif
 
 	if (exec) {
-		sp -= 11*2;
+		sp -= 10*2;
 
 		NEW_AUX_ENT(0, AT_PHDR, load_addr + exec->e_phoff);
 		NEW_AUX_ENT(1, AT_PHENT, sizeof (struct elf_phdr));
 		NEW_AUX_ENT(2, AT_PHNUM, exec->e_phnum);
-		NEW_AUX_ENT(3, AT_PAGESZ, ELF_EXEC_PAGESIZE);
-		NEW_AUX_ENT(4, AT_BASE, interp_load_addr);
-		NEW_AUX_ENT(5, AT_FLAGS, 0);
-		NEW_AUX_ENT(6, AT_ENTRY, load_bias + exec->e_entry);
-		NEW_AUX_ENT(7, AT_UID, (elf_addr_t) current->uid);
-		NEW_AUX_ENT(8, AT_EUID, (elf_addr_t) current->euid);
-		NEW_AUX_ENT(9, AT_GID, (elf_addr_t) current->gid);
-		NEW_AUX_ENT(10, AT_EGID, (elf_addr_t) current->egid);
+		NEW_AUX_ENT(3, AT_BASE, interp_load_addr);
+		NEW_AUX_ENT(4, AT_FLAGS, 0);
+		NEW_AUX_ENT(5, AT_ENTRY, load_bias + exec->e_entry);
+		NEW_AUX_ENT(6, AT_UID, (elf_addr_t) current->uid);
+		NEW_AUX_ENT(7, AT_EUID, (elf_addr_t) current->euid);
+		NEW_AUX_ENT(8, AT_GID, (elf_addr_t) current->gid);
+		NEW_AUX_ENT(9, AT_EGID, (elf_addr_t) current->egid);
 	}
 #undef NEW_AUX_ENT
 
diff -urN linux-davidm/fs/open.c lia64/fs/open.c
--- linux-davidm/fs/open.c	Wed Oct  4 16:53:39 2000
+++ lia64/fs/open.c	Mon Oct 30 22:50:49 2000
@@ -103,7 +103,7 @@
 	inode = nd.dentry->d_inode;
 
 	error = -EACCES;
-	if (S_ISDIR(inode->i_mode))
+	if (!S_ISREG(inode->i_mode))
 		goto dput_and_out;
 
 	error = permission(inode,MAY_WRITE);
@@ -164,7 +164,7 @@
 	dentry = file->f_dentry;
 	inode = dentry->d_inode;
 	error = -EACCES;
-	if (S_ISDIR(inode->i_mode) || !(file->f_mode & FMODE_WRITE))
+	if (!S_ISREG(inode->i_mode) || !(file->f_mode & FMODE_WRITE))
 		goto out_putf;
 	error = -EPERM;
 	if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
diff -urN linux-davidm/fs/proc/array.c lia64/fs/proc/array.c
--- linux-davidm/fs/proc/array.c	Fri Sep  8 14:34:59 2000
+++ lia64/fs/proc/array.c	Mon Oct 30 22:51:05 2000
@@ -575,7 +575,7 @@
 		goto getlen_out;
 
 	/* Check whether the mmaps could change if we sleep */
-	volatile_task = (task != current || atomic_read(&mm->mm_users) > 1);
+	volatile_task = (task != current || atomic_read(&mm->mm_users) > 2);
 
 	/* decode f_pos */
 	lineno = *ppos >> MAPS_LINE_SHIFT;
diff -urN linux-davidm/include/asm-ia64/delay.h lia64/include/asm-ia64/delay.h
--- linux-davidm/include/asm-ia64/delay.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/delay.h	Mon Oct 30 22:51:21 2000
@@ -55,6 +55,10 @@
 	unsigned long result;
 
 	__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
+#ifdef CONFIG_ITANIUM
+	while (__builtin_expect ((__s32) result = -1, 0))
+		__asm__ __volatile__("mov %0=ar.itc" : "=r"(result) :: "memory");
+#endif
 	return result;
 }
 
diff -urN linux-davidm/include/asm-ia64/hw_irq.h lia64/include/asm-ia64/hw_irq.h
--- linux-davidm/include/asm-ia64/hw_irq.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/hw_irq.h	Tue Oct 31 00:15:17 2000
@@ -31,13 +31,22 @@
 
 #define IA64_SPURIOUS_INT	0x0f
 
-#define IA64_MIN_VECTORED_IRQ	 16
-#define IA64_MAX_VECTORED_IRQ	255
+/*
+ * Vectors 0x10-0x1f are used for low priority interrupts, e.g. CMCI.
+ */
+#define PCE_IRQ			0x1e	/* platform corrected error interrupt vector */
+#define CMC_IRQ			0x1f	/* correctable machine-check interrupt vector */
+/*
+ * Vectors 0x20-0x2f are reserved for legacy ISA IRQs.
+ */
+#define FIRST_DEVICE_IRQ	0x30
+#define LAST_DEVICE_IRQ		0xe7
 
-#define PERFMON_IRQ		0x28	/* performanc monitor interrupt vector */
+#define MCA_RENDEZ_IRQ		0xe8	/* MCA rendez interrupt */
+#define PERFMON_IRQ		0xee	/* performanc monitor interrupt vector */
 #define TIMER_IRQ		0xef	/* use highest-prio group 15 interrupt for timer */
+#define	MCA_WAKEUP_IRQ		0xf0	/* MCA wakeup interrupt (must be higher than MCA_RENDEZ_IRQ) */
 #define IPI_IRQ			0xfe	/* inter-processor interrupt vector */
-#define CMC_IRQ			0xff	/* correctable machine-check interrupt vector */
 
 /* IA64 inter-cpu interrupt related definitions */
 
@@ -62,12 +71,13 @@
 
 extern struct hw_interrupt_type irq_type_ia64_sapic;	/* CPU-internal interrupt controller */
 
-extern void ipi_send (int cpu, int vector, int delivery_mode, int redirect);
+extern int ia64_alloc_irq (void);	/* allocate a free irq */
+extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 
 static inline void
 hw_resend_irq (struct hw_interrupt_type *h, unsigned int vector)
 {
-	ipi_send(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
+	ia64_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
 }
 
 #endif /* _ASM_IA64_HW_IRQ_H */
diff -urN linux-davidm/include/asm-ia64/ia32.h lia64/include/asm-ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/ia32.h	Mon Oct 30 22:53:22 2000
@@ -5,6 +5,8 @@
 
 #ifdef CONFIG_IA32_SUPPORT
 
+#include <linux/param.h>
+
 /*
  * 32 bit structures for IA32 support.
  */
@@ -32,6 +34,8 @@
 
 #define IA32_PAGE_SHIFT		12	/* 4KB pages */
 #define IA32_PAGE_SIZE		(1ULL << IA32_PAGE_SHIFT)
+#define IA32_CLOCKS_PER_SEC	100	/* Cast in stone for IA32 Linux */
+#define IA32_TICK(tick)		((unsigned long long)(tick) * IA32_CLOCKS_PER_SEC / CLOCKS_PER_SEC)
 
 /* fcntl.h */
 struct flock32 {
diff -urN linux-davidm/include/asm-ia64/iosapic.h lia64/include/asm-ia64/iosapic.h
--- linux-davidm/include/asm-ia64/iosapic.h	Thu Jun 22 07:09:45 2000
+++ lia64/include/asm-ia64/iosapic.h	Mon Oct 30 22:53:32 2000
@@ -3,121 +3,60 @@
 
 #include <linux/config.h>
 
-#define	IO_SAPIC_DEFAULT_ADDR	0xFEC00000
+#define	IOSAPIC_DEFAULT_ADDR	0xFEC00000
 
-#define	IO_SAPIC_REG_SELECT	0x0
-#define	IO_SAPIC_WINDOW		0x10
-#define	IO_SAPIC_EOI		0x40
+#define	IOSAPIC_REG_SELECT	0x0
+#define	IOSAPIC_WINDOW		0x10
+#define	IOSAPIC_EOI		0x40
 
-#define	IO_SAPIC_VERSION	0x1
+#define	IOSAPIC_VERSION	0x1
 
 /*
  * Redirection table entry
  */
+#define	IOSAPIC_RTE_LOW(i)	(0x10+i*2)
+#define	IOSAPIC_RTE_HIGH(i)	(0x11+i*2)
 
-#define	IO_SAPIC_RTE_LOW(i)	(0x10+i*2)
-#define	IO_SAPIC_RTE_HIGH(i)	(0x11+i*2)
-
-
-#define	IO_SAPIC_DEST_SHIFT		16
+#define	IOSAPIC_DEST_SHIFT		16
 
 /*
  * Delivery mode
  */
-
-#define	IO_SAPIC_DELIVERY_SHIFT		8
-#define	IO_SAPIC_FIXED			0x0
-#define	IO_SAPIC_LOWEST_PRIORITY	0x1
-#define	IO_SAPIC_PMI			0x2
-#define	IO_SAPIC_NMI			0x4
-#define	IO_SAPIC_INIT			0x5
-#define	IO_SAPIC_EXTINT			0x7
+#define	IOSAPIC_DELIVERY_SHIFT		8
+#define	IOSAPIC_FIXED			0x0
+#define	IOSAPIC_LOWEST_PRIORITY	0x1
+#define	IOSAPIC_PMI			0x2
+#define	IOSAPIC_NMI			0x4
+#define	IOSAPIC_INIT			0x5
+#define	IOSAPIC_EXTINT			0x7
 
 /*
  * Interrupt polarity
  */
-
-#define	IO_SAPIC_POLARITY_SHIFT		13
-#define	IO_SAPIC_POL_HIGH		0
-#define	IO_SAPIC_POL_LOW		1
+#define	IOSAPIC_POLARITY_SHIFT		13
+#define	IOSAPIC_POL_HIGH		0
+#define	IOSAPIC_POL_LOW		1
 
 /*
  * Trigger mode
  */
-
-#define	IO_SAPIC_TRIGGER_SHIFT		15
-#define	IO_SAPIC_EDGE			0
-#define	IO_SAPIC_LEVEL			1
+#define	IOSAPIC_TRIGGER_SHIFT		15
+#define	IOSAPIC_EDGE			0
+#define	IOSAPIC_LEVEL			1
 
 /*
  * Mask bit
  */
-
-#define	IO_SAPIC_MASK_SHIFT		16
-#define	IO_SAPIC_UNMASK			0
-#define	IO_SAPIC_MSAK			1
-
-/*
- * Bus types
- */
-#define  BUS_ISA         0               /* ISA Bus */
-#define  BUS_PCI         1               /* PCI Bus */
-
-#ifndef CONFIG_IA64_PCI_FIRMWARE_IRQ
-struct intr_routing_entry {
-      unsigned char srcbus;
-      unsigned char srcbusno;
-      unsigned char srcbusirq;
-      unsigned char iosapic_pin;
-      unsigned char dstiosapic;
-      unsigned char mode;
-      unsigned char trigger;
-      unsigned char polarity;
-};
-
-extern        struct  intr_routing_entry      intr_routing[];
-#endif
+#define	IOSAPIC_MASK_SHIFT		16
+#define	IOSAPIC_UNMASK			0
+#define	IOSAPIC_MSAK			1
 
 #ifndef __ASSEMBLY__
 
-#include <asm/irq.h>
-
-/*
- * IOSAPIC Version Register return 32 bit structure like:
- * {
- *	unsigned int version   : 8;
- *	unsigned int reserved1 : 8;
- *	unsigned int pins      : 8;
- *	unsigned int reserved2 : 8;
- * }
- */
-extern unsigned int iosapic_version(unsigned long);
-extern void iosapic_init(unsigned long, int);
-
-struct iosapic_vector {
-	unsigned long iosapic_base; /* IOSAPIC Base address */
-        char pin;		    /* IOSAPIC pin (-1 = No data) */
-	unsigned char bus;	    /* Bus number */
-	unsigned char baseirq;	    /* Base IRQ handled by this IOSAPIC */
-	unsigned char bustype;	    /* Bus type (ISA, PCI, etc) */
-	unsigned int busdata;	    /* Bus specific ID */
-        /* These bitfields use the values defined above */
-	unsigned char dmode        : 3;
-	unsigned char polarity     : 1;
-	unsigned char trigger      : 1; 
-	unsigned char UNUSED       : 3;
-};
-extern struct iosapic_vector iosapic_vector[NR_IRQS];
-
-#define iosapic_addr(v)     iosapic_vector[v].iosapic_base
-#define iosapic_pin(v)      iosapic_vector[v].pin
-#define iosapic_bus(v)      iosapic_vector[v].bus
-#define iosapic_baseirq(v)  iosapic_vector[v].baseirq
-#define iosapic_bustype(v)  iosapic_vector[v].bustype
-#define iosapic_busdata(v)  iosapic_vector[v].busdata
-#define iosapic_dmode(v)    iosapic_vector[v].dmode
-#define iosapic_trigger(v)  iosapic_vector[v].trigger
-#define iosapic_polarity(v) iosapic_vector[v].polarity
+extern void __init iosapic_init (unsigned long address, unsigned int base_irq);
+extern void iosapic_register_legacy_irq (unsigned long irq, unsigned long pin,
+					 unsigned long polarity, unsigned long trigger);
+extern void iosapic_pci_fixup (void);
 
 # endif /* !__ASSEMBLY__ */
 #endif /* __ASM_IA64_IOSAPIC_H */
diff -urN linux-davidm/include/asm-ia64/machvec.h lia64/include/asm-ia64/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-ia64/machvec.h	Mon Oct 30 23:37:09 2000
@@ -31,7 +31,6 @@
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
-typedef void ia64_mv_register_iosapic_t (struct acpi_entry_iosapic *);
 
 extern void machvec_noop (void);
 
@@ -39,7 +38,7 @@
 #  include <asm/machvec_hpsim.h>
 # elif defined (CONFIG_IA64_DIG)
 #  include <asm/machvec_dig.h>
-# elif defined (CONFIG_IA64_SGI_SN1_SIM)
+# elif defined (CONFIG_IA64_SGI_SN1)
 #  include <asm/machvec_sn1.h>
 # elif defined (CONFIG_IA64_GENERIC)
 
@@ -55,7 +54,6 @@
 #  define platform_cmci_handler	ia64_mv.cmci_handler
 #  define platform_log_print	ia64_mv.log_print
 #  define platform_pci_fixup	ia64_mv.pci_fixup
-#  define platform_register_iosapic	ia64_mv.register_iosapic
 # endif
 
 struct ia64_machine_vector {
@@ -68,7 +66,6 @@
 	ia64_mv_mca_handler_t *mca_handler;
 	ia64_mv_cmci_handler_t *cmci_handler;
 	ia64_mv_log_print_t *log_print;
-	ia64_mv_register_iosapic_t *register_iosapic;
 };
 
 #define MACHVEC_INIT(name)			\
@@ -81,8 +78,7 @@
 	platform_mca_init,			\
 	platform_mca_handler,			\
 	platform_cmci_handler,			\
-	platform_log_print,			\
-	platform_register_iosapic			\
+	platform_log_print			\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -116,9 +112,6 @@
 #endif
 #ifndef platform_pci_fixup
 # define platform_pci_fixup	((ia64_mv_pci_fixup_t *) machvec_noop)
-#endif
-#ifndef platform_register_iosapic
-# define platform_register_iosapic	((ia64_mv_register_iosapic_t *) machvec_noop)
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
diff -urN linux-davidm/include/asm-ia64/machvec_dig.h lia64/include/asm-ia64/machvec_dig.h
--- linux-davidm/include/asm-ia64/machvec_dig.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-ia64/machvec_dig.h	Mon Oct 30 22:54:21 2000
@@ -5,7 +5,6 @@
 extern ia64_mv_irq_init_t dig_irq_init;
 extern ia64_mv_pci_fixup_t dig_pci_fixup;
 extern ia64_mv_map_nr_t map_nr_dense;
-extern ia64_mv_register_iosapic_t dig_register_iosapic;
 
 /*
  * This stuff has dual use!
@@ -17,8 +16,7 @@
 #define platform_name		"dig"
 #define platform_setup		dig_setup
 #define platform_irq_init	dig_irq_init
-#define platform_pci_fixup	dig_pci_fixup
+#define platform_pci_fixup	iosapic_pci_fixup
 #define platform_map_nr		map_nr_dense
-#define platform_register_iosapic dig_register_iosapic
 
 #endif /* _ASM_IA64_MACHVEC_DIG_h */
diff -urN linux-davidm/include/asm-ia64/mca.h lia64/include/asm-ia64/mca.h
--- linux-davidm/include/asm-ia64/mca.h	Fri Apr 21 15:21:24 2000
+++ lia64/include/asm-ia64/mca.h	Mon Oct 30 22:54:41 2000
@@ -18,6 +18,7 @@
 #include <asm/param.h>
 #include <asm/sal.h>
 #include <asm/processor.h>
+#include <asm/hw_irq.h>
 
 /* These are the return codes from all the IA64_MCA specific interfaces */
 typedef	int ia64_mca_return_code_t;
@@ -30,9 +31,9 @@
 #define IA64_MCA_RENDEZ_TIMEOUT		(100 * HZ)	/* 1000 milliseconds */
 
 /* Interrupt vectors reserved for MC handling. */
-#define IA64_MCA_RENDEZ_INT_VECTOR	0xF3	/* Rendez interrupt */
-#define IA64_MCA_WAKEUP_INT_VECTOR	0x12	/* Wakeup interrupt */
-#define IA64_MCA_CMC_INT_VECTOR		0xF2	/* Correctable machine check interrupt */
+#define IA64_MCA_RENDEZ_INT_VECTOR	MCA_RENDEZ_IRQ	/* Rendez interrupt */
+#define IA64_MCA_WAKEUP_INT_VECTOR	MCA_WAKEUP_IRQ	/* Wakeup interrupt */
+#define IA64_MCA_CMC_INT_VECTOR		CMC_IRQ	/* Correctable machine check interrupt */
 
 #define IA64_CMC_INT_DISABLE		0
 #define IA64_CMC_INT_ENABLE		1
diff -urN linux-davidm/include/asm-ia64/mman.h lia64/include/asm-ia64/mman.h
--- linux-davidm/include/asm-ia64/mman.h	Fri Apr 21 15:21:24 2000
+++ lia64/include/asm-ia64/mman.h	Mon Oct 30 22:54:48 2000
@@ -23,6 +23,8 @@
 #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
 #define MAP_LOCKED	0x2000		/* pages are locked */
 #define MAP_NORESERVE	0x4000		/* don't check for reservations */
+#define MAP_WRITECOMBINED 0x10000	/* write-combine the area */
+#define MAP_NONCACHED	0x20000		/* don't cache the memory */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_INVALIDATE	2		/* invalidate the caches */
diff -urN linux-davidm/include/asm-ia64/param.h lia64/include/asm-ia64/param.h
--- linux-davidm/include/asm-ia64/param.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/param.h	Mon Oct 30 22:55:07 2000
@@ -32,4 +32,8 @@
 
 #define MAXHOSTNAMELEN	64	/* max length of hostname */
 
+#ifdef __KERNEL__
+# define CLOCKS_PER_SEC	HZ	/* frequency at which times() counts */
+#endif
+
 #endif /* _ASM_IA64_PARAM_H */
diff -urN linux-davidm/include/asm-ia64/processor.h lia64/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/processor.h	Mon Oct 30 22:56:56 2000
@@ -4,7 +4,7 @@
 /*
  * Copyright (C) 1998-2000 Hewlett-Packard Co
  * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1998-2000 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  *
@@ -19,7 +19,13 @@
 #include <asm/types.h>
 
 #define IA64_NUM_DBG_REGS	8
-#define IA64_NUM_PM_REGS	4
+/*
+ * Limits for PMC and PMD are set to less than maximum architected values
+ * but should be sufficient for a while
+ */
+#define IA64_NUM_PMC_REGS	32
+#define IA64_NUM_PMD_REGS	32
+#define IA64_NUM_PMD_COUNTERS	4
 
 /*
  * TASK_SIZE really is a mis-named.  It really is the maximum user
@@ -288,10 +294,15 @@
 	__u64 dbr[IA64_NUM_DBG_REGS];
 	__u64 ibr[IA64_NUM_DBG_REGS];
 #ifdef CONFIG_PERFMON
-	__u64 pmc[IA64_NUM_PM_REGS];
-	__u64 pmd[IA64_NUM_PM_REGS];
-	__u64 pmod[IA64_NUM_PM_REGS];
-# define INIT_THREAD_PM		{0, }, {0, }, {0, },
+	__u64 pmc[IA64_NUM_PMC_REGS];
+	__u64 pmd[IA64_NUM_PMD_REGS];
+	struct {
+		__u64		val;	/* virtual 64bit counter */
+		__u64		rval;	/* reset value on overflow */
+		int		sig;	/* signal used to notify */
+		int		pid;	/* process to notify */
+	} pmu_counters[IA64_NUM_PMD_COUNTERS];
+# define INIT_THREAD_PM		{0, }, {0, }, {{ 0, 0, 0, 0}, },
 #else
 # define INIT_THREAD_PM
 #endif
@@ -423,8 +434,8 @@
 #endif
 
 #ifdef CONFIG_PERFMON
-extern void ia64_save_pm_regs (struct thread_struct *thread);
-extern void ia64_load_pm_regs (struct thread_struct *thread);
+extern void ia64_save_pm_regs (struct task_struct *task);
+extern void ia64_load_pm_regs (struct task_struct *task);
 #endif
 
 #define ia64_fph_enable()	__asm__ __volatile__ (";; rsm psr.dfh;; srlz.d;;" ::: "memory");
diff -urN linux-davidm/include/asm-ia64/spinlock.h lia64/include/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/spinlock.h	Mon Oct 30 22:57:29 2000
@@ -18,8 +18,9 @@
 #undef NEW_LOCK
 
 #ifdef NEW_LOCK
+
 typedef struct { 
-	volatile unsigned char lock;
+	volatile unsigned int lock;
 } spinlock_t;
 
 #define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
@@ -38,7 +39,7 @@
 		"mov r30=1\n"								\
 		"mov ar.ccv=r0\n"							\
 		";;\n"									\
-		IA64_SEMFIX"cmpxchg1.acq r30=[%0],r30,ar.ccv\n"				\
+		IA64_SEMFIX"cmpxchg4.acq r30=[%0],r30,ar.ccv\n"				\
 		";;\n"									\
 		"cmp.ne p15,p0=r30,r0\n"						\
 		"(p15) br.call.spnt.few b7=ia64_spinlock_contention\n"			\
@@ -48,18 +49,16 @@
 		: "ar.ccv", "ar.pfs", "b7", "p15", "r28", "r29", "r30", "memory");	\
 }
 
-#define spin_trylock(x)								\
-({										\
-	register char *addr __asm__ ("r31") = (char *) &(x)->lock;		\
-	register long result;							\
-										\
-	__asm__ __volatile__ (							\
-		"mov r30=1\n"							\
-		"mov ar.ccv=r0\n"						\
-		";;\n"								\
-		IA64_SEMFIX"cmpxchg1.acq %0=[%1],r30,ar.ccv\n"			\
-		: "=r"(result) : "r"(addr) : "ar.ccv", "r30", "memory");	\
-	(result = 0);								\
+#define spin_trylock(x)									\
+({											\
+	register long result;								\
+											\
+	__asm__ __volatile__ (								\
+		"mov ar.ccv=r0\n"							\
+		";;\n"									\
+		IA64_SEMFIX"cmpxchg4.acq %0=[%2],%1,ar.ccv\n"				\
+		: "=r"(result) : "r"(1), "r"(&(x)->lock) : "ar.ccv", "memory");		\
+	(result = 0);									\
 })
 
 #define spin_is_locked(x)	((x)->lock != 0)
diff -urN linux-davidm/include/asm-ia64/system.h lia64/include/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/system.h	Mon Oct 30 22:57:47 2000
@@ -27,7 +27,8 @@
 
 #define GATE_ADDR		(0xa000000000000000 + PAGE_SIZE)
 
-#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC)
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
+    || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPECIFIC)
   /* Workaround for Errata 97.  */
 # define IA64_SEMFIX_INSN	mf;
 # define IA64_SEMFIX	"mf;"
diff -urN linux-davidm/include/asm-ia64/uaccess.h lia64/include/asm-ia64/uaccess.h
--- linux-davidm/include/asm-ia64/uaccess.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/uaccess.h	Mon Oct 30 22:58:00 2000
@@ -125,46 +125,28 @@
 struct __large_struct { unsigned long buf[100]; };
 #define __m(x) (*(struct __large_struct *)(x))
 
-#define __get_user_64(addr)								\
+/* We need to declare the __ex_table section before we can use it in .xdata.  */
+__asm__ (".section \"__ex_table\", \"a\"\n\t.previous");
+
+#define __get_user_64(addr)									\
 	__asm__ ("\n1:\tld8 %0=%2%P2\t// %0 and %1 get overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 (2b-1b)|1\n"						\
-		 "\t.previous"								\
-		: "=r"(__gu_val), "=r"(__gu_err)					\
-		: "m"(__m(addr)), "1"(__gu_err));
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+		: "=r"(__gu_val), "=r"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
 
-#define __get_user_32(addr)								\
+#define __get_user_32(addr)									\
 	__asm__ ("\n1:\tld4 %0=%2%P2\t// %0 and %1 get overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 (2b-1b)|1\n"						\
-		 "\t.previous"								\
-		: "=r"(__gu_val), "=r"(__gu_err)					\
-		: "m"(__m(addr)), "1"(__gu_err));
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+		: "=r"(__gu_val), "=r"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
 
-#define __get_user_16(addr)								\
+#define __get_user_16(addr)									\
 	__asm__ ("\n1:\tld2 %0=%2%P2\t// %0 and %1 get overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 (2b-1b)|1\n"						\
-		 "\t.previous"								\
-		: "=r"(__gu_val), "=r"(__gu_err)					\
-		: "m"(__m(addr)), "1"(__gu_err));
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+		: "=r"(__gu_val), "=r"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
 
-#define __get_user_8(addr)								\
+#define __get_user_8(addr)									\
 	__asm__ ("\n1:\tld1 %0=%2%P2\t// %0 and %1 get overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 (2b-1b)|1\n"						\
-		 "\t.previous"								\
-		: "=r"(__gu_val), "=r"(__gu_err)					\
-		: "m"(__m(addr)), "1"(__gu_err));
-
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+		: "=r"(__gu_val), "=r"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
 
 extern void __put_user_unknown (void);
 
@@ -206,46 +188,26 @@
 #define __put_user_64(x,addr)								\
 	__asm__ __volatile__ (								\
 		 "\n1:\tst8 %1=%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 2b-1b\n"							\
-		 "\t.previous"								\
-		: "=r"(__pu_err)							\
-		: "m"(__m(addr)), "rO"(x), "0"(__pu_err))
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+		: "=r"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
 
 #define __put_user_32(x,addr)								\
 	__asm__ __volatile__ (								\
 		 "\n1:\tst4 %1=%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 2b-1b\n"							\
-		 "\t.previous"								\
-		: "=r"(__pu_err)							\
-		: "m"(__m(addr)), "rO"(x), "0"(__pu_err))
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+		: "=r"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
 
 #define __put_user_16(x,addr)								\
 	__asm__ __volatile__ (								\
 		 "\n1:\tst2 %1=%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 2b-1b\n"							\
-		 "\t.previous"								\
-		: "=r"(__pu_err)							\
-		: "m"(__m(addr)), "rO"(x), "0"(__pu_err))
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+		: "=r"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
 
 #define __put_user_8(x,addr)								\
 	__asm__ __volatile__ (								\
 		 "\n1:\tst1 %1=%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n"									\
-		 "\t.section __ex_table,\"a\"\n"					\
-		 "\t\tdata4 @gprel(1b)\n"						\
-		 "\t\tdata4 2b-1b\n"							\
-		 "\t.previous"								\
-		: "=r"(__pu_err)							\
-		: "m"(__m(addr)), "rO"(x), "0"(__pu_err))
+		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+		: "=r"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
 
 /*
  * Complex access routines
diff -urN linux-davidm/include/asm-ia64/unistd.h lia64/include/asm-ia64/unistd.h
--- linux-davidm/include/asm-ia64/unistd.h	Mon Oct 30 23:54:14 2000
+++ lia64/include/asm-ia64/unistd.h	Tue Oct 31 00:18:03 2000
@@ -160,7 +160,7 @@
 #define __NR_nanosleep			1168
 #define __NR_nfsservctl			1169
 #define __NR_prctl			1170
-#define __NR_getpagesize		1171
+/* 1171 is reserved for backwards compatibility with old __NR_getpagesize */
 #define __NR_mmap2			1172
 #define __NR_pciconfig_read		1173
 #define __NR_pciconfig_write		1174
diff -urN linux-davidm/include/linux/elf.h lia64/include/linux/elf.h
--- linux-davidm/include/linux/elf.h	Wed Oct  4 16:53:43 2000
+++ lia64/include/linux/elf.h	Mon Oct 30 22:58:27 2000
@@ -165,6 +165,7 @@
 #define AT_EGID   14	/* effective gid */
 #define AT_PLATFORM 15  /* string identifying CPU for optimizations */
 #define AT_HWCAP  16    /* arch dependent hints at CPU capabilities */
+#define AT_CLKTCK 17	/* frequency at which times() increments */
 
 typedef struct dynamic{
   Elf32_Sword d_tag;
diff -urN linux-davidm/include/linux/mm.h lia64/include/linux/mm.h
--- linux-davidm/include/linux/mm.h	Wed Oct  4 16:53:43 2000
+++ lia64/include/linux/mm.h	Mon Oct 30 22:58:40 2000
@@ -95,6 +95,8 @@
 
 #define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
 #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
+#define VM_WRITECOMBINED 0x00100000	/* Write-combined */
+#define VM_NONCACHED	0x00200000	/* Noncached access */
 
 #define VM_STACK_FLAGS	0x00000177
 
diff -urN linux-davidm/mm/mmap.c lia64/mm/mmap.c
--- linux-davidm/mm/mmap.c	Fri Sep  8 14:35:08 2000
+++ lia64/mm/mmap.c	Mon Oct 30 23:02:32 2000
@@ -151,6 +151,12 @@
 		_trans(prot, PROT_WRITE, VM_WRITE) |
 		_trans(prot, PROT_EXEC, VM_EXEC);
 	flag_bits +#ifdef MAP_WRITECOMBINED
+		_trans(flags, MAP_WRITECOMBINED, VM_WRITECOMBINED) |
+#endif
+#ifdef MAP_NONCACHED
+		_trans(flags, MAP_NONCACHED, VM_NONCACHED) |
+#endif
 		_trans(flags, MAP_GROWSDOWN, VM_GROWSDOWN) |
 		_trans(flags, MAP_DENYWRITE, VM_DENYWRITE) |
 		_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE);

