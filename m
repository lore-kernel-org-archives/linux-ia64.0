From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 18 Mar 2003 18:15:27 +0000
Subject: [Linux-ia64] [PATCH] remove stale mmiob function
Message-Id: <marc-linux-ia64-105590723705262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The consensus on lkml was that devices should do reads from safe
registers to ensure PIO write ordering, which means we no longer need
mmiob.  This patch removes the mmiob entries from the machine vector
headers and io.h and updates the documentation about PIO ordering.

Thanks,
Jesse


diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64/include/asm-ia64/io.h linux-2.5.64-ia64-nommiob/include/asm-ia64/io.h
--- linux-2.5.64-ia64/include/asm-ia64/io.h	Tue Mar  4 19:28:57 2003
+++ linux-2.5.64-ia64-nommiob/include/asm-ia64/io.h	Tue Mar 18 09:36:56 2003
@@ -69,22 +69,6 @@
  */
 #define __ia64_mf_a()	__asm__ __volatile__ ("mf.a" ::: "memory")
 
-/**
- * __ia64_mmiob - I/O space memory barrier
- *
- * Acts as a memory mapped I/O barrier for platforms that queue writes to
- * I/O space.  This ensures that subsequent writes to I/O space arrive after
- * all previous writes.  For most ia64 platforms, this is a simple
- * 'mf.a' instruction, so the address is ignored.  For other platforms,
- * the address may be required to ensure proper ordering of writes to I/O space
- * since a 'dummy' read might be necessary to barrier the write operation.
- */
-static inline void
-__ia64_mmiob (void)
-{
-	__ia64_mf_a();
-}
-
 static inline const unsigned long
 __ia64_get_io_port_base (void)
 {
@@ -287,7 +271,6 @@
 #define __outb		platform_outb
 #define __outw		platform_outw
 #define __outl		platform_outl
-#define __mmiob         platform_mmiob
 
 #define inb(p)		__inb(p)
 #define inw(p)		__inw(p)
@@ -301,7 +284,6 @@
 #define outsb(p,s,c)	__outsb(p,s,c)
 #define outsw(p,s,c)	__outsw(p,s,c)
 #define outsl(p,s,c)	__outsl(p,s,c)
-#define mmiob()		__mmiob()
 
 /*
  * The address passed to these functions are ioremap()ped already.
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64/include/asm-ia64/machvec.h linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec.h
--- linux-2.5.64-ia64/include/asm-ia64/machvec.h	Fri Mar  7 16:02:45 2003
+++ linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec.h	Tue Mar 18 09:37:05 2003
@@ -61,7 +61,6 @@
 typedef void ia64_mv_outb_t (unsigned char, unsigned long);
 typedef void ia64_mv_outw_t (unsigned short, unsigned long);
 typedef void ia64_mv_outl_t (unsigned int, unsigned long);
-typedef void ia64_mv_mmiob_t (void);
 
 extern void machvec_noop (void);
 
@@ -110,7 +109,6 @@
 #  define platform_outb		ia64_mv.outb
 #  define platform_outw		ia64_mv.outw
 #  define platform_outl		ia64_mv.outl
-#  define platofrm_mmiob        ia64_mv.mmiob
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
@@ -149,7 +147,6 @@
 	ia64_mv_outb_t *outb;
 	ia64_mv_outw_t *outw;
 	ia64_mv_outl_t *outl;
-	ia64_mv_mmiob_t *mmiob;
 } __attribute__((__aligned__(16)));
 
 #define MACHVEC_INIT(name)			\
@@ -184,7 +181,6 @@
 	platform_outb,				\
 	platform_outw,				\
 	platform_outl,				\
-        platform_mmiob                          \
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -299,9 +295,6 @@
 #endif
 #ifndef platform_outl
 # define platform_outl		__ia64_outl
-#endif
-#ifndef platform_mmiob
-# define platform_mmiob         __ia64_mmiob
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64/include/asm-ia64/machvec_init.h linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_init.h
--- linux-2.5.64-ia64/include/asm-ia64/machvec_init.h	Tue Mar  4 19:28:55 2003
+++ linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_init.h	Tue Mar 18 09:37:11 2003
@@ -16,7 +16,6 @@
 extern ia64_mv_outb_t __ia64_outb;
 extern ia64_mv_outw_t __ia64_outw;
 extern ia64_mv_outl_t __ia64_outl;
-extern ia64_mv_mmiob_t __ia64_mmiob;
 
 #define MACHVEC_HELPER(name)									\
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __section__ (".machvec")))	\
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64/include/asm-ia64/machvec_sn1.h linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_sn1.h
--- linux-2.5.64-ia64/include/asm-ia64/machvec_sn1.h	Fri Mar  7 16:02:45 2003
+++ linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_sn1.h	Tue Mar 18 09:37:16 2003
@@ -44,7 +44,6 @@
 extern ia64_mv_outb_t sn1_outb;
 extern ia64_mv_outw_t sn1_outw;
 extern ia64_mv_outl_t sn1_outl;
-extern ia64_mv_mmiob_t sn_mmiob;
 extern ia64_mv_pci_alloc_consistent	sn1_pci_alloc_consistent;
 extern ia64_mv_pci_free_consistent	sn1_pci_free_consistent;
 extern ia64_mv_pci_map_single		sn1_pci_map_single;
@@ -74,7 +73,6 @@
 #define platform_outb		sn1_outb
 #define platform_outw		sn1_outw
 #define platform_outl		sn1_outl
-#define platform_mmiob          sn_mmiob
 #define platform_pci_dma_init	machvec_noop
 #define platform_pci_alloc_consistent	sn1_pci_alloc_consistent
 #define platform_pci_free_consistent	sn1_pci_free_consistent
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.64-ia64/include/asm-ia64/machvec_sn2.h linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_sn2.h
--- linux-2.5.64-ia64/include/asm-ia64/machvec_sn2.h	Fri Mar  7 16:02:45 2003
+++ linux-2.5.64-ia64-nommiob/include/asm-ia64/machvec_sn2.h	Tue Mar 18 09:37:20 2003
@@ -47,7 +47,6 @@
 extern ia64_mv_outb_t sn_outb;
 extern ia64_mv_outw_t sn_outw;
 extern ia64_mv_outl_t sn_outl;
-extern ia64_mv_mmiob_t			sn2_mmiob;
 extern ia64_mv_pci_alloc_consistent	sn_pci_alloc_consistent;
 extern ia64_mv_pci_free_consistent	sn_pci_free_consistent;
 extern ia64_mv_pci_map_single		sn_pci_map_single;
@@ -78,7 +77,6 @@
 #define platform_outb			sn_outb
 #define platform_outw			sn_outw
 #define platform_outl			sn_outl
-#define platform_mmiob			sn2_mmiob
 #define platform_irq_desc		sn_irq_desc
 #define platform_irq_to_vector		sn_irq_to_vector
 #define platform_local_vector_to_irq	sn_local_vector_to_irq
--- linux-2.5.64-ia64/Documentation/mmio_barrier.txt	Fri Mar  7 16:02:45 2003
+++ /dev/null	Thu Aug 24 02:00:32 2000
@@ -1,15 +0,0 @@
-On some platforms, so-called memory-mapped I/O is weakly ordered.  For
-example, the following might occur:
-
-CPU A writes 0x1 to Device #1
-CPU B writes 0x2 to Device #1
-Device #1 sees 0x2
-Device #1 sees 0x1
-
-On such platforms, driver writers are responsible for ensuring that I/O
-writes to memory-mapped addresses on their device arrive in the order
-intended.  The mmiob() macro is provided for this purpose.  A typical use
-of this macro might be immediately prior to the exit of a critical
-section of code proteced by spinlocks.  This would ensure that subsequent
-writes to I/O space arrived only after all prior writes (much like a
-typical memory barrier op, mb(), only with respect to I/O).
--- /dev/null	Thu Aug 24 02:00:32 2000
+++ linux-2.5.64-ia64-nommiob/Documentation/io_ordering.txt	Tue Mar 18 10:02:11 2003
@@ -0,0 +1,47 @@
+On some platforms, so-called memory-mapped I/O is weakly ordered.  On such
+platforms, driver writers are responsible for ensuring that I/O writes to
+memory-mapped addresses on their device arrive in the order intended.  This is
+typically done by reading a 'safe' device or bridge register, causing the I/O
+chipset to flush pending writes to the device before any reads are posted.  A
+driver would usually use this technique immediately prior to the exit of a
+critical section of code protected by spinlocks.  This would ensure that
+subsequent writes to I/O space arrived only after all prior writes (much like a
+memory barrier op, mb(), only with respect to I/O).
+
+A more concrete example from a hypothetical device driver:
+
+        ...
+CPU A:  spin_lock_irqsave(&dev_lock, flags)
+CPU A:  val = readl(my_status);
+CPU A:  ...
+CPU A:  writel(newval, ring_ptr);
+CPU A:  spin_unlock_irqrestore(&dev_lock, flags)
+        ...
+CPU B:  spin_lock_irqsave(&dev_lock, flags)
+CPU B:  val = readl(my_status);
+CPU B:  ...
+CPU B:  writel(newval2, ring_ptr);
+CPU B:  spin_unlock_irqrestore(&dev_lock, flags)
+        ...
+
+In the case above, the device may receive newval2 before it receives newval,
+which could cause problems.  Fixing it is easy enough though:
+
+        ...
+CPU A:  spin_lock_irqsave(&dev_lock, flags)
+CPU A:  val = readl(my_status);
+CPU A:  ...
+CPU A:  writel(newval, ring_ptr);
+CPU A:  (void)readl(safe_register); /* maybe a config register? */
+CPU A:  spin_unlock_irqrestore(&dev_lock, flags)
+        ...
+CPU B:  spin_lock_irqsave(&dev_lock, flags)
+CPU B:  val = readl(my_status);
+CPU B:  ...
+CPU B:  writel(newval2, ring_ptr);
+CPU B:  (void)readl(safe_register); /* maybe a config register? */
+CPU B:  spin_unlock_irqrestore(&dev_lock, flags)
+
+Here, the reads from safe_register will cause the I/O chipset to flush any
+pending writes before actually posting the read to the chipset, preventing
+possible data corruption.

