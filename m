From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 03 Dec 2004 18:25:09 +0000
Subject: [PATCH] remove HCDP support for early printk
Message-Id: <200412031125.09732.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_F+KsBXsWBdJBYLD"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_F+KsBXsWBdJBYLD
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This fragment of drivers/firmware/pcdp.c should move to the
IA64_EARLY_PRINTK_UART patch.

With "console=uart,io,0x3f8" or similar, a serial console
works early enough for most things (not *quite* as early as
IA64_EARLY_PRINTK_UART admittedly).

--Boundary-00=_F+KsBXsWBdJBYLD
Content-Type: text/x-diff;
  charset="us-ascii";
  name="hcdp-remove-early-printk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="hcdp-remove-early-printk.patch"

ia64: remove HCDP support for early printk

This is only used by the ia64 early_printk patch, which isn't in the
mainline tree.  If anybody is still using that patch, hcdp_early_uart()
should be incorporated into it.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

===== drivers/firmware/pcdp.c 1.8 vs edited =====
--- 1.8/drivers/firmware/pcdp.c	2004-11-19 00:03:10 -07:00
+++ edited/drivers/firmware/pcdp.c	2004-12-03 09:20:38 -07:00
@@ -98,44 +98,3 @@
 
 	return -ENODEV;
 }
-
-#ifdef CONFIG_IA64_EARLY_PRINTK_UART
-unsigned long
-hcdp_early_uart (void)
-{
-	efi_system_table_t *systab;
-	efi_config_table_t *config_tables;
-	unsigned long addr = 0;
-	struct pcdp *pcdp = 0;
-	struct pcdp_uart *uart;
-	int i;
-
-	systab = (efi_system_table_t *) ia64_boot_param->efi_systab;
-	if (!systab)
-		return 0;
-	systab = __va(systab);
-
-	config_tables = (efi_config_table_t *) systab->tables;
-	if (!config_tables)
-		return 0;
-	config_tables = __va(config_tables);
-
-	for (i = 0; i < systab->nr_tables; i++) {
-		if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) == 0) {
-			pcdp = (struct pcdp *) config_tables[i].table;
-			break;
-		}
-	}
-	if (!pcdp)
-		return 0;
-	pcdp = __va(pcdp);
-
-	for (i = 0, uart = pcdp->uart; i < pcdp->num_uarts; i++, uart++) {
-		if (uart->type == PCDP_CONSOLE_UART) {
-			addr = uart->addr.address;
-			break;
-		}
-	}
-	return addr;
-}
-#endif /* CONFIG_IA64_EARLY_PRINTK_UART */

--Boundary-00=_F+KsBXsWBdJBYLD--
