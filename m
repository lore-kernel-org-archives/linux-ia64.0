From: Ishimatsu Yasuaki <isimatu.yasuaki@jp.fujitsu.com>
Date: Fri, 06 Apr 2007 07:51:12 +0000
Subject: [PATCH] Fix wrong assumption about irq and vector in msi_ia64.c
Message-Id: <4615FBF0.7060900@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes a wrong assumption in ia64 MSI code that IRQ equals
vector.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/msi_ia64.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.21-rc5/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6.21-rc5.orig/arch/ia64/kernel/msi_ia64.c   2007-04-05 21:30:52.000000000 +0900
+++ linux-2.6.21-rc5/arch/ia64/kernel/msi_ia64.c        2007-04-05 21:31:34.000000000 +0900
@@ -76,7 +76,7 @@

        set_irq_msi(irq, desc);
        dest_phys_id = cpu_physical_id(first_cpu(cpu_online_map));
-       vector = irq;
+       vector = irq_to_vector(irq);

        msg.address_hi = 0;
        msg.address_lo @@ -110,7 +110,7 @@

 static int ia64_msi_retrigger_irq(unsigned int irq)
 {
-       unsigned int vector = irq;
+       unsigned int vector = irq_to_vector(irq);
        ia64_resend_irq(vector);

        return 1;
