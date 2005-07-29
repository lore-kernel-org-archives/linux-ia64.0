From: takeuchi satoru <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 29 Jul 2005 07:33:26 +0000
Subject: [PATCH 2.6.13-rc4] Remove unnecessary function declarations
Message-Id: <20050729.163326.65874239.takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I resend this patch because I sent the previous mail
without Subject: line.

Thanks,
Satoru Takeuchi

This patch removes unnecessary function declarations in
<include/asm-ia64/iosapic.h>.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

---

 include/asm-ia64/iosapic.h |    2 --
 1 files changed, 2 deletions(-)

diff -puN include/asm-ia64/iosapic.h~my-patch include/asm-ia64/iosapic.h
--- linux-2.6.13-rc4/include/asm-ia64/iosapic.h~my-patch	2005-07-29 15:23:18.000000000 +0900
+++ linux-2.6.13-rc4-takeuchi/include/asm-ia64/iosapic.h	2005-07-29 15:23:18.000000000 +0900
@@ -78,7 +78,6 @@ extern int iosapic_remove (unsigned int 
 #endif /* CONFIG_HOTPLUG */
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
-extern void iosapic_enable_intr (unsigned int vector);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);
 #ifdef CONFIG_ACPI_DEALLOCATE_IRQ
@@ -95,7 +94,6 @@ extern int __init iosapic_register_platf
 					   unsigned long trigger);
 extern unsigned int iosapic_version (char __iomem *addr);
 
-extern void iosapic_pci_fixup (int);
 #ifdef CONFIG_NUMA
 extern void __devinit map_iosapic_to_node (unsigned int, int);
 #endif
_
