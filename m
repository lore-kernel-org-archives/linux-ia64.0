From: Andreas Schwab <schwab@suse.de>
Date: Thu, 04 Mar 2004 17:28:31 +0000
Subject: Fix PCIE and SHPC hotplug drivers for ia64
Message-Id: <jek720wmgw.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch fixes the PCIE and SHPC hotplug driver for ia64.  The function
pcibios_set_irq_routing only exists on x86, and acpi_bridges_head may be
NULL, so don't crash.

Andreas.

--- linux-2.6.3/drivers/pci/hotplug/pciehp_pci.c.~1~	2004-02-24 16:22:18.37=
5705230 +0100
+++ linux-2.6.3/drivers/pci/hotplug/pciehp_pci.c	2004-02-24 16:27:00.829344=
589 +0100
@@ -103,7 +103,7 @@ int pciehp_unconfigure_device(struct pci
  */
 int pciehp_set_irq (u8 bus_num, u8 dev_num, u8 int_pin, u8 irq_num)
 {
-#if !defined(CONFIG_X86_IO_APIC) && !defined(CONFIG_X86_64)
+#if defined(CONFIG_X86) && !defined(CONFIG_X86_IO_APIC) && !defined(CONFIG=
_X86_64)
 	int rc;
 	u16 temp_word;
 	struct pci_dev fakedev;
--- linux-2.6.3/drivers/pci/hotplug/pciehprm_acpi.c.~1~	2004-02-27 16:33:20=
.000000000 +0100
+++ linux-2.6.3/drivers/pci/hotplug/pciehprm_acpi.c	2004-02-29 16:22:58.086=
155839 +0100
@@ -1265,7 +1265,8 @@ static int print_acpi_resources (struct=20
 int pciehprm_print_pirt(void)
 {
 	dbg("PCIEHPRM ACPI Slots\n");
-	print_acpi_resources (acpi_bridges_head);
+	if (acpi_bridges_head)
+		print_acpi_resources (acpi_bridges_head);
=20
 	return 0;
 }
--- linux-2.6.3/drivers/pci/hotplug/shpchp_pci.c.~1~	2004-02-24 16:21:45.53=
2011299 +0100
+++ linux-2.6.3/drivers/pci/hotplug/shpchp_pci.c	2004-02-24 16:27:22.883998=
276 +0100
@@ -101,7 +101,7 @@ int shpchp_unconfigure_device(struct pci
  */
 int shpchp_set_irq (u8 bus_num, u8 dev_num, u8 int_pin, u8 irq_num)
 {
-#if !defined(CONFIG_X86_IO_APIC) && !defined(CONFIG_X86_64)
+#if defined(CONFIG_X86) && !defined(CONFIG_X86_IO_APIC) && !defined(CONFIG=
_X86_64)
 	int rc;
 	u16 temp_word;
 	struct pci_dev fakedev;

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
