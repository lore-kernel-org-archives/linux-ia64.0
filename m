From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 02 Oct 2006 16:42:25 +0000
Subject: [patch] ia64: note requirement for 8250_pnp, now that 8250_acpi is gone
Message-Id: <200610021042.25632.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We removed 8250_acpi in 2.6.17.  If we don't have PNPACPI turned on,
we won't find any ACPI serial devices, so mention this requirement in
the troubleshooting part of the documentation.

CONFIG_PNPACPI is already turned on in all the relevant defconfigs.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: mm2/Documentation/ia64/serial.txt
=================================--- mm2.orig/Documentation/ia64/serial.txt	2006-06-17 19:49:35.000000000 -0600
+++ mm2/Documentation/ia64/serial.txt	2006-06-29 10:46:08.000000000 -0600
@@ -124,6 +124,13 @@
 
 	- Add entry to /etc/securetty for console tty.
 
+    No ACPI serial devices found in 2.6.17 or later:
+
+	- Turn on CONFIG_PNP and CONFIG_PNPACPI.  Prior to 2.6.17, ACPI
+	  serial devices were discovered by 8250_acpi.  In 2.6.17,
+	  8250_acpi was replaced by the combination of 8250_pnp and
+	  CONFIG_PNPACPI.
+
 
 
 [1] http://www.dig64.org/specifications/DIG64_PCDPv20.pdf
