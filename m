From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 17 Dec 2001 19:09:15 +0000
Subject: Re: [Linux-ia64] mmio barrier macro
Message-Id: <marc-linux-ia64-105590698805708@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805698@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805698@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 14, 2001 at 04:55:55PM -0800, Jesse Barnes wrote:
> On Fri, Dec 14, 2001 at 04:22:42PM -0800, David Mosberger wrote:
> > This patch looks wrong to me.  It shouldn't replace __ia64_mf_a() with
> > platform_mmiob() because this will force the use of mf.a even on
> > platforms that don't need it for memory-mapped I/O.  Also, how about a
> 
> Oh yeah, good point.  I guess that means our platform specific
> inX/outX routines should be retained then, and we can put the barriers
> there.
> 
> > comment explaining exactly what is being ordered with respect to whom
> > (yes, I know there are many examples in Linux where this hasn't been
> > done, but I don't think that's a good reason to make the situation
> > worse).

I'm not sure what more you wanted in the comment, but I tried to
clarify the one in include/asm-ia64/io.h a little.  Here's the new
version.  Please let me know what you think.

Thanks,
Jesse


diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/arch/ia64/sn/kernel/sn1/iomv.c linux-2.4.16-ia64-mmiob/arch/ia64/sn/kernel/sn1/iomv.c
--- linux-2.4.16-ia64/arch/ia64/sn/kernel/sn1/iomv.c	Mon Dec 17 10:57:21 2001
+++ linux-2.4.16-ia64-mmiob/arch/ia64/sn/kernel/sn1/iomv.c	Mon Dec 17 11:03:39 2001
@@ -9,6 +9,8 @@
 #include <asm/io.h>
 #include <linux/pci.h>
 #include <asm/sn/simulator.h>
+#include <asm/pio_flush.h>
+#include <asm/delay.h>
 
 static inline void *
 sn1_io_addr(unsigned long port)
@@ -134,3 +136,9 @@
 	__ia64_mf_a();
 }
 #endif /* SN1_IOPORTS */
+
+void
+sn_mmiob (unsigned long addr)
+{
+	PIO_FLUSH();
+}
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/include/asm-ia64/io.h linux-2.4.16-ia64-mmiob/include/asm-ia64/io.h
--- linux-2.4.16-ia64/include/asm-ia64/io.h	Fri Nov  9 14:26:17 2001
+++ linux-2.4.16-ia64-mmiob/include/asm-ia64/io.h	Mon Dec 17 11:08:14 2001
@@ -69,6 +69,23 @@
  */
 #define __ia64_mf_a()	__asm__ __volatile__ ("mf.a" ::: "memory")
 
+/**
+ * __ia64_mmiob - I/O space memory barrier
+ * @addr: device or PCI bridge address to read from
+ *
+ * Acts as a memory mapped I/O barrier for platforms that queue writes to 
+ * I/O space.  This ensures that subsequent writes to I/O space arrive after
+ * all previous writes.  For most ia64 platforms, this is a simple
+ * 'mf.a' instruction, so the address is ignored.  For other platforms,
+ * the address may be required to ensure proper ordering of writes to I/O space
+ * since a 'dummy' read might be necessary to barrier the write operation.
+ */
+static inline void
+__ia64_mmiob (unsigned long addr)
+{
+	__ia64_mf_a();
+}
+
 static inline const unsigned long
 __ia64_get_io_port_base (void)
 {
@@ -271,6 +288,7 @@
 #define __outb		platform_outb
 #define __outw		platform_outw
 #define __outl		platform_outl
+#define __mmiob         platform_mmiob
 
 #define inb		__inb
 #define inw		__inw
@@ -284,6 +302,7 @@
 #define outsb		__outsb
 #define outsw		__outsw
 #define outsl		__outsl
+#define mmiob           __mmiob
 
 /*
  * The address passed to these functions are ioremap()ped already.
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/include/asm-ia64/machvec.h linux-2.4.16-ia64-mmiob/include/asm-ia64/machvec.h
--- linux-2.4.16-ia64/include/asm-ia64/machvec.h	Mon Dec 17 10:57:22 2001
+++ linux-2.4.16-ia64-mmiob/include/asm-ia64/machvec.h	Mon Dec 17 11:03:39 2001
@@ -60,6 +60,7 @@
 typedef void ia64_mv_outb_t (unsigned char, unsigned long);
 typedef void ia64_mv_outw_t (unsigned short, unsigned long);
 typedef void ia64_mv_outl_t (unsigned int, unsigned long);
+typedef void ia64_mv_mmiob_t (unsigned long);
 
 extern void machvec_noop (void);
 
@@ -107,6 +108,7 @@
 #  define platform_outb		ia64_mv.outb
 #  define platform_outw		ia64_mv.outw
 #  define platform_outl		ia64_mv.outl
+#  define platofrm_mmiob        ia64_mv.mmiob
 # endif
 
 struct ia64_machine_vector {
@@ -140,6 +142,7 @@
 	ia64_mv_outb_t *outb;
 	ia64_mv_outw_t *outw;
 	ia64_mv_outl_t *outl;
+	ia64_mv_mmiob_t *mmiob;
 };
 
 #define MACHVEC_INIT(name)			\
@@ -173,7 +176,8 @@
 	platform_inl,				\
 	platform_outb,				\
 	platform_outw,				\
-	platform_outl				\
+	platform_outl,				\
+        platform_mmiob                          \
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -287,6 +291,9 @@
 #endif
 #ifndef platform_outl
 # define platform_outl		__ia64_outl
+#endif
+#ifndef platform_mmiob
+# define platform_mmiob         __ia64_mmiob
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/include/asm-ia64/machvec_sn1.h linux-2.4.16-ia64-mmiob/include/asm-ia64/machvec_sn1.h
--- linux-2.4.16-ia64/include/asm-ia64/machvec_sn1.h	Mon Dec 17 10:57:22 2001
+++ linux-2.4.16-ia64-mmiob/include/asm-ia64/machvec_sn1.h	Mon Dec 17 11:03:39 2001
@@ -14,6 +14,7 @@
 extern ia64_mv_outb_t sn1_outb;
 extern ia64_mv_outw_t sn1_outw;
 extern ia64_mv_outl_t sn1_outl;
+extern ia64_mv_mmiob_t sn_mmiob;
 extern ia64_mv_pci_alloc_consistent	sn1_pci_alloc_consistent;
 extern ia64_mv_pci_free_consistent	sn1_pci_free_consistent;
 extern ia64_mv_pci_map_single		sn1_pci_map_single;
@@ -45,6 +46,7 @@
 #define platform_outb		sn1_outb
 #define platform_outw		sn1_outw
 #define platform_outl		sn1_outl
+#define platform_mmiob          sn_mmiob
 #define platform_pci_dma_init	machvec_noop
 #define platform_pci_alloc_consistent	sn1_pci_alloc_consistent
 #define platform_pci_free_consistent	sn1_pci_free_consistent

