From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 07 Sep 2005 05:08:18 +0000
Subject: [PATCH 2.6.13 3/3] Minor cleanups - remove unnecessary function prototype
Message-Id: <431E75C2.4060003@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The function prototypes for iosapic_enable_intr() and
iosapic_pci_fixup() in include/asm-ia64/iosapic.h are no longer
needed. This patch removes them. The original patch has been posted by
Satoru Takeuchi.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
---

 include/asm-ia64/iosapic.h |    2 --
 1 files changed, 2 deletions(-)

diff -puN include/asm-ia64/iosapic.h~ia64-cleanup-iosapic_h include/asm-ia64/iosapic.h
--- linux-2.6.13/include/asm-ia64/iosapic.h~ia64-cleanup-iosapic_h	2005-09-07 11:53:20.000000000 +0900
+++ linux-2.6.13-kanesige/include/asm-ia64/iosapic.h	2005-09-07 11:53:20.000000000 +0900
@@ -80,7 +80,6 @@ extern int iosapic_remove (unsigned int 
 #endif /* CONFIG_HOTPLUG */
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
-extern void iosapic_enable_intr (unsigned int vector);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);
 extern void iosapic_unregister_intr (unsigned int irq);
@@ -95,7 +94,6 @@ extern int __init iosapic_register_platf
 					   unsigned long trigger);
 extern unsigned int iosapic_version (char __iomem *addr);
 
-extern void iosapic_pci_fixup (int);
 #ifdef CONFIG_NUMA
 extern void __devinit map_iosapic_to_node (unsigned int, int);
 #endif
_

