From: Simon Horman <horms@verge.net.au>
Date: Wed, 28 Nov 2007 09:21:20 +0000
Subject: [patch 3/4] ia64: make irq_type_iosapic_level static
Message-Id: <20071128092247.461158620@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

irq_type_iosapic_level is not used outside of arch/ia64/kernel/iosapic.c
so it seems senible to make it static.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2007-11-28 13:59:48.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2007-11-28 13:59:59.000000000 +0900
@@ -429,7 +429,7 @@ iosapic_end_level_irq (unsigned int irq)
 #define iosapic_disable_level_irq	mask_irq
 #define iosapic_ack_level_irq		nop
 
-struct irq_chip irq_type_iosapic_level = {
+static struct irq_chip irq_type_iosapic_level = {
 	.name =		"IO-SAPIC-level",
 	.startup =	iosapic_startup_level_irq,
 	.shutdown =	iosapic_shutdown_level_irq,

-- 

-- 
Horms

