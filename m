From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 08 Apr 2003 23:09:00 +0000
Subject: [Linux-ia64] [patch] fixup for processor.h
Message-Id: <marc-linux-ia64-105590723705442@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a trivial patch to processor.h to change "extern" to "static".

The patch is against linux-2.5.64-ia64-030307

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


diff -X /home/mort/diffex -uNr linux-2.5.64.pristine/include/asm-ia64/processor.h linux-2.5.64/include/asm-ia64/processor.h
--- linux-2.5.64.pristine/include/asm-ia64/processor.h	Tue Apr  8 18:53:21 2003
+++ linux-2.5.64/include/asm-ia64/processor.h	Tue Apr  8 18:58:31 2003
@@ -912,13 +912,13 @@
 #define ARCH_HAS_SPINLOCK_PREFETCH
 #define PREFETCH_STRIDE 256
 
-extern inline void
+static inline void
 prefetch (const void *x)
 {
          __asm__ __volatile__ ("lfetch [%0]" : : "r"(x));
 }
 
-extern inline void
+static inline void
 prefetchw (const void *x)
 {
 	__asm__ __volatile__ ("lfetch.excl [%0]" : : "r"(x));

