From: Horms <horms@verge.net.au>
Date: Tue, 06 Mar 2007 07:20:10 +0000
Subject: [PATCH] IA64: remove duplicate declaration of efi_initialize_iomem_resources
Message-Id: <20070306072007.GA28832@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

efi_initialize_iomem_resources() is declared in both include/linux/efi.h
and arch/ia64/kernel/setup.c. This patch removes the latter.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2007-03-05 11:22:47.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2007-03-05 13:23:44.000000000 +0900
@@ -91,8 +91,6 @@
 	.name	= "Kernel code",
 	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
 };
-extern void efi_initialize_iomem_resources(struct resource *,
-		struct resource *);
 extern char _text[], _end[], _etext[];
 
 unsigned long ia64_max_cacheline_size;
