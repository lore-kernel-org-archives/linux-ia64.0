From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 10 Jan 2005 21:25:49 +0000
Subject: [PATCH] fix warning in arch/ia64/pci/pci.c
Message-Id: <200501101325.49728.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_dLv4B+GiUfgSpKN"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_dLv4B+GiUfgSpKN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Bjorn, I think you had a similar fix awhile back?

Fix a 'mixing code and declarations' warning in pci.c by creating a small 
function that's a no-op if CONFIG_NUMA=n but otherwise includes the proper 
extern.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_dLv4B+GiUfgSpKN
Content-Type: text/plain;
  charset="us-ascii";
  name="pci-fix-warning.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pci-fix-warning.patch"

===== arch/ia64/pci/pci.c 1.60 vs edited =====
--- 1.60/arch/ia64/pci/pci.c	2005-01-04 18:48:18 -08:00
+++ edited/arch/ia64/pci/pci.c	2005-01-06 17:49:11 -08:00
@@ -131,6 +131,19 @@
 	.write = pci_write,
 };
 
+#ifdef CONFIG_NUMA
+extern acpi_status acpi_map_iosapic(acpi_handle, u32, void *, void **);
+static void acpi_map_iosapics(void)
+{
+	acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
+}
+#else
+static void acpi_map_iosapics(void)
+{
+	return;
+}
+#endif /* CONFIG_NUMA */
+
 static int __init
 pci_acpi_init (void)
 {
@@ -138,11 +151,7 @@
 
 	printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
 
-#ifdef CONFIG_NUMA
-extern acpi_status acpi_map_iosapic (acpi_handle, u32, void*, void**);
-
-	acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
-#endif
+	acpi_map_iosapics();
 
 	if (pci_routeirq) {
 		/*

--Boundary-00=_dLv4B+GiUfgSpKN--
