From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 20 Oct 2004 22:48:59 +0000
Subject: [PATCH] more sparse I/O accessor fixes
Message-Id: <200410201548.59622.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_btudBQpZ+tiCNp4"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_btudBQpZ+tiCNp4
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I forgot to add 'const volatile' to the I/O read/write functions in the last 
patch, and also forgot to update the _relaxed variants.  This patch fixes 
that by adding 'const volatile' to the sn2 specific read/write routines as 
well as the ia64 machine vector wrappers.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse


--Boundary-00=_btudBQpZ+tiCNp4
Content-Type: text/plain;
  charset="us-ascii";
  name="sparse-io-access-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sparse-io-access-fixes.patch"

===== include/asm-ia64/machvec.h 1.27 vs edited =====
--- 1.27/include/asm-ia64/machvec.h	2004-10-20 13:38:35 -07:00
+++ edited/include/asm-ia64/machvec.h	2004-10-20 15:25:54 -07:00
@@ -62,14 +62,14 @@
 typedef void ia64_mv_outb_t (unsigned char, unsigned long);
 typedef void ia64_mv_outw_t (unsigned short, unsigned long);
 typedef void ia64_mv_outl_t (unsigned int, unsigned long);
-typedef unsigned char ia64_mv_readb_t (void __iomem *);
-typedef unsigned short ia64_mv_readw_t (void __iomem *);
-typedef unsigned int ia64_mv_readl_t (void __iomem *);
-typedef unsigned long ia64_mv_readq_t (void __iomem *);
-typedef unsigned char ia64_mv_readb_relaxed_t (void __iomem *);
-typedef unsigned short ia64_mv_readw_relaxed_t (void __iomem *);
-typedef unsigned int ia64_mv_readl_relaxed_t (void __iomem *);
-typedef unsigned long ia64_mv_readq_relaxed_t (void __iomem *);
+typedef unsigned char ia64_mv_readb_t (const volatile void __iomem *);
+typedef unsigned short ia64_mv_readw_t (const volatile void __iomem *);
+typedef unsigned int ia64_mv_readl_t (const volatile void __iomem *);
+typedef unsigned long ia64_mv_readq_t (const volatile void __iomem *);
+typedef unsigned char ia64_mv_readb_relaxed_t (const volatile void __iomem *);
+typedef unsigned short ia64_mv_readw_relaxed_t (const volatile void __iomem *);
+typedef unsigned int ia64_mv_readl_relaxed_t (const volatile void __iomem *);
+typedef unsigned long ia64_mv_readq_relaxed_t (const volatile void __iomem *);
 
 static inline void
 machvec_noop (void)
===== include/asm-ia64/sn/io.h 1.2 vs edited =====
--- 1.2/include/asm-ia64/sn/io.h	2004-10-20 13:38:35 -07:00
+++ edited/include/asm-ia64/sn/io.h	2004-10-20 15:27:01 -07:00
@@ -129,7 +129,7 @@
  */
 
 static inline unsigned char
-___sn_readb (void __iomem *addr)
+___sn_readb (const volatile void __iomem *addr)
 {
 	unsigned char val;
 
@@ -140,7 +140,7 @@
 }
 
 static inline unsigned short
-___sn_readw (void __iomem *addr)
+___sn_readw (const volatile void __iomem *addr)
 {
 	unsigned short val;
 
@@ -151,7 +151,7 @@
 }
 
 static inline unsigned int
-___sn_readl (void __iomem *addr)
+___sn_readl (const volatile void __iomem *addr)
 {
 	unsigned int val;
 
@@ -162,7 +162,7 @@
 }
 
 static inline unsigned long
-___sn_readq (void __iomem *addr)
+___sn_readq (const volatile void __iomem *addr)
 {
 	unsigned long val;
 
@@ -215,27 +215,27 @@
 }
 
 static inline unsigned char
-___sn_readb_relaxed (void *addr)
+___sn_readb_relaxed (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned char *)addr;
+	return *(volatile unsigned char __force *)addr;
 }
 
 static inline unsigned short
-___sn_readw_relaxed (void *addr)
+___sn_readw_relaxed (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned short *)addr;
+	return *(volatile unsigned short __force *)addr;
 }
 
 static inline unsigned int
-___sn_readl_relaxed (void *addr)
+___sn_readl_relaxed (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned int *) addr;
+	return *(volatile unsigned int __force *) addr;
 }
 
 static inline unsigned long
-___sn_readq_relaxed (void *addr)
+___sn_readq_relaxed (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned long *) addr;
+	return *(volatile unsigned long __force *) addr;
 }
 
 struct pci_dev;

--Boundary-00=_btudBQpZ+tiCNp4--
