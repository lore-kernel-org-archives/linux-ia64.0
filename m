From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 26 Oct 2004 21:57:02 +0000
Subject: [PATCH] ia64 iomap implementation
Message-Id: <200410261557.02701.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_ugsfBl0XookVqkc"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_ugsfBl0XookVqkc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

ia64: implement iomap interfaces

This preserves the ioreadX() == inX() semantics (same as i386),
since it's not clear that the speedup of omitting the mf.a for
port operations is worth the risk of breaking drivers.

This touches lib/iomap.c as well as the ia64-specific stuff, so
I guess you and Linus can sort that out.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

===== include/asm-ia64/io.h 1.22 vs edited =====
--- 1.22/include/asm-ia64/io.h 2004-10-25 14:06:49 -06:00
+++ edited/include/asm-ia64/io.h 2004-10-26 14:17:37 -06:00
@@ -32,7 +32,8 @@
  */
 #define IO_SPACE_LIMIT  0xffffffffffffffffUL
 
-#define MAX_IO_SPACES   16
+#define MAX_IO_SPACES_BITS  4
+#define MAX_IO_SPACES   (1UL << MAX_IO_SPACES_BITS)
 #define IO_SPACE_BITS   24
 #define IO_SPACE_SIZE   (1UL << IO_SPACE_BITS)
 
@@ -52,10 +53,24 @@
 
 # ifdef __KERNEL__
 
+/*
+ * All MMIO iomem cookies are in region 6; anything less is a PIO cookie:
+ * 0xCxxxxxxxxxxxxxxx MMIO cookie (return from ioremap)
+ * 0x000000001SPPPPPP PIO cookie (S=space number, P..P=port)
+ *
+ * ioread/writeX() uses the leading 1 in PIO cookies (PIO_OFFSET) to catch
+ * code that uses bare port numbers without the prerequisite pci_iomap().
+ */
+#define PIO_OFFSET  (1UL << (MAX_IO_SPACES_BITS + IO_SPACE_BITS))
+#define PIO_MASK  (PIO_OFFSET - 1)
+#define PIO_RESERVED  __IA64_UNCACHED_OFFSET
+#define HAVE_ARCH_PIO_SIZE
+
 #include <asm/intrinsics.h>
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
+#include <asm-generic/iomap.h>
 
 /*
  * Change virtual addresses to physical addresses and vv.
===== lib/iomap.c 1.5 vs edited =====
--- 1.5/lib/iomap.c 2004-10-18 23:27:35 -06:00
+++ edited/lib/iomap.c 2004-10-26 14:10:11 -06:00
@@ -19,7 +19,10 @@
  *
  * Architectures for which this is not true can't use this generic
  * implementation and should do their own copy.
- *
+ */
+
+#ifndef HAVE_ARCH_PIO_SIZE
+/*
  * We encode the physical PIO addresses (0-0xffff) into the
  * pointer by offsetting them with a constant (0x10000) and
  * assuming that all the low addresses are always PIO. That means
@@ -29,6 +32,7 @@
 #define PIO_OFFSET 0x10000UL
 #define PIO_MASK 0x0ffffUL
 #define PIO_RESERVED 0x40000UL
+#endif
 
 /*
  * Ugly macros are a way of life.

--Boundary-00=_ugsfBl0XookVqkc
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iomap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iomap.patch"

===== include/asm-ia64/io.h 1.22 vs edited =====
--- 1.22/include/asm-ia64/io.h	2004-10-25 14:06:49 -06:00
+++ edited/include/asm-ia64/io.h	2004-10-26 14:17:37 -06:00
@@ -32,7 +32,8 @@
  */
 #define IO_SPACE_LIMIT		0xffffffffffffffffUL
 
-#define MAX_IO_SPACES			16
+#define MAX_IO_SPACES_BITS		4
+#define MAX_IO_SPACES			(1UL << MAX_IO_SPACES_BITS)
 #define IO_SPACE_BITS			24
 #define IO_SPACE_SIZE			(1UL << IO_SPACE_BITS)
 
@@ -52,10 +53,24 @@
 
 # ifdef __KERNEL__
 
+/*
+ * All MMIO iomem cookies are in region 6; anything less is a PIO cookie:
+ *	0xCxxxxxxxxxxxxxxx	MMIO cookie (return from ioremap)
+ *	0x000000001SPPPPPP	PIO cookie (S=space number, P..P=port)
+ *
+ * ioread/writeX() uses the leading 1 in PIO cookies (PIO_OFFSET) to catch
+ * code that uses bare port numbers without the prerequisite pci_iomap().
+ */
+#define PIO_OFFSET		(1UL << (MAX_IO_SPACES_BITS + IO_SPACE_BITS))
+#define PIO_MASK		(PIO_OFFSET - 1)
+#define PIO_RESERVED		__IA64_UNCACHED_OFFSET
+#define HAVE_ARCH_PIO_SIZE
+
 #include <asm/intrinsics.h>
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
+#include <asm-generic/iomap.h>
 
 /*
  * Change virtual addresses to physical addresses and vv.
===== lib/iomap.c 1.5 vs edited =====
--- 1.5/lib/iomap.c	2004-10-18 23:27:35 -06:00
+++ edited/lib/iomap.c	2004-10-26 14:10:11 -06:00
@@ -19,7 +19,10 @@
  *
  * Architectures for which this is not true can't use this generic
  * implementation and should do their own copy.
- *
+ */
+
+#ifndef HAVE_ARCH_PIO_SIZE
+/*
  * We encode the physical PIO addresses (0-0xffff) into the
  * pointer by offsetting them with a constant (0x10000) and
  * assuming that all the low addresses are always PIO. That means
@@ -29,6 +32,7 @@
 #define PIO_OFFSET	0x10000UL
 #define PIO_MASK	0x0ffffUL
 #define PIO_RESERVED	0x40000UL
+#endif
 
 /*
  * Ugly macros are a way of life.

--Boundary-00=_ugsfBl0XookVqkc--
