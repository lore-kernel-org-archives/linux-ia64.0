From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 28 Mar 2003 01:28:09 +0000
Subject: [Linux-ia64] Re: [PATCH] machine vectors for readX routines
Message-Id: <marc-linux-ia64-105590723705348@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 27, 2003 at 04:53:41PM -0800, Jesse Barnes wrote:
> It's unfortunate that our platform requires this, but the overhead of
> the extra cycles for the indirect call should be small compared to how
> long it takes the read to complete.  I'm not sure if I got this patch
> right, it's against the nommiob patch I sent you earlier, so hopefully
> you won't have any conflicts when applying it.

Here's one with the comments.

Thanks,
Jesse


diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/arch/ia64/lib/io.c linux-2.5.64-readX/arch/ia64/lib/io.c
--- linux-2.5.64-ia64-nommiob/arch/ia64/lib/io.c	Tue Mar  4 19:28:53 2003
+++ linux-2.5.64-readX/arch/ia64/lib/io.c	Thu Mar 27 15:52:21 2003
@@ -87,12 +87,31 @@
 	__ia64_outl(val, port);
 }
 
-void
-ia64_mmiob (void)
+unsigned char
+ia64_readb (void *addr)
 {
-	__ia64_mmiob();
+	return __ia64_readb (addr);
 }
 
+unsigned short
+ia64_readw (void *addr)
+{
+	return __ia64_readw (addr);
+}
+
+unsigned int
+ia64_readl (void *addr)
+{
+	return __ia64_readl (addr);
+}
+
+unsigned long
+ia64_readq (void *addr)
+{
+	return __ia64_readq (addr)
+}
+
+
 /* define aliases: */
 
 asm (".global __ia64_inb, __ia64_inw, __ia64_inl");
@@ -105,7 +124,11 @@
 asm ("__ia64_outw = ia64_outw");
 asm ("__ia64_outl = ia64_outl");
 
-asm (".global __ia64_mmiob");
-asm ("__ia64_mmiob = ia64_mmiob");
+asm (".global __ia64_readb, __ia64_readw, __ia64_readl, __ia64_readq");
+asm ("__ia64_readb = ia64_readb");
+asm ("__ia64_readw = ia64_readw");
+asm ("__ia64_readl = ia64_readl");
+asm ("__ia64_readq = ia64_readq");
+
 
 #endif /* CONFIG_IA64_GENERIC */
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/arch/ia64/sn/kernel/sn2/io.c linux-2.5.64-readX/arch/ia64/sn/kernel/sn2/io.c
--- linux-2.5.64-ia64-nommiob/arch/ia64/sn/kernel/sn2/io.c	Wed Dec 31 16:00:00 1969
+++ linux-2.5.64-readX/arch/ia64/sn/kernel/sn2/io.c	Thu Mar 27 15:51:51 2003
@@ -0,0 +1,98 @@
+/* 
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2003 Silicon Graphics, Inc. All rights reserved.
+ *
+ * The generic kernel requires function pointers to these routines, so
+ * we wrap the inlines from asm/ia64/sn/sn2/io.h here.
+ */
+
+#include <linux/config.h>
+#include <linux/types.h>
+
+#include <asm/sn/sn2/io.h>
+
+#ifdef CONFIG_IA64_GENERIC
+
+unsigned int
+sn_inb (unsigned long port)
+{
+	return __sn_inb(port);
+}
+
+unsigned int
+sn_inw (unsigned long port)
+{
+	return __sn_inw(port);
+}
+
+unsigned int
+sn_inl (unsigned long port)
+{
+	return __sn_inl(port);
+}
+
+void
+sn_outb (unsigned char val, unsigned long port)
+{
+	__sn_outb(val, port);
+}
+
+void
+sn_outw (unsigned short val, unsigned long port)
+{
+	__sn_outw(val, port);
+}
+
+void
+sn_outl (unsigned int val, unsigned long port)
+{
+	__sn_outl(val, port);
+}
+
+unsigned char
+sn_readb (void *addr)
+{
+	return __sn_readb (addr);
+}
+
+unsigned short
+sn_readw (void *addr)
+{
+	return __sn_readw (addr);
+}
+
+unsigned int
+sn_readl (void *addr)
+{
+	return __sn_readl (addr);
+}
+
+unsigned long
+sn_readq (void *addr)
+{
+	return __sn_readq (addr)
+}
+
+
+/* define aliases: */
+
+asm (".global __sn_inb, __sn_inw, __sn_inl");
+asm ("__sn_inb = sn_inb");
+asm ("__sn_inw = sn_inw");
+asm ("__sn_inl = sn_inl");
+
+asm (".global __sn_outb, __sn_outw, __sn_outl");
+asm ("__sn_outb = sn_outb");
+asm ("__sn_outw = sn_outw");
+asm ("__sn_outl = sn_outl");
+
+asm (".global __sn_readb, __sn_readw, __sn_readl, __sn_readq");
+asm ("__sn_readb = sn_readb");
+asm ("__sn_readw = sn_readw");
+asm ("__sn_readl = sn_readl");
+asm ("__sn_readq = sn_readq");
+
+#endif /* CONFIG_IA64_GENERIC */
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/arch/ia64/sn/kernel/sn2/iomv.c linux-2.5.64-readX/arch/ia64/sn/kernel/sn2/iomv.c
--- linux-2.5.64-ia64-nommiob/arch/ia64/sn/kernel/sn2/iomv.c	Tue Mar  4 19:29:30 2003
+++ linux-2.5.64-readX/arch/ia64/sn/kernel/sn2/iomv.c	Thu Mar 27 15:53:37 2003
@@ -3,10 +3,11 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2002 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/pci.h>
+#include <linux/module.h>
 #include <asm/io.h>
 #include <asm/delay.h>
 #include <asm/sn/simulator.h>
@@ -46,8 +47,10 @@
 	}
 }
 
+EXPORT_SYMBOL(sn_io_addr);
+
 /**
- * sn2_mmiob - I/O space memory barrier
+ * sn_mmiob - I/O space memory barrier
  *
  * Acts as a memory mapped I/O barrier for platforms that queue writes to 
  * I/O space.  This ensures that subsequent writes to I/O space arrive after
@@ -60,9 +63,9 @@
  *
  */
 void
-sn2_mmiob (void)
+sn_mmiob (void)
 {
-	while ((((volatile unsigned long) (*pda->pio_write_status_addr)) & SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK) != 
+	while ((((volatile unsigned long) (*pda.pio_write_status_addr)) & SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK) != 
 				SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK)
 		udelay(1);
 }
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/include/asm-ia64/io.h linux-2.5.64-readX/include/asm-ia64/io.h
--- linux-2.5.64-ia64-nommiob/include/asm-ia64/io.h	Thu Mar 27 16:02:05 2003
+++ linux-2.5.64-readX/include/asm-ia64/io.h	Thu Mar 27 16:56:31 2003
@@ -287,27 +287,32 @@
 
 /*
  * The address passed to these functions are ioremap()ped already.
+ *
+ * We need these to be machine vectors since some platforms don't provide
+ * DMA coherence via PIO reads (PCI drivers and the spec imply that this is
+ * a good idea).  Writes are ok though for all existing ia64 platforms (and
+ * hopefully it'll stay that way).
  */
 static inline unsigned char
-__readb (void *addr)
+__ia64_readb (void *addr)
 {
 	return *(volatile unsigned char *)addr;
 }
 
 static inline unsigned short
-__readw (void *addr)
+__ia64_readw (void *addr)
 {
 	return *(volatile unsigned short *)addr;
 }
 
 static inline unsigned int
-__readl (void *addr)
+__ia64_readl (void *addr)
 {
 	return *(volatile unsigned int *) addr;
 }
 
 static inline unsigned long
-__readq (void *addr)
+__ia64_readq (void *addr)
 {
 	return *(volatile unsigned long *) addr;
 }
@@ -335,6 +340,11 @@
 {
 	*(volatile unsigned long *) addr = val;
 }
+
+#define __readb		platform_readb
+#define __readw		platform_readw
+#define __readl		platform_readl
+#define __readq		platform_readq
 
 #define readb(a)	__readb((void *)(a))
 #define readw(a)	__readw((void *)(a))
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec.h linux-2.5.64-readX/include/asm-ia64/machvec.h
--- linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec.h	Thu Mar 27 16:02:05 2003
+++ linux-2.5.64-readX/include/asm-ia64/machvec.h	Thu Mar 27 15:48:16 2003
@@ -61,6 +61,10 @@
 typedef void ia64_mv_outb_t (unsigned char, unsigned long);
 typedef void ia64_mv_outw_t (unsigned short, unsigned long);
 typedef void ia64_mv_outl_t (unsigned int, unsigned long);
+typedef unsigned char ia64_mv_readb_t (void *);
+typedef unsigned short ia64_mv_readw_t (void *);
+typedef unsigned int ia64_mv_readl_t (void *);
+typedef unsigned long ia64_mv_readq_t (void *);
 
 extern void machvec_noop (void);
 
@@ -109,6 +113,10 @@
 #  define platform_outb		ia64_mv.outb
 #  define platform_outw		ia64_mv.outw
 #  define platform_outl		ia64_mv.outl
+#  define platform_readb        ia64_mv.readb
+#  define platform_readw        ia64_mv.readw
+#  define platform_readl        ia64_mv.readl
+#  define platform_readq        ia64_mv.readq
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
@@ -147,7 +155,11 @@
 	ia64_mv_outb_t *outb;
 	ia64_mv_outw_t *outw;
 	ia64_mv_outl_t *outl;
-} __attribute__((__aligned__(16)));
+	ia64_mv_readb_t *readb;
+	ia64_mv_readw_t *readw;
+	ia64_mv_readl_t *readl;
+	ia64_mv_readq_t *readq;
+};
 
 #define MACHVEC_INIT(name)			\
 {						\
@@ -181,6 +193,10 @@
 	platform_outb,				\
 	platform_outw,				\
 	platform_outl,				\
+	platform_readb,				\
+	platform_readw,				\
+	platform_readl,				\
+	platform_readq,				\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -295,6 +311,18 @@
 #endif
 #ifndef platform_outl
 # define platform_outl		__ia64_outl
+#endif
+#ifndef platform_readb
+# define platform_readb		__ia64_readb
+#endif
+#ifndef platform_readw
+# define platform_readw		__ia64_readw
+#endif
+#ifndef platform_readl
+# define platform_readl		__ia64_readl
+#endif
+#ifndef platform_readq
+# define platform_readq		__ia64_readq
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_sn2.h linux-2.5.64-readX/include/asm-ia64/machvec_sn2.h
--- linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_sn2.h	Thu Mar 27 16:02:05 2003
+++ linux-2.5.64-readX/include/asm-ia64/machvec_sn2.h	Thu Mar 27 16:03:26 2003
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2002 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -41,12 +41,16 @@
 extern ia64_mv_irq_desc sn_irq_desc;
 extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
-extern ia64_mv_inb_t sn_inb;
-extern ia64_mv_inw_t sn_inw;
-extern ia64_mv_inl_t sn_inl;
-extern ia64_mv_outb_t sn_outb;
-extern ia64_mv_outw_t sn_outw;
-extern ia64_mv_outl_t sn_outl;
+extern ia64_mv_inb_t __sn_inb;
+extern ia64_mv_inw_t __sn_inw;
+extern ia64_mv_inl_t __sn_inl;
+extern ia64_mv_outb_t __sn_outb;
+extern ia64_mv_outw_t __sn_outw;
+extern ia64_mv_outl_t __sn_outl;
+extern ia64_mv_readb_t __sn_readb;
+extern ia64_mv_readw_t __sn_readw;
+extern ia64_mv_readl_t __sn_readl;
+extern ia64_mv_readq_t __sn_readq;
 extern ia64_mv_pci_alloc_consistent	sn_pci_alloc_consistent;
 extern ia64_mv_pci_free_consistent	sn_pci_free_consistent;
 extern ia64_mv_pci_map_single		sn_pci_map_single;
@@ -71,12 +75,17 @@
 #define platform_irq_init		sn_irq_init
 #define platform_send_ipi		sn2_send_IPI
 #define platform_global_tlb_purge       sn2_global_tlb_purge
-#define platform_inb			sn_inb
-#define platform_inw			sn_inw
-#define platform_inl			sn_inl
-#define platform_outb			sn_outb
-#define platform_outw			sn_outw
-#define platform_outl			sn_outl
+#define platform_pci_fixup		sn_pci_fixup
+#define platform_inb			__sn_inb
+#define platform_inw			__sn_inw
+#define platform_inl			__sn_inl
+#define platform_outb			__sn_outb
+#define platform_outw			__sn_outw
+#define platform_outl			__sn_outl
+#define platform_readb			__sn_readb
+#define platform_readw			__sn_readw
+#define platform_readl			__sn_readl
+#define platform_readq			__sn_readq
 #define platform_irq_desc		sn_irq_desc
 #define platform_irq_to_vector		sn_irq_to_vector
 #define platform_local_vector_to_irq	sn_local_vector_to_irq
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/include/asm-ia64/sn/io.h linux-2.5.64-readX/include/asm-ia64/sn/io.h
--- linux-2.5.64-ia64-nommiob/include/asm-ia64/sn/io.h	Tue Mar  4 19:28:58 2003
+++ linux-2.5.64-readX/include/asm-ia64/sn/io.h	Thu Mar 27 15:51:07 2003
@@ -3,8 +3,8 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
+ * Copyright (C) 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
  * Copyright (C) 2000 Ralf Baechle
- * Copyright (C) 2000-2001 Silicon Graphics, Inc.
  */
 #ifndef _ASM_IA64_SN_IO_H
 #define _ASM_IA64_SN_IO_H
@@ -77,5 +77,10 @@
 #include <asm/sn/sn2/shub.h>
 #include <asm/sn/sn2/shubio.h>
 #endif
+
+/*
+ * Used to ensure write ordering (like mb(), but for I/O space)
+ */
+extern void sn_mmiob(void);
 
 #endif /* _ASM_IA64_SN_IO_H */
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64-nommiob/include/asm-ia64/sn/sn2/io.h linux-2.5.64-readX/include/asm-ia64/sn/sn2/io.h
--- linux-2.5.64-ia64-nommiob/include/asm-ia64/sn/sn2/io.h	Wed Dec 31 16:00:00 1969
+++ linux-2.5.64-readX/include/asm-ia64/sn/sn2/io.h	Thu Mar 27 15:51:35 2003
@@ -0,0 +1,206 @@
+/* 
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#ifndef _ASM_SN_SN2_IO_H
+#define _ASM_SN_SN2_IO_H
+
+extern void * sn_io_addr(unsigned long port); /* Forward definition */
+extern void sn_mmiob(void); /* Forward definition */
+
+#define __sn_mf_a()   __asm__ __volatile__ ("mf.a" ::: "memory")
+
+extern void sn_dma_flush(unsigned long);
+
+/*
+ * The following routines are SN Platform specific, called when
+ * a reference is made to inX/outX set macros.  SN Platform
+ * inX set of macros ensures that Posted DMA writes on the
+ * Bridge is flushed.
+ *
+ * The routines should be self explainatory.
+ */
+
+static inline unsigned int
+__sn_inb (unsigned long port)
+{
+	volatile unsigned char *addr = sn_io_addr(port);
+	unsigned char ret;
+
+	ret = *addr;
+	sn_dma_flush((unsigned long)addr);
+	__sn_mf_a();
+	return ret;
+}
+
+static inline unsigned int
+__sn_inw (unsigned long port)
+{
+	volatile unsigned short *addr = sn_io_addr(port);
+	unsigned short ret;
+
+	ret = *addr;
+	sn_dma_flush((unsigned long)addr);
+	__sn_mf_a();
+	return ret;
+}
+
+static inline unsigned int
+__sn_inl (unsigned long port)
+{
+	volatile unsigned int *addr = sn_io_addr(port);
+	unsigned int ret;
+
+	ret = *addr;
+	sn_dma_flush((unsigned long)addr);
+	__sn_mf_a();
+	return ret;
+}
+
+static inline void
+__sn_outb (unsigned char val, unsigned long port)
+{
+	volatile unsigned char *addr = sn_io_addr(port);
+
+	*addr = val;
+	sn_mmiob();
+}
+
+static inline void
+__sn_outw (unsigned short val, unsigned long port)
+{
+	volatile unsigned short *addr = sn_io_addr(port);
+
+	*addr = val;
+	sn_mmiob();
+}
+
+static inline void
+__sn_outl (unsigned int val, unsigned long port)
+{
+	volatile unsigned int *addr = sn_io_addr(port);
+
+	*addr = val;
+	sn_mmiob();
+}
+
+/*
+ * The following routines are SN Platform specific, called when 
+ * a reference is made to readX/writeX set macros.  SN Platform 
+ * readX set of macros ensures that Posted DMA writes on the 
+ * Bridge is flushed.
+ * 
+ * The routines should be self explainatory.
+ */
+
+static inline unsigned char
+__sn_readb (void *addr)
+{
+	unsigned char val;
+
+	val = *(volatile unsigned char *)addr;
+	sn_dma_flush((unsigned long)addr);
+        return val;
+}
+
+static inline unsigned short
+__sn_readw (void *addr)
+{
+	unsigned short val;
+
+	val = *(volatile unsigned short *)addr;
+	sn_dma_flush((unsigned long)addr);
+        return val;
+}
+
+static inline unsigned int
+__sn_readl (void *addr)
+{
+	unsigned int val;
+
+	val = *(volatile unsigned int *) addr;
+	sn_dma_flush((unsigned long)addr);
+        return val;
+}
+
+static inline unsigned long
+__sn_readq (void *addr)
+{
+	unsigned long val;
+
+	val = *(volatile unsigned long *) addr;
+	sn_dma_flush((unsigned long)addr);
+        return val;
+}
+
+/*
+ * For generic and SN2 kernels, we have a set of fast access
+ * PIO macros.	These macros are provided on SN Platform
+ * because the normal inX and readX macros perform an
+ * additional task of flushing Post DMA request on the Bridge.
+ *
+ * These routines should be self explainatory.
+ */
+
+static inline unsigned int
+sn_inb_fast (unsigned long port)
+{
+	volatile unsigned char *addr = (unsigned char *)port;
+	unsigned char ret;
+
+	ret = *addr;
+	__sn_mf_a();
+	return ret;
+}
+
+static inline unsigned int
+sn_inw_fast (unsigned long port)
+{
+	volatile unsigned short *addr = (unsigned short *)port;
+	unsigned short ret;
+
+	ret = *addr;
+	__sn_mf_a();
+	return ret;
+}
+
+static inline unsigned int
+sn_inl_fast (unsigned long port)
+{
+	volatile unsigned int *addr = (unsigned int *)port;
+	unsigned int ret;
+
+	ret = *addr;
+	__sn_mf_a();
+	return ret;
+}
+
+static inline unsigned char
+sn_readb_fast (void *addr)
+{
+	return *(volatile unsigned char *)addr;
+}
+
+static inline unsigned short
+sn_readw_fast (void *addr)
+{
+	return *(volatile unsigned short *)addr;
+}
+
+static inline unsigned int
+sn_readl_fast (void *addr)
+{
+	return *(volatile unsigned int *) addr;
+}
+
+static inline unsigned long
+sn_readq_fast (void *addr)
+{
+	return *(volatile unsigned long *) addr;
+}
+
+#endif

