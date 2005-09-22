From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 22 Sep 2005 20:07:47 +0000
Subject: [PATCH] Increase maximum kmalloc size to 256K
Message-Id: <Pine.LNX.4.62.0509221306380.18133@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, manfred@colorfulllife.com

The workqueue structure can grow larger than 128k under 2.6.14-rc2 (with 
all debugging features enabled on 64 bit platforms) which will make 
kzalloc for workqueue structure entries fail. This patch increases the 
maximum slab entry size to 256K.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc2/include/linux/kmalloc_sizes.h
=================================--- linux-2.6.14-rc2.orig/include/linux/kmalloc_sizes.h	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/include/linux/kmalloc_sizes.h	2005-09-22 12:41:19.000000000 -0700
@@ -19,8 +19,8 @@
 	CACHE(32768)
 	CACHE(65536)
 	CACHE(131072)
-#ifndef CONFIG_MMU
 	CACHE(262144)
+#ifndef CONFIG_MMU
 	CACHE(524288)
 	CACHE(1048576)
 #ifdef CONFIG_LARGE_ALLOCS
