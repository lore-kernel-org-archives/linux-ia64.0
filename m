From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 26 Oct 2004 21:46:57 +0000
Subject: [PATCH] fix machine vectors for mmiowb
Message-Id: <200410261446.57885.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_RXsfB/moIrk6N2p"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_RXsfB/moIrk6N2p
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I left out some of the necessary machine vector magic in the mmiowb patch 
which caused the generic build to break.  This patch fixes it up by properly 
#defining it and #undefing it and adding a routine to lib/io.c.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_RXsfB/moIrk6N2p
Content-Type: text/plain;
  charset="us-ascii";
  name="mmiowb-generic-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mmiowb-generic-fix.patch"

===== arch/ia64/lib/io.c 1.9 vs edited =====
--- 1.9/arch/ia64/lib/io.c	2004-10-05 11:30:39 -07:00
+++ edited/arch/ia64/lib/io.c	2004-10-26 14:34:32 -07:00
@@ -73,6 +73,7 @@
 #undef __ia64_writew
 #undef __ia64_writel
 #undef __ia64_writeq
+#undef __ia64_mmiowb
 
 unsigned int
 __ia64_inb (unsigned long port)
@@ -156,6 +157,12 @@
 __ia64_readq_relaxed (void __iomem *addr)
 {
 	return ___ia64_readq (addr);
+}
+
+void
+__ia64_mmiowb(void)
+{
+	___ia64_mmiowb();
 }
 
 #endif /* CONFIG_IA64_GENERIC */
===== include/asm-ia64/io.h 1.22 vs edited =====
--- 1.22/include/asm-ia64/io.h	2004-10-25 13:06:49 -07:00
+++ edited/include/asm-ia64/io.h	2004-10-26 14:42:43 -07:00
@@ -92,7 +92,7 @@
 #define __ia64_mf_a()	ia64_mfa()
 
 /**
- * __ia64_mmiowb - I/O write barrier
+ * ___ia64_mmiowb - I/O write barrier
  *
  * Ensure ordering of I/O space writes.  This will make sure that writes
  * following the barrier will arrive after all previous writes.  For most
@@ -100,7 +100,7 @@
  *
  * See Documentation/DocBook/deviceiobook.tmpl for more information.
  */
-static inline void __ia64_mmiowb(void)
+static inline void ___ia64_mmiowb(void)
 {
 	ia64_mfa();
 }
@@ -147,6 +147,7 @@
 #define __ia64_writew	___ia64_writew
 #define __ia64_writel	___ia64_writel
 #define __ia64_writeq	___ia64_writeq
+#define __ia64_mmiowb	___ia64_mmiowb
 
 /*
  * For the in/out routines, we need to do "mf.a" _after_ doing the I/O access to ensure

--Boundary-00=_RXsfB/moIrk6N2p--
