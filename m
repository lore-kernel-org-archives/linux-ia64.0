From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 28 Jul 2005 07:53:45 +0000
Subject: [PATCH 2.6.13-rc3 3/6] failure of acpi_register_gsi() should be handled
Message-Id: <42E88F09.2000904@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E88DC8.7050507@jp.fujitsu.com>
In-Reply-To: <42E88DC8.7050507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


This patch adds the error check of acpi_register_gsi() into hpet
driver.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.13-rc3-kanesige/drivers/char/hpet.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff -puN drivers/char/hpet.c~handle-error-acpi_register_gsi-hpet drivers/char/hpet.c
--- linux-2.6.13-rc3/drivers/char/hpet.c~handle-error-acpi_register_gsi-hpet	2005-07-28 01:01:16.000000000 +0900
+++ linux-2.6.13-rc3-kanesige/drivers/char/hpet.c	2005-07-28 01:01:16.000000000 +0900
@@ -906,11 +906,15 @@ static acpi_status hpet_resources(struct
 		if (irqp->number_of_interrupts > 0) {
 			hdp->hd_nirqs = irqp->number_of_interrupts;
 
-			for (i = 0; i < hdp->hd_nirqs; i++)
-				hdp->hd_irq[i] +			for (i = 0; i < hdp->hd_nirqs; i++) {
+				int rc  				    acpi_register_gsi(irqp->interrupts[i],
 						      irqp->edge_level,
 						      irqp->active_high_low);
+				if (rc < 0)
+					return AE_ERROR;
+				hdp->hd_irq[i] = rc;
+			}
 		}
 	}
 

_

