From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 12 Sep 2000 02:57:39 +0000
Subject: [Linux-ia64] fix for test8 kernel
Message-Id: <marc-linux-ia64-105590678205489@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached patch fixes the problem that caused grief on some
machines (primarily B1 Big Surs, it seems).  The problem showed itself
as an infinite stream of "unexpected irq 0" messages.  The fix is due
to Asit Mallick and fixes a problem I created when I goofed in
applying another patch.

	--david

diff -urN linux-2.4.0-test8-ia64-000908/drivers/acpi/acpiconf.c
linux-2.4.0-test8-ia64-000908.ji/drivers/acpi/acpiconf.c
--- linux-2.4.0-test8-ia64-000908/drivers/acpi/acpiconf.c	Sun Sep 10
23:51:21 2000
+++ linux-2.4.0-test8-ia64-000908.ji/drivers/acpi/acpiconf.c	Mon Sep 11
14:12:03 2000
@@ -311,7 +311,7 @@
 	pprts = (PCI_ROUTING_TABLE **)prts;
 
 	for ( i = 0; i < PCI_MAX_BUS; i++) {
-		prt = prtf = *pprts++;
+		prt = *pprts++;
 		if (prt) {
 			for ( ; prt->length > 0; nvec++) {
 				prt = (PCI_ROUTING_TABLE *)
((NATIVE_UINT)prt + (NATIVE_UINT)prt->length);
@@ -331,7 +331,7 @@
 	pprts = (PCI_ROUTING_TABLE **)prts;
 
 	for ( i = 0; i < PCI_MAX_BUS; i++) {
-		prt = *pprts++;
+		prt = prtf = *pprts++;
 		if (prt) {
 			for ( ; prt->length > 0; pvec++) {
 				pvec->bus	= (UINT16)i;



