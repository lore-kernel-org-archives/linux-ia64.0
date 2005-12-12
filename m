From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 12 Dec 2005 17:34:32 +0000
Subject: [PATCH] Add __read_mostly support for IA64
Message-Id: <Pine.LNX.4.62.0512120933550.14498@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sparc64, i386 and x86_64 have support for a special data section dedicated
to rarely updated data that is frequently read. The section was created to
avoid false sharing of those rarely read data with frequently written kernel
data.

This patch creates such a data section for ia64 and will group rarely written
data into this section.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.15-rc5-mm2/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux-2.6.15-rc5-mm2.orig/arch/ia64/kernel/vmlinux.lds.S	2005-12-03 21:10:42.000000000 -0800
+++ linux-2.6.15-rc5-mm2/arch/ia64/kernel/vmlinux.lds.S	2005-12-12 09:21:32.000000000 -0800
@@ -177,6 +177,9 @@ SECTIONS
 	}
   . = ALIGN(PAGE_SIZE);		/* make sure the gate page doesn't expose kernel data */
 
+  .data.read_mostly : AT(ADDR(.data.read_mostly) - LOAD_OFFSET)
+        { *(.data.read_mostly) }
+
   .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - LOAD_OFFSET)
         { *(.data.cacheline_aligned) }
 
Index: linux-2.6.15-rc5-mm2/include/linux/cache.h
=================================--- linux-2.6.15-rc5-mm2.orig/include/linux/cache.h	2005-12-12 09:10:34.000000000 -0800
+++ linux-2.6.15-rc5-mm2/include/linux/cache.h	2005-12-12 09:14:57.000000000 -0800
@@ -13,7 +13,7 @@
 #define SMP_CACHE_BYTES L1_CACHE_BYTES
 #endif
 
-#if defined(CONFIG_X86) || defined(CONFIG_SPARC64)
+#if defined(CONFIG_X86) || defined(CONFIG_SPARC64) || defined(CONFIG_IA64)
 #define __read_mostly __attribute__((__section__(".data.read_mostly")))
 #else
 #define __read_mostly
