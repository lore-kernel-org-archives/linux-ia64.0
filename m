From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 14 Dec 2004 21:31:27 +0000
Subject: [PATCH] Fix memcpy_fromio prototype
Message-Id: <20041214213127.GV27199@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Remove one layer of indirection from memcpy_fromio/memcpy_toio/memset_io
and fix the prototypes to be const where appropriate.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: arch/ia64/lib/io.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/lib/io.c,v
retrieving revision 1.6
diff -u -p -r1.6 io.c
--- arch/ia64/lib/io.c	29 Nov 2004 19:55:31 -0000	1.6
+++ arch/ia64/lib/io.c	14 Dec 2004 21:23:07 -0000
@@ -8,8 +8,7 @@
  * Copy data from IO memory space to "real" memory space.
  * This needs to be optimized.
  */
-void
-__ia64_memcpy_fromio (void *to, volatile void __iomem *from, long count)
+void memcpy_fromio(void *to, const volatile void __iomem *from, long count)
 {
 	char *dst = to;
 
@@ -18,30 +17,28 @@ __ia64_memcpy_fromio (void *to, volatile
 		*dst++ = readb(from++);
 	}
 }
-EXPORT_SYMBOL(__ia64_memcpy_fromio);
+EXPORT_SYMBOL(memcpy_fromio);
 
 /*
  * Copy data from "real" memory space to IO memory space.
  * This needs to be optimized.
  */
-void
-__ia64_memcpy_toio (volatile void __iomem *to, void *from, long count)
+void memcpy_toio(volatile void __iomem *to, const void *from, long count)
 {
-	char *src = from;
+	const char *src = from;
 
 	while (count) {
 		count--;
 		writeb(*src++, to++);
 	}
 }
-EXPORT_SYMBOL(__ia64_memcpy_toio);
+EXPORT_SYMBOL(memcpy_toio);
 
 /*
  * "memset" on IO memory space.
  * This needs to be optimized.
  */
-void
-__ia64_memset_c_io (volatile void __iomem *dst, unsigned long c, long count)
+void memset_io(volatile void __iomem *dst, int c, long count)
 {
 	unsigned char ch = (char)(c & 0xff);
 
@@ -51,7 +48,7 @@ __ia64_memset_c_io (volatile void __iome
 		dst++;
 	}
 }
-EXPORT_SYMBOL(__ia64_memset_c_io);
+EXPORT_SYMBOL(memset_io);
 
 #ifdef CONFIG_IA64_GENERIC
 
Index: include/asm-ia64/io.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/io.h,v
retrieving revision 1.8
diff -u -p -r1.8 io.h
--- include/asm-ia64/io.h	29 Nov 2004 19:56:42 -0000	1.8
+++ include/asm-ia64/io.h	14 Dec 2004 21:23:08 -0000
@@ -447,14 +447,9 @@ iounmap (volatile void __iomem *addr)
 /*
  * String version of IO memory access ops:
  */
-extern void __ia64_memcpy_fromio (void *, volatile void __iomem *, long);
-extern void __ia64_memcpy_toio (volatile void __iomem *, void *, long);
-extern void __ia64_memset_c_io (volatile void __iomem *, unsigned long, long);
-
-#define memcpy_fromio(to,from,len)	__ia64_memcpy_fromio((to), (from),(len))
-#define memcpy_toio(to,from,len)	__ia64_memcpy_toio((to),(from),(len))
-#define memset_io(addr,c,len)		__ia64_memset_c_io((addr), 0x0101010101010101UL*(u8)(c), \
-							   (len))
+extern void memcpy_fromio(void *dst, const volatile void __iomem *src, long n);
+extern void memcpy_toio(volatile void __iomem *dst, const void *src, long n);
+extern void memset_io(volatile void __iomem *s, int c, long n);
 
 #define dma_cache_inv(_start,_size)             do { } while (0)
 #define dma_cache_wback(_start,_size)           do { } while (0)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
