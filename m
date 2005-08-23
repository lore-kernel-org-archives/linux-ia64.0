From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 23 Aug 2005 16:24:26 +0000
Subject: [PATCH] ia64: fix IO_SPACE_SPARSE_ENCODING macro ambiguity
Message-Id: <200508231024.26073.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Parenthesize "p" to avoid ambiguity.  No callers have a problem today;
this is just to clean up the bad form.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-vga/include/asm-ia64/io.h
=================================--- work-vga.orig/include/asm-ia64/io.h	2005-08-10 14:07:01.000000000 -0600
+++ work-vga/include/asm-ia64/io.h	2005-08-18 13:56:55.000000000 -0600
@@ -41,7 +41,7 @@
 #define IO_SPACE_BASE(space)		((space) << IO_SPACE_BITS)
 #define IO_SPACE_PORT(port)		((port) & (IO_SPACE_SIZE - 1))
 
-#define IO_SPACE_SPARSE_ENCODING(p)	((((p) >> 2) << 12) | (p & 0xfff))
+#define IO_SPACE_SPARSE_ENCODING(p)	((((p) >> 2) << 12) | ((p) & 0xfff))
 
 struct io_space {
 	unsigned long mmio_base;	/* base in MMIO space */
