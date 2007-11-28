From: Simon Horman <horms@verge.net.au>
Date: Wed, 28 Nov 2007 09:21:18 +0000
Subject: [patch 1/4] ia64: make iosapic_version static
Message-Id: <20071128092247.028699233@vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

iosapic_version is not used outside of arch/ia64/kernel/iosapic.c
so it seems senible to make it static.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2007-11-28 13:14:09.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2007-11-28 13:15:08.000000000 +0900
@@ -491,7 +491,7 @@ struct irq_chip irq_type_iosapic_edge = 
 	.set_affinity =	iosapic_set_affinity
 };
 
-unsigned int
+static unsigned int
 iosapic_version (char __iomem *addr)
 {
 	/*
Index: linux-2.6/include/asm-ia64/iosapic.h
=================================--- linux-2.6.orig/include/asm-ia64/iosapic.h	2007-11-28 11:47:53.000000000 +0900
+++ linux-2.6/include/asm-ia64/iosapic.h	2007-11-28 13:15:17.000000000 +0900
@@ -94,7 +94,6 @@ extern int __init iosapic_register_platf
 					   u16 eid, u16 id,
 					   unsigned long polarity,
 					   unsigned long trigger);
-extern unsigned int iosapic_version (char __iomem *addr);
 
 #ifdef CONFIG_NUMA
 extern void __devinit map_iosapic_to_node (unsigned int, int);

-- 

-- 
Horms

