From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Jul 2004 17:58:31 +0000
Subject: [PATCH] fix ia64 early_printk build problem
Message-Id: <200407131158.31821.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rename PCDP_TABLE_GUID back to HCDP_TABLE_GUID to get the file to
compile again.  This change is against current 2.6 BK and is under
CONFIG_IA64_EARLY_PRINTK_UART.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

diff -Nru a/drivers/firmware/pcdp.c b/drivers/firmware/pcdp.c
--- a/drivers/firmware/pcdp.c	2004-07-13 12:02:45 -06:00
+++ b/drivers/firmware/pcdp.c	2004-07-13 12:02:45 -06:00
@@ -193,7 +193,7 @@
 	config_tables = __va(config_tables);
 
 	for (i = 0; i < systab->nr_tables; i++) {
-		if (efi_guidcmp(config_tables[i].guid, PCDP_TABLE_GUID) = 0) {
+		if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) = 0) {
 			pcdp = (struct pcdp *) config_tables[i].table;
 			break;
 		}
