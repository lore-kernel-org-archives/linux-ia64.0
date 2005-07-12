From: Christoph Lameter <clameter@engr.sgi.com>
Date: Tue, 12 Jul 2005 23:34:50 +0000
Subject: [PATCH] __read_mostly for IA64
Message-Id: <Pine.LNX.4.62.0507121633530.5062@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

i386, x86_64 and sparc64 support the __read_mostly attribute to place
frequently read variables separately from variables that may be frequently
written to thereby optimizing cacheline use and avoiding false aliasing.

This patch implements __read_mostly for IA64.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc2/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux-2.6.13-rc2.orig/arch/ia64/kernel/vmlinux.lds.S	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/arch/ia64/kernel/vmlinux.lds.S	2005-07-12 16:13:47.000000000 -0700
@@ -179,6 +179,9 @@ SECTIONS
   .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - LOAD_OFFSET)
         { *(.data.cacheline_aligned) }
 
+  .data.read_mostly : AT(ADDR(.data.read_mostly) - LOAD_OFFSET)
+        { *(.data.read_mostly) }
+
   /* Per-cpu data: */
   percpu : { } :percpu
   . = ALIGN(PERCPU_PAGE_SIZE);
Index: linux-2.6.13-rc2/include/linux/cache.h
=================================--- linux-2.6.13-rc2.orig/include/linux/cache.h	2005-07-12 16:18:41.000000000 -0700
+++ linux-2.6.13-rc2/include/linux/cache.h	2005-07-12 16:19:00.000000000 -0700
@@ -13,7 +13,7 @@
 #define SMP_CACHE_BYTES L1_CACHE_BYTES
 #endif
 
-#if defined(CONFIG_X86) || defined(CONFIG_SPARC64)
+#if defined(CONFIG_X86) || defined(CONFIG_SPARC64) || defined(CONFIG_IA64)
 #define __read_mostly __attribute__((__section__(".data.read_mostly")))
 #else
 #define __read_mostly
