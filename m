From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 20 Feb 2003 18:00:02 +0000
Subject: [Linux-ia64] [PATCH] 1/5 iosapic: make pcat_compat system property
Message-Id: <marc-linux-ia64-105590709805887@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This series of patches is against 2.5.60 + linux-2.5.60-ia64-030212.diff.gz.
I've tested them on a zx1 system, but haven't been able to build a kernel
that works on an i2000 yet.

Make "pcat_compat" a system property, not a per-IOSAPIC property.

diff -u -ur base/arch/ia64/kernel/acpi.c iosapic-2/arch/ia64/kernel/acpi.c
--- base/arch/ia64/kernel/acpi.c	2003-02-18 13:57:43.000000000 -0700
+++ iosapic-2/arch/ia64/kernel/acpi.c	2003-02-18 15:08:09.000000000 -0700
@@ -55,6 +55,7 @@
 asm (".weak iosapic_override_isa_irq");
 asm (".weak iosapic_register_platform_intr");
 asm (".weak iosapic_init");
+asm (".weak iosapic_system_init");
 asm (".weak iosapic_version");
 
 void (*pm_idle) (void);
@@ -335,16 +336,9 @@
 
 	acpi_table_print_madt_entry(header);
 
-	if (iosapic_init) {
-#ifndef CONFIG_ITANIUM
-		/* PCAT_COMPAT flag indicates dual-8259 setup */
-		iosapic_init(iosapic->address, iosapic->global_irq_base,
-			     acpi_madt->flags.pcat_compat);
-#else
-		/* Firmware on old Itanium systems is broken */
-		iosapic_init(iosapic->address, iosapic->global_irq_base, 1);
-#endif
-	}
+	if (iosapic_init)
+		iosapic_init(iosapic->address, iosapic->global_irq_base);
+
 	return 0;
 }
 
@@ -439,7 +433,13 @@
 	acpi_madt = (struct acpi_table_madt *) __va(phys_addr);
 
 	/* remember the value for reference after free_initmem() */
+#ifdef CONFIG_ITANIUM
+	has_8259 = 1; /* Firmware on old Itanium systems is broken */
+#else
 	has_8259 = acpi_madt->flags.pcat_compat;
+#endif
+	if (iosapic_system_init)
+		iosapic_system_init(has_8259);
 
 	/* Get base address of IPI Message Block */
 
diff -u -ur base/arch/ia64/kernel/iosapic.c iosapic-2/arch/ia64/kernel/iosapic.c
--- base/arch/ia64/kernel/iosapic.c	2003-02-10 11:38:31.000000000 -0700
+++ iosapic-2/arch/ia64/kernel/iosapic.c	2003-02-18 15:09:15.000000000 -0700
@@ -111,11 +111,12 @@
 	char		*addr;		/* base address of IOSAPIC */
 	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
-	unsigned char	pcat_compat;	/* 8259 compatibility flag */
 } iosapic_lists[256] __devinitdata;
 
 static int num_iosapic = 0;
 
+static unsigned char pcat_compat;	/* 8259 compatibility flag */
+
 
 /*
  * Find an IOSAPIC associated with a GSI
@@ -615,19 +616,14 @@
 }
 
 void __devinit
-iosapic_init (unsigned long phys_addr, unsigned int gsi_base, int pcat_compat)
+iosapic_system_init (int system_pcat_compat)
 {
-	int num_rte, vector;
-	unsigned int isa_irq, ver;
-	char *addr;
-	static int first_time = 1;
+	int vector;
 
-	if (first_time) {
-		first_time = 0;
-		for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
-			iosapic_intr_info[vector].rte_index = -1;	/* mark as unused */
-	}
+	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
+		iosapic_intr_info[vector].rte_index = -1;	/* mark as unused */
 
+	pcat_compat = system_pcat_compat;
 	if (pcat_compat) {
 		/*
 		 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT support
@@ -637,6 +633,14 @@
 		outb(0xff, 0xA1);
 		outb(0xff, 0x21);
 	}
+}
+
+void __devinit
+iosapic_init (unsigned long phys_addr, unsigned int gsi_base)
+{
+	int num_rte, vector;
+	unsigned int isa_irq, ver;
+	char *addr;
 
 	addr = ioremap(phys_addr, 0);
 	ver = iosapic_version(addr);
@@ -649,7 +653,6 @@
 	num_rte = ((ver >> 16) & 0xff) + 1;
 
 	iosapic_lists[num_iosapic].addr = addr;
-	iosapic_lists[num_iosapic].pcat_compat = pcat_compat;
 	iosapic_lists[num_iosapic].gsi_base = gsi_base;
 	iosapic_lists[num_iosapic].num_rte = num_rte;
 	num_iosapic++;
@@ -732,7 +735,7 @@
 	struct acpi_prt_entry *entry;
 	struct list_head *node;
 	unsigned int gsi, gsi_base;
-	int index, vector, pcat_compat;
+	int index, vector;
 	char pci_id[16];
 	char *addr;
 
@@ -756,7 +759,6 @@
 			}
 			addr = iosapic_lists[index].addr;
 			gsi_base = iosapic_lists[index].gsi_base;
-			pcat_compat = iosapic_lists[index].pcat_compat;
 
 			if (pcat_compat && (gsi < 16))
 				vector = isa_irq_to_vector(gsi);
diff -u -ur base/include/asm-ia64/iosapic.h iosapic-2/include/asm-ia64/iosapic.h
--- base/include/asm-ia64/iosapic.h	2003-02-10 11:38:43.000000000 -0700
+++ iosapic-2/include/asm-ia64/iosapic.h	2003-02-18 15:08:09.000000000 -0700
@@ -51,9 +51,9 @@
 
 #ifndef __ASSEMBLY__
 
+extern void __devinit iosapic_system_init (int pcat_compat);
 extern void __devinit iosapic_init (unsigned long address,
-				    unsigned int gsi_base,
-				    int pcat_compat);
+				    unsigned int gsi_base);
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
 extern void iosapic_parse_prt (void);


