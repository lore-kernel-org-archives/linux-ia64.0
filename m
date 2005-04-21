From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 21 Apr 2005 13:39:31 +0000
Subject: [RFC/PATCH 1/3] ACPI based I/O APIC hot-plug
Message-Id: <4267AD13.5080900@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pcihpd-discuss-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org


This patch adds the following new interfaces for I/O xAPIC
hotplug. The implementation of these interfaces depends on each
architecture.

    o int acpi_register_ioapic(acpi_handle handle, u64 phys_addr,
			       u32 gsi_base);

        This new interface is to add a new I/O xAPIC specified by
        phys_addr and gsi_base pair. phys_addr is the physical address
        to which the I/O xAPIC is mapped and gsi_base is global system
        interrupt base of the I/O xAPIC. acpi_register_ioapic returns
        0 on success, or negative value on error.

    o int acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base);

        This new interface is to remove a I/O xAPIC specified by
        gsi_base. acpi_unregister_ioapic returns 0 on success, or
        negative value on error.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.12-rc2-mm3-kanesige/arch/i386/kernel/acpi/boot.c |   16 ++++++++++++
 linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c      |   17 +++++++++++++
 linux-2.6.12-rc2-mm3-kanesige/include/linux/acpi.h         |    3 ++
 3 files changed, 36 insertions(+)

diff -puN arch/i386/kernel/acpi/boot.c~ioapic_hotplug_acpi arch/i386/kernel/acpi/boot.c
--- linux-2.6.12-rc2-mm3/arch/i386/kernel/acpi/boot.c~ioapic_hotplug_acpi	2005-04-20 10:51:30.128486652 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/i386/kernel/acpi/boot.c	2005-04-20 10:51:45.876533334 +0900
@@ -506,6 +506,22 @@ acpi_unmap_lsapic(int cpu)
 EXPORT_SYMBOL(acpi_unmap_lsapic);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
+int
+acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_register_ioapic);
+
+int
+acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_unregister_ioapic);
+
 static unsigned long __init
 acpi_scan_rsdp (
 	unsigned long		start,
diff -puN arch/ia64/kernel/acpi.c~ioapic_hotplug_acpi arch/ia64/kernel/acpi.c
--- linux-2.6.12-rc2-mm3/arch/ia64/kernel/acpi.c~ioapic_hotplug_acpi	2005-04-20 10:51:30.131416339 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c	2005-04-20 10:51:30.136299152 +0900
@@ -892,4 +892,21 @@ acpi_map_iosapic (acpi_handle handle, u3
 	return AE_OK;
 }
 #endif /* CONFIG_NUMA */
+
+int
+acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_register_ioapic);
+
+int
+acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_unregister_ioapic);
+
 #endif /* CONFIG_ACPI_BOOT */
diff -puN include/linux/acpi.h~ioapic_hotplug_acpi include/linux/acpi.h
--- linux-2.6.12-rc2-mm3/include/linux/acpi.h~ioapic_hotplug_acpi	2005-04-20 10:51:30.133369464 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/include/linux/acpi.h	2005-04-20 10:51:30.137275714 +0900
@@ -408,6 +408,9 @@ int acpi_map_lsapic(acpi_handle handle, 
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
+int acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base);
+int acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base);
+
 extern int acpi_mp_config;
 
 extern u32 pci_mmcfg_base_addr;

_
