From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 21 Apr 2005 13:39:45 +0000
Subject: [RFC/PATCH 3/3] ACPI based I/O APIC hot-plug
Message-Id: <4267AD21.7040006@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Len Brown <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Greg KH <greg@kroah.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net


This patch adds PCI based I/O xAPIC hot-add support to ACPIPHP
driver. When PCI root bridge is hot-added, all PCI based I/O xAPICs
under the root bridge are hot-added by this patch. Hot-remove support
is TBD.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.12-rc2-mm3-kanesige/drivers/pci/hotplug/acpiphp_glue.c |  120 ++++++++++
 1 files changed, 120 insertions(+)

diff -puN drivers/pci/hotplug/acpiphp_glue.c~acpiphp_ioapic_add drivers/pci/hotplug/acpiphp_glue.c
--- linux-2.6.12-rc2-mm3/drivers/pci/hotplug/acpiphp_glue.c~acpiphp_ioapic_add	2005-04-20 10:51:56.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/drivers/pci/hotplug/acpiphp_glue.c	2005-04-21 19:18:05.000000000 +0900
@@ -552,6 +552,125 @@ static void remove_bridge(acpi_handle ha
 	}
 }
 
+static struct pci_dev *get_apic_pci_info(acpi_handle handle)
+{
+	struct acpi_pci_id id;
+	struct pci_bus *bus;
+	struct pci_dev *dev;
+
+	if (ACPI_FAILURE(acpi_get_pci_id(handle, &id)))
+		return NULL;
+
+	bus = pci_find_bus(id.segment, id.bus);
+	if (!bus)
+		return NULL;
+
+	list_for_each_entry(dev, &bus->devices, bus_list) {
+		if (dev->devfn != PCI_DEVFN(id.device, id.function))
+			continue;
+		if ((dev->class >> 8) != PCI_CLASS_SYSTEM_PIC)
+			continue;
+		if ((dev->class & 0xff) = 0x10 || (dev->class & 0xff) = 0x20)
+			return dev;
+	}
+	return NULL;
+}
+
+static int get_gsi_base(acpi_handle handle, u32 *gsi_base)
+{
+	acpi_status status;
+	int result = -1;
+	unsigned long gsb;
+	struct acpi_buffer buffer = {ACPI_ALLOCATE_BUFFER, NULL};
+	union acpi_object *obj;
+	void *table;
+
+	status = acpi_evaluate_integer(handle, "_GSB", NULL, &gsb);
+	if (ACPI_SUCCESS(status)) {
+		*gsi_base = (u32)gsb;
+		return 0;
+	}
+
+	status = acpi_evaluate_object(handle, "_MAT", NULL, &buffer);
+	if (ACPI_FAILURE(status) || !buffer.length || !buffer.pointer)
+		return result;
+
+	obj = buffer.pointer;
+	if (obj->type != ACPI_TYPE_BUFFER)
+		goto out;
+
+	table = obj->buffer.pointer;
+	switch (((acpi_table_entry_header *)table)->type) {
+	case ACPI_MADT_IOSAPIC:
+		*gsi_base = ((struct acpi_table_iosapic *)table)->global_irq_base;
+		result = 0;
+		break;
+	case ACPI_MADT_IOAPIC:
+		*gsi_base = ((struct acpi_table_ioapic *)table)->global_irq_base;
+		result = 0;
+		break;
+	default:
+		break;
+	}
+ out:
+	acpi_os_free(buffer.pointer);
+	return result;
+}
+
+static acpi_status
+ioapic_add(acpi_handle handle, u32 lvl, void *context, void **rv)
+{
+	acpi_status status;
+	unsigned long sta;
+	acpi_handle tmp;
+	struct pci_dev *pdev;
+	u32 gsi_base;
+	u64 phys_addr;
+
+	/* Evaluate _STA if present */
+	status = acpi_evaluate_integer(handle, "_STA", NULL, &sta);
+	if (ACPI_SUCCESS(status) && sta != ACPI_STA_ALL)
+		return AE_CTRL_DEPTH;
+
+	/* Scan only PCI bus scope */
+	status = acpi_get_handle(handle, "_HID", &tmp);
+	if (ACPI_SUCCESS(status))
+		return AE_CTRL_DEPTH;
+
+	pdev = get_apic_pci_info(handle);
+	if (!pdev)
+		return AE_OK;
+
+	if (get_gsi_base(handle, &gsi_base))
+		return AE_OK;
+
+	if (pci_enable_device(pdev))
+		return AE_OK;
+
+	pci_set_master(pdev);
+
+	if (pci_request_region(pdev, 0, "I/O APIC(acpiphp)")) {
+		pci_disable_device(pdev);
+		return AE_OK;
+	}
+
+	phys_addr = pci_resource_start(pdev, 0);
+	if (acpi_register_ioapic(handle, phys_addr, gsi_base)) {
+		pci_release_region(pdev, 0);
+		pci_disable_device(pdev);
+		return AE_OK;
+	}
+
+	return AE_OK;
+}
+
+static int acpiphp_configure_ioapics(acpi_handle handle)
+{
+	acpi_walk_namespace(ACPI_TYPE_DEVICE, handle,
+			    ACPI_UINT32_MAX, ioapic_add, NULL, NULL);
+	return 0;
+}
+
 static int power_on_slot(struct acpiphp_slot *slot)
 {
 	acpi_status status;
@@ -942,6 +1061,7 @@ static int acpiphp_configure_bridge (acp
 	acpiphp_sanitize_bus(bus);
 	acpiphp_set_hpp_values(handle, bus);
 	pci_enable_bridges(bus);
+	acpiphp_configure_ioapics(handle);
 	return 0;
 }
 

_
