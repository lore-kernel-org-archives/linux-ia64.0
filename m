From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 07 Dec 2000 08:26:50 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.0-test11)
Message-Id: <marc-linux-ia64-105590678205807@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The directory at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

now has files linux-2.4.0-test11-ia64-001206.diff* which contain the
latest IA-64 kernel diff relative to Linus' 2.4.0-test11.

This patch makes a significant change to the virtual memory space of
IA-64 Linux: so far, within each region, the first N bytes and the
last N bytes could be mapped by a process (with N=3D2^39 when 8KB pages
are in use).  This patch changes this so that all mappable space is at
the beginning of a region.  That is, region offsets 0-(2*N-1) are now
mappable instead.  This change was necessary to fix the bug that Asit
discovered under heavy swap activity when the memory size was 256MB
(there is nothing magic about this size; the problem could have
occurred with other sizes as well).  Normal applications should not
notice this change, though if something has stack-related addresses
hardcoded, those applications need to be updated, obviously (it's
usually a bad idea to hardcode such things anyhow).

Other changes:

	- Matt: EFI CRC updates to avoid copyright issues
	- Andreas: fix typo in __NR_pivot_root
	- Jonathan: don't acquire xtime_lock in timer interrupt
	  of application processors
	- Kanoj: updates for SN1 machine
	- Intel: lots of ACPI updates (including ACPI 2.0 support)
	- Asit: place the virtual linear page table is at the end of a
	  region and make it big enough to map the entire implemented
	  virtual address within a region
	- Asit (I think): fix for software I/O TLB problems
	- export more kernel symbols for modules
	- platform_pci_fixup() is now called twice: once before
	  the PCI busscan and once after
	- NaT Consumption faults and Unsupported Data Reference faults
	  now result in SIGILL with no kernel messages printed; you can
	  tell from the siginfo's si_code and si_imm values what caused
	  the signal: si_code=3DILL_ILLOPN and si_imm& implies
	  NaT Consumption, si_imm1 implies Unsupported Data Reference
	- fix a bug in the IA-64 page fault handler which caused it to
	  pick up the wrong VMA for permission checking when
	  the VMA was growing towards higher addresses; this hasn't caused
	  any known errors, but was a potential source of problems and
	  had to be fixed; thanks to Matthew Willcox for pointing this out
	- fix for fcntl(F_GETOWN) failure reported by SCO (this is untested;
	  could someone from SCO rerun the test and let me know if it does
	  indeed fix the problem?)

CAVEAT: the kernel now relies on PAL_VM_SUMMARY returning the correct
value for IMPL_VA_MSB.  If you have old firmware, this may cause the kernel
to fail to boot.  To find out, look for the message of the form:

	CPU 0: XX virtual and YY physical address bits

if XX is anything other than 50, you need to upgrade your firmware.

This kernel is known to build and run on 2P Big Sur and the HP Ski
simulator.  I expect it to work fine on 4P Lion and UP as well.

As usual, the attached relative diff is fyi only.

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/Makefile lia64/arch/ia64/Makefile
--- linux-davidm/arch/ia64/Makefile	Mon Oct  9 17:54:53 2000
+++ lia64/arch/ia64/Makefile	Wed Dec  6 22:09:11 2000
@@ -19,22 +19,28 @@
 EXTRA	=20
 CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -Wa,-x -ffixed-r13 -mfixed-range=F10-=
f15,f32-f127 \
	  -funwind-tables
 CFLAGS_KERNEL :=3D -mconstant-gp
=20
 ifeq ($(CONFIG_ITANIUM_ASTEP_SPECIFIC),y)
 	CFLAGS +=3D -ma-step
 endif
+ifeq ($(CONFIG_ITANIUM_BSTEP_SPECIFIC),y)
+	CFLAGS +=3D -mb-step
+endif
=20
 ifdef CONFIG_IA64_GENERIC
 	CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.a	\
 				arch/$(ARCH)/sn/sn.a	\
 				arch/$(ARCH)/dig/dig.a	\
+				arch/$(ARCH)/sn/io/sgiio.o \
 				$(CORE_FILES)
 	SUBDIRS		:=3D	arch/$(ARCH)/hp		\
 				arch/$(ARCH)/sn/sn1	\
 				arch/$(ARCH)/sn		\
 				arch/$(ARCH)/dig	\
+				arch/$(ARCH)/sn/io	\
 				$(SUBDIRS)
=20
 else # !GENERIC
@@ -47,10 +53,7 @@
 endif
=20
 ifdef CONFIG_IA64_SGI_SN1
-CFLAGS :=3D $(CFLAGS) -DSN -I. -DBRINGUP -DDIRECT_L1_CONSOLE \
-		-DNUMA_BASE -DSIMULATED_KLGRAPH -DNUMA_MIGR_CONTROL  \
-		-DLITTLE_ENDIAN -DREAL_HARDWARE -DLANGUAGE_C=3D1 	     \
-		-D_LANGUAGE_C=3D1
+CFLAGS +=3D -DBRINGUP
         SUBDIRS         :=3D      arch/$(ARCH)/sn/sn1	\
 				arch/$(ARCH)/sn		\
 				arch/$(ARCH)/sn/io	\
@@ -96,7 +99,7 @@
=20
 arch/$(ARCH)/vmlinux.lds: arch/$(ARCH)/vmlinux.lds.S FORCE
 	$(CPP) -D__ASSEMBLY__ -C -P -I$(HPATH) -I$(HPATH)/asm-$(ARCH) \
-		arch/$(ARCH)/vmlinux.lds.S > $@
+		-traditional arch/$(ARCH)/vmlinux.lds.S > $@
=20
 FORCE: ;
=20
diff -urN linux-davidm/arch/ia64/config.in lia64/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/config.in	Wed Dec  6 22:09:46 2000
@@ -59,6 +59,7 @@
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable AzusA hacks' CONFIG_IA64_AZUSA_HACKS
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
+	bool '  Enable ACPI 2.0 with errata 1.3' CONFIG_ACPI20
 	bool '  ACPI kernel configuration manager (EXPERIMENTAL)' CONFIG_ACPI_KER=
NEL_CONFIG
 	if [ "$CONFIG_ACPI_KERNEL_CONFIG" =3D "y" ]; then
 	  define_bool CONFIG_PM y
@@ -79,8 +80,9 @@
 	define_bool CONFIG_DEVFS_FS y
 	define_bool CONFIG_IA64_BRL_EMU y
 	define_bool CONFIG_IA64_MCA y
-	define_bool CONFIG_IA64_SGI_IO y
 	define_bool CONFIG_ITANIUM y
+	define_bool CONFIG_SGI_IOC3_ETH y
+	bool '  Enable DISCONTIGMEM support' CONFIG_DISCONTIGMEM y
 fi
=20
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kco=
re.
diff -urN linux-davidm/arch/ia64/hp/hpsim_setup.c lia64/arch/ia64/hp/hpsim_=
setup.c
--- linux-davidm/arch/ia64/hp/hpsim_setup.c	Fri Jul 14 16:08:11 2000
+++ lia64/arch/ia64/hp/hpsim_setup.c	Wed Dec  6 22:10:09 2000
@@ -63,12 +63,6 @@
 }
=20
 void __init
-hpsim_pci_fixup (void)
-{
-}
-
-
-void __init
 hpsim_setup (char **cmdline_p)
 {
 	ROOT_DEV =3D to_kdev_t(0x0801);		/* default to first SCSI drive */
diff -urN linux-davidm/arch/ia64/kernel/acpi.c lia64/arch/ia64/kernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/acpi.c	Wed Dec  6 22:18:40 2000
@@ -8,6 +8,10 @@
  * Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 2000 Hewlett-Packard Co.
  * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000 Intel Corp.
+ * Copyright (C) 2000 J.I. Lee <jung-ik.lee@intel.com>
+ *      ACPI based kernel configuration manager.
+ *      ACPI 2.0 & IA64 ext 0.71
  */
=20
 #include <linux/config.h>
@@ -41,27 +45,82 @@
 asm (".weak iosapic_register_legacy_irq");
 asm (".weak iosapic_init");
=20
+const char *
+acpi_get_sysname (void)
+{
+	/* the following should go away once we have an ACPI parser: */
+#ifdef CONFIG_IA64_GENERIC
+	return "hpsim";
+#else
+# if defined (CONFIG_IA64_HP_SIM)
+	return "hpsim";
+# elif defined (CONFIG_IA64_SGI_SN1)
+	return "sn1";
+# elif defined (CONFIG_IA64_DIG)
+	return "dig";
+# else
+#	error Unknown platform.  Fix acpi.c.
+# endif
+#endif
+
+}
+
 /*
- * Identify usable CPU's and remember them for SMP bringup later.
+ * Configure legacy IRQ information.
  */
 static void __init
-acpi_lsapic (char *p)=20
+acpi_legacy_irq (char *p)
 {
-	int add =3D 1;
-
-	acpi_entry_lsapic_t *lsapic =3D (acpi_entry_lsapic_t *) p;
+	acpi_entry_int_override_t *legacy =3D (acpi_entry_int_override_t *) p;
+	unsigned long polarity =3D 0, edge_triggered =3D 0;
=20
-	if ((lsapic->flags & LSAPIC_PRESENT) =3D 0)=20
+	/*
+	 * If the platform we're running doesn't define
+	 * iosapic_register_legacy_irq(), we ignore this info...
+	 */
+	if (!iosapic_register_legacy_irq)
 		return;
=20
+	switch (legacy->flags) {
+	      case 0x5:	polarity =3D 1; edge_triggered =3D 1; break;
+	      case 0x7: polarity =3D 0; edge_triggered =3D 1; break;
+	      case 0xd: polarity =3D 1; edge_triggered =3D 0; break;
+	      case 0xf: polarity =3D 0; edge_triggered =3D 0; break;
+	      default:
+		printk("    ACPI Legacy IRQ 0x%02x: Unknown flags 0x%x\n", legacy->isa_i=
rq,
+		       legacy->flags);
+		break;
+	}
+	iosapic_register_legacy_irq(legacy->isa_irq, legacy->pin, polarity, edge_=
triggered);
+}
+
+/*
+ * ACPI 2.0 tables parsing functions
+ */
+
+static unsigned long
+readl_unaligned(void *p)
+{
+	unsigned long ret;
+
+	memcpy(&ret, p, sizeof(long));
+	return ret;
+}
+
+/*
+ * Identify usable CPU's and remember them for SMP bringup later.
+ */
+static void __init
+acpi20_lsapic (char *p)=20
+{
+	int add =3D 1;
+
+	acpi20_entry_lsapic_t *lsapic =3D (acpi20_entry_lsapic_t *) p;
 	printk("      CPU %d (%.04x:%.04x): ", total_cpus, lsapic->eid, lsapic->i=
d);
=20
 	if ((lsapic->flags & LSAPIC_ENABLED) =3D 0) {
 		printk("Disabled.\n");
 		add =3D 0;
-	} else if (lsapic->flags & LSAPIC_PERFORMANCE_RESTRICTED) {
-		printk("Performance Restricted; ignoring.\n");
-		add =3D 0;
 	}
=20
 #ifdef CONFIG_SMP
@@ -78,33 +137,223 @@
 }
=20
 /*
- * Configure legacy IRQ information.
+ * Info on platform interrupt sources: NMI. PMI, INIT, etc.
  */
 static void __init
-acpi_legacy_irq (char *p)
+acpi20_platform (char *p)
 {
-	acpi_entry_int_override_t *legacy =3D (acpi_entry_int_override_t *) p;
-	unsigned long polarity =3D 0, edge_triggered =3D 0;
+	acpi20_entry_platform_src_t *plat =3D (acpi20_entry_platform_src_t *) p;
+
+	printk("PLATFORM: IOSAPIC %x -> Vector %x on CPU %.04u:%.04u\n",
+	       plat->iosapic_vector, plat->global_vector, plat->eid, plat->id);
+}
+
+/*
+ * Override the physical address of the local APIC in the MADT stable head=
er.
+ */
+static void __init
+acpi20_lapic_addr_override (char *p)
+{
+	acpi20_entry_lapic_addr_override_t * lapic =3D (acpi20_entry_lapic_addr_o=
verride_t *) p;
+
+	if (lapic->lapic_address) {
+		iounmap((void *)ipi_base_addr);
+		ipi_base_addr =3D (unsigned long) ioremap(lapic->lapic_address, 0);
+
+		printk("LOCAL ACPI override to 0x%lx(p=3D0x%lx)\n",
+		       ipi_base_addr, lapic->lapic_address);
+	}
+}
+
+/*
+ * Parse the ACPI Multiple APIC Description Table
+ */
+static void __init
+acpi20_parse_madt (acpi_madt_t *madt)
+{
+	acpi_entry_iosapic_t *iosapic;
+	char *p, *end;
+
+	/* Base address of IPI Message Block */
+	if (madt->lapic_address) {
+		ipi_base_addr =3D (unsigned long) ioremap(madt->lapic_address, 0);
+		printk("Lapic address set to 0x%lx\n", ipi_base_addr);
+	} else
+		printk("Lapic address set to default 0x%lx\n", ipi_base_addr);
+
+	p =3D (char *) (madt + 1);
+	end =3D p + (madt->header.length - sizeof(acpi_madt_t));
=20
 	/*
-	 * If the platform we're running doesn't define
-	 * iosapic_register_legacy_irq(), we ignore this info...
+	 * Splitted entry parsing to ensure ordering.
 	 */
-	if (!iosapic_register_legacy_irq)
+
+	while (p < end) {
+		switch (*p) {
+		case ACPI20_ENTRY_LOCAL_APIC_ADDR_OVERRIDE:
+			printk("ACPI 2.0 MADT: LOCAL APIC Override\n");
+			acpi20_lapic_addr_override(p);
+			break;
+
+		case ACPI20_ENTRY_LOCAL_SAPIC:
+			printk("ACPI 2.0 MADT: LOCAL SAPIC\n");
+			acpi20_lsapic(p);
+			break;
+=09
+		case ACPI20_ENTRY_IO_SAPIC:
+			iosapic =3D (acpi_entry_iosapic_t *) p;
+			if (iosapic_init)
+				iosapic_init(iosapic->address, iosapic->irq_base);
+			break;
+
+		case ACPI20_ENTRY_PLATFORM_INT_SOURCE:
+			printk("ACPI 2.0 MADT: PLATFORM INT SOUCE\n");
+			acpi20_platform(p);
+			break;
+
+		case ACPI20_ENTRY_LOCAL_APIC:
+			printk("ACPI 2.0 MADT: LOCAL APIC entry\n"); break;
+		case ACPI20_ENTRY_IO_APIC:
+			printk("ACPI 2.0 MADT: IO APIC entry\n"); break;
+		case ACPI20_ENTRY_NMI_SOURCE:
+			printk("ACPI 2.0 MADT: NMI SOURCE entry\n"); break;
+		case ACPI20_ENTRY_LOCAL_APIC_NMI:
+			printk("ACPI 2.0 MADT: LOCAL APIC NMI entry\n"); break;
+		case ACPI20_ENTRY_INT_SRC_OVERRIDE:
+			break;
+		default:
+			printk("ACPI 2.0 MADT: unknown entry skip\n"); break;
+			break;
+		}
+
+		p +=3D p[1];
+	}
+
+	p =3D (char *) (madt + 1);
+	end =3D p + (madt->header.length - sizeof(acpi_madt_t));
+
+	while (p < end) {
+	=09
+		switch (*p) {
+		case ACPI20_ENTRY_INT_SRC_OVERRIDE:
+			printk("ACPI 2.0 MADT: INT SOURCE Override\n");
+			acpi_legacy_irq(p);
+			break;
+		default:
+			break;
+		}
+
+		p +=3D p[1];
+	}
+
+	/* Make bootup pretty */
+	printk("      %d CPUs available, %d CPUs total\n",
+		available_cpus, total_cpus);
+}
+
+int __init=20
+acpi20_parse (acpi20_rsdp_t *rsdp20)
+{
+	acpi_xsdt_t *xsdt;
+	acpi_desc_table_hdr_t *hdrp;
+	int tables, i;
+
+	if (strncmp(rsdp20->signature, ACPI_RSDP_SIG, ACPI_RSDP_SIG_LEN)) {
+		printk("ACPI 2.0 RSDP signature incorrect!\n");
+		return 0;
+	} else {
+		printk("ACPI 2.0 Root System Description Ptr at 0x%lx\n",
+			(unsigned long)rsdp20);
+	}
+
+	xsdt =3D __va(rsdp20->xsdt);
+	hdrp =3D &xsdt->header;
+	if (strncmp(hdrp->signature,
+		ACPI_XSDT_SIG, ACPI_XSDT_SIG_LEN)) {
+		printk("ACPI 2.0 XSDT signature incorrect. Trying RSDT\n");
+		/* RSDT parsing here */
+		return 0;
+	} else {
+		printk("ACPI 2.0 XSDT at 0x%lx (p=3D0x%lx)\n",
+		(unsigned long)xsdt, (unsigned long)rsdp20->xsdt);
+	}
+
+	printk("ACPI 2.0: %.6s %.8s %d.%d\n",
+		hdrp->oem_id,
+		hdrp->oem_table_id,
+		hdrp->oem_revision >> 16,
+		hdrp->oem_revision & 0xffff);
+
+#ifdef CONFIG_ACPI_KERNEL_CONFIG
+	acpi_cf_init((void *)rsdp20);
+#endif
+
+	tables =3D(hdrp->length -sizeof(acpi_desc_table_hdr_t))>>3;
+
+	for (i =3D 0; i < tables; i++) {
+		hdrp =3D (acpi_desc_table_hdr_t *) __va(readl_unaligned(&xsdt->entry_ptr=
s[i]));
+		printk("        :table %4.4s found\n", hdrp->signature);
+
+		/* Only interested int the MADT table for now ... */
+		if (strncmp(hdrp->signature,
+			ACPI_MADT_SIG, ACPI_MADT_SIG_LEN) !=3D 0)
+			continue;
+
+		acpi20_parse_madt((acpi_madt_t *) hdrp);
+	}
+
+#ifdef CONFIG_ACPI_KERNEL_CONFIG
+	acpi_cf_terminate();
+#endif
+
+#ifdef CONFIG_SMP
+	if (available_cpus =3D 0) {
+		printk("ACPI: Found 0 CPUS; assuming 1\n");
+		available_cpus =3D 1; /* We've got at least one of these, no? */
+	}
+	smp_boot_data.cpu_count =3D available_cpus;
+#endif
+	return 1;
+}
+/*
+ * ACPI 1.0b with 0.71 IA64 extensions functions; should be removed once a=
ll=20
+ * platforms start supporting ACPI 2.0
+ */
+
+/*
+ * Identify usable CPU's and remember them for SMP bringup later.
+ */
+static void __init
+acpi_lsapic (char *p)=20
+{
+	int add =3D 1;
+
+	acpi_entry_lsapic_t *lsapic =3D (acpi_entry_lsapic_t *) p;
+
+	if ((lsapic->flags & LSAPIC_PRESENT) =3D 0)=20
 		return;
=20
-	/* See MPS 1.4 section 4.3.4 */
-	switch (legacy->flags) {
-	      case 0x5:	polarity =3D 1; edge_triggered =3D 1; break;
-	      case 0x8: polarity =3D 0; edge_triggered =3D 1; break;
-	      case 0xd: polarity =3D 1; edge_triggered =3D 0; break;
-	      case 0xf: polarity =3D 0; edge_triggered =3D 0; break;
-	      default:
-		printk("    ACPI Legacy IRQ 0x%02x: Unknown flags 0x%x\n", legacy->isa_i=
rq,
-		       legacy->flags);
-		break;
+	printk("      CPU %d (%.04x:%.04x): ", total_cpus, lsapic->eid, lsapic->i=
d);
+
+	if ((lsapic->flags & LSAPIC_ENABLED) =3D 0) {
+		printk("Disabled.\n");
+		add =3D 0;
+	} else if (lsapic->flags & LSAPIC_PERFORMANCE_RESTRICTED) {
+		printk("Performance Restricted; ignoring.\n");
+		add =3D 0;
 	}
-	iosapic_register_legacy_irq(legacy->isa_irq, legacy->pin, polarity, edge_=
triggered);
+
+#ifdef CONFIG_SMP
+	smp_boot_data.cpu_phys_id[total_cpus] =3D -1;
+#endif
+	if (add) {
+		printk("Available.\n");
+		available_cpus++;
+#ifdef CONFIG_SMP
+		smp_boot_data.cpu_phys_id[total_cpus] =3D (lsapic->id << 8) | lsapic->ei=
d;
+#endif /* CONFIG_SMP */
+	}
+	total_cpus++;
 }
=20
 /*
@@ -115,7 +364,7 @@
 {
 	acpi_entry_platform_src_t *plat =3D (acpi_entry_platform_src_t *) p;
=20
-	printk("PLATFORM: IOSAPIC %x -> Vector %lx on CPU %.04u:%.04u\n",
+	printk("PLATFORM: IOSAPIC %x -> Vector %x on CPU %.04u:%.04u\n",
 	       plat->iosapic_vector, plat->global_vector, plat->eid, plat->id);
 }
=20
@@ -173,18 +422,12 @@
 	acpi_desc_table_hdr_t *hdrp;
 	long tables, i;
=20
-	if (!rsdp) {
-		printk("Uh-oh, no ACPI Root System Description Pointer table!\n");
-		return 0;
-	}
-
 	if (strncmp(rsdp->signature, ACPI_RSDP_SIG, ACPI_RSDP_SIG_LEN)) {
 		printk("Uh-oh, ACPI RSDP signature incorrect!\n");
 		return 0;
 	}
=20
-	rsdp->rsdt =3D __va(rsdp->rsdt);
-	rsdt =3D rsdp->rsdt;
+	rsdt =3D __va(rsdp->rsdt);
 	if (strncmp(rsdt->header.signature, ACPI_RSDT_SIG, ACPI_RSDT_SIG_LEN)) {
 		printk("Uh-oh, ACPI RDST signature incorrect!\n");
 		return 0;
@@ -220,23 +463,4 @@
 	smp_boot_data.cpu_count =3D available_cpus;
 #endif
 	return 1;
-}
-
-const char *
-acpi_get_sysname (void)
-{      =20
-	/* the following should go away once we have an ACPI parser: */
-#ifdef CONFIG_IA64_GENERIC
-	return "hpsim";
-#else
-# if defined (CONFIG_IA64_HP_SIM)
-	return "hpsim";
-# elif defined (CONFIG_IA64_SGI_SN1)
-	return "sn1";
-# elif defined (CONFIG_IA64_DIG)
-	return "dig";
-# else
-#	error Unknown platform.  Fix acpi.c.
-# endif
-#endif
 }
diff -urN linux-davidm/arch/ia64/kernel/efi.c lia64/arch/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/efi.c	Wed Dec  6 22:20:03 2000
@@ -332,6 +332,9 @@
 		if (efi_guidcmp(config_tables[i].guid, MPS_TABLE_GUID) =3D 0) {
 			efi.mps =3D __va(config_tables[i].table);
 			printk(" MPS=3D0x%lx", config_tables[i].table);
+		} else if (efi_guidcmp(config_tables[i].guid, ACPI_20_TABLE_GUID) =3D 0)=
 {
+			efi.acpi20 =3D __va(config_tables[i].table);
+			printk(" ACPI 2.0=3D0x%lx", config_tables[i].table);
 		} else if (efi_guidcmp(config_tables[i].guid, ACPI_TABLE_GUID) =3D 0) {
 			efi.acpi =3D __va(config_tables[i].table);
 			printk(" ACPI=3D0x%lx", config_tables[i].table);
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c lia64/arch/ia64/kernel=
/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Mon Oct  9 17:54:54 2000
+++ lia64/arch/ia64/kernel/ia64_ksyms.c	Wed Dec  6 22:20:30 2000
@@ -92,6 +92,9 @@
 #include <asm/uaccess.h>
 EXPORT_SYMBOL(__copy_user);
 EXPORT_SYMBOL(__do_clear_user);
+EXPORT_SYMBOL(__strlen_user);
+EXPORT_SYMBOL(__strncpy_from_user);
+EXPORT_SYMBOL(__strnlen_user);
=20
 #include <asm/unistd.h>
 EXPORT_SYMBOL(__ia64_syscall);
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c lia64/arch/ia64/kernel/io=
sapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/iosapic.c	Wed Dec  6 22:22:38 2000
@@ -443,11 +443,14 @@
 }
=20
 void
-iosapic_pci_fixup (void)
+iosapic_pci_fixup (int phase)
 {
 	struct	pci_dev	*dev;
 	unsigned char pin;
 	int vector;
+
+	if (phase !=3D 1)
+		return;
=20
 	pci_for_each_dev(dev) {
 		pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pin);
diff -urN linux-davidm/arch/ia64/kernel/ivt.S lia64/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/ivt.S	Wed Dec  6 22:21:29 2000
@@ -112,15 +112,14 @@
 (p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
 	srlz.d					// ensure "rsm psr.dt" has taken effect
 (p6)	movl r19=3D__pa(SWAPPER_PGD_ADDR)		// region 5 is rooted at swapper_p=
g_dir
-(p6)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-1
-(p7)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-4
+(p6)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
 (p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3DPTA + IFA(33,42)*8
 (p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3DPTA + (((IFA(61,63) << 7)=
 | IFA(33,39))*8)
 	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
 	shr.u r18=3Dr16,PMD_SHIFT			// shift L2 index into position
 	;;
-(p6)	cmp.eq p7,p6=3D-1,r21			// unused address bits all ones?
 	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?
@@ -222,15 +221,14 @@
 (p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
 	srlz.d					// ensure "rsm psr.dt" has taken effect
 (p6)	movl r19=3D__pa(SWAPPER_PGD_ADDR)		// region 5 is rooted at swapper_p=
g_dir
-(p6)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-1
-(p7)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-4
+(p6)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
 (p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3DPTA + IFA(33,42)*8
 (p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3DPTA + (((IFA(61,63) << 7)=
 | IFA(33,39))*8)
 	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
 	shr.u r18=3Dr16,PMD_SHIFT			// shift L2 index into position
 	;;
-(p6)	cmp.eq p7,p6=3D-1,r21			// unused address bits all ones?
 	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?
@@ -309,15 +307,14 @@
 (p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
 	srlz.d					// ensure "rsm psr.dt" has taken effect
 (p6)	movl r19=3D__pa(SWAPPER_PGD_ADDR)		// region 5 is rooted at swapper_p=
g_dir
-(p6)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-1
-(p7)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-4
+(p6)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
+(p7)	shr r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
 (p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3DPTA + IFA(33,42)*8
 (p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3DPTA + (((IFA(61,63) << 7)=
 | IFA(33,39))*8)
 	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
 	shr.u r18=3Dr16,PMD_SHIFT			// shift L2 index into position
 	;;
-(p6)	cmp.eq p7,p6=3D-1,r21			// unused address bits all ones?
 	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?
@@ -351,28 +348,31 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
-#ifdef CONFIG_DISABLE_VHPT
+	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX
+	mov r21=3Dcr.ipsr
 	mov r31=3Dpr
 	;;
-	shr.u r21=3Dr16,61			// get the region number into r21
-	;;
-	cmp.gt p6,p0=3D6,r21			// user mode=20
-(p6)	br.cond.dptk.many itlb_fault
+#ifdef CONFIG_DISABLE_VHPT
+	shr.u r22=3Dr16,61			// get the region number into r21
 	;;
-	mov pr=3Dr31,-1
+	cmp.gt p8,p0=3D6,r22			// user mode=20
+(p8)	br.cond.dptk.many itlb_fault
 #endif
-	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX
-	;;
+	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
-	dep r16=3D0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS)	// clear ed & =
reserved bits
+	dep r19=3D0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS)	// clear ed & =
reserved bits
 	;;
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
-	dep r16=3Dr17,r16,0,12	// insert PTE control bits into r16
+	cmp.ne p8,p0=3Dr0,r23	// psr.cpl !=3D 0?
+	dep r19=3Dr17,r19,0,12	// insert PTE control bits into r19
 	;;
-	or r16=3Dr16,r18		// set bit 4 (uncached) if the access was to region 6
+	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to region 6
+(p8)	br.cond.spnt.many page_fault
 	;;
-	itc.i r16		// insert the TLB entry
+	itc.i r19		// insert the TLB entry
+	mov pr=3Dr31,-1
 	rfi
+	;;
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -389,21 +389,24 @@
 	cmp.gt p8,p0=3D6,r22			// user mode
 (p8)	br.cond.dptk.many dtlb_fault
 #endif
+	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	tbit.nz p6,p7=3Dr20,IA64_ISR_SP_BIT	// is speculation bit on?
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
-	dep r16=3D0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS) // clear ed & =
reserved bits
+	dep r19=3D0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS) // clear ed & =
reserved bits
 	;;
-	dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
-	dep r16=3Dr17,r16,0,12	// insert PTE control bits into r16
+	cmp.ne p8,p0=3Dr0,r23
+(p8)	br.cond.spnt.many page_fault
+
+	dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
+	dep r19=3Dr17,r19,0,12	// insert PTE control bits into r19
 	;;
-	or r16=3Dr16,r18		// set bit 4 (uncached) if the access was to region 6
+	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to region 6
 (p6)	mov cr.ipsr=3Dr21
 	;;
-(p7)	itc.d r16		// insert the TLB entry
+(p7)	itc.d r19		// insert the TLB entry
 	mov pr=3Dr31,-1
 	rfi
-
 	;;
=20
 	//-----------------------------------------------------------------------=
------------
@@ -870,6 +873,7 @@
 	cmp.ne p6,p0=3D0,r8
 (p6)	br.call.dpnt b6=B6		// call returns to ia64_leave_kernel
 	br.sptk ia64_leave_kernel
+	;;
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
diff -urN linux-davidm/arch/ia64/kernel/pci-dma.c lia64/arch/ia64/kernel/pc=
i-dma.c
--- linux-davidm/arch/ia64/kernel/pci-dma.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/pci-dma.c	Wed Dec  6 22:22:55 2000
@@ -24,7 +24,8 @@
 #include <linux/init.h>
 #include <linux/bootmem.h>
=20
-#define ALIGN(val, align) ((unsigned long) (((unsigned long) (val) + ((ali=
gn) - 1)) & ~((align) - 1)))
+#define ALIGN(val, align) ((unsigned long)	\
+	(((unsigned long) (val) + ((align) - 1)) & ~((align) - 1)))
=20
 /*
  * log of the size of each IO TLB slab.  The number of slabs is command li=
ne
@@ -109,7 +110,8 @@
 {
 	unsigned long flags;
 	char *dma_addr;
-	unsigned int i, nslots, stride, index, wrap;
+	unsigned int nslots, stride, index, wrap;
+	int i;
=20
 	/*
 	 * For mappings greater than a page size, we limit the stride (and hence =
alignment)
@@ -133,7 +135,7 @@
 		wrap =3D index =3D ALIGN(io_tlb_index, stride);
=20
 		if (index >=3D io_tlb_nslabs)=20
-			index =3D 0;
+			wrap =3D index =3D 0;
=20
 		do {
 			/*
@@ -142,14 +144,19 @@
 			 * entries as '0' indicating unavailable.
 			 */
 			if (io_tlb_list[index] >=3D nslots) {
+				int count =3D 0;
+
 				for (i =3D index; i < index + nslots; i++)
 					io_tlb_list[i] =3D 0;
+				for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
+					io_tlb_list[i] =3D ++count;
 				dma_addr =3D io_tlb_start + (index << IO_TLB_SHIFT);
=20
 				/*
 				 * Update the indices to avoid searching in the next round.
 				 */
-				io_tlb_index =3D (index + nslots) < io_tlb_nslabs ? (index + nslots) :=
 0;
+				io_tlb_index =3D ((index + nslots) < io_tlb_nslabs
+						? (index + nslots) : 0);
=20
 				goto found;
 			}
@@ -209,15 +216,17 @@
 	{
 		int count =3D ((index + nslots) < io_tlb_nslabs ? io_tlb_list[index + ns=
lots] : 0);
 		/*
-		 * Step 1: return the slots to the free list, merging the slots with sup=
erceeding slots
+		 * Step 1: return the slots to the free list, merging the slots with
+		 * superceeding slots
 		 */
 		for (i =3D index + nslots - 1; i >=3D index; i--)
 			io_tlb_list[i] =3D ++count;
 		/*
-		 * Step 2: merge the returned slots with the preceeding slots, if availa=
ble (non zero)
+		 * Step 2: merge the returned slots with the preceeding slots, if
+		 * available (non zero)
 		 */
 		for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
-			io_tlb_list[i] +=3D io_tlb_list[index];
+			io_tlb_list[i] =3D ++count;
 	}
 	spin_unlock_irqrestore(&io_tlb_lock, flags);
 }
diff -urN linux-davidm/arch/ia64/kernel/pci.c lia64/arch/ia64/kernel/pci.c
--- linux-davidm/arch/ia64/kernel/pci.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/pci.c	Wed Dec  6 22:23:15 2000
@@ -122,10 +122,13 @@
 #	define PCI_BUSES_TO_SCAN 255
 	int i;
=20
+	platform_pci_fixup(0);	/* phase 0 initialization (before PCI bus has been=
 scanned) */
+
 	printk("PCI: Probing PCI hardware\n");
 	for (i =3D 0; i < PCI_BUSES_TO_SCAN; i++)=20
 		pci_scan_bus(i, &pci_conf, NULL);
-	platform_pci_fixup();
+
+	platform_pci_fixup(1);	/* phase 1 initialization (after PCI bus has been =
scanned) */
 	return;
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/setup.c lia64/arch/ia64/kernel/setu=
p.c
--- linux-davidm/arch/ia64/kernel/setup.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/setup.c	Wed Dec  6 22:23:29 2000
@@ -235,6 +235,12 @@
 	machvec_init(acpi_get_sysname());
 #endif
=20
+#ifdef	CONFIG_ACPI20
+	if (efi.acpi20) {
+		/* Parse the ACPI 2.0 tables */
+		acpi20_parse(efi.acpi20);
+	} else=20
+#endif
 	if (efi.acpi) {
 		/* Parse the ACPI tables */
 		acpi_parse(efi.acpi);
@@ -376,15 +382,7 @@
=20
 	status =3D ia64_pal_vm_summary(&vm1, &vm2);
 	if (status =3D PAL_STATUS_SUCCESS) {
-#if 1
-		/*
-		 * XXX the current PAL code returns IMPL_VA_MSB=3D60, which is dead-wron=
g.
-		 * --davidm 00/05/26
-		 s*/
-		impl_va_msb =3D 50;
-#else
 		impl_va_msb =3D vm2.pal_vm_info_2_s.impl_va_msb;
-#endif
 		phys_addr_size =3D vm1.pal_vm_info_1_s.phys_add_size;
 	}
 	printk("CPU %d: %lu virtual and %lu physical address bits\n",
diff -urN linux-davidm/arch/ia64/kernel/sys_ia64.c lia64/arch/ia64/kernel/s=
ys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Mon Oct  9 17:54:55 2000
+++ lia64/arch/ia64/kernel/sys_ia64.c	Wed Dec  6 22:24:07 2000
@@ -95,10 +95,10 @@
 static inline unsigned long
 do_mmap2 (unsigned long addr, unsigned long len, int prot, int flags, int =
fd, unsigned long pgoff)
 {
-	unsigned long loff, hoff;
+	unsigned long roff;
 	struct file *file =3D 0;
 	/* the virtual address space that is mappable in each region: */
-#	define OCTANT_SIZE	((PTRS_PER_PGD<<PGDIR_SHIFT)/8)
+#	define OCTANT_SIZE	(1UL << (4*PAGE_SHIFT - 12))
=20
 	/*
 	 * A zero mmap always succeeds in Linux, independent of
@@ -107,15 +107,12 @@
 	if (PAGE_ALIGN(len) =3D 0)
 		return addr;
=20
-	/* Don't permit mappings into or across the address hole in a region: */
-	loff =3D rgn_offset(addr);
-	hoff =3D loff - (RGN_SIZE - OCTANT_SIZE/2);
-	if ((len | loff | (loff + len)) >=3D OCTANT_SIZE/2
-	    && (len | hoff | (hoff + len)) >=3D OCTANT_SIZE/2)
+	/* don't permit mappings into unmapped space or the virtual page table of=
 a region: */
+	roff =3D rgn_offset(addr);
+	if ((len | roff | (roff + len)) >=3D OCTANT_SIZE)
 		return -EINVAL;
=20
-	/* Don't permit mappings that would cross a region boundary: */
-
+	/* don't permit mappings that would cross a region boundary: */
 	if (rgn_index(addr) !=3D rgn_index(addr + len))
 		return -EINVAL;
=20
diff -urN linux-davidm/arch/ia64/kernel/time.c lia64/arch/ia64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Mon Oct  9 17:54:55 2000
+++ lia64/arch/ia64/kernel/time.c	Wed Dec  6 22:24:20 2000
@@ -152,19 +152,7 @@
 {
 	int cpu =3D smp_processor_id();
 	unsigned long new_itm;
-#if 0
-	static unsigned long last_time;
-	static unsigned char count;
-	int printed =3D 0;
-#endif
=20
-	/*
-	 * Here we are in the timer irq handler. We have irqs locally
-	 * disabled, but we don't know if the timer_bh is running on
-	 * another CPU. We need to avoid to SMP race by acquiring the
-	 * xtime_lock.
-	 */
-	write_lock(&xtime_lock);
 	new_itm =3D itm.next[cpu].count;
=20
 	if (!time_after(ia64_get_itc(), new_itm))
@@ -173,48 +161,33 @@
=20
 	while (1) {
 		/*
-		 * Do kernel PC profiling here.  We multiply the
-		 * instruction number by four so that we can use a
-		 * prof_shift of 2 to get instruction-level instead of
-		 * just bundle-level accuracy.
+		 * Do kernel PC profiling here.  We multiply the instruction number by
+		 * four so that we can use a prof_shift of 2 to get instruction-level
+		 * instead of just bundle-level accuracy.
 		 */
 		if (!user_mode(regs))=20
 			do_profile(regs->cr_iip + 4*ia64_psr(regs)->ri);
=20
 #ifdef CONFIG_SMP
 		smp_do_timer(regs);
-		if (smp_processor_id() =3D 0)
-			do_timer(regs);
-#else
-		do_timer(regs);
 #endif
+		if (smp_processor_id() =3D 0) {
+			/*
+			 * Here we are in the timer irq handler. We have irqs locally
+			 * disabled, but we don't know if the timer_bh is running on
+			 * another CPU. We need to avoid to SMP race by acquiring the
+			 * xtime_lock.
+			 */
+			write_lock(&xtime_lock);
+			do_timer(regs);
+			write_unlock(&xtime_lock);
+		}
=20
 		new_itm +=3D itm.delta;
 		itm.next[cpu].count =3D new_itm;
 		if (time_after(new_itm, ia64_get_itc()))
 			break;
-
-#if 0
-		/*
-		 * SoftSDV in SMP mode is _slow_, so we do "lose" ticks,=20
-		 * but it's really OK...
-		 */
-		if (count > 0 && jiffies - last_time > 5*HZ)
-			count =3D 0;
-		if (count++ =3D 0) {
-			last_time =3D jiffies;
-			if (!printed) {
-				printk("Lost clock tick on CPU %d (now=3D%lx, next=3D%lx)!!\n",
-				       cpu, ia64_get_itc(), itm.next[cpu].count);
-				printed =3D 1;
-# ifdef CONFIG_IA64_DEBUG_IRQ
-				printk("last_cli_ip=3D%lx\n", last_cli_ip);
-# endif
-			}
-		}
-#endif
 	}
-	write_unlock(&xtime_lock);
=20
 	/*
 	 * If we're too close to the next clock tick for comfort, we
diff -urN linux-davidm/arch/ia64/kernel/traps.c lia64/arch/ia64/kernel/trap=
s.c
--- linux-davidm/arch/ia64/kernel/traps.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/kernel/traps.c	Wed Dec  6 22:24:51 2000
@@ -78,7 +78,7 @@
 die_if_kernel (char *str, struct pt_regs *regs, long err)
 {
 	if (user_mode(regs)) {
-#if 1
+#if 0
 		/* XXX for debugging only */
 		printk ("!!die_if_kernel: %s(%d): %s %ld\n",
 			current->comm, current->pid, str, err);
@@ -484,6 +484,20 @@
 		sprintf(buf, "Disabled FPL fault---not supposed to happen!");
 		break;
=20
+	      case 26: /* NaT Consumption */
+	      case 31: /* Unsupported Data Reference */
+		if (user_mode(regs)) {
+			siginfo.si_signo =3D SIGILL;
+			siginfo.si_code =3D ILL_ILLOPN;
+			siginfo.si_errno =3D 0;
+			siginfo.si_addr =3D (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_imm =3D vector;
+			force_sig_info(SIGILL, &siginfo, current);
+			return;
+		}
+		sprintf(buf, (vector =3D 26) ? "NaT consumption" : "Unsupported data ref=
erence");
+		break;
+
 	      case 29: /* Debug */
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
@@ -522,10 +536,10 @@
=20
 	      case 34:		/* Unimplemented Instruction Address Trap */
 		if (user_mode(regs)) {
-			printk("Woah! Unimplemented Instruction Address Trap!\n");
-			siginfo.si_code =3D ILL_BADIADDR;
 			siginfo.si_signo =3D SIGILL;
+			siginfo.si_code =3D ILL_BADIADDR;
 			siginfo.si_errno =3D 0;
+			siginfo.si_addr =3D (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 			force_sig_info(SIGILL, &siginfo, current);
 			return;
 		}
@@ -544,7 +558,8 @@
=20
 	      case 46:
 		printk("Unexpected IA-32 intercept trap (Trap 46)\n");
-		printk("  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx, iim - 0x%lx\n", regs->c=
r_iip, ifa, isr, iim);
+		printk("  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx, iim - 0x%lx\n",
+		       regs->cr_iip, ifa, isr, iim);
 		force_sig(SIGSEGV, current);
 		return;
=20
diff -urN linux-davidm/arch/ia64/lib/memcpy.S lia64/arch/ia64/lib/memcpy.S
--- linux-davidm/arch/ia64/lib/memcpy.S	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/lib/memcpy.S	Wed Dec  6 22:25:15 2000
@@ -106,6 +106,13 @@
 (p7)	br.cond.spnt.few memcpy_short
 (p6)	br.cond.spnt.few memcpy_long
 	;;
+	nop.m	0
+	;;
+	nop.m	0
+	nop.i	0
+	;;
+	nop.m	0
+	;;
 	.rotr val[N]
 	.rotp p[N]
 	.align 32
@@ -139,6 +146,15 @@
 	;;
 	mov ar.lc=3Dcnt
 	;;
+	nop.m	0		=09
+	;;
+	nop.m	0
+	nop.i	0
+	;;
+	nop.m	0
+	;;
+	nop.m	0
+	;;
 	/*
 	 * It is faster to put a stop bit in the loop here because it makes
 	 * the pipeline shorter (and latency is what matters on short copies).
@@ -249,6 +265,13 @@
 	add t4=3Dt0,t4
 	mov pr=3Dcnt,0x38			// set (p5,p4,p3) to # of bytes last-word bytes to co=
py
 	mov ar.lc=3Dt2
+	;;
+	nop.m	0		=09
+	;;
+	nop.m	0
+	nop.i	0
+	;;
+	nop.m	0
 	;;
 (p6)	ld8 val[1]=3D[src2],8		// prime the pump...
 	mov b6=3Dt4
diff -urN linux-davidm/arch/ia64/mm/fault.c lia64/arch/ia64/mm/fault.c
--- linux-davidm/arch/ia64/mm/fault.c	Thu Jun 22 07:09:45 2000
+++ lia64/arch/ia64/mm/fault.c	Wed Dec  6 22:25:31 2000
@@ -121,17 +121,19 @@
 			goto bad_area;
 		if (expand_stack(vma, address))
 			goto bad_area;
-	} else if (expand_backing_store(prev_vma, address))
-		goto bad_area;
+	} else {
+		vma =3D prev_vma;
+		if (expand_backing_store(vma, address))
+			goto bad_area;
+	}
 	goto good_area;
=20
   bad_area:
 	up(&mm->mmap_sem);
 	if (isr & IA64_ISR_SP) {
 		/*
-		 * This fault was due to a speculative load set the
-		 * "ed" bit in the psr to ensure forward progress
-		 * (target register will get a NaT).
+		 * This fault was due to a speculative load set the "ed" bit in the psr =
to
+		 * ensure forward progress (target register will get a NaT).
 		 */
 		ia64_psr(regs)->ed =3D 1;
 		return;
@@ -146,6 +148,15 @@
 	}
=20
   no_context:
+	if (isr & IA64_ISR_SP) {
+		/*
+		 * This fault was due to a speculative load set the "ed" bit in the psr =
to
+		 * ensure forward progress (target register will get a NaT).
+		 */
+		ia64_psr(regs)->ed =3D 1;
+		return;
+	}
+
 	fix =3D search_exception_table(regs->cr_iip);
 	if (fix) {
 		regs->r8 =3D -EFAULT;
diff -urN linux-davidm/arch/ia64/mm/init.c lia64/arch/ia64/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/mm/init.c	Wed Dec  6 22:26:21 2000
@@ -313,7 +313,12 @@
 void __init
 ia64_rid_init (void)
 {
-	unsigned long flags, rid, pta, impl_va_msb;
+	unsigned long flags, rid, pta, impl_va_bits;
+#ifdef CONFIG_DISABLE_VHPT
+#	define VHPT_ENABLE_BIT	0
+#else
+#	define VHPT_ENABLE_BIT	1
+#endif
=20
 	/* Set up the kernel identity mappings (regions 6 & 7) and the vmalloc ar=
ea (region 5): */
 	ia64_clear_ic(flags);
@@ -330,44 +335,46 @@
 	__restore_flags(flags);
=20
 	/*
-	 * Check if the virtually mapped linear page table (VMLPT)
-	 * overlaps with a mapped address space.  The IA-64
-	 * architecture guarantees that at least 50 bits of virtual
-	 * address space are implemented but if we pick a large enough
-	 * page size (e.g., 64KB), the VMLPT is big enough that it
-	 * will overlap with the upper half of the kernel mapped
-	 * region.  I assume that once we run on machines big enough
-	 * to warrant 64KB pages, IMPL_VA_MSB will be significantly
-	 * bigger, so we can just adjust the number below to get
-	 * things going.  Alternatively, we could truncate the upper
-	 * half of each regions address space to not permit mappings
-	 * that would overlap with the VMLPT.  --davidm 99/11/13
+	 * Check if the virtually mapped linear page table (VMLPT) overlaps with =
a mapped
+	 * address space.  The IA-64 architecture guarantees that at least 50 bit=
s of
+	 * virtual address space are implemented but if we pick a large enough pa=
ge size
+	 * (e.g., 64KB), the mapped address space is big enough that it will over=
lap with
+	 * VMLPT.  I assume that once we run on machines big enough to warrant 64=
KB pages,
+	 * IMPL_VA_MSB will be significantly bigger, so this is unlikely to becom=
e a
+	 * problem in practice.  Alternatively, we could truncate the top of the =
mapped
+	 * address space to not permit mappings that would overlap with the VMLPT.
+	 * --davidm 00/12/06
+	 */
+#	define pte_bits			3
+#	define mapped_space_bits	(3*(PAGE_SHIFT - pte_bits) + PAGE_SHIFT)
+	/*
+	 * The virtual page table has to cover the entire implemented address spa=
ce within
+	 * a region even though not all of this space may be mappable.  The reaso=
n for
+	 * this is that the Access bit and Dirty bit fault handlers perform
+	 * non-speculative accesses to the virtual page table, so the address ran=
ge of the
+	 * virtual page table itself needs to be covered by virtual page table.
 	 */
-#	define ld_pte_size		3
-#	define ld_max_addr_space_pages	3*(PAGE_SHIFT - ld_pte_size) /* max # of =
mappable pages */
-#	define ld_max_addr_space_size	(ld_max_addr_space_pages + PAGE_SHIFT)
-#	define ld_max_vpt_size		(ld_max_addr_space_pages + ld_pte_size)
+#	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
 #	define POW2(n)			(1ULL << (n))
-	impl_va_msb =3D ffz(~my_cpu_data.unimpl_va_mask) - 1;
=20
-	if (impl_va_msb < 50 || impl_va_msb > 60)
-		panic("Bogus impl_va_msb value of %lu!\n", impl_va_msb);
+	impl_va_bits =3D ffz(~my_cpu_data.unimpl_va_mask);
=20
-	if (POW2(ld_max_addr_space_size - 1) + POW2(ld_max_vpt_size) > POW2(impl_=
va_msb))
+	if (impl_va_bits < 51 || impl_va_bits > 61)
+		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
+
+	/* place the VMLPT at the end of each page-table mapped region: */
+	pta =3D POW2(61) - POW2(vmlpt_bits);
+
+	if (POW2(mapped_space_bits) >=3D pta)
 		panic("mm/init: overlap between virtually mapped linear page table and "
 		      "mapped kernel space!");
-	pta =3D POW2(61) - POW2(impl_va_msb);
-#ifndef CONFIG_DISABLE_VHPT
 	/*
 	 * Set the (virtually mapped linear) page table address.  Bit
 	 * 8 selects between the short and long format, bits 2-7 the
 	 * size of the table, and bit 0 whether the VHPT walker is
 	 * enabled.
 	 */
-	ia64_set_pta(pta | (0<<8) | ((3*(PAGE_SHIFT-3)+3)<<2) | 1);
-#else
-	ia64_set_pta(pta | (0<<8) | ((3*(PAGE_SHIFT-3)+3)<<2) | 0);
-#endif
+	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | VHPT_ENABLE_BIT);
 }
=20
 /*
diff -urN linux-davidm/arch/ia64/mm/tlb.c lia64/arch/ia64/mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Wed Dec  6 23:15:23 2000
+++ lia64/arch/ia64/mm/tlb.c	Wed Dec  6 22:26:48 2000
@@ -194,7 +194,11 @@
=20
 	if (mm !=3D current->active_mm) {
 		/* this does happen, but perhaps it's not worth optimizing for? */
+#ifdef CONFIG_SMP
+		flush_tlb_all();
+#else
 		mm->context =3D 0;
+#endif
 		return;
 	}
=20
diff -urN linux-davidm/drivers/acpi/Makefile lia64/drivers/acpi/Makefile
--- linux-davidm/drivers/acpi/Makefile	Wed Dec  6 23:15:23 2000
+++ lia64/drivers/acpi/Makefile	Mon Nov 20 17:45:48 2000
@@ -2,7 +2,7 @@
 # Makefile for the Linux ACPI interpreter
 #
=20
-SUB_DIRS        :+SUB_DIRS        :=3D=20
 MOD_SUB_DIRS    :=3D $(SUB_DIRS)
 MOD_IN_SUB_DIRS : ALL_SUB_DIRS    :=3D $(SUB_DIRS)
@@ -12,27 +12,33 @@
 M_OBJS   :=20
 export ACPI_CFLAGS
-#ACPI_CFLAGS :=3D -D_LINUX -DCONFIG_ACPI_KERNEL_CONFIG_CBN_FIX -DCONFIG_AC=
PI_KERNEL_CONFIG_ONLY -DCONFIG_ACPI_KERNEL_CONFIG_DEBUG -DCONFIG_ACPI_KERNE=
L_CONFIG_BM_PROFILE
-ACPI_CFLAGS :=3D -D_LINUX -DCONFIG_ACPI_KERNEL_CONFIG_CBN_FIX -DCONFIG_ACP=
I_KERNEL_CONFIG_ONLY
+ifdef CONFIG_ACPI_KERNEL_CONFIG
+  ACPI_CFLAGS :=3D -D_LINUX -DCONFIG_ACPI_KERNEL_CONFIG_ONLY
+else
+  ACPI_CFLAGS :=3D -D_LINUX
+endif
=20
 EXTRA_CFLAGS +=3D -I./include
=20
 EXTRA_CFLAGS +=3D $(ACPI_CFLAGS)
=20
 # if the interpreter is used, it overrides arch/i386/kernel/acpi.c
-ifeq ($(CONFIG_ACPI_INTERPRETER),y)
+ifeq ($(CONFIG_ACPI),y)
+
   SUB_DIRS +=3D common dispatcher events hardware\
 	      interpreter namespace parser resources tables
+
   ACPI_OBJS :=3D $(patsubst %,%.o,$(SUB_DIRS))
 #  ACPI_OBJS +=3D $(patsubst %.c,%.o,$(wildcard *.c))
=20
 ifdef CONFIG_ACPI_KERNEL_CONFIG
   ACPI_OBJS +=3D acpiconf.o osconf.o os.o
 else
-  ACPI_OBJS +=3D driver.o ec.o cpu.o os.o sys.o table.o
+  ACPI_OBJS +=3D driver.o cmbatt.o cpu.o ec.o ksyms.o os.o sys.o table.o
 endif
=20
   O_OBJS +=3D $(ACPI_OBJS)
+  OX_OBJS =3D ksyms.o
 endif
=20
 include $(TOPDIR)/Rules.make
diff -urN linux-davidm/fs/fcntl.c lia64/fs/fcntl.c
--- linux-davidm/fs/fcntl.c	Wed Dec  6 18:33:28 2000
+++ lia64/fs/fcntl.c	Wed Dec  6 22:36:29 2000
@@ -269,6 +269,7 @@
 			 * to fix this will be in libc.
 			 */
 			err =3D filp->f_owner.pid;
+			force_successful_syscall_return();
 			break;
 		case F_SETOWN:
 			lock_kernel();
diff -urN linux-davidm/fs/partitions/efi.c lia64/fs/partitions/efi.c
--- linux-davidm/fs/partitions/efi.c	Wed Dec  6 23:15:23 2000
+++ lia64/fs/partitions/efi.c	Wed Dec  6 22:36:43 2000
@@ -4,8 +4,12 @@
  * http://developer.intel.com/technology/efi/efi.htm
  * efi.[ch] by Matt Domsch <Matt_Domsch@dell.com>=20
  *   Copyright 2000 Dell Computer Corporation
- * CRC routines taken from the EFI Sample Implementation,
- *   1999.12.31, lib/crc.c
+ *
+ * Note, the EFI Specification, v0.99, has a reference to
+ * Dr. Dobbs Journal, May 1994 (actually it's in May 1992)
+ * but that isn't the CRC function being used by EFI.  Intel's
+ * EFI Sample Implementation shows that they use the same function
+ * as was COPYRIGHT (C) 1986 Gary S. Brown.
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -25,6 +29,13 @@
  * TODO:
  *
  * Changelog:
+ * Tue Dec  5 2000 Matt Domsch <Matt_Domsch@dell.com>
+ * - Moved crc32() to linux/lib, added efi_crc32().
+ *
+ * Thu Nov 30 2000 Matt Domsch <Matt_Domsch@dell.com>
+ * - Replaced Intel's CRC32 function with an equivalent
+ *   non-license-restricted version.
+ *=20
  * Wed Oct 25 2000 Matt Domsch <Matt_Domsch@dell.com>
  * - Fixed the LastLBA() call to return the proper last block
  *=20
@@ -44,6 +55,7 @@
 #include <linux/smp_lock.h>
 #include <asm/system.h>
 #include <asm/efi.h>
+#include <linux/crc32.h>
=20
 #include "check.h"
 #include "efi.h"
@@ -61,79 +73,27 @@
 #define debug_printk(...)
 #endif
=20
-/* CRC routines taken from the EFI Sample Implementation,
- *   1999.12.31, lib/crc.c
- *
- * Note, the EFI Specification, v0.99, has a reference to
- * Dr. Dobbs Journal, May 1994 (actually it's in May 1992)
- * but that isn't the CRC function being used by EFI.
- */
-
-static u32 CRCTable[256] =3D {
-	0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F,
-	0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988,
-	0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2,
-	0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
-	0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
-	0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172,
-	0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
-	0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
-	0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423,
-	0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
-	0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
-	0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
-	0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D,
-	0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
-	0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
-	0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
-	0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7,
-	0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0,
-	0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA,
-	0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
-	0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
-	0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
-	0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84,
-	0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
-	0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
-	0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC,
-	0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E,
-	0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
-	0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55,
-	0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
-	0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28,
-	0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
-	0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
-	0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38,
-	0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
-	0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
-	0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69,
-	0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2,
-	0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC,
-	0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
-	0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693,
-	0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94,
-	0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D=20
-};
+/************************************************************
+ * efi_crc32()
+ * Requires:
+ *  - a buffer of length len
+ * Modifies: nothing
+ * Returns:
+ *  EFI-style CRC32 value for buf
+ * =20
+ * This function uses the crc32 function by Gary S. Brown,
+ * but seeds the function with ~0, and xor's with ~0 at the end.
+ ************************************************************/
=20
-static u32
-CalculateCrc (void *_pt, u32 Size)
+u32 static inline
+efi_crc32(const void *buf, unsigned long len)
 {
-	u8 *pt =3D (u8 *)_pt;
-	register u32 Crc;
-
-	/*  compute crc */
-	Crc =3D 0xffffffff;
-	while (Size) {
-		Crc =3D (Crc >> 8) ^ CRCTable[(__u8) Crc ^ *pt];
-		pt +=3D 1;
-		Size -=3D 1;
-	}
-	Crc =3D Crc ^ 0xffffffff;
-	return Crc;
+  return (crc32(buf, len, ~0L) ^ ~0L);
 }
=20
=20
=20
+
 /************************************************************
  * IsLegacyMBRValid()
  * Requires:
@@ -387,7 +347,7 @@
 	/* Check the GUID Partition Table CRC */
 	origcrc =3D (*gpt)->HeaderCRC32;
 	(*gpt)->HeaderCRC32 =3D 0;
-	crc =3D CalculateCrc(*gpt, (*gpt)->HeaderSize);
+	crc =3D efi_crc32((const unsigned char *)(*gpt), (*gpt)->HeaderSize);
  =20
  =20
 	if (crc !=3D origcrc) {
@@ -415,7 +375,8 @@
 	}
  =20
 	/* Check the GUID Partition Entry Array CRC */
-	crc =3D CalculateCrc(*ptes, (*gpt)->NumberOfPartitionEntries *
+	crc =3D efi_crc32((const unsigned char *)(*ptes),
+                    (*gpt)->NumberOfPartitionEntries *
 			   (*gpt)->SizeOfPartitionEntry);
  =20
 	if (crc !=3D (*gpt)->PartitionEntryArrayCRC32)  {
diff -urN linux-davidm/include/asm-ia64/a.out.h lia64/include/asm-ia64/a.ou=
t.h
--- linux-davidm/include/asm-ia64/a.out.h	Sun Feb  6 18:42:40 2000
+++ lia64/include/asm-ia64/a.out.h	Wed Dec  6 22:36:55 2000
@@ -7,14 +7,13 @@
  * probably would be better to clean up binfmt_elf.c so it does not
  * necessarily depend on there being a.out support.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/types.h>
=20
-struct exec
-{
+struct exec {
 	unsigned long a_info;
 	unsigned long a_text;
 	unsigned long a_data;
@@ -31,7 +30,7 @@
 #define N_TXTOFF(x)	0
=20
 #ifdef __KERNEL__
-# define STACK_TOP	0xa000000000000000UL
+# define STACK_TOP	(0x8000000000000000UL + (1UL << (4*PAGE_SHIFT - 12)))
 # define IA64_RBS_BOT	(STACK_TOP - 0x80000000L)	/* bottom of register back=
ing store */
 #endif
=20
diff -urN linux-davidm/include/asm-ia64/acpi-ext.h lia64/include/asm-ia64/a=
cpi-ext.h
--- linux-davidm/include/asm-ia64/acpi-ext.h	Mon Oct  9 17:54:57 2000
+++ lia64/include/asm-ia64/acpi-ext.h	Wed Dec  6 22:37:07 2000
@@ -8,19 +8,27 @@
  *=20
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
+ * Copyright (C) 2000 Intel Corp.
+ * Copyright (C) 2000 J.I. Lee <jung-ik.lee@intel.com>
+ *	ACPI 2.0 specification=20
  */
=20
 #include <linux/types.h>
=20
+#pragma	pack(1)
 #define ACPI_RSDP_SIG "RSD PTR " /* Trailing space required */
 #define ACPI_RSDP_SIG_LEN 8
 typedef struct {
 	char signature[8];
 	u8 checksum;
 	char oem_id[6];
-	char reserved;		/* Must be 0 */
-	struct acpi_rsdt *rsdt;
-} acpi_rsdp_t;
+	u8 revision;
+	u32 rsdt;
+	u32 lenth;
+	struct acpi_xsdt *xsdt;
+	u8 ext_checksum;
+	u8 reserved[3];
+} acpi20_rsdp_t;
=20
 typedef struct {
 	char signature[4];
@@ -32,20 +40,73 @@
 	u32 oem_revision;
 	u32 creator_id;
 	u32 creator_revision;
-	char reserved[4];
 } acpi_desc_table_hdr_t;
=20
 #define ACPI_RSDT_SIG "RSDT"
 #define ACPI_RSDT_SIG_LEN 4
-typedef struct acpi_rsdt {
+typedef struct {
+	acpi_desc_table_hdr_t header;
+	u8 reserved[4];
+	u32 entry_ptrs[1];	/* Not really . . . */
+} acpi20_rsdt_t;
+
+#define ACPI_XSDT_SIG "XSDT"
+#define ACPI_XSDT_SIG_LEN 4
+typedef struct acpi_xsdt {
 	acpi_desc_table_hdr_t header;
 	unsigned long entry_ptrs[1];	/* Not really . . . */
+} acpi_xsdt_t;
+
+/* Common structures for ACPI 2.0 and 0.71 */
+
+typedef struct acpi_entry_iosapic {
+	u8 type;
+	u8 length;
+	u8 id;
+	u8 reserved;
+	u32 irq_base;	/* start of IRQ's this IOSAPIC is responsible for. */
+	unsigned long address;	/* Address of this IOSAPIC */
+} acpi_entry_iosapic_t;
+
+/* Local SAPIC flags */
+#define LSAPIC_ENABLED                (1<<0)
+#define LSAPIC_PERFORMANCE_RESTRICTED (1<<1)
+#define LSAPIC_PRESENT                (1<<2)
+
+/* Defines legacy IRQ->pin mapping */
+typedef struct {
+	u8 type;
+	u8 length;
+	u8 bus;		/* Constant 0 =3D ISA */
+	u8 isa_irq;	/* ISA IRQ # */
+	u32 pin;		/* called vector in spec; really IOSAPIC pin number */
+	u16 flags;	/* Edge/Level trigger & High/Low active */
+} acpi_entry_int_override_t;
+
+#define INT_OVERRIDE_ACTIVE_LOW    0x03
+#define INT_OVERRIDE_LEVEL_TRIGGER 0x0d
+
+/* IA64 ext 0.71 */
+
+typedef struct {
+	char signature[8];
+	u8 checksum;
+	char oem_id[6];
+	char reserved;		/* Must be 0 */
+	struct acpi_rsdt *rsdt;
+} acpi_rsdp_t;
+
+typedef struct {
+	acpi_desc_table_hdr_t header;
+	u8 reserved[4];
+	unsigned long entry_ptrs[1];	/* Not really . . . */
 } acpi_rsdt_t;
=20
 #define ACPI_SAPIC_SIG "SPIC"
 #define ACPI_SAPIC_SIG_LEN 4
 typedef struct {
 	acpi_desc_table_hdr_t header;
+	u8 reserved[4];
 	unsigned long interrupt_block;
 } acpi_sapic_t;
=20
@@ -55,11 +116,6 @@
 #define ACPI_ENTRY_INT_SRC_OVERRIDE    2
 #define ACPI_ENTRY_PLATFORM_INT_SOURCE 3	/* Unimplemented */
=20
-/* Local SAPIC flags */
-#define LSAPIC_ENABLED                (1<<0)
-#define LSAPIC_PERFORMANCE_RESTRICTED (1<<1)
-#define LSAPIC_PRESENT                (1<<2)
-
 typedef struct acpi_entry_lsapic {
 	u8 type;
 	u8 length;
@@ -69,42 +125,71 @@
 	u8 eid;
 } acpi_entry_lsapic_t;
=20
-typedef struct acpi_entry_iosapic {
+typedef struct {
 	u8 type;
 	u8 length;
-	u16 reserved;
-	u32 irq_base;	/* start of IRQ's this IOSAPIC is responsible for. */
-	unsigned long address;	/* Address of this IOSAPIC */
-} acpi_entry_iosapic_t;
+	u16 flags;
+	u8 int_type;
+	u8 id;
+	u8 eid;
+	u8 iosapic_vector;
+	u8 reserved[4];
+	u32 global_vector;
+} acpi_entry_platform_src_t;
=20
-/* Defines legacy IRQ->pin mapping */
+/* ACPI 2.0 with 1.3 errata specific structures */
+
+#define ACPI_MADT_SIG "APIC"
+#define ACPI_MADT_SIG_LEN 4
 typedef struct {
+	acpi_desc_table_hdr_t header;
+	u32 lapic_address;
+	u32 flags;
+} acpi_madt_t;
+
+/* acpi 2.0 MADT structure types */
+#define ACPI20_ENTRY_LOCAL_APIC                 0
+#define ACPI20_ENTRY_IO_APIC                    1
+#define ACPI20_ENTRY_INT_SRC_OVERRIDE           2
+#define ACPI20_ENTRY_NMI_SOURCE                 3
+#define ACPI20_ENTRY_LOCAL_APIC_NMI             4
+#define ACPI20_ENTRY_LOCAL_APIC_ADDR_OVERRIDE   5
+#define ACPI20_ENTRY_IO_SAPIC                   6
+#define ACPI20_ENTRY_LOCAL_SAPIC                7
+#define ACPI20_ENTRY_PLATFORM_INT_SOURCE        8
+
+typedef struct acpi20_entry_lsapic {
 	u8 type;
 	u8 length;
-	u8 bus;	/* Constant 0 =3D ISA */
-	u8 isa_irq;	/* ISA IRQ # */
-	u8 pin;	/* called vector in spec; really IOSAPIC pin number */
-	u32 flags;	/* Edge/Level trigger & High/Low active */
-	u8 reserved[6];
-} acpi_entry_int_override_t;
-#define INT_OVERRIDE_ACTIVE_LOW    0x03
-#define INT_OVERRIDE_LEVEL_TRIGGER 0x0d
+	u8 acpi_processor_id;
+	u8 id;
+	u8 eid;
+	u8 reserved[3];
+	u32 flags;
+} acpi20_entry_lsapic_t;
+
+typedef struct acpi20_entry_lapic_addr_override {
+	u8 type;
+	u8 length;
+	u8 reserved[2];
+	unsigned long lapic_address;
+} acpi20_entry_lapic_addr_override_t;
=20
 typedef struct {
 	u8 type;
 	u8 length;
-	u32 flags;
+	u16 flags;
 	u8 int_type;
 	u8 id;
 	u8 eid;
 	u8 iosapic_vector;
-	unsigned long reserved;
-	unsigned long global_vector;
-} acpi_entry_platform_src_t;
+	u32 global_vector;
+} acpi20_entry_platform_src_t;
=20
+extern int acpi20_parse(acpi20_rsdp_t *);
 extern int acpi_parse(acpi_rsdp_t *);
 extern const char *acpi_get_sysname (void);
=20
 extern void (*acpi_idle) (void);	/* power-management idle function, if any=
 */
-
+#pragma	pack()
 #endif /* _ASM_IA64_ACPI_EXT_H */
diff -urN linux-davidm/include/asm-ia64/efi.h lia64/include/asm-ia64/efi.h
--- linux-davidm/include/asm-ia64/efi.h	Mon Oct  9 17:54:58 2000
+++ lia64/include/asm-ia64/efi.h	Wed Dec  6 23:13:14 2000
@@ -168,6 +168,9 @@
 #define ACPI_TABLE_GUID    \
     ((efi_guid_t) { 0xeb9d2d30, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0=
x27, 0x3f, 0xc1, 0x4d }})
=20
+#define ACPI_20_TABLE_GUID    \
+    ((efi_guid_t) { 0x8868e871, 0xe4f1, 0x11d3, { 0xbc, 0x22, 0x0, 0x80, 0=
xc7, 0x3c, 0x88, 0x81 }})
+
 #define SMBIOS_TABLE_GUID    \
     ((efi_guid_t) { 0xeb9d2d31, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0=
x27, 0x3f, 0xc1, 0x4d }})
 =09
@@ -204,7 +207,8 @@
 extern struct efi {
 	efi_system_table_t *systab;	/* EFI system table */
 	void *mps;			/* MPS table */
-	void *acpi;			/* ACPI table */
+	void *acpi;			/* ACPI table  (IA64 ext 0.71) */
+	void *acpi20;			/* ACPI table  (ACPI 2.0) */
 	void *smbios;			/* SM BIOS table */
 	void *sal_systab;		/* SAL system table */
 	void *boot_info;		/* boot info table */
diff -urN linux-davidm/include/asm-ia64/iosapic.h lia64/include/asm-ia64/io=
sapic.h
--- linux-davidm/include/asm-ia64/iosapic.h	Wed Dec  6 23:15:30 2000
+++ lia64/include/asm-ia64/iosapic.h	Wed Dec  6 22:37:31 2000
@@ -56,7 +56,7 @@
 extern void __init iosapic_init (unsigned long address, unsigned int base_=
irq);
 extern void iosapic_register_legacy_irq (unsigned long irq, unsigned long =
pin,
 					 unsigned long polarity, unsigned long trigger);
-extern void iosapic_pci_fixup (void);
+extern void iosapic_pci_fixup (int);
=20
 # endif /* !__ASSEMBLY__ */
 #endif /* __ASM_IA64_IOSAPIC_H */
diff -urN linux-davidm/include/asm-ia64/machvec.h lia64/include/asm-ia64/ma=
chvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Wed Dec  6 23:15:30 2000
+++ lia64/include/asm-ia64/machvec.h	Wed Dec  6 23:13:06 2000
@@ -25,7 +25,7 @@
=20
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_irq_init_t (void);
-typedef void ia64_mv_pci_fixup_t (void);
+typedef void ia64_mv_pci_fixup_t (int);
 typedef unsigned long ia64_mv_map_nr_t (unsigned long);
 typedef void ia64_mv_mca_init_t (void);
 typedef void ia64_mv_mca_handler_t (void);
diff -urN linux-davidm/include/asm-ia64/machvec_sn1.h lia64/include/asm-ia6=
4/machvec_sn1.h
--- linux-davidm/include/asm-ia64/machvec_sn1.h	Wed Dec  6 23:15:31 2000
+++ lia64/include/asm-ia64/machvec_sn1.h	Wed Dec  6 22:37:56 2000
@@ -5,6 +5,13 @@
 extern ia64_mv_irq_init_t sn1_irq_init;
 extern ia64_mv_map_nr_t sn1_map_nr;
 extern ia64_mv_send_ipi_t sn1_send_IPI;
+extern ia64_mv_pci_fixup_t sn1_pci_fixup;
+extern ia64_mv_inb_t sn1_inb;
+extern ia64_mv_inw_t sn1_inw;
+extern ia64_mv_inl_t sn1_inl;
+extern ia64_mv_outb_t sn1_outb;
+extern ia64_mv_outw_t sn1_outw;
+extern ia64_mv_outl_t sn1_outl;
=20
 /*
  * This stuff has dual use!
@@ -18,5 +25,12 @@
 #define platform_irq_init	sn1_irq_init
 #define platform_map_nr		sn1_map_nr
 #define platform_send_ipi	sn1_send_IPI
+#define platform_pci_fixup	sn1_pci_fixup
+#define platform_inb		sn1_inb
+#define platform_inw		sn1_inw
+#define platform_inl		sn1_inl
+#define platform_outb		sn1_outb
+#define platform_outw		sn1_outw
+#define platform_outl		sn1_outl
=20
 #endif /* _ASM_IA64_MACHVEC_SN1_h */
diff -urN linux-davidm/include/asm-ia64/mca.h lia64/include/asm-ia64/mca.h
--- linux-davidm/include/asm-ia64/mca.h	Wed Dec  6 23:15:31 2000
+++ lia64/include/asm-ia64/mca.h	Wed Dec  6 23:14:18 2000
@@ -46,11 +46,11 @@
 	u64	cmcv_regval;
 	struct	{
 		u64  	cmcr_vector		: 8;
-		u64	cmcr_ignored1		: 47;
+		u64	cmcr_reserved1		: 4;
+		u64	cmcr_ignored1		: 1;
+		u64	cmcr_reserved2		: 3;
 		u64	cmcr_mask		: 1;
-		u64	cmcr_reserved1		: 3;
-		u64	cmcr_ignored2		: 1;
-		u64	cmcr_reserved2		: 4;
+		u64	cmcr_ignored2		: 47;
 	} cmcv_reg_s;
=20
 } cmcv_reg_t;
diff -urN linux-davidm/include/asm-ia64/offsets.h lia64/include/asm-ia64/of=
fsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Mon Oct  9 17:54:59 2000
+++ lia64/include/asm-ia64/offsets.h	Wed Dec  6 22:45:34 2000
@@ -11,7 +11,7 @@
 #define PT_PTRACED_BIT			0
 #define PT_TRACESYS_BIT			1
=20
-#define IA64_TASK_SIZE			3328	/* 0xd00 */
+#define IA64_TASK_SIZE			3472	/* 0xd90 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
@@ -21,10 +21,10 @@
 #define IA64_TASK_SIGPENDING_OFFSET	16	/* 0x10 */
 #define IA64_TASK_NEED_RESCHED_OFFSET	40	/* 0x28 */
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
-#define IA64_TASK_THREAD_OFFSET		1424	/* 0x590 */
-#define IA64_TASK_THREAD_KSP_OFFSET	1424	/* 0x590 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	3184	/* 0xc70 */
-#define IA64_TASK_PID_OFFSET		188	/* 0xbc */
+#define IA64_TASK_THREAD_OFFSET		960	/* 0x3c0 */
+#define IA64_TASK_THREAD_KSP_OFFSET	960	/* 0x3c0 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	3328	/* 0xd00 */
+#define IA64_TASK_PID_OFFSET		196	/* 0xc4 */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
 #define IA64_PT_REGS_CR_IIP_OFFSET	8	/* 0x8 */
@@ -115,7 +115,7 @@
 #define IA64_SWITCH_STACK_AR_UNAT_OFFSET	528	/* 0x210 */
 #define IA64_SWITCH_STACK_AR_RNAT_OFFSET	536	/* 0x218 */
 #define IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET 544	/* 0x220 */
-#define IA64_SWITCH_STACK_PR_OFFSET	464	/* 0x1d0 */
+#define IA64_SWITCH_STACK_PR_OFFSET	552	/* 0x228 */
 #define IA64_SIGCONTEXT_AR_BSP_OFFSET	72	/* 0x48 */
 #define IA64_SIGCONTEXT_AR_RNAT_OFFSET	80	/* 0x50 */
 #define IA64_SIGCONTEXT_FLAGS_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/page.h lia64/include/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Wed Dec  6 23:15:31 2000
+++ lia64/include/asm-ia64/page.h	Wed Dec  6 23:13:06 2000
@@ -92,21 +92,17 @@
  */
 #define MAP_NR_DENSE(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE=
_SHIFT)
=20
-/*
- * This variant works well for the SGI SN1 architecture (which does have h=
uge
- * holes in the memory address space).
- */
-#define MAP_NR_SN1(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE_S=
HIFT)
-
 #ifdef CONFIG_IA64_GENERIC
 # include <asm/machvec.h>
-# define virt_to_page(kaddr)   (mem_map + platform_map_nr(kaddr))
-#elif defined (CONFIG_IA64_SN_SGI_SN1)
-# define virt_to_page(kaddr)   (mem_map + MAP_NR_SN1(kaddr))
+# define virt_to_page(kaddr)	(mem_map + platform_map_nr(kaddr))
+#elif defined (CONFIG_IA64_SGI_SN1)
+# ifndef CONFIG_DISCONTIGMEM
+#  define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
+# endif
 #else
-# define virt_to_page(kaddr)   (mem_map + MAP_NR_DENSE(kaddr))
+# define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
 #endif
-#define VALID_PAGE(page)       ((page - mem_map) < max_mapnr)
+#define VALID_PAGE(page)	((page - mem_map) < max_mapnr)
=20
 typedef union ia64_va {
 	struct {
diff -urN linux-davidm/include/asm-ia64/pgtable.h lia64/include/asm-ia64/pg=
table.h
--- linux-davidm/include/asm-ia64/pgtable.h	Wed Dec  6 23:15:31 2000
+++ lia64/include/asm-ia64/pgtable.h	Wed Dec  6 23:13:10 2000
@@ -135,7 +135,7 @@
 #define __P011	PAGE_READONLY	/* ditto */
 #define __P100	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_X_RX)
 #define __P101	PAGE_COPY
- #define __P110	PAGE_COPY
+#define __P110	PAGE_COPY
 #define __P111	PAGE_COPY
=20
 #define __S000	PAGE_NONE
@@ -214,13 +214,13 @@
=20
 /*
  * On some architectures, special things need to be done when setting
- * the PTE in a page table.  Nothing special needs to be on ia-64.
+ * the PTE in a page table.  Nothing special needs to be on IA-64.
  */
 #define set_pte(ptep, pteval)	(*(ptep) =3D (pteval))
=20
-#define VMALLOC_START		(0xa000000000000000+2*PAGE_SIZE)
+#define VMALLOC_START		(0xa000000000000000 + 2*PAGE_SIZE)
 #define VMALLOC_VMADDR(x)	((unsigned long)(x))
-#define VMALLOC_END		(0xa000000000000000+ (1UL << (4*PAGE_SHIFT - 13)))
+#define VMALLOC_END		(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 12)))
=20
 /*
  * BAD_PAGETABLE is used when we need a bogus page-table, while
diff -urN linux-davidm/include/asm-ia64/ptrace.h lia64/include/asm-ia64/ptr=
ace.h
--- linux-davidm/include/asm-ia64/ptrace.h	Mon Oct  9 17:55:00 2000
+++ lia64/include/asm-ia64/ptrace.h	Wed Dec  6 23:13:06 2000
@@ -2,8 +2,8 @@
 #define _ASM_IA64_PTRACE_H
=20
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
  *
  * 12/07/98	S. Eranian	added pt_regs & switch_stack
@@ -74,6 +74,9 @@
=20
 #ifndef __ASSEMBLY__
=20
+#include <asm/current.h>
+#include <asm/page.h>
+
 /*
  * This struct defines the way the registers are saved on system
  * calls.
@@ -236,7 +239,14 @@
=20
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
-#endif
+
+static inline void
+force_successful_syscall_return (void)
+{
+	ia64_task_regs(current)->r8 =3D 0;
+}
+
+#endif /* !__KERNEL__ */
=20
 #endif /* !__ASSEMBLY__ */
=20
diff -urN linux-davidm/include/asm-ia64/unistd.h lia64/include/asm-ia64/uni=
std.h
--- linux-davidm/include/asm-ia64/unistd.h	Wed Dec  6 23:15:31 2000
+++ lia64/include/asm-ia64/unistd.h	Wed Dec  6 22:39:55 2000
@@ -196,7 +196,7 @@
 #define __NR_getsockopt			1204
 #define __NR_sendmsg			1205
 #define __NR_recvmsg			1206
-#define __NR_sys_pivot_root		1207
+#define __NR_pivot_root			1207
 #define __NR_mincore			1208
 #define __NR_madvise			1209
 #define __NR_stat			1210
diff -urN linux-davidm/include/linux/crc32.h lia64/include/linux/crc32.h
--- linux-davidm/include/linux/crc32.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/linux/crc32.h	Wed Dec  6 22:40:05 2000
@@ -0,0 +1,17 @@
+/*
+ * crc32.h
+ * See linux/lib/crc32.c for license and changes
+ */
+#ifndef _LINUX_CRC32_H
+#define _LINUX_CRC32_H
+
+#include <linux/types.h>
+
+/*
+ * This computes a 32 bit CRC of the data in the buffer, and returns the C=
RC.
+ * The polynomial used is 0xedb88320.
+ */
+
+extern u32 crc32 (const void *buf, unsigned long len, u32 seed);
+
+#endif /* _LINUX_CRC32_H */
diff -urN linux-davidm/lib/Makefile lia64/lib/Makefile
--- linux-davidm/lib/Makefile	Fri Jul  7 16:41:11 2000
+++ lia64/lib/Makefile	Wed Dec  6 22:41:02 2000
@@ -7,7 +7,7 @@
 #
=20
 L_TARGET :=3D lib.a
-L_OBJS   :=3D errno.o ctype.o string.o vsprintf.o brlock.o
+L_OBJS   :=3D errno.o ctype.o string.o vsprintf.o brlock.o crc32.o
 LX_OBJS  :=3D cmdline.o
=20
 ifneq ($(CONFIG_HAVE_DEC_LOCK),y)=20
diff -urN linux-davidm/lib/crc32.c lia64/lib/crc32.c
--- linux-davidm/lib/crc32.c	Wed Dec 31 16:00:00 1969
+++ lia64/lib/crc32.c	Wed Dec  6 22:41:15 2000
@@ -0,0 +1,125 @@
+/*=20
+ * Dec 5, 2000 Matt Domsch <Matt_Domsch@dell.com>
+ * - Copied crc32.c from the linux/drivers/net/cipe directory.
+ * - Now pass seed as an arg
+ * - changed unsigned long to u32, added #include<linux/types.h>
+ * - changed len to be an unsigned long
+ * - changed crc32val to be a register
+ * - License remains unchanged!  It's still GPL-compatable!
+ */
+
+  /* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D */
+  /*  COPYRIGHT (C) 1986 Gary S. Brown.  You may use this program, or     =
  */
+  /*  code or tables extracted from it, as desired without restriction.   =
  */
+  /*                                                                      =
  */
+  /*  First, the polynomial itself and its table of feedback terms.  The  =
  */
+  /*  polynomial is                                                       =
  */
+  /*  X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0 =
  */
+  /*                                                                      =
  */
+  /*  Note that we take it "backwards" and put the highest-order term in  =
  */
+  /*  the lowest-order bit.  The X^32 term is "implied"; the LSB is the   =
  */
+  /*  X^31 term, etc.  The X^0 term (usually shown as "+1") results in    =
  */
+  /*  the MSB being 1.                                                    =
  */
+  /*                                                                      =
  */
+  /*  Note that the usual hardware shift register implementation, which   =
  */
+  /*  is what we're using (we're merely optimizing it by doing eight-bit  =
  */
+  /*  chunks at a time) shifts bits into the lowest-order term.  In our   =
  */
+  /*  implementation, that means shifting towards the right.  Why do we   =
  */
+  /*  do it this way?  Because the calculated CRC must be transmitted in  =
  */
+  /*  order from highest-order term to lowest-order term.  UARTs transmit =
  */
+  /*  characters in order from LSB to MSB.  By storing the CRC this way,  =
  */
+  /*  we hand it to the UART in the order low-byte to high-byte; the UART =
  */
+  /*  sends each low-bit to hight-bit; and the result is transmission bit =
  */
+  /*  by bit from highest- to lowest-order term without requiring any bit =
  */
+  /*  shuffling on our part.  Reception works similarly.                  =
  */
+  /*                                                                      =
  */
+  /*  The feedback terms table consists of 256, 32-bit entries.  Notes:   =
  */
+  /*                                                                      =
  */
+  /*      The table can be generated at runtime if desired; code to do so =
  */
+  /*      is shown later.  It might not be obvious, but the feedback      =
  */
+  /*      terms simply represent the results of eight shift/xor opera-    =
  */
+  /*      tions for all combinations of data and CRC register values.     =
  */
+  /*                                                                      =
  */
+  /*      The values must be right-shifted by eight bits by the "updcrc"  =
  */
+  /*      logic; the shift must be unsigned (bring in zeroes).  On some   =
  */
+  /*      hardware you could probably optimize the shift in assembler by  =
  */
+  /*      using byte-swap instructions.                                   =
  */
+  /*      polynomial $edb88320                                            =
  */
+  /*                                                                      =
  */
+  /*  --------------------------------------------------------------------=
  */
+
+#include <linux/crc32.h>
+
+static u32 crc32_tab[] =3D {
+      0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
+      0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
+      0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
+      0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, 0x84be41deL,
+      0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, 0x136c9856L,
+      0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, 0x63066cd9L,
+      0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
+      0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL,
+      0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L,
+      0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, 0x51de003aL,
+      0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, 0xcfba9599L,
+      0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, 0xb10be924L,
+      0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
+      0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL,
+      0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL,
+      0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, 0xe6635c01L,
+      0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, 0x6c0695edL,
+      0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, 0x12b7e950L,
+      0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
+      0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L,
+      0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL,
+      0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, 0x33031de5L,
+      0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, 0xbe0b1010L,
+      0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, 0xce61e49fL,
+      0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
+      0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L,
+      0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L,
+      0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L,
+      0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, 0xf00f9344L,
+      0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, 0x806567cbL,
+      0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
+      0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L,
+      0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L,
+      0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL,
+      0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, 0x316e8eefL,
+      0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, 0x5268e236L,
+      0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
+      0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L,
+      0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL,
+      0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, 0x05005713L,
+      0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, 0x92d28e9bL,
+      0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, 0xf1d4e242L,
+      0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
+      0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL,
+      0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L,
+      0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, 0xd06016f7L,
+      0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, 0x40df0b66L,
+      0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, 0x30b5ffe9L,
+      0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
+      0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L,
+      0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL,
+      0x2d02ef8dL
+   };
+
+/* Return a 32-bit CRC of the contents of the buffer. */
+
+u32
+crc32(const void *buf, unsigned long len, u32 seed)
+{
+  unsigned long i;
+  register u32 crc32val;
+  const unsigned char *s =3D buf;
+
+  crc32val =3D seed;
+  for (i =3D 0;  i < len;  i ++)
+    {
+      crc32val +	crc32_tab[(crc32val ^ s[i]) & 0xff] ^
+	  (crc32val >> 8);
+    }
+  return crc32val;
+}

