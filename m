From: Aron Griffis <aron@hp.com>
Date: Tue, 17 Oct 2006 04:28:15 +0000
Subject: [PATCH] move ioremap/ioremap_nocache under __KERNEL__
Message-Id: <20061017042814.GA4158@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I noticed these are declared extern outside of __KERNEL__, but surely
they wouldn't be available to userland since they're defined in
ioremap.c.  Am I missing something here?

If I'm right about this, then there's probably a good deal of other
stuff in io.h that could move inside __KERNEL__, but at least this is
a start.

Signed-off-by: Aron Griffis <aron@hp.com>

diff -r 59a71f61e1df include/asm-ia64/io.h
--- a/include/asm-ia64/io.h	Tue Oct 17 02:19:03 2006 +0700
+++ b/include/asm-ia64/io.h	Tue Oct 17 00:24:12 2006 -0400
@@ -417,6 +417,8 @@ __writeq (unsigned long val, volatile vo
 # define outl_p		outl
 #endif
 
+# ifdef __KERNEL__
+
 extern void __iomem * ioremap(unsigned long offset, unsigned long size);
 extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
 
@@ -429,8 +431,6 @@ iounmap (volatile void __iomem *addr)
 #define dmi_ioremap ioremap
 #define dmi_iounmap(x,l) iounmap(x)
 #define dmi_alloc(l) kmalloc(l, GFP_ATOMIC)
-
-# ifdef __KERNEL__
 
 /*
  * String version of IO memory access ops:
