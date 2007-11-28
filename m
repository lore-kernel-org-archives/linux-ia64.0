From: Simon Horman <horms@verge.net.au>
Date: Wed, 28 Nov 2007 09:21:19 +0000
Subject: [patch 2/4] ia64: make iosapic_ack_edge_irq static
Message-Id: <20071128092247.245256422@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

iosapic_ack_edge_irq is not used outside of arch/ia64/kernel/iosapic.c
so it seems senible to make it static.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2007-11-28 13:19:12.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2007-11-28 13:19:27.000000000 +0900
@@ -478,7 +478,7 @@ iosapic_ack_edge_irq (unsigned int irq)
 #define iosapic_disable_edge_irq	nop
 #define iosapic_end_edge_irq		nop
 
-struct irq_chip irq_type_iosapic_edge = {
+static struct irq_chip irq_type_iosapic_edge = {
 	.name =		"IO-SAPIC-edge",
 	.startup =	iosapic_startup_edge_irq,
 	.shutdown =	iosapic_disable_edge_irq,

-- 

-- 
Horms

