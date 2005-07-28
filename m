From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 28 Jul 2005 07:56:18 +0000
Subject: [PATCH 2.6.13-rc3 5/6] failure of acpi_register_gsi() should be handled
Message-Id: <42E88FA2.5010707@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E88DC8.7050507@jp.fujitsu.com>
In-Reply-To: <42E88DC8.7050507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


This patch adds the error check of acpi_register_gsi() into ACPI based
8250 serial driver.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.13-rc3-kanesige/drivers/serial/8250_acpi.c |   20 +++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff -puN drivers/serial/8250_acpi.c~handle-error-acpi_register_gsi-8250_acpi drivers/serial/8250_acpi.c
--- linux-2.6.13-rc3/drivers/serial/8250_acpi.c~handle-error-acpi_register_gsi-8250_acpi	2005-07-28 01:01:18.000000000 +0900
+++ linux-2.6.13-rc3-kanesige/drivers/serial/8250_acpi.c	2005-07-28 01:01:18.000000000 +0900
@@ -47,18 +47,30 @@ static acpi_status acpi_serial_port(stru
 static acpi_status acpi_serial_ext_irq(struct uart_port *port,
 				       struct acpi_resource_ext_irq *ext_irq)
 {
-	if (ext_irq->number_of_interrupts > 0)
-		port->irq = acpi_register_gsi(ext_irq->interrupts[0],
+	int rc;
+
+	if (ext_irq->number_of_interrupts > 0) {
+		rc = acpi_register_gsi(ext_irq->interrupts[0],
 	                   ext_irq->edge_level, ext_irq->active_high_low);
+		if (rc < 0)
+			return AE_ERROR;
+		port->irq = rc;
+	}
 	return AE_OK;
 }
 
 static acpi_status acpi_serial_irq(struct uart_port *port,
 				   struct acpi_resource_irq *irq)
 {
-	if (irq->number_of_interrupts > 0)
-		port->irq = acpi_register_gsi(irq->interrupts[0],
+	int rc;
+
+	if (irq->number_of_interrupts > 0) {
+		rc = acpi_register_gsi(irq->interrupts[0],
 	                   irq->edge_level, irq->active_high_low);
+		if (rc < 0)
+			return AE_ERROR;
+		port->irq = rc;
+	}
 	return AE_OK;
 }
 

_

