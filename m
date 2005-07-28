From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 28 Jul 2005 07:54:53 +0000
Subject: [PATCH 2.6.13-rc3 4/6] failure of acpi_register_gsi() should be handled
Message-Id: <42E88F4D.8050306@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E88DC8.7050507@jp.fujitsu.com>
In-Reply-To: <42E88DC8.7050507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


This patch adds the error check of acpi_register_gsi() into pnpacpi
driver.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.13-rc3-kanesige/drivers/pnp/pnpacpi/rsparser.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/pnp/pnpacpi/rsparser.c~handle-error-acpi_register_gsi-pnpacpi drivers/pnp/pnpacpi/rsparser.c
--- linux-2.6.13-rc3/drivers/pnp/pnpacpi/rsparser.c~handle-error-acpi_register_gsi-pnpacpi	2005-07-28 01:01:17.000000000 +0900
+++ linux-2.6.13-rc3-kanesige/drivers/pnp/pnpacpi/rsparser.c	2005-07-28 01:01:17.000000000 +0900
@@ -81,7 +81,7 @@ pnpacpi_parse_allocated_irqresource(stru
 		i++;
 	if (i < PNP_MAX_IRQ) {
 		res->irq_resource[i].flags = IORESOURCE_IRQ;  //Also clears _UNSET flag
-		if (irq = -1) {
+		if (irq < 0) {
 			res->irq_resource[i].flags |= IORESOURCE_DISABLED;
 			return;
 		}

_


