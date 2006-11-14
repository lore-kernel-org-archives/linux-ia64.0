From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Tue, 14 Nov 2006 07:22:57 +0000
Subject: [PATCH] Incorrect MSI interrupt type name
Message-Id: <1163488977.4311.52.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

/proc/interrupts shows "<NULL>" for MSI interrupt type name on
my ia64 machine.

Below patch against 2.6.19-rc5-mm1 fixes it.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

---

--- linux-2.6.19-rc5-mm1/arch/ia64/kernel/msi_ia64.c	2006-11-14 14:16:12.000000000 +0800
+++ linux-2.6.19-rc5-mm1_fix/arch/ia64/kernel/msi_ia64.c	2006-11-14 15:08:37.000000000 +0800
@@ -115,7 +115,7 @@ static int ia64_msi_retrigger_irq(unsign
  * Generic ops used on most IA64 platforms.
  */
 static struct irq_chip ia64_msi_chip = {
-	.name		= "PCI-MSI",
+	.typename	= "PCI-MSI",
 	.mask		= mask_msi_irq,
 	.unmask		= unmask_msi_irq,
 	.ack		= ia64_ack_msi_irq,
