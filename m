From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 09 Jan 2002 01:36:00 +0000
Subject: [Linux-ia64] [PATCH] mmio barrier patch update
Message-Id: <marc-linux-ia64-105590698805779@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a new version of the mmio barrier patch (against 2.4.17 w/the
ia64 patch) I posted before the break.  In addition to writing some
documentation for the macro, I've removed the argument to the mmiob()
macro for a few reasons:

(1) platforms that need to do dummy reads from bridge chips or devices
    can do a loop of reads from each bridge chip or a device on each
    bus to ensure ordering
(2) hopefully there aren't that many platforms that have to do the
    above
(3) it simplifies another change I think we'll need--a mmiob() in the
    scheduler for processes that have done I/O in their timeslice

If these aren't good reasons, please let me know.  I'd like to get as
much input about the first two as possible; I'm really hoping that (2)
is true at the very least because it would mean that (1) might be a
valid workaround.

Thanks,
Jesse


diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.17-ia64/Documentation/mmio_barrier.txt linux-2.4.17-ia64-mmiob/Documentation/mmio_barrier.txt
--- linux-2.4.17-ia64/Documentation/mmio_barrier.txt	Wed Dec 31 16:00:00 1969
+++ linux-2.4.17-ia64-mmiob/Documentation/mmio_barrier.txt	Tue Jan  8 15:57:37 2002
@@ -0,0 +1,15 @@
+On some platforms, so-called memory-mapped I/O is weakly ordered.  For
+example, the following might occur:
+
+CPU A writes 0x1 to Device #1
+CPU B writes 0x2 to Device #1
+Device #1 sees 0x2
+Device #1 sees 0x1
+
+On such platforms, driver writers are responsible for ensuring that I/O
+writes to memory-mapped addresses on their device arrive in the order
+intended.  The mmiob() macro is provided for this purpose.  A typical use
+of this macro might be immediately prior to the exit of a critical
+section of code proteced by spinlocks.  This would ensure that subsequent
+writes to I/O space arrived only after all prior writes (much like a
+typical memory barrier op, mb(), only with respect to I/O).
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.17-ia64/arch/ia64/sn/kernel/sn1/iomv.c linux-2.4.17-ia64-mmiob/arch/ia64/sn/kernel/sn1/iomv.c
--- linux-2.4.17-ia64/arch/ia64/sn/kernel/sn1/iomv.c	Tue Jan  8 15:45:11 2002
+++ linux-2.4.17-ia64-mmiob/arch/ia64/sn/kernel/sn1/iomv.c	Tue Jan  8 15:58:54 2002
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
+sn_mmiob ()
+{
+	PIO_FLUSH();
+}
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.17-ia64/include/asm-ia64/io.h linux-2.4.17-ia64-mmiob/include/asm-ia64/io.h
--- linux-2.4.17-ia64/include/asm-ia64/io.h	Fri Nov  9 14:26:17 2001
+++ linux-2.4.17-ia64-mmiob/include/asm-ia64/io.h	Tue Jan  8 15:58:03 2002
@@ -69,6 +69,22 @@
  */
 #define __ia64_mf_a()	__asm__ __volatile__ ("mf.a" ::: "memory")
 
+/**
+ * __ia64_mmiob - I/O space memory barrier
+ *
+ * Acts as a memory mapped I/O barrier for platforms that queue writes to 
+ * I/O space.  This ensures that subsequent writes to I/O space arrive after
+ * all previous writes.  For most ia64 platforms, this is a simple
+ * 'mf.a' instruction, so the address is ignored.  For other platforms,
+ * the address may be required to ensure proper ordering of writes to I/O space
+ * since a 'dummy' read might be necessary to barrier the write operation.
+ */
+static inline void
+__ia64_mmiob ()
+{
+	__ia64_mf_a();
+}
+
 static inline const unsigned long
 __ia64_get_io_port_base (void)
 {
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
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.17-ia64/include/asm-ia64/machvec.h linux-2.4.17-ia64-mmiob/include/asm-ia64/machvec.h
--- linux-2.4.17-ia64/include/asm-ia64/machvec.h	Tue Jan  8 15:45:11 2002
+++ linux-2.4.17-ia64-mmiob/include/asm-ia64/machvec.h	Tue Jan  8 15:59:44 2002
@@ -60,6 +60,7 @@
 typedef void ia64_mv_outb_t (unsigned char, unsigned long);
 typedef void ia64_mv_outw_t (unsigned short, unsigned long);
 typedef void ia64_mv_outl_t (unsigned int, unsigned long);
+typedef void ia64_mv_mmiob_t (void);
 
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
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.17-ia64/include/asm-ia64/machvec_sn1.h linux-2.4.17-ia64-mmiob/include/asm-ia64/machvec_sn1.h
--- linux-2.4.17-ia64/include/asm-ia64/machvec_sn1.h	Tue Jan  8 15:45:11 2002
+++ linux-2.4.17-ia64-mmiob/include/asm-ia64/machvec_sn1.h	Tue Jan  8 15:45:54 2002
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

