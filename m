From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 25 Oct 2004 16:48:48 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <200410251048.48249.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_w5SfBFxHh2YVXMe"
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_w5SfBFxHh2YVXMe
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 21 October 2004 8:34 am, David Mosberger wrote:
> Is anybody already working on an ia64-version of lib/iomap.c?

Here's a start (also attached, because of the kmail bug that
corrupts whitespace).

The idea is that all MMIO iomem cookies are in region 6, so
anything less than that must be a PIO cookie.  So we have:

 0xCxxxxxxxxxxxxxxx MMIO cookie (return from ioremap)
 0xRxxxxxxx1SPPPPPP PIO cookie (R=[0-9AB], S=space num, P..P=port)

I heard a rumor that ioreadX() on PIO cookies is supposed to
have looser semantics than inX() on the port, so we might be
able to get away without the memory fence in inb().  But I
can't substantiate that, so this keeps the generic behavior
of ioreadX() and inX() having identical semantics for PIO.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

===== include/asm-ia64/io.h 1.21 vs edited =====
--- 1.21/include/asm-ia64/io.h 2004-10-05 12:30:39 -06:00
+++ edited/include/asm-ia64/io.h 2004-10-25 10:06:00 -06:00
@@ -32,7 +32,8 @@
  */
 #define IO_SPACE_LIMIT  0xffffffffffffffffUL
 
-#define MAX_IO_SPACES   16
+#define MAX_IO_SPACES_BITS  4
+#define MAX_IO_SPACES   (1UL << MAX_IO_SPACES_BITS)
 #define IO_SPACE_BITS   24
 #define IO_SPACE_SIZE   (1UL << IO_SPACE_BITS)
 
@@ -52,10 +53,16 @@
 
 # ifdef __KERNEL__
 
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
+++ edited/lib/iomap.c 2004-10-25 10:09:26 -06:00
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

--Boundary-00=_w5SfBFxHh2YVXMe
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="diffs"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="diffs"

===== include/asm-ia64/io.h 1.21 vs edited =====
--- 1.21/include/asm-ia64/io.h	2004-10-05 12:30:39 -06:00
+++ edited/include/asm-ia64/io.h	2004-10-25 10:06:00 -06:00
@@ -32,7 +32,8 @@
  */
 #define IO_SPACE_LIMIT		0xffffffffffffffffUL
 
-#define MAX_IO_SPACES			16
+#define MAX_IO_SPACES_BITS		4
+#define MAX_IO_SPACES			(1UL << MAX_IO_SPACES_BITS)
 #define IO_SPACE_BITS			24
 #define IO_SPACE_SIZE			(1UL << IO_SPACE_BITS)
 
@@ -52,10 +53,16 @@
 
 # ifdef __KERNEL__
 
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
+++ edited/lib/iomap.c	2004-10-25 10:09:26 -06:00
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

--Boundary-00=_w5SfBFxHh2YVXMe--
