From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 14 Dec 2001 22:54:44 +0000
Subject: [Linux-ia64] mmio barrier macro
Message-Id: <marc-linux-ia64-105590698805698@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a first iteration of the macro I was talking about implementing
awhile back.  I'd like people to check it out (especially those with
platforms that can issue pios out of order) and give me some feedback.
The next thing I have to do is implement the mmiob() macro for all
other architectures.  Since most archs don't have this problem, it'll
probably just be a regular memory barrier or a noop.

I'm also not quite sure if I have the machvec stuff right.  It seems
to compile and work for sn1 platforms, but I haven't tested others
yet.

Thanks,
Jesse


diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/arch/ia64/sn/kernel/sn1/iomv.c linux-2.4.16-mmiob/arch/ia64/sn/kernel/sn1/iomv.c
--- linux-2.4.16-ia64/arch/ia64/sn/kernel/sn1/iomv.c	Tue Dec 11 15:44:50 2001
+++ linux-2.4.16-mmiob/arch/ia64/sn/kernel/sn1/iomv.c	Fri Dec 14 14:47:04 2001
@@ -9,6 +9,8 @@
 #include <asm/io.h>
 #include <linux/pci.h>
 #include <asm/sn/simulator.h>
+#include <asm/pio_flush.h>
+#include <asm/delay.h>
 
 static inline void *
 sn1_io_addr(unsigned long port)
@@ -134,3 +136,10 @@
 	__ia64_mf_a();
 }
 #endif /* SN1_IOPORTS */
+
+void
+sn_mmiob (unsigned long addr)
+{
+	PIO_FLUSH();
+}
+
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/include/asm-ia64/io.h linux-2.4.16-mmiob/include/asm-ia64/io.h
--- linux-2.4.16-ia64/include/asm-ia64/io.h	Fri Nov  9 14:26:17 2001
+++ linux-2.4.16-mmiob/include/asm-ia64/io.h	Fri Dec 14 14:44:49 2001
@@ -69,6 +69,22 @@
  */
 #define __ia64_mf_a()	__asm__ __volatile__ ("mf.a" ::: "memory")
 
+/**
+ * __ia64_mmiob - memory mapped I/O barrier
+ * @addr: device or PCI bridge address to read from
+ *
+ * Acts as a memory mapped I/O barrier for platforms that queue uncached
+ * writes.  This ensures that subsequent uncached writes arrive after
+ * all previous writes.  For most ia64 platforms, this is a simple
+ * 'mf.a' instruction, so the address is ignored.  For other platforms,
+ * the address is required to ensure proper ordering of uncached writes.
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
@@ -102,7 +118,7 @@
 	unsigned char ret;
 
 	ret = *addr;
-	__ia64_mf_a();
+	platform_mmiob(0);
 	return ret;
 }
 
@@ -113,7 +129,7 @@
 	unsigned short ret;
 
 	ret = *addr;
-	__ia64_mf_a();
+	platform_mmiob(0);
 	return ret;
 }
 
@@ -124,7 +140,7 @@
 	unsigned int ret;
 
 	ret = *addr;
-	__ia64_mf_a();
+	platform_mmiob(0);
 	return ret;
 }
 
@@ -134,7 +150,7 @@
 	volatile unsigned char *addr = __ia64_mk_io_addr(port);
 
 	*addr = val;
-	__ia64_mf_a();
+	platform_mmiob(0);
 }
 
 static inline void
@@ -143,7 +159,7 @@
 	volatile unsigned short *addr = __ia64_mk_io_addr(port);
 
 	*addr = val;
-	__ia64_mf_a();
+	platform_mmiob(0);
 }
 
 static inline void
@@ -152,7 +168,7 @@
 	volatile unsigned int *addr = __ia64_mk_io_addr(port);
 
 	*addr = val;
-	__ia64_mf_a();
+	platform_mmiob(0);
 }
 
 static inline void
@@ -163,10 +179,10 @@
 	if (platform_inb = __ia64_inb) {
 		volatile unsigned char *addr = __ia64_mk_io_addr(port);
 
-		__ia64_mf_a();
+		platform_mmiob(0);
 		while (count--)
 			*dp++ = *addr;
-		__ia64_mf_a();
+		platform_mmiob(0);
 	} else
 		while (count--)
 			*dp++ = platform_inb(port);
@@ -181,10 +197,10 @@
 	if (platform_inw = __ia64_inw) {
 		volatile unsigned short *addr = __ia64_mk_io_addr(port);
 
-		__ia64_mf_a();
+		platform_mmiob(0);
 		while (count--)
 			*dp++ = *addr;
-		__ia64_mf_a();
+		platform_mmiob(0);
 	} else
 		while (count--)
 			*dp++ = platform_inw(port);
@@ -199,10 +215,10 @@
 	if (platform_inl = __ia64_inl) {
 		volatile unsigned int *addr = __ia64_mk_io_addr(port);
 
-		__ia64_mf_a();
+		platform_mmiob(0);
 		while (count--)
 			*dp++ = *addr;
-		__ia64_mf_a();
+		platform_mmiob(0);
 	} else
 		while (count--)
 			*dp++ = platform_inl(port);
@@ -219,7 +235,7 @@
 
 		while (count--)
 			*addr = *sp++;
-		__ia64_mf_a();
+		platform_mmiob(0);
 	} else
 		while (count--)
 			platform_outb(*sp++, port);
@@ -236,7 +252,7 @@
 
 		while (count--)
 			*addr = *sp++;
-		__ia64_mf_a();
+		platform_mmiob(0);
 	} else
 		while (count--)
 			platform_outw(*sp++, port);
@@ -253,7 +269,7 @@
 
 		while (count--)
 			*addr = *sp++;
-		__ia64_mf_a();
+		platform_mmiob(0);
 	} else
 		while (count--)
 			platform_outl(*sp++, port);
@@ -271,6 +287,7 @@
 #define __outb		platform_outb
 #define __outw		platform_outw
 #define __outl		platform_outl
+#define __mmiob         platform_mmiob
 
 #define inb		__inb
 #define inw		__inw
@@ -284,6 +301,7 @@
 #define outsb		__outsb
 #define outsw		__outsw
 #define outsl		__outsl
+#define mmiob           __mmiob
 
 /*
  * The address passed to these functions are ioremap()ped already.
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/include/asm-ia64/machvec.h linux-2.4.16-mmiob/include/asm-ia64/machvec.h
--- linux-2.4.16-ia64/include/asm-ia64/machvec.h	Tue Dec 11 15:44:50 2001
+++ linux-2.4.16-mmiob/include/asm-ia64/machvec.h	Fri Dec 14 14:44:49 2001
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
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16-ia64/include/asm-ia64/machvec_sn1.h linux-2.4.16-mmiob/include/asm-ia64/machvec_sn1.h
--- linux-2.4.16-ia64/include/asm-ia64/machvec_sn1.h	Tue Dec 11 15:44:50 2001
+++ linux-2.4.16-mmiob/include/asm-ia64/machvec_sn1.h	Fri Dec 14 14:45:50 2001
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

