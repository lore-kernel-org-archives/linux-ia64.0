From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 20 Feb 2003 18:03:32 +0000
Subject: [Linux-ia64] [PATCH] 5/5 iosapic: rationalize __init/__devinit
Message-Id: <marc-linux-ia64-105590709805891@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rationalize __init/__devinit attributes.  The noteworthy changes are
that
	iosapic_system_init(),
	iosapic_init(),
	iosapic_register_platform_intr(), and
	iosapic_override_isa_irq()
are __init (only called from ACPI __init functions), but
	iosapic_lists[],
	num_iosapic,
	find_iosapic(),
	register_intr(),
	iosapic_register_intr(), and
	acpi_register_irq()
are not because they may be used after init-time by modules.

More detailed analysis:

	iosapic_lists[], num_iosapic: normal, referenced by
		find_iosapic (normal)
		register_intr (normal)
		iosapic_init (__init)

	pcat_compat: __initdata, referenced by
		iosapic_system_init (__init)
		iosapic_init (__init)
		iosapic_parse_prt (__init)

	find_iosapic: normal, called by
		register_intr (normal)

	register_intr: normal, called by
		iosapic_register_intr (normal), called by
			acpi_register_irq (normal), called by
				modules (=> can't be __init or __devinit)
		iosapic_register_platform_intr (__init)
		iosapic_override_isa_irq (__init)
		iosapic_parse_prt (__init)

	iosapic_reassign_vector: __init, called by
		iosapic_register_platform_intr (__init), called by
			acpi_parse_plat_int_src (__init)

	iosapic_system_init: __init, called by
		acpi_parse_madt (__init)

	iosapic_init: __init, called by
		acpi_parse_iosapic (__init)

	iosapic_register_platform_intr: __init, called by
		acpi_parse_plat_int_src (__init)

	iosapic_override_isa_irq: __init, called by
		acpi_parse_int_src_ovr (__init)
		iosapic_init (__init)

	fixup_vector: __init, called by
		iosapic_parse_prt (__init), called by
			acpi_pci_irq_init (__init)

diff -u -ur iosapic-5/arch/ia64/kernel/acpi.c iosapic-6/arch/ia64/kernel/acpi.c
--- iosapic-5/arch/ia64/kernel/acpi.c	2003-02-18 15:33:15.000000000 -0700
+++ iosapic-6/arch/ia64/kernel/acpi.c	2003-02-19 15:12:23.000000000 -0700
@@ -837,7 +837,7 @@
 	return gsi_to_vector(irq);
 }
 
-int __init
+int
 acpi_register_irq (u32 gsi, u32 polarity, u32 trigger)
 {
 	int vector = 0;
diff -u -ur iosapic-5/arch/ia64/kernel/iosapic.c iosapic-6/arch/ia64/kernel/iosapic.c
--- iosapic-5/arch/ia64/kernel/iosapic.c	2003-02-18 15:33:15.000000000 -0700
+++ iosapic-6/arch/ia64/kernel/iosapic.c	2003-02-19 15:07:24.000000000 -0700
@@ -29,6 +29,9 @@
  * 02/07/29	T. Kochi	Allocate interrupt vectors dynamically
  * 02/08/04	T. Kochi	Cleaned up terminology (irq, global system interrupt, vector, etc.)
  * 02/09/20	D. Mosberger	Simplified by taking advantage of ACPI's pci_irq code.
+ * 03/02/19	B. Helgaas	Make pcat_compat system-wide, not per-IOSAPIC.
+ *				Remove iosapic_address & gsi_base from external interfaces.
+ *				Rationalize __init/__devinit attributes.
  */
 /*
  * Here is what the interrupt logic between a PCI device and the kernel looks like:
@@ -111,17 +114,17 @@
 	char		*addr;		/* base address of IOSAPIC */
 	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
-} iosapic_lists[256] __devinitdata;
+} iosapic_lists[256];
 
-static int num_iosapic = 0;
+static int num_iosapic;
 
-static unsigned char pcat_compat;	/* 8259 compatibility flag */
+static unsigned char pcat_compat __initdata;	/* 8259 compatibility flag */
 
 
 /*
  * Find an IOSAPIC associated with a GSI
  */
-static inline int __devinit
+static inline int
 find_iosapic (unsigned int gsi)
 {
 	int i;
@@ -424,7 +427,7 @@
  * if the given vector is already owned by other,
  *  assign a new vector for the other and make the vector available
  */
-static void
+static void __init
 iosapic_reassign_vector (int vector)
 {
 	int new_vector;
@@ -516,7 +519,7 @@
  * ACPI calls this when it finds an entry for a platform interrupt.
  * Note that the irq_base and IOSAPIC address must be set in iosapic_init().
  */
-int
+int __init
 iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
 				int iosapic_vector, u16 eid, u16 id,
 				unsigned long polarity, unsigned long trigger)
@@ -565,7 +568,7 @@
  * ACPI calls this when it finds an entry for a legacy ISA IRQ override.
  * Note that the gsi_base and IOSAPIC address must be set in iosapic_init().
  */
-void
+void __init
 iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 			  unsigned long polarity,
 			  unsigned long trigger)
@@ -586,7 +589,7 @@
 	set_rte(vector, dest);
 }
 
-void __devinit
+void __init
 iosapic_system_init (int system_pcat_compat)
 {
 	int vector;
@@ -606,7 +609,7 @@
 	}
 }
 
-void __devinit
+void __init
 iosapic_init (unsigned long phys_addr, unsigned int gsi_base)
 {
 	int num_rte;
@@ -643,7 +646,7 @@
 	}
 }
 
-static void
+static void __init
 fixup_vector (int vector, unsigned int gsi, const char *pci_id)
 {
 	struct hw_interrupt_type *irq_type = &irq_type_iosapic_level;
diff -u -ur iosapic-5/include/asm-ia64/iosapic.h iosapic-6/include/asm-ia64/iosapic.h
--- iosapic-5/include/asm-ia64/iosapic.h	2003-02-18 15:33:15.000000000 -0700
+++ iosapic-6/include/asm-ia64/iosapic.h	2003-02-19 10:02:36.000000000 -0700
@@ -51,18 +51,18 @@
 
 #ifndef __ASSEMBLY__
 
-extern void __devinit iosapic_system_init (int pcat_compat);
-extern void __devinit iosapic_init (unsigned long address,
+extern void __init iosapic_system_init (int pcat_compat);
+extern void __init iosapic_init (unsigned long address,
 				    unsigned int gsi_base);
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
-extern void iosapic_parse_prt (void);
+extern void __init iosapic_parse_prt (void);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);
-extern void iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
+extern void __init iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 				      unsigned long polarity,
 				      unsigned long trigger);
-extern int iosapic_register_platform_intr (u32 int_type,
+extern int __init iosapic_register_platform_intr (u32 int_type,
 					   unsigned int gsi,
 					   int pmi_vector,
 					   u16 eid, u16 id,


