From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Mar 2004 23:26:04 +0000
Subject: Re: [ACPI] [PATCH] 3 of 6 use global_irq to refer to ACPI global IRQs
Message-Id: <200403091626.04892.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com>
In-Reply-To: <200403091619.04333.bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andi Kleen <ak-l3A5Bk7waGM@public.gmane.org>, "Nakajima, Jun" <jun.nakajima-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

i386, x86_64: Use "global_irq", not "irq", when referring to ACPI global IR=
Qs

In mpparse.c, rename "irq" to "global_irq" to make it clear
these are ACPI global IRQs, not the usual Linux IRQs.

diff -Nru a/arch/i386/kernel/mpparse.c b/arch/i386/kernel/mpparse.c
--- a/arch/i386/kernel/mpparse.c	Tue Mar  9 15:25:27 2004
+++ b/arch/i386/kernel/mpparse.c	Tue Mar  9 15:25:27 2004
@@ -851,18 +851,18 @@
=20
=20
 static int __init mp_find_ioapic (
-	int			irq)
+	int			global_irq)
 {
 	int			i =3D 0;
=20
-	/* Find the IOAPIC that manages this IRQ. */
+	/* Find the IOAPIC that manages this global IRQ. */
 	for (i =3D 0; i < nr_ioapics; i++) {
-		if ((irq >=3D mp_ioapic_routing[i].irq_start)
-			&& (irq <=3D mp_ioapic_routing[i].irq_end))
+		if ((global_irq >=3D mp_ioapic_routing[i].irq_start)
+			&& (global_irq <=3D mp_ioapic_routing[i].irq_end))
 			return i;
 	}
=20
-	printk(KERN_ERR "ERROR: Unable to locate IOAPIC for IRQ %d\n", irq);
+	printk(KERN_ERR "ERROR: Unable to locate IOAPIC for global IRQ %d\n", glo=
bal_irq);
=20
 	return -1;
 }
@@ -906,7 +906,7 @@
 		io_apic_get_redir_entries(idx);
=20
 	printk("IOAPIC[%d]: apic_id %d, version %d, address 0x%lx, "
-		"IRQ %d-%d\n", idx, mp_ioapics[idx].mpc_apicid,=20
+		"global IRQ %d-%d\n", idx, mp_ioapics[idx].mpc_apicid,=20
 		mp_ioapics[idx].mpc_apicver, mp_ioapics[idx].mpc_apicaddr,
 		mp_ioapic_routing[idx].irq_start,
 		mp_ioapic_routing[idx].irq_end);
@@ -1029,7 +1029,7 @@
=20
 extern FADT_DESCRIPTOR acpi_fadt;
=20
-void __init mp_config_ioapic_for_sci(int irq)
+void __init mp_config_ioapic_for_sci(int global_irq)
 {
 	int ioapic;
 	int ioapic_pin;
@@ -1076,11 +1076,11 @@
 	 */
 	flags =3D entry->flags;
 	acpi_fadt.sci_int =3D entry->global_irq;
-	irq =3D entry->global_irq;
+	global_irq =3D entry->global_irq;
=20
-	ioapic =3D mp_find_ioapic(irq);
+	ioapic =3D mp_find_ioapic(global_irq);
=20
-	ioapic_pin =3D irq - mp_ioapic_routing[ioapic].irq_start;
+	ioapic_pin =3D global_irq - mp_ioapic_routing[ioapic].irq_start;
=20
 	/*
 	 * MPS INTI flags:
@@ -1088,7 +1088,7 @@
 	 *  polarity: 0=DEfault, 1=3Dhigh, 3=3Dlow
 	 * Per ACPI spec, default for SCI means level/low.
 	 */
-	io_apic_set_pci_routing(ioapic, ioapic_pin, irq,=20
+	io_apic_set_pci_routing(ioapic, ioapic_pin, global_irq,=20
 		(flags.trigger =3D 1 ? 0 : 1), (flags.polarity =3D 1 ? 0 : 1));
 }
=20
@@ -1100,7 +1100,7 @@
 	struct acpi_prt_entry	*entry =3D NULL;
 	int			ioapic =3D -1;
 	int			ioapic_pin =3D 0;
-	int			irq =3D 0;
+	int			global_irq =3D 0;
 	int			idx, bit =3D 0;
 	int			edge_level =3D 0;
 	int			active_high_low =3D 0;
@@ -1114,32 +1114,32 @@
=20
 		/* Need to get irq for dynamic entry */
 		if (entry->link.handle) {
-			irq =3D acpi_pci_link_get_irq(entry->link.handle, entry->link.index, &e=
dge_level, &active_high_low);
-			if (!irq)
+			global_irq =3D acpi_pci_link_get_irq(entry->link.handle, entry->link.in=
dex, &edge_level, &active_high_low);
+			if (!global_irq)
 				continue;
 		}
 		else {
 			/* Hardwired IRQ. Assume PCI standard settings */
-			irq =3D entry->link.index;
+			global_irq =3D entry->link.index;
 			edge_level =3D 1;
 			active_high_low =3D 1;
 		}
=20
 		/* Don't set up the ACPI SCI because it's already set up */
-                if (acpi_fadt.sci_int =3D irq) {
-			irq =3D acpi_irq_to_vector(irq);
-			entry->irq =3D irq; /* we still need to set entry's irq */
+                if (acpi_fadt.sci_int =3D global_irq) {
+			global_irq =3D acpi_irq_to_vector(global_irq);
+			entry->irq =3D global_irq; /* we still need to set entry's irq */
 			continue;
                 }
 =09
-		ioapic =3D mp_find_ioapic(irq);
+		ioapic =3D mp_find_ioapic(global_irq);
 		if (ioapic < 0)
 			continue;
-		ioapic_pin =3D irq - mp_ioapic_routing[ioapic].irq_start;
+		ioapic_pin =3D global_irq - mp_ioapic_routing[ioapic].irq_start;
=20
 		if (es7000_plat) {
-			if (!ioapic && (irq < 16))
-				irq +=3D 16;
+			if (!ioapic && (global_irq < 16))
+				global_irq +=3D 16;
 		}
=20
 		/*=20
@@ -1158,14 +1158,14 @@
 		if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
 			Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
 				mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
-			entry->irq =3D acpi_irq_to_vector(irq);
+			entry->irq =3D acpi_irq_to_vector(global_irq);
 			continue;
 		}
=20
 		mp_ioapic_routing[ioapic].pin_programmed[idx] |=3D (1<<bit);
=20
-		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, irq, edge_level, active=
_high_low)) {
-			entry->irq =3D acpi_irq_to_vector(irq);
+		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, global_irq, edge_level,=
 active_high_low)) {
+			entry->irq =3D acpi_irq_to_vector(global_irq);
 		}
 		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d\n",
 			entry->id.segment, entry->id.bus,
diff -Nru a/arch/x86_64/kernel/mpparse.c b/arch/x86_64/kernel/mpparse.c
--- a/arch/x86_64/kernel/mpparse.c	Tue Mar  9 15:25:27 2004
+++ b/arch/x86_64/kernel/mpparse.c	Tue Mar  9 15:25:27 2004
@@ -697,18 +697,18 @@
=20
=20
 static int __init mp_find_ioapic (
-	int			irq)
+	int			global_irq)
 {
 	int			i =3D 0;
=20
-	/* Find the IOAPIC that manages this IRQ. */
+	/* Find the IOAPIC that manages this global IRQ. */
 	for (i =3D 0; i < nr_ioapics; i++) {
-		if ((irq >=3D mp_ioapic_routing[i].irq_start)
-			&& (irq <=3D mp_ioapic_routing[i].irq_end))
+		if ((global_irq >=3D mp_ioapic_routing[i].irq_start)
+			&& (global_irq <=3D mp_ioapic_routing[i].irq_end))
 			return i;
 	}
=20
-	printk(KERN_ERR "ERROR: Unable to locate IOAPIC for IRQ %d\n", irq);
+	printk(KERN_ERR "ERROR: Unable to locate IOAPIC for global IRQ %d\n", glo=
bal_irq);
=20
 	return -1;
 }
@@ -752,7 +752,7 @@
 		io_apic_get_redir_entries(idx);
=20
 	printk(KERN_INFO "IOAPIC[%d]: apic_id %d, version %d, address 0x%x, "
-		"IRQ %d-%d\n", idx, mp_ioapics[idx].mpc_apicid,=20
+		"global IRQ %d-%d\n", idx, mp_ioapics[idx].mpc_apicid,=20
 		mp_ioapics[idx].mpc_apicver, mp_ioapics[idx].mpc_apicaddr,
 		mp_ioapic_routing[idx].irq_start,
 		mp_ioapic_routing[idx].irq_end);
@@ -878,7 +878,7 @@
=20
 extern FADT_DESCRIPTOR acpi_fadt;
=20
-void __init mp_config_ioapic_for_sci(int irq)
+void __init mp_config_ioapic_for_sci(int global_irq)
 {
 	int ioapic;
 	int ioapic_pin;
@@ -925,11 +925,11 @@
 	 */
 	flags =3D entry->flags;
 	acpi_fadt.sci_int =3D entry->global_irq;
-	irq =3D entry->global_irq;
+	global_irq =3D entry->global_irq;
=20
-	ioapic =3D mp_find_ioapic(irq);
+	ioapic =3D mp_find_ioapic(global_irq);
=20
-	ioapic_pin =3D irq - mp_ioapic_routing[ioapic].irq_start;
+	ioapic_pin =3D global_irq - mp_ioapic_routing[ioapic].irq_start;
=20
 	/*
 	 * MPS INTI flags:
@@ -937,7 +937,7 @@
 	 *  polarity: 0=DEfault, 1=3Dhigh, 3=3Dlow
 	 * Per ACPI spec, default for SCI means level/low.
 	 */
-	io_apic_set_pci_routing(ioapic, ioapic_pin, irq,=20
+	io_apic_set_pci_routing(ioapic, ioapic_pin, global_irq,=20
 		(flags.trigger =3D 1 ? 0 : 1), (flags.polarity =3D 1 ? 0 : 1));
 }
=20
@@ -949,7 +949,7 @@
 	struct acpi_prt_entry	*entry =3D NULL;
 	int			ioapic =3D -1;
 	int			ioapic_pin =3D 0;
-	int			irq =3D 0;
+	int			global_irq =3D 0;
 	int			idx, bit =3D 0;
 	int			edge_level =3D 0;
 	int			active_high_low =3D 0;
@@ -963,24 +963,24 @@
=20
 		/* Need to get irq for dynamic entry */
 		if (entry->link.handle) {
-			irq =3D acpi_pci_link_get_irq(entry->link.handle, entry->link.index, &e=
dge_level, &active_high_low);
-			if (!irq)
+			global_irq =3D acpi_pci_link_get_irq(entry->link.handle, entry->link.in=
dex, &edge_level, &active_high_low);
+			if (!global_irq)
 				continue;
 		} else {
 			/* Hardwired IRQ. Assume PCI standard settings */
-			irq =3D entry->link.index;
+			global_irq =3D entry->link.index;
 			edge_level =3D 1;
 			active_high_low =3D 1;
 		}
=20
 		/* Don't set up the ACPI SCI because it's already set up */
-		if (acpi_fadt.sci_int =3D irq)
+		if (acpi_fadt.sci_int =3D global_irq)
 			continue;
=20
-		ioapic =3D mp_find_ioapic(irq);
+		ioapic =3D mp_find_ioapic(global_irq);
 		if (ioapic < 0)
 			continue;
-		ioapic_pin =3D irq - mp_ioapic_routing[ioapic].irq_start;
+		ioapic_pin =3D global_irq - mp_ioapic_routing[ioapic].irq_start;
=20
 		/*=20
 		 * Avoid pin reprogramming.  PRTs typically include entries =20
@@ -998,13 +998,13 @@
 		if ((1<<bit) & mp_ioapic_routing[ioapic].pin_programmed[idx]) {
 			Dprintk(KERN_DEBUG "Pin %d-%d already programmed\n",
 				mp_ioapic_routing[ioapic].apic_id, ioapic_pin);
-			entry->irq =3D acpi_irq_to_vector(irq);
+			entry->irq =3D acpi_irq_to_vector(global_irq);
 			continue;
 		}
=20
 		mp_ioapic_routing[ioapic].pin_programmed[idx] |=3D (1<<bit);
-		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, irq, edge_level, active=
_high_low)) {
-			entry->irq =3D acpi_irq_to_vector(irq);
+		if (!io_apic_set_pci_routing(ioapic, ioapic_pin, global_irq, edge_level,=
 active_high_low)) {
+			entry->irq =3D acpi_irq_to_vector(global_irq);
 		}
 		printk(KERN_DEBUG "%02x:%02x:%02x[%c] -> %d-%d -> IRQ %d\n",
 			entry->id.segment, entry->id.bus,

