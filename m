From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 27 Jun 2001 07:09:08 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.5)
Message-Id: <marc-linux-ia64-105590693005780@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.5-ia64-010626.diff*.

There are no major new features in this patch, mostly bug fixes,
clean-ups for gcc3.0, etc.  However, I did start to tune things a bit
more for Itanium and those changes result in dramatically better
fork+exit performance as well as large improvements in various
bandwidth intensive tests (such as pipe bandwidth or TCP bandwidth).
The tuning didn't require any significant code changes (thanks largely
to the software-pipelining support in ia64) but still, I'd recommend
testing things heavily before including the new kernel in a
distribution (I should say that I have run with these mods for weeks
now without any problems).

More detailed change log:

	- included Martin's /dev/guid support (the implementation is
	  likely to contiue to evolve, but I think the features is
	  important enough to warrant inclusion in the normal
	  sources)

	- NEC contributed an I/O SAPIC implementation of
	  set_affinity() which allows to direct a particular irq to a
	  particular cpu via /proc/irq/.  Note: I/O SAPIC can direct
	  to only one CPU at a time.  If you attempt to target
	  multiple CPUs, only the CPU with the smallest id will
	  receive the interrupt.  Needless to say: it's easy to shoot
	  yourself in the foot by playing with the irq redirection,
	  but it can be useful, of course.

	- fixed ia32 version of lseek() (needed to get
	  profile-feedback to work in the Intel compilers)

	- use a separate irq vector for smp rescheduling instead of
	  going through the generic (and slow) IPI path

	- fix the mmap() problem reported by the Debian project

	- bring FPSWA support in sync with documentation

	- tune clear_page(), clear_user(), and copy_user() also for
	  uncached case (important, e.g., for smp fork/exit)

	- include the inode initialization bug fix forwarded by Keith

As usual the patch below is fyi only.  Oh, I should say that gcc3.0
compiles this kernel just fine.  My earlier suspicion turned out to be
wrong.  The problem I was seeing wasn't related to gcc3.0 after all.

Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help linux-2.4.5-lia/Documen=
tation/Configure.help
--- linux-davidm/Documentation/Configure.help	Tue Jun 26 22:55:31 2001
+++ linux-2.4.5-lia/Documentation/Configure.help	Tue Jun 26 22:21:03 2001
@@ -12036,6 +12036,12 @@
   were partitioned using EFI GPT.  Presently only useful on the
   IA-64 platform.
=20
+/dev/guid support (EXPERIMENTAL)
+CONFIG_DEVFS_GUID
+  Say Y here if you would like to access disks and partitions by
+  their Globally Unique Identifiers (GUIDs) which will appear as
+  symbolic links in /dev/guid.
+
 Ultrix partition support
 CONFIG_ULTRIX_PARTITION
   Say Y here if you would like to be able to read the hard disk
diff -urN linux-davidm/MAINTAINERS linux-2.4.5-lia/MAINTAINERS
--- linux-davidm/MAINTAINERS	Wed May 30 09:57:00 2001
+++ linux-2.4.5-lia/MAINTAINERS	Tue Jun 26 22:21:18 2001
@@ -602,6 +602,13 @@
 W:	http://www.kernelconcepts.de/
 S:	Maintained
=20
+IA64 (Itanium) PLATFORM
+P:	David Mosberger-Tang
+M:	davidm@hpl.hp.com
+L:	linux-ia64@linuxia64.org
+W:	http://www.linuxia64.org/
+S:	Maintained
+
 IBM MCA SCSI SUBSYSTEM DRIVER
 P:	Michael Lang
 M:	langa2@kph.uni-mainz.de
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.5-lia/arch/ia6=
4/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Tue Jun 26 22:55:32 2001
+++ linux-2.4.5-lia/arch/ia64/ia32/ia32_entry.S	Tue Jun 26 22:21:54 2001
@@ -140,7 +140,7 @@
 	data8 sys_lchown
 	data8 sys32_ni_syscall	  /* old break syscall holder */
 	data8 sys32_ni_syscall
-	data8 sys_lseek
+	data8 sys32_lseek
 	data8 sys_getpid	  /* 20 */
 	data8 sys_mount
 	data8 sys_oldumount
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.5-lia/arch/ia64/=
ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Tue Jun 26 22:55:32 2001
+++ linux-2.4.5-lia/arch/ia64/ia32/sys_ia32.c	Tue Jun 26 22:22:37 2001
@@ -2784,6 +2784,15 @@
 	return ret;
 }
=20
+int
+sys32_lseek (unsigned int fd, int offset, unsigned int whence)
+{
+	extern off_t sys_lseek (unsigned int fd, off_t offset, unsigned int origi=
n);
+
+	/* Sign-extension of "offset" is important here... */
+	return sys_lseek(fd, offset, whence);
+}
+
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
=20
 /* In order to reduce some races, while at the same time doing additional
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.4.5-lia/arch/ia64/=
kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Tue Jun 26 22:55:32 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/Makefile	Tue Jun 26 22:23:14 2001
@@ -13,7 +13,7 @@
=20
 export-objs :=3D ia64_ksyms.o
=20
-obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_i=
a64.o irq_sapic.o ivt.o \
+obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_i=
a64.o irq_lsapic.o ivt.o \
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
 obj-$(CONFIG_IA64_GENERIC) +=3D machvec.o iosapic.o
diff -urN linux-davidm/arch/ia64/kernel/fw-emu.c linux-2.4.5-lia/arch/ia64/=
kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Tue Jun 26 22:55:32 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/fw-emu.c	Tue Jun 26 22:23:26 2001
@@ -121,68 +121,63 @@
  */
 extern void pal_emulator_static (void);
=20
-asm ("
-	.proc pal_emulator_static
-pal_emulator_static:
-	mov r8=3D-1
-
-	mov r9%6
-	;;
-	cmp.gtu p6,p7=3Dr9,r28		/* r28 <=3D 255? */
-(p6)	br.cond.sptk.few static
-	;;
-	mov r9Q2
-	;;
-	cmp.gtu p6,p7=3Dr9,r28
-(p6)	br.cond.sptk.few stacked
-	;;
-static:	cmp.eq p6,p7=3D6,r28		/* PAL_PTCE_INFO */
-(p7)	br.cond.sptk.few 1f
-	;;
-	mov r8=3D0			/* status =3D 0 */
-	movl r9=3D0x100000000		/* tc.base */
-	movl r10=3D0x0000000200000003	/* count[0], count[1] */
-	movl r11=3D0x1000000000002000	/* stride[0], stride[1] */
-	br.cond.sptk.few rp
-
-1:	cmp.eq p6,p7=14,r28		/* PAL_FREQ_RATIOS */
-(p7)	br.cond.sptk.few 1f
-	mov r8=3D0			/* status =3D 0 */
-	movl r9 =3D0x100000064		/* proc_ratio (1/100) */
-	movl r10=3D0x100000100		/* bus_ratio<<32 (1/256) */
-	movl r11=3D0x100000064		/* itc_ratio<<32 (1/100) */
-	;;
-1:	cmp.eq p6,p7=19,r28		/* PAL_RSE_INFO */
-(p7)	br.cond.sptk.few 1f
-	mov r8=3D0			/* status =3D 0 */
-	mov r9=96			/* num phys stacked */
-	mov r10=3D0			/* hints */
-	mov r11=3D0
-	br.cond.sptk.few rp
-
-1:	cmp.eq p6,p7=3D1,r28		/* PAL_CACHE_FLUSH */
-(p7)	br.cond.sptk.few 1f
-	mov r9=3Dar.lc
-	movl r8R4288			/* flush 512k million cache lines (16MB) */
-	;;
-	mov ar.lc=3Dr8
-	movl r8=3D0xe000000000000000
-	;;
-.loop:	fc r8
-	add r82,r8
-	br.cloop.sptk.few .loop
-	sync.i
-	;;
-	srlz.i
-	;;
-	mov ar.lc=3Dr9
-	mov r8=3Dr0
-1:	br.cond.sptk.few rp
-
-stacked:
-	br.ret.sptk.few rp
-
-	.endp pal_emulator_static\n");
+asm (
+"	.proc pal_emulator_static\n"
+"pal_emulator_static:
+	mov r8=3D-1\n"
+"	mov r9%6\n"
+"	;;\n"
+"	cmp.gtu p6,p7=3Dr9,r28		/* r28 <=3D 255? */\n"
+"(p6)	br.cond.sptk.few static\n"
+"	;;\n"
+"	mov r9Q2\n"
+"	;;\n"
+"	cmp.gtu p6,p7=3Dr9,r28\n"
+"(p6)	br.cond.sptk.few stacked\n"
+"	;;\n"
+"static:	cmp.eq p6,p7=3D6,r28		/* PAL_PTCE_INFO */\n"
+"(p7)	br.cond.sptk.few 1f\n"
+"	;;\n"
+"	mov r8=3D0			/* status =3D 0 */\n"
+"	movl r9=3D0x100000000		/* tc.base */\n"
+"	movl r10=3D0x0000000200000003	/* count[0], count[1] */\n"
+"	movl r11=3D0x1000000000002000	/* stride[0], stride[1] */\n"
+"	br.cond.sptk.few rp\n"
+"1:	cmp.eq p6,p7=14,r28		/* PAL_FREQ_RATIOS */\n"
+"(p7)	br.cond.sptk.few 1f\n"
+"	mov r8=3D0			/* status =3D 0 */\n"
+"	movl r9 =3D0x100000064		/* proc_ratio (1/100) */\n"
+"	movl r10=3D0x100000100		/* bus_ratio<<32 (1/256) */\n"
+"	movl r11=3D0x100000064		/* itc_ratio<<32 (1/100) */\n"
+"	;;\n"
+"1:	cmp.eq p6,p7=19,r28		/* PAL_RSE_INFO */\n"
+"(p7)	br.cond.sptk.few 1f\n"
+"	mov r8=3D0			/* status =3D 0 */\n"
+"	mov r9=96			/* num phys stacked */\n"
+"	mov r10=3D0			/* hints */\n"
+"	mov r11=3D0\n"
+"	br.cond.sptk.few rp\n"
+"1:	cmp.eq p6,p7=3D1,r28		/* PAL_CACHE_FLUSH */\n"
+"(p7)	br.cond.sptk.few 1f\n"
+"	mov r9=3Dar.lc\n"
+"	movl r8R4288			/* flush 512k million cache lines (16MB) */\n"
+"	;;\n"
+"	mov ar.lc=3Dr8\n"
+"	movl r8=3D0xe000000000000000\n"
+"	;;\n"
+".loop:	fc r8\n"
+"	add r82,r8\n"
+"	br.cloop.sptk.few .loop\n"
+"	sync.i\n"
+"	;;\n"
+"	srlz.i\n"
+"	;;\n"
+"	mov ar.lc=3Dr9\n"
+"	mov r8=3Dr0\n"
+"1:	br.cond.sptk.few rp\n"
+"stacked:\n"
+"	br.ret.sptk.few rp\n"
+"	.endp pal_emulator_static\n");
=20
 /* Macro to emulate SAL call using legacy IN and OUT calls to CF8, CFC etc=
.. */
=20
diff -urN linux-davidm/arch/ia64/kernel/gate.S linux-2.4.5-lia/arch/ia64/ke=
rnel/gate.S
--- linux-davidm/arch/ia64/kernel/gate.S	Tue Jun 26 22:55:32 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/gate.S	Tue Jun 26 22:23:38 2001
@@ -15,8 +15,6 @@
=20
 	.section .text.gate,"ax"
=20
-	.align PAGE_SIZE
-
 #	define ARG0_OFF		(16 + IA64_SIGFRAME_ARG0_OFFSET)
 #	define ARG1_OFF		(16 + IA64_SIGFRAME_ARG1_OFFSET)
 #	define ARG2_OFF		(16 + IA64_SIGFRAME_ARG2_OFFSET)
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c linux-2.4.5-lia/arch/ia64=
/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Tue Jun 26 22:55:32 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/iosapic.c	Tue Jun 26 22:23:50 2001
@@ -20,7 +20,7 @@
  * Here is what the interrupt logic between a PCI device and the CPU looks=
 like:
  *
  * (1) A PCI device raises one of the four interrupt pins (INTA, INTB, INT=
C, INTD).  The
- *     device is uniquely identified by its bus-, device-, and slot-number=
 (the function
+ *     device is uniquely identified by its bus--, and slot-number (the fu=
nction
  *     number does not matter here because all functions share the same in=
terrupt
  *     lines).
  *
@@ -205,7 +205,43 @@
 static void
 iosapic_set_affinity (unsigned int irq, unsigned long mask)
 {
-	printk("iosapic_set_affinity: not implemented yet\n");
+	unsigned long flags;
+	u32 high32, low32;
+	int dest, pin;
+	char *addr;
+
+	mask &=3D (1UL << smp_num_cpus) - 1;
+
+	if (!mask || irq >=3D IA64_NUM_VECTORS)
+		return;
+
+	dest =3D ffz(~mask);
+
+	pin =3D iosapic_irq[irq].pin;
+	addr =3D iosapic_irq[irq].addr;
+
+	if (pin < 0)
+		return;			/* not an IOSAPIC interrupt */
+
+	/* dest contains both id and eid */
+	high32 =3D dest << IOSAPIC_DEST_SHIFT;
+
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		/* get current delivery mode by reading the low32 */
+		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		low32 =3D readl(addr + IOSAPIC_WINDOW);
+
+		/* change delivery mode to fixed */
+		low32 &=3D ~(7 << IOSAPIC_DELIVERY_SHIFT);
+		low32 |=3D (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
+
+		writel(IOSAPIC_RTE_HIGH(pin), addr + IOSAPIC_REG_SELECT);
+		writel(high32, addr + IOSAPIC_WINDOW);
+		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		writel(low32, addr + IOSAPIC_WINDOW);
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
=20
 /*
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.4.5-lia/arch/ia6=
4/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Sun Apr 29 15:49:25 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/irq_ia64.c	Tue Jun 26 22:24:20 2001
@@ -72,6 +72,11 @@
 ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 {
 	unsigned long saved_tpr;
+#ifdef CONFIG_SMP
+#	define IS_RESCHEDULE(vec)	(vec =3D IA64_IPI_RESCHEDULE)
+#else
+#	define IS_RESCHEDULE(vec)	(0)
+#endif
=20
 #if IRQ_DEBUG
 	{
@@ -110,24 +115,25 @@
 	 */
 	saved_tpr =3D ia64_get_tpr();
 	ia64_srlz_d();
-	do {
-		ia64_set_tpr(vector);
-		ia64_srlz_d();
-
-		do_IRQ(local_vector_to_irq(vector), regs);
-
-		/*
-		 * Disable interrupts and send EOI:
-		 */
-		local_irq_disable();
-		ia64_set_tpr(saved_tpr);
+	while (vector !=3D IA64_SPURIOUS_INT_VECTOR) {
+		if (!IS_RESCHEDULE(vector)) {
+			ia64_set_tpr(vector);
+			ia64_srlz_d();
+
+			do_IRQ(local_vector_to_irq(vector), regs);
+
+			/*
+			 * Disable interrupts and send EOI:
+			 */
+			local_irq_disable();
+			ia64_set_tpr(saved_tpr);
+		}
 		ia64_eoi();
 		vector =3D ia64_get_ivr();
-	} while (vector !=3D IA64_SPURIOUS_INT_VECTOR);
+	}
 }
=20
 #ifdef CONFIG_SMP
-
 extern void handle_IPI (int irq, void *dev_id, struct pt_regs *regs);
=20
 static struct irqaction ipi_irqaction =3D {
@@ -147,7 +153,7 @@
 		if (irq_to_vector(irq) =3D vec) {
 			desc =3D irq_desc(irq);
 			desc->status |=3D IRQ_PER_CPU;
-			desc->handler =3D &irq_type_ia64_sapic;
+			desc->handler =3D &irq_type_ia64_lsapic;
 			if (action)
 				setup_irq(irq, action);
 		}
diff -urN linux-davidm/arch/ia64/kernel/irq_lsapic.c linux-2.4.5-lia/arch/i=
a64/kernel/irq_lsapic.c
--- linux-davidm/arch/ia64/kernel/irq_lsapic.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.5-lia/arch/ia64/kernel/irq_lsapic.c	Tue Jun 26 22:24:36 2001
@@ -0,0 +1,38 @@
+/*
+ * LSAPIC Interrupt Controller
+ *
+ * This takes care of interrupts that are generated by the CPU's
+ * internal Streamlined Advanced Programmable Interrupt Controller
+ * (LSAPIC), such as the ITC and IPI interrupts.
+    *
+ * Copyright (C) 1999 VA Linux Systems
+ * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
+ * Copyright (C) 2000 Hewlett-Packard Co
+ * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+
+#include <linux/sched.h>
+#include <linux/irq.h>
+
+static unsigned int
+lsapic_noop_startup (unsigned int irq)
+{
+	return 0;
+}
+
+static void
+lsapic_noop (unsigned int irq)
+{
+	/* nuthing to do... */
+}
+
+struct hw_interrupt_type irq_type_ia64_lsapic =3D {
+	typename:	"LSAPIC",
+	startup:	lsapic_noop_startup,
+	shutdown:	lsapic_noop,
+	enable:		lsapic_noop,
+	disable:	lsapic_noop,
+	ack:		lsapic_noop,
+	end:		lsapic_noop,
+	set_affinity:	(void (*)(unsigned int, unsigned long)) lsapic_noop
+};
diff -urN linux-davidm/arch/ia64/kernel/irq_sapic.c linux-2.4.5-lia/arch/ia=
64/kernel/irq_sapic.c
--- linux-davidm/arch/ia64/kernel/irq_sapic.c	Fri Apr 21 15:21:24 2000
+++ linux-2.4.5-lia/arch/ia64/kernel/irq_sapic.c	Wed Dec 31 16:00:00 1969
@@ -1,38 +0,0 @@
-/*
- * SAPIC Interrupt Controller
- *
- * This takes care of interrupts that are generated by the CPU's
- * internal Streamlined Advanced Programmable Interrupt Controller
- * (SAPIC), such as the ITC and IPI interrupts.
- *
- * Copyright (C) 1999 VA Linux Systems
- * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 2000 Hewlett-Packard Co
- * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#include <linux/sched.h>
-#include <linux/irq.h>
-
-static unsigned int
-sapic_noop_startup (unsigned int irq)
-{
-	return 0;
-}
-
-static void
-sapic_noop (unsigned int irq)
-{
-	/* nuthing to do... */
-}
-
-struct hw_interrupt_type irq_type_ia64_sapic =3D {
-	typename:	"SAPIC",
-	startup:	sapic_noop_startup,
-	shutdown:	sapic_noop,
-	enable:		sapic_noop,
-	disable:	sapic_noop,
-	ack:		sapic_noop,
-	end:		sapic_noop,
-	set_affinity:	(void (*)(unsigned int, unsigned long)) sapic_noop
-};
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.5-lia/arch/ia64/ker=
nel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Tue Jun 26 22:55:32 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/ivt.S	Tue Jun 26 22:25:00 2001
@@ -9,16 +9,14 @@
  * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB handler now=
 uses virtual PT.
  */
 /*
- * This file defines the interrupt vector table used by the CPU.
+ * This file defines the interruption vector table used by the CPU.
  * It does not include one entry per possible cause of interruption.
  *
- * External interrupts only use 1 entry. All others are internal interrupts
- *
  * The first 20 entries of the table contain 64 bundles each while the
  * remaining 48 entries contain only 16 bundles each.
  *
  * The 64 bundles are used to allow inlining the whole handler for critical
- * interrupts like TLB misses.
+ * interruptions like TLB misses.
  *
  *  For each entry, the comment is as follows:
  *
@@ -27,7 +25,7 @@
  *  entry number ---------/         /                  /          /
  *  size of the entry -------------/                  /          /
  *  vector name -------------------------------------/          /
- *  related interrupts (what is the real interrupt?) ----------/
+ *  interruptions triggering this vector ----------------------/
  *
  * The table is 32KB in size and must be aligned on 32KB boundary.
  * (The CPU ignores the 15 lower bits of the address)
@@ -363,7 +361,7 @@
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interrupt collection is enabled
+	srlz.i					// guarantee that interruption collectin is on
 	;;
 (p15)	ssm psr.i				// restore psr.i
 	movl r14=3Dia64_leave_kernel
@@ -650,7 +648,7 @@
=20
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interrupt collection is enabled
+	srlz.i					// guarantee that interruption collection is on
 	cmp.eq pSys,pNonSys=3Dr0,r0		// set pSys=3D1, pNonSys=3D0
 	;;
 (p15)	ssm psr.i		// restore psr.i
@@ -724,11 +722,14 @@
 	tnat.nz p15,p0=3Din7
=20
 (p11)	mov in3=3D-1
+	tnat.nz p8,p0=3Dr15	// demining r15 is not a must, but it is safer
+
 (p12)	mov in4=3D-1
 (p13)	mov in5=3D-1
 	;;
 (p14)	mov in6=3D-1
 (p15)	mov in7=3D-1
+(p8)	mov r15=3D-1
 	br.ret.sptk.many rp
 END(demine_args)
=20
@@ -790,7 +791,7 @@
 	SAVE_MIN_WITH_COVER
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i		// guarantee that interrupt collection is enabled
+	srlz.i		// guarantee that interruption collection is on
 	;;
 (p15)	ssm psr.i	// restore psr.i
 	adds r3=3D8,r2	// set up second base pointer for SAVE_REST
@@ -839,7 +840,7 @@
 	mov r14=3Dcr.isr
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interrupt collection is enabled
+	srlz.i					// guarantee that interruption collection is on
 	;;
 (p15)	ssm psr.i
 	adds r3=3D8,r2            // Base pointer for SAVE_REST
@@ -927,7 +928,7 @@
=20
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i				// guarantee that interrupt collection is enabled
+	srlz.i				// guarantee that interruption collection is on
 	;;
 (p15)	ssm psr.i			// restore psr.i
 	movl r15=3Dia64_leave_kernel
@@ -960,7 +961,7 @@
=20
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interrupt collection is enabled
+	srlz.i					// guarantee that interruption collection is on
 	;;
 (p15)	ssm psr.i				// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer
@@ -1002,7 +1003,7 @@
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
-	srlz.i					// guarantee that interrupt collection is enabled
+	srlz.i					// guarantee that interruption collection is on
 	;;
 (p15)	ssm psr.i				// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer for SAVE_REST
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.5-lia/arch/ia64/k=
ernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Tue Jun 26 22:55:33 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/setup.c	Tue Jun 26 22:25:11 2001
@@ -57,12 +57,6 @@
 unsigned long ia64_cycles_per_usec;
 struct ia64_boot_param *ia64_boot_param;
 struct screen_info screen_info;
-/* This tells _start which CPU is booting.  */
-int cpu_now_booting;
-
-#ifdef CONFIG_SMP
-volatile unsigned long cpu_online_map;
-#endif
=20
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
=20
@@ -514,9 +508,7 @@
=20
 #ifdef CONFIG_IA32_SUPPORT
 	/* initialize global ia32 state - CR0 and CR4 */
-	__asm__("mov ar.cflg =3D %0"
-		: /* no outputs */
-		: "r" (((ulong) IA32_CR4 << 32) | IA32_CR0));
+	asm volatile ("mov ar.cflg =3D %0" :: "r" (((ulong) IA32_CR4 << 32) | IA3=
2_CR0));
 #endif
=20
 	/* disable all local interrupt sources: */
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.5-lia/arch/ia64/ker=
nel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Tue Jun 26 22:55:33 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/smp.c	Tue Jun 26 22:26:02 2001
@@ -68,11 +68,10 @@
=20
 static volatile struct call_data_struct *call_data;
=20
-#define IPI_RESCHEDULE		0
-#define IPI_CALL_FUNC		1
-#define IPI_CPU_STOP		2
+#define IPI_CALL_FUNC		0
+#define IPI_CPU_STOP		1
 #ifndef CONFIG_ITANIUM_PTCG
-# define IPI_FLUSH_TLB		3
+# define IPI_FLUSH_TLB		2
 #endif  /*!CONFIG_ITANIUM_PTCG */
=20
 static void
@@ -107,13 +106,6 @@
 		ops &=3D ~(1 << which);
=20
 		switch (which) {
-		case IPI_RESCHEDULE:
-			/*
-			 * Reschedule callback.  Everything to be done is done by the
-			 * interrupt return path.
-			 */
-			break;
-
 		case IPI_CALL_FUNC:
 			{
 				struct call_data_struct *data;
@@ -200,10 +192,6 @@
 static inline void
 send_IPI_single (int dest_cpu, int op)
 {
-
-	if (dest_cpu =3D -1)
-		return;
-
 	set_bit(op, &cpu_data[dest_cpu].ipi_operation);
 	platform_send_ipi(dest_cpu, IA64_IPI_VECTOR, IA64_IPI_DM_INT, 0);
 }
@@ -237,7 +225,7 @@
 void
 smp_send_reschedule (int cpu)
 {
-	send_IPI_single(cpu, IPI_RESCHEDULE);
+	platform_send_ipi(cpu, IA64_IPI_RESCHEDULE, IA64_IPI_DM_INT, 0);
 }
=20
 #ifndef CONFIG_ITANIUM_PTCG
@@ -255,7 +243,9 @@
 	 * Really need a null IPI but since this rarely should happen & since thi=
s code
 	 * will go away, lets not add one.
 	 */
-	send_IPI_allbutself(IPI_RESCHEDULE);
+	for (i =3D 0; i < smp_num_cpus; ++i) {
+		if (i !=3D smp_processor_id())
+			smp_send_reschedule(i);
 }
=20
 #endif  /* !CONFIG_ITANIUM_PTCG */
@@ -285,7 +275,8 @@
 {
 	struct call_data_struct data;
 	int cpus =3D 1;
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTE=
P_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	unsigned long timeout;
 #endif
=20
@@ -307,7 +298,8 @@
   resend:
   	send_IPI_single(cpuid, IPI_CALL_FUNC);
=20
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTE=
P_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	/*  Wait for response */
 	timeout =3D jiffies + HZ;
 	while ((atomic_read(&data.started) !=3D cpus) && time_before(jiffies, tim=
eout))
@@ -352,7 +344,8 @@
 {
 	struct call_data_struct data;
 	int cpus =3D smp_num_cpus-1;
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTE=
P_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	unsigned long timeout;
 #endif
=20
@@ -373,7 +366,8 @@
 	/*  Send a message to all other CPUs and wait for them to respond */
 	send_IPI_allbutself(IPI_CALL_FUNC);
=20
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTE=
P_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	/* Wait for response */
 	timeout =3D jiffies + HZ;
 	while ((atomic_read(&data.started) !=3D cpus) && time_before(jiffies, tim=
eout))
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c linux-2.4.5-lia/arch/ia64=
/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Tue Jun 26 22:55:33 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/smpboot.c	Tue Jun 26 22:26:26 2001
@@ -467,7 +467,7 @@
 	set_bit(0, &cpu_online_map);
 	set_bit(0, &cpu_callin_map);
=20
-	printk("Loops_per_jiffy for BOOT CPU =3D 0x%x\n", loops_per_jiffy);
+	printk("Loops_per_jiffy for BOOT CPU =3D 0x%lx\n", loops_per_jiffy);
=20
 	local_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
 	ia64_cpu_to_sapicid[0] =3D boot_cpu_id;
@@ -508,8 +508,8 @@
 			do_boot_cpu(sapicid);
=20
 			/*
-			* Make sure we unmap all failed CPUs
-			*/
+			 * Make sure we unmap all failed CPUs
+			 */
 			if (ia64_cpu_to_sapicid[cpu] =3D -1)
 				printk("phys CPU#%d not responding - cannot use it.\n", cpu);
 		}
@@ -517,8 +517,8 @@
 		smp_num_cpus =3D cpucount + 1;
=20
 		/*
-		* Allow the user to impress friends.
-		*/
+		 * Allow the user to impress friends.
+		 */
=20
 		printk("Before bogomips.\n");
 		if (!cpucount) {
@@ -534,6 +534,7 @@
 		}
 	}
   smp_done:
+	;
 }
=20
 /*
diff -urN linux-davidm/arch/ia64/kernel/sys_ia64.c linux-2.4.5-lia/arch/ia6=
4/kernel/sys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Tue Jun 26 22:55:33 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/sys_ia64.c	Tue Jun 26 22:26:57 2001
@@ -178,11 +178,22 @@
 	unsigned long roff;
 	struct file *file =3D 0;
=20
+	flags &=3D ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+	if (!(flags & MAP_ANONYMOUS)) {
+		file =3D fget(fd);
+		if (!file)
+			return -EBADF;
+
+		if (!file->f_op || !file->f_op->mmap)
+			return -ENODEV;
+	}
+
 	/*
-	 * A zero mmap always succeeds in Linux, independent of
-	 * whether or not the remaining arguments are valid.
+	 * A zero mmap always succeeds in Linux, independent of whether or not the
+	 * remaining arguments are valid.
 	 */
-	if (PAGE_ALIGN(len) =3D 0)
+	len =3D PAGE_ALIGN(len);
+	if (len =3D 0)
 		return addr;
=20
 	/* don't permit mappings into unmapped space or the virtual page table of=
 a region: */
@@ -193,13 +204,6 @@
 	/* don't permit mappings that would cross a region boundary: */
 	if (rgn_index(addr) !=3D rgn_index(addr + len))
 		return -EINVAL;
-
-	flags &=3D ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	if (!(flags & MAP_ANONYMOUS)) {
-		file =3D fget(fd);
-		if (!file)
-			return -EBADF;
-	}
=20
 	down_write(&current->mm->mmap_sem);
 	addr =3D do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.5-lia/arch/ia64/ke=
rnel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Tue Jun 26 22:55:33 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/time.c	Tue Jun 26 22:27:11 2001
@@ -292,6 +292,6 @@
 time_init (void)
 {
 	register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
-	efi_gettimeofday(&xtime);
+	efi_gettimeofday((struct timeval *) &xtime);
 	ia64_init_itm();
 }
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.5-lia/arch/ia64/k=
ernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Tue Jun 26 22:55:33 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/traps.c	Tue Jun 26 22:28:08 2001
@@ -215,11 +215,9 @@
 fp_emulate (int fp_fault, void *bundle, long *ipsr, long *fpsr, long *isr,=
 long *pr, long *ifs,
 	    struct pt_regs *regs)
 {
+	struct ia64_fpreg f6_11[6];
 	fp_state_t fp_state;
 	fpswa_ret_t ret;
-#ifdef FPSWA_BUG
-	struct ia64_fpreg f6_15[10];
-#endif
=20
 	if (!fpswa_interface)
 		return -1;
@@ -231,23 +229,12 @@
 	 * kernel, so set those bits in the mask and set the low volatile
 	 * pointer to point to these registers.
 	 */
-#ifndef FPSWA_BUG
-	fp_state.bitmask_low64 =3D 0x3c0;  /* bit 6..9 */
-	fp_state.fp_state_low_volatile =3D (fp_state_low_volatile_t *) &regs->f6;
-#else
-	fp_state.bitmask_low64 =3D 0xffc0;  /* bit6..bit15 */
-	f6_15[0] =3D regs->f6;
-	f6_15[1] =3D regs->f7;
-	f6_15[2] =3D regs->f8;
-	f6_15[3] =3D regs->f9;
-	__asm__ ("stf.spill %0=F10%P0" : "=3Dm"(f6_15[4]));
-	__asm__ ("stf.spill %0=F11%P0" : "=3Dm"(f6_15[5]));
-	__asm__ ("stf.spill %0=F12%P0" : "=3Dm"(f6_15[6]));
-	__asm__ ("stf.spill %0=F13%P0" : "=3Dm"(f6_15[7]));
-	__asm__ ("stf.spill %0=F14%P0" : "=3Dm"(f6_15[8]));
-	__asm__ ("stf.spill %0=F15%P0" : "=3Dm"(f6_15[9]));
-	fp_state.fp_state_low_volatile =3D (fp_state_low_volatile_t *) f6_15;
-#endif
+	fp_state.bitmask_low64 =3D 0xfc0;  /* bit6..bit11 */
+	f6_11[0] =3D regs->f6; f6_11[1] =3D regs->f7;
+	f6_11[2] =3D regs->f8; f6_11[3] =3D regs->f9;
+	__asm__ ("stf.spill %0=F10%P0" : "=3Dm"(f6_11[4]));
+	__asm__ ("stf.spill %0=F11%P0" : "=3Dm"(f6_11[5]));
+	fp_state.fp_state_low_volatile =3D (fp_state_low_volatile_t *) f6_11;
 	/*
 	 * unsigned long (*EFI_FPSWA) (
 	 *      unsigned long    trap_type,
@@ -263,18 +250,10 @@
 					(unsigned long *) ipsr, (unsigned long *) fpsr,
 					(unsigned long *) isr, (unsigned long *) pr,
 					(unsigned long *) ifs, &fp_state);
-#ifdef FPSWA_BUG
-	__asm__ ("ldf.fill f10=3D%0%P0" :: "m"(f6_15[4]));
-	__asm__ ("ldf.fill f11=3D%0%P0" :: "m"(f6_15[5]));
-	__asm__ ("ldf.fill f12=3D%0%P0" :: "m"(f6_15[6]));
-	__asm__ ("ldf.fill f13=3D%0%P0" :: "m"(f6_15[7]));
-	__asm__ ("ldf.fill f14=3D%0%P0" :: "m"(f6_15[8]));
-	__asm__ ("ldf.fill f15=3D%0%P0" :: "m"(f6_15[9]));
-	regs->f6 =3D f6_15[0];
-	regs->f7 =3D f6_15[1];
-	regs->f8 =3D f6_15[2];
-	regs->f9 =3D f6_15[3];
-#endif
+	regs->f6 =3D f6_11[0]; regs->f7 =3D f6_11[1];
+	regs->f8 =3D f6_11[2]; regs->f9 =3D f6_11[3];
+	__asm__ ("ldf.fill f10=3D%0%P0" :: "m"(f6_11[4]));
+	__asm__ ("ldf.fill f11=3D%0%P0" :: "m"(f6_11[5]));
 	return ret.status;
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.5-lia/arch/ia64/=
kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Tue Jun 26 22:55:33 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/unwind.c	Tue Jun 26 22:28:21 2001
@@ -1361,10 +1361,10 @@
 	}
 }
=20
-static inline struct unw_table_entry *
+static inline const struct unw_table_entry *
 lookup (struct unw_table *table, unsigned long rel_ip)
 {
-	struct unw_table_entry *e =3D 0;
+	const struct unw_table_entry *e =3D 0;
 	unsigned long lo, hi, mid;
=20
 	/* do a binary search for right entry: */
@@ -1389,7 +1389,7 @@
 build_script (struct unw_frame_info *info)
 {
 	struct unw_reg_state *rs, *next;
-	struct unw_table_entry *e =3D 0;
+	const struct unw_table_entry *e =3D 0;
 	struct unw_script *script =3D 0;
 	unsigned long ip =3D info->ip;
 	struct unw_state_record sr;
@@ -1951,7 +1951,7 @@
 {
 	extern char __start_gate_section[], __stop_gate_section[];
 	unsigned long *lp, start, end, segbase =3D unw.kernel_table.segment_base;
-	struct unw_table_entry *entry, *first;
+	const struct unw_table_entry *entry, *first;
 	size_t info_size, size;
 	char *info;
=20
diff -urN linux-davidm/arch/ia64/kernel/unwind_i.h linux-2.4.5-lia/arch/ia6=
4/kernel/unwind_i.h
--- linux-davidm/arch/ia64/kernel/unwind_i.h	Mon Oct  9 17:54:56 2000
+++ linux-2.4.5-lia/arch/ia64/kernel/unwind_i.h	Tue Jun 26 22:28:30 2001
@@ -58,7 +58,7 @@
 	unsigned long segment_base;	/* base for offsets in the unwind table entri=
es */
 	unsigned long start;
 	unsigned long end;
-	struct unw_table_entry *array;
+	const struct unw_table_entry *array;
 	unsigned long length;
 };
=20
diff -urN linux-davidm/arch/ia64/lib/clear_page.S linux-2.4.5-lia/arch/ia64=
/lib/clear_page.S
--- linux-davidm/arch/ia64/lib/clear_page.S	Sun Apr 29 15:49:26 2001
+++ linux-2.4.5-lia/arch/ia64/lib/clear_page.S	Tue Jun 26 22:30:32 2001
@@ -1,8 +1,6 @@
 /*
  *
- * Optimized version of the standard clearpage() function
- *
- * Based on comments from ddd. Try not to overflow the write buffer.
+ * Optimized function to clear a page of memory.
  *
  * Inputs:
  *	in0:	address of page
@@ -13,27 +11,41 @@
  * Copyright (C) 1999-2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 1/06/01 davidm	Tuned for Itanium.
  */
 #include <asm/asmmacro.h>
 #include <asm/page.h>
=20
+#define saved_lc	r2
+#define dst0		in0
+#define dst1		r8
+#define dst2		r9
+#define dst3		r10
+#define dst_fetch	r11
+
 GLOBAL_ENTRY(clear_page)
 	.prologue
-	alloc r11=3Dar.pfs,1,0,0,0
-	.save ar.lc, r16
-	mov r16=3Dar.lc		// slow
-
-	.body
-
-	mov r17=3DPAGE_SIZE/32-1	// -1 =3D repeat/until
+	.regstk 1,0,0,0
+	mov r16 =3D PAGE_SIZE/64-1	// -1 =3D repeat/until
 	;;
-	adds r18=16,in0
-	mov ar.lc=3Dr17
+	.save ar.lc, saved_lc
+	mov saved_lc =3D ar.lc
+	.body
+	mov ar.lc =3D r16
+	adds dst1 =3D 16, dst0
+	adds dst2 =3D 32, dst0
+	adds dst3 =3D 48, dst0
+	adds dst_fetch =3D 512, dst0
 	;;
-1:	stf.spill.nta [in0]=F0,32
-	stf.spill.nta [r18]=F0,32
+1:	stf.spill.nta [dst0] =3D f0, 64
+	stf.spill.nta [dst1] =3D f0, 64
+	stf.spill.nta [dst2] =3D f0, 64
+	stf.spill.nta [dst3] =3D f0, 64
+
+	lfetch [dst_fetch], 64
 	br.cloop.dptk.few 1b
 	;;
-	mov ar.lc=3Dr16		// restore lc
+	mov ar.lc =3D r2		// restore lc
 	br.ret.sptk.few rp
 END(clear_page)
diff -urN linux-davidm/arch/ia64/lib/clear_user.S linux-2.4.5-lia/arch/ia64=
/lib/clear_user.S
--- linux-davidm/arch/ia64/lib/clear_user.S	Sun Apr 29 15:49:26 2001
+++ linux-2.4.5-lia/arch/ia64/lib/clear_user.S	Tue Jun 26 22:30:43 2001
@@ -69,7 +69,7 @@
 (p6)	br.cond.dptk.few long_do_clear
 	;;				// WAR on ar.lc
 	//
-	// worst case 16 cyles, avg 8 cycles
+	// worst case 16 iterations, avg 8 iterations
 	//
 	// We could have played with the predicates to use the extra
 	// M slot for 2 stores/iteration but the cost the initialization
diff -urN linux-davidm/arch/ia64/lib/copy_page.S linux-2.4.5-lia/arch/ia64/=
lib/copy_page.S
--- linux-davidm/arch/ia64/lib/copy_page.S	Sun Apr 29 15:49:26 2001
+++ linux-2.4.5-lia/arch/ia64/lib/copy_page.S	Tue Jun 26 22:30:55 2001
@@ -2,8 +2,6 @@
  *
  * Optimized version of the standard copy_page() function
  *
- * Based on comments from ddd. Try not to overflow write buffer.
- *
  * Inputs:
  *	in0:	address of target page
  *	in1:	address of source page
@@ -12,11 +10,14 @@
  *
  * Copyright (C) 1999, 2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 2001 David Mosberger <davidm@hpl.hp.com>
+ *
+ * 4/06/01 davidm	Tuned to make it perform well both for cached and uncach=
ed copies.
  */
 #include <asm/asmmacro.h>
 #include <asm/page.h>
=20
-#define PIPE_DEPTH	6
+#define PIPE_DEPTH	3
 #define EPI		p[PIPE_DEPTH-1]
=20
 #define lcount		r16
@@ -27,62 +28,67 @@
 #define src2		r21
 #define tgt1		r22
 #define tgt2		r23
+#define srcf		r24
+#define tgtf		r25
+
+#define Nrot		((8*PIPE_DEPTH+7)&~7)
=20
 GLOBAL_ENTRY(copy_page)
 	.prologue
 	.save ar.pfs, saved_pfs
-	alloc saved_pfs=3Dar.pfs,3,((2*PIPE_DEPTH+7)&~7),0,((2*PIPE_DEPTH+7)&~7)
+	alloc saved_pfs=3Dar.pfs,3,Nrot-3,0,Nrot
=20
-	.rotr t1[PIPE_DEPTH], t2[PIPE_DEPTH]
+	.rotr t1[PIPE_DEPTH], t2[PIPE_DEPTH], t3[PIPE_DEPTH], t4[PIPE_DEPTH], \
+	      t5[PIPE_DEPTH], t6[PIPE_DEPTH], t7[PIPE_DEPTH], t8[PIPE_DEPTH]
 	.rotp p[PIPE_DEPTH]
=20
 	.save ar.lc, saved_lc
-	mov saved_lc=3Dar.lc	// save ar.lc ahead of time
+	mov saved_lc=3Dar.lc
+	mov ar.ec=3DPIPE_DEPTH
+
+	mov lcount=3DPAGE_SIZE/64-1
 	.save pr, saved_pr
-	mov saved_pr=3Dpr		// rotating predicates are preserved
-				// resgisters we must save.
+	mov saved_pr=3Dpr
+	mov pr.rot=3D1<<16
+
 	.body
=20
-	mov src1=3Din1		// initialize 1st stream source
-	adds src2=3D8,in1		// initialize 2nd stream source
-	mov lcount=3DPAGE_SIZE/16-1 // as many 16bytes as there are on a page
-				  // -1 is because br.ctop is repeat/until
-
-	adds tgt2=3D8,in0		// initialize 2nd stream target
-	mov tgt1=3Din0		// initialize 1st stream target
-	;;
-	mov pr.rot=3D1<<16	// pr16=3D1 & pr[17-63]=3D0 , 63 not modified
-
-	mov ar.lc=3Dlcount	// set loop counter
-	mov ar.ec=3DPIPE_DEPTH	// ar.ec must match pipeline depth
-	;;
-
-	// We need to preload the n-1 stages of the pipeline (n=DEpth).
-	// We do this during the "prolog" of the loop: we execute
-	// n-1 times the "load" bundle. Then both loads & stores are
-	// enabled until we reach the end of the last word of the page
-	// on the load side. Then, we enter the epilog (controlled by ec)
-	// where we just do the stores and no loads n times : drain the pipe
-	// (we exit the loop when ec=3D1).
-	//
-	// The initialization of the prolog is done via the predicate registers:
-	// the choice of EPI DEPENDS on the depth of the pipeline (n).
-	// When lc > 0 pr63=3D1 and it is fed back into pr16 and pr16-pr62
-	// are then shifted right at every iteration,
-	// Thus by initializing pr16=3D1 and the rest to 0 before the loop
-	// we get EPI=3D1 after n iterations.
-	//
-1:				// engage loop now, let the magic happen...
-(p16)	ld8 t1[0]=3D[src1],16	// new data on top of pipeline in 1st stream
-(p16)	ld8 t2[0]=3D[src2],16	// new data on top of pipeline in 2nd stream
-	nop.i 0x0
-(EPI)	st8 [tgt1]=3Dt1[PIPE_DEPTH-1],16	// store top of  1st pipeline
-(EPI)	st8 [tgt2]=3Dt2[PIPE_DEPTH-1],16	// store top of 2nd pipeline
-	br.ctop.dptk.few 1b	// once lc=3D0, ec-- & p16=3D0
-				// stores but no loads anymore
+	mov src1=3Din1
+	adds src2=3D8,in1
+	;;
+	adds tgt2=3D8,in0
+	add srcfQ2,in1
+	mov ar.lc=3Dlcount
+	mov tgt1=3Din0
+	add tgtfQ2,in0
+	;;
+1:
+(p[0])	ld8 t1[0]=3D[src1],16
+(EPI)	st8 [tgt1]=3Dt1[PIPE_DEPTH-1],16
+(p[0])	ld8 t2[0]=3D[src2],16
+(EPI)	st8 [tgt2]=3Dt2[PIPE_DEPTH-1],16
+	;;
+(p[0])	ld8 t3[0]=3D[src1],16
+(EPI)	st8 [tgt1]=3Dt3[PIPE_DEPTH-1],16
+(p[0])	ld8 t4[0]=3D[src2],16
+(EPI)	st8 [tgt2]=3Dt4[PIPE_DEPTH-1],16
+	;;
+(p[0])	ld8 t5[0]=3D[src1],16
+(EPI)	st8 [tgt1]=3Dt5[PIPE_DEPTH-1],16
+(p[0])	ld8 t6[0]=3D[src2],16
+(EPI)	st8 [tgt2]=3Dt6[PIPE_DEPTH-1],16
+	;;
+(p[0])	ld8 t7[0]=3D[src1],16
+(EPI)	st8 [tgt1]=3Dt7[PIPE_DEPTH-1],16
+(p[0])	ld8 t8[0]=3D[src2],16
+(EPI)	st8 [tgt2]=3Dt8[PIPE_DEPTH-1],16
+
+	lfetch [srcf], 64
+	lfetch [tgtf], 64
+	br.ctop.sptk.few 1b
 	;;
 	mov pr=3Dsaved_pr,0xffffffffffff0000	// restore predicates
-	mov ar.pfs=3Dsaved_pfs	// restore ar.ec
-	mov ar.lc=3Dsaved_lc	// restore saved lc
-	br.ret.sptk.few rp	// bye...
+	mov ar.pfs=3Dsaved_pfs
+	mov ar.lc=3Dsaved_lc
+	br.ret.sptk.few rp
 END(copy_page)
diff -urN linux-davidm/arch/ia64/lib/copy_user.S linux-2.4.5-lia/arch/ia64/=
lib/copy_user.S
--- linux-davidm/arch/ia64/lib/copy_user.S	Sun Apr 29 15:49:26 2001
+++ linux-2.4.5-lia/arch/ia64/lib/copy_user.S	Tue Jun 26 22:31:21 2001
@@ -35,7 +35,7 @@
 // Tuneable parameters
 //
 #define COPY_BREAK	16	// we do byte copy below (must be >=16)
-#define PIPE_DEPTH	4	// pipe depth
+#define PIPE_DEPTH	21	// pipe depth
=20
 #define EPI		p[PIPE_DEPTH-1] // PASTE(p,16+PIPE_DEPTH-1)
=20
diff -urN linux-davidm/arch/ia64/vmlinux.lds.S linux-2.4.5-lia/arch/ia64/vm=
linux.lds.S
--- linux-davidm/arch/ia64/vmlinux.lds.S	Tue Jun 26 22:55:34 2001
+++ linux-2.4.5-lia/arch/ia64/vmlinux.lds.S	Tue Jun 26 22:32:14 2001
@@ -25,7 +25,7 @@
   .text : AT(ADDR(.text) - PAGE_OFFSET)
     {
 	*(.text.ivt)
-	/* these are not really text pages, but the zero page needs to be in a fi=
xed location: */
+	/* these are not really text pages, but they need to be page aligned: */
 	*(__special_page_section)
 	__start_gate_section =3D .;
 	*(.text.gate)
diff -urN linux-davidm/fs/block_dev.c linux-2.4.5-lia/fs/block_dev.c
--- linux-davidm/fs/block_dev.c	Wed May 30 09:58:06 2001
+++ linux-2.4.5-lia/fs/block_dev.c	Tue Jun 26 22:32:56 2001
@@ -595,14 +595,15 @@
=20
 int ioctl_by_bdev(struct block_device *bdev, unsigned cmd, unsigned long a=
rg)
 {
-	kdev_t rdev =3D to_kdev_t(bdev->bd_dev);
 	struct inode inode_fake;
 	int res;
 	mm_segment_t old_fs =3D get_fs();
=20
 	if (!bdev->bd_op->ioctl)
 		return -EINVAL;
-	inode_fake.i_rdev=3Drdev;
+	memset(&inode_fake, 0, sizeof(inode_fake));
+	inode_fake.i_rdev =3D to_kdev_t(bdev->bd_dev);
+	inode_fake.i_bdev =3D bdev;
 	init_waitqueue_head(&inode_fake.i_wait);
 	set_fs(KERNEL_DS);
 	res =3D bdev->bd_op->ioctl(&inode_fake, NULL, cmd, arg);
diff -urN linux-davidm/fs/devfs/base.c linux-2.4.5-lia/fs/devfs/base.c
--- linux-davidm/fs/devfs/base.c	Wed May 30 09:58:06 2001
+++ linux-2.4.5-lia/fs/devfs/base.c	Tue Jun 26 22:33:16 2001
@@ -1903,6 +1903,27 @@
     return master->slave;
 }   /*  End Function devfs_get_unregister_slave  */
=20
+#ifdef CONFIG_DEVFS_GUID
+/**
+ *	devfs_unregister_slave - remove the slave that is unregistered when @ma=
ster is unregistered.
+ *      Destroys the connection established by devfs_auto_unregister.
+ *
+ *	@master: The master devfs entry.
+ */
+
+void devfs_unregister_slave (devfs_handle_t master)
+{
+	devfs_handle_t slave;
+
+	if (master =3D NULL) return;
+
+	slave =3D master->slave;
+	if (slave) {
+		master->slave =3D NULL;
+		unregister (slave);
+	};
+}
+#endif /* CONFIG_DEVFS_GUID */
=20
 /**
  *	devfs_get_name - Get the name for a device entry in its parent director=
y.
@@ -2103,6 +2124,9 @@
 EXPORT_SYMBOL(devfs_get_next_sibling);
 EXPORT_SYMBOL(devfs_auto_unregister);
 EXPORT_SYMBOL(devfs_get_unregister_slave);
+#ifdef CONFIG_DEVFS_GUID
+EXPORT_SYMBOL(devfs_unregister_slave);
+#endif
 EXPORT_SYMBOL(devfs_register_chrdev);
 EXPORT_SYMBOL(devfs_register_blkdev);
 EXPORT_SYMBOL(devfs_unregister_chrdev);
diff -urN linux-davidm/fs/partitions/Config.in linux-2.4.5-lia/fs/partition=
s/Config.in
--- linux-davidm/fs/partitions/Config.in	Tue Jun 26 22:55:38 2001
+++ linux-2.4.5-lia/fs/partitions/Config.in	Tue Jun 26 22:33:28 2001
@@ -25,6 +25,7 @@
       bool '    Solaris (x86) partition table support' CONFIG_SOLARIS_X86_=
PARTITION
       bool '    Unixware slices support' CONFIG_UNIXWARE_DISKLABEL
       bool '    EFI GUID Partition support' CONFIG_EFI_PARTITION
+      dep_bool '    /dev/guid support (EXPERIMENTAL)' CONFIG_DEVFS_GUID $C=
ONFIG_DEVFS_FS $CONFIG_EFI_PARTITION
    fi
    bool '  SGI partition support' CONFIG_SGI_PARTITION
    bool '  Ultrix partition table support' CONFIG_ULTRIX_PARTITION
diff -urN linux-davidm/fs/partitions/check.c linux-2.4.5-lia/fs/partitions/=
check.c
--- linux-davidm/fs/partitions/check.c	Tue Jun 26 22:55:38 2001
+++ linux-2.4.5-lia/fs/partitions/check.c	Tue Jun 26 22:33:40 2001
@@ -79,6 +79,20 @@
 	NULL
 };
=20
+#ifdef CONFIG_DEVFS_GUID
+static devfs_handle_t guid_top_handle;
+
+#define GUID_UNPARSED_LEN 36
+static void
+uuid_unparse_1(efi_guid_t *guid, char *out)
+{
+	sprintf(out, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
+		guid->data1, guid->data2, guid->data3,
+ 		guid->data4[0], guid->data4[1], guid->data4[2], guid->data4[3],
+		guid->data4[4], guid->data4[5], guid->data4[6], guid->data4[7]);
+}
+#endif
+
 /*
  * disk_name() is used by partition check code and the md driver.
  * It formats the devicename of the indicated disk into
@@ -314,6 +328,101 @@
 	devfs_register_partitions (hd, i, hd->sizes ? 0 : 1);
 }
=20
+#ifdef CONFIG_DEVFS_GUID
+/*
+  devfs_register_guid: create a /dev/guid entry for a disk or partition
+                       if it has a GUID.
+
+  The /dev/guid entry will be a symlink to the "real" devfs device.
+  It is marked as "slave" of the real device,
+  to be automatically unregistered by devfs if that device is unregistered.
+
+  If the partition already had a /dev/guid entry, delete (unregister) it.
+  (If the disk was repartitioned, it's likely the old GUID entry will be w=
rong).
+
+  dev, minor:  Device for which an entry is to be created.
+
+  Prerequisites: dev->part[minor].guid must be either NULL or point
+                 to a valid kmalloc'ed GUID.
+*/
+
+static void devfs_register_guid (struct gendisk *dev, int minor)
+{
+	efi_guid_t *guid =3D dev->part[minor].guid;
+	devfs_handle_t guid_handle, slave,
+		real_master =3D dev->part[minor].de;
+	devfs_handle_t master =3D real_master;
+	char guid_link[GUID_UNPARSED_LEN + 1];
+	char dirname[128];
+	int pos, st;
+
+	if (!guid_top_handle)
+		guid_top_handle =3D devfs_mk_dir (NULL, "guid", NULL);
+
+	if (!guid || !master) return;
+
+	do {
+		slave =3D devfs_get_unregister_slave (master);
+		if (slave) {
+			if (slave =3D master || slave =3D real_master) {
+				printk (KERN_WARNING
+					"devfs_register_guid: infinite slave loop!\n");
+				return;
+			} else if (devfs_get_parent (slave) =3D guid_top_handle) {
+				printk (KERN_INFO
+					"devfs_register_guid: unregistering %s\n",
+					devfs_get_name (slave, NULL));
+				devfs_unregister_slave (master);
+				slave =3D NULL;
+			} else
+				master =3D slave;
+		};
+	} while (slave);
+
+	uuid_unparse_1 (guid, guid_link);
+	pos =3D devfs_generate_path (real_master, dirname + 3,
+				   sizeof (dirname) - 3);
+	if (pos < 0) {
+		printk (KERN_WARNING
+			"devfs_register_guid: error generating path: %d\n",
+			pos);
+		return;
+	};
+
+	strncpy (dirname + pos, "../", 3);
+
+	st =3D devfs_mk_symlink (guid_top_handle, guid_link,
+			       DEVFS_FL_DEFAULT,
+			       dirname + pos, &guid_handle, NULL);
+
+	if (st < 0) {
+		printk ("Error %d creating symlink\n", st);
+	} else {
+		devfs_auto_unregister (master, guid_handle);
+	};
+};
+
+/*
+  free_disk_guids: kfree all guid data structures alloced for
+  the disk device specified by (dev, minor) and all its partitions.
+
+  This function does not remove symlinks in /dev/guid.
+*/
+static void free_disk_guids (struct gendisk *dev, int minor)
+{
+	int i;
+	efi_guid_t *guid;
+
+	for (i =3D 0; i < dev->max_p; i++) {
+		guid =3D dev->part[minor + i].guid;
+		if (!guid) continue;
+		kfree (guid);
+		dev->part[minor + i].guid =3D NULL;
+	};
+}
+
+#endif /* CONFIG_DEVFS_GUID */
+
 #ifdef CONFIG_DEVFS_FS
 static void devfs_register_partition (struct gendisk *dev, int minor, int =
part)
 {
@@ -322,7 +431,11 @@
 	unsigned int devfs_flags =3D DEVFS_FL_DEFAULT;
 	char devname[16];
=20
-	if (dev->part[minor + part].de) return;
+	/* Even if the devfs handle is still up-to-date,
+	   the GUID entry probably isn't */
+	if (dev->part[minor + part].de)
+		goto do_guid;
+
 	dir =3D devfs_get_parent (dev->part[minor].de);
 	if (!dir) return;
 	if ( dev->flags && (dev->flags[devnum] & GENHD_FL_REMOVABLE) )
@@ -333,6 +446,11 @@
 			    dev->major, minor + part,
 			    S_IFBLK | S_IRUSR | S_IWUSR,
 			    dev->fops, NULL);
+ do_guid:
+#ifdef CONFIG_DEVFS_GUID
+	devfs_register_guid (dev, minor + part);
+#endif
+	return;
 }
=20
 static void devfs_register_disc (struct gendisk *dev, int minor)
@@ -345,7 +463,9 @@
 	static unsigned int disc_counter;
 	static devfs_handle_t devfs_handle;
=20
-	if (dev->part[minor].de) return;
+	if (dev->part[minor].de)
+		goto do_guid;
+
 	if ( dev->flags && (dev->flags[devnum] & GENHD_FL_REMOVABLE) )
 		devfs_flags |=3D DEVFS_FL_REMOVABLE;
 	if (dev->de_arr) {
@@ -372,6 +492,12 @@
 	devfs_auto_unregister (dev->part[minor].de, slave);
 	if (!dev->de_arr)
 		devfs_auto_unregister (slave, dir);
+
+ do_guid:
+#ifdef CONFIG_DEVFS_GUID
+	devfs_register_guid (dev, minor);
+#endif
+	return;
 }
 #endif  /*  CONFIG_DEVFS_FS  */
=20
@@ -393,6 +519,7 @@
 	if (unregister) {
 		devfs_unregister (dev->part[minor].de);
 		dev->part[minor].de =3D NULL;
+		free_disk_guids (dev, minor);
 	}
 #endif  /*  CONFIG_DEVFS_FS  */
 }
@@ -410,8 +537,21 @@
 void register_disk(struct gendisk *gdev, kdev_t dev, unsigned minors,
 	struct block_device_operations *ops, long size)
 {
+	int i;
+
 	if (!gdev)
 		return;
+
+#ifdef CONFIG_DEVFS_GUID
+	/* Initialize all guid fields to NULL (=3D^ not kmalloc'ed).
+	   It is assumed that drivers call register_disk after
+	   allocating the gen_hd structure, and call grok_partitions
+	   directly for a revalidate event, as those drives I've inspected
+	   (among which hd and sd) do. */
+	for (i =3D 0; i < gdev->max_p; i++)
+		gdev->part[MINOR(dev) + i].guid =3D NULL;
+#endif
+
 	grok_partitions(gdev, MINOR(dev)>>gdev->minor_shift, minors, size);
 }
=20
@@ -429,6 +569,13 @@
 	if (!size || minors =3D 1)
 		return;
=20
+#ifdef CONFIG_DEVFS_GUID
+	/* In case this is a revalidation, free GUID memory.
+	   On the first call for this device,
+	   register_disk has set all entries to NULL,
+	   and nothing will happen. */
+	free_disk_guids (dev, first_minor);
+#endif
 	blk_size[dev->major] =3D NULL;
 	check_partition(dev, MKDEV(dev->major, first_minor), 1 + first_minor);
=20
diff -urN linux-davidm/fs/partitions/efi.c linux-2.4.5-lia/fs/partitions/ef=
i.c
--- linux-davidm/fs/partitions/efi.c	Tue Jun 26 22:55:38 2001
+++ linux-2.4.5-lia/fs/partitions/efi.c	Tue Jun 26 22:33:56 2001
@@ -61,7 +61,7 @@
 #include "check.h"
 #include "efi.h"
=20
-#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+#if CONFIG_BLK_DEV_MD
 extern void md_autodetect_dev(kdev_t dev);
 #endif
=20
@@ -479,7 +479,30 @@
 	return 0;
 }
=20
+#ifdef CONFIG_DEVFS_GUID
+/* set_partition_guid */
+/* Fill in the GUID field of the partition.
+   It is set to NULL by register_disk before. */
+static void set_partition_guid (struct gendisk *hd,
+				const int minor,
+				const efi_guid_t *guid)
+{
+	efi_guid_t *part_guid =3D hd->part[minor].guid;
+
+	if (!guid || !hd) return;
+
+	part_guid =3D kmalloc (sizeof (efi_guid_t), GFP_KERNEL);
=20
+        if (part_guid) {
+		memcpy (part_guid, guid, sizeof (efi_guid_t));
+	} else {
+		printk (KERN_WARNING
+                        "add_gpt_partitions: cannot allocate GUID memory!\=
n");
+	};
+
+	hd->part[minor].guid =3D part_guid;
+}
+#endif /* CONFIG_DEVFS_GUID */
=20
 /*
  * Create devices for each entry in the GUID Partition Table Entries.
@@ -502,7 +525,7 @@
 	u32 i, nummade=3D0;
=20
 	efi_guid_t unusedGuid =3D UNUSED_ENTRY_GUID;
-#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+#if CONFIG_BLK_DEV_MD
 	efi_guid_t raidGuid =3D PARTITION_LINUX_RAID_GUID;
 #endif
=20
@@ -516,6 +539,11 @@
 	}
=20
 	debug_printk(efi_printk_level "GUID Partition Table is valid!  Yea!\n");
+
+#ifdef CONFIG_DEVFS_GUID
+	set_partition_guid (hd, nextminor - 1, &(gpt->DiskGUID));
+#endif
+
 	for (i =3D 0; i < gpt->NumberOfPartitionEntries &&
 		     nummade < (hd->max_p - 1); i++) {
 		if (!efi_guidcmp(unusedGuid, ptes[i].PartitionTypeGuid))
@@ -524,8 +552,12 @@
 		add_gd_partition(hd, nextminor, ptes[i].StartingLBA,
 				 (ptes[i].EndingLBA-ptes[i].StartingLBA + 1));
=20
+#ifdef CONFIG_DEVFS_GUID
+		set_partition_guid (hd, nextminor, &(ptes[i].UniquePartitionGuid));
+#endif
+
 		/* If there's this is a RAID volume, tell md */
-#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+#if CONFIG_BLK_DEV_MD
 		if (!efi_guidcmp(raidGuid, ptes[i].PartitionTypeGuid)) {
 			md_autodetect_dev(MKDEV(MAJOR(dev),nextminor));
 		}
diff -urN linux-davidm/include/asm-ia64/fpswa.h linux-2.4.5-lia/include/asm=
-ia64/fpswa.h
--- linux-davidm/include/asm-ia64/fpswa.h	Sun Feb 13 10:30:50 2000
+++ linux-2.4.5-lia/include/asm-ia64/fpswa.h	Tue Jun 26 22:34:10 2001
@@ -9,10 +9,6 @@
  * Copyright (C) 1999 Goutham Rao <goutham.rao@intel.com>
  */
=20
-#if 1
-#define FPSWA_BUG
-#endif
-
 typedef struct {
 	/* 4 * 128 bits */
 	unsigned long fp_lp[4*2];
diff -urN linux-davidm/include/asm-ia64/hw_irq.h linux-2.4.5-lia/include/as=
m-ia64/hw_irq.h
--- linux-davidm/include/asm-ia64/hw_irq.h	Sun Apr 29 15:50:41 2001
+++ linux-2.4.5-lia/include/asm-ia64/hw_irq.h	Tue Jun 26 22:34:23 2001
@@ -49,6 +49,7 @@
 #define IA64_PERFMON_VECTOR		0xee	/* performanc monitor interrupt vector */
 #define IA64_TIMER_VECTOR		0xef	/* use highest-prio group 15 interrupt for=
 timer */
 #define	IA64_MCA_WAKEUP_VECTOR		0xf0	/* MCA wakeup (must be >MCA_RENDEZ_VE=
CTOR) */
+#define IA64_IPI_RESCHEDULE		0xfd	/* SMP reschedule */
 #define IA64_IPI_VECTOR			0xfe	/* inter-processor interrupt vector */
=20
 /* IA64 inter-cpu interrupt related definitions */
@@ -69,7 +70,7 @@
=20
 extern unsigned long ipi_base_addr;
=20
-extern struct hw_interrupt_type irq_type_ia64_sapic;	/* CPU-internal inter=
rupt controller */
+extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal inte=
rrupt controller */
=20
 extern int ia64_alloc_irq (void);	/* allocate a free irq */
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int red=
irect);
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.5-lia/include/a=
sm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Tue Jun 26 22:55:38 2001
+++ linux-2.4.5-lia/include/asm-ia64/offsets.h	Tue Jun 26 22:34:41 2001
@@ -25,8 +25,8 @@
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
 #define IA64_TASK_THREAD_OFFSET		1456	/* 0x5b0 */
 #define IA64_TASK_THREAD_KSP_OFFSET	1456	/* 0x5b0 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	3752	/* 0xea8 */
-#define IA64_TASK_PFM_NOTIFY_OFFSET	3648	/* 0xe40 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	1568	/* 0x620 */
+#define IA64_TASK_PFM_NOTIFY_OFFSET	2088	/* 0x828 */
 #define IA64_TASK_PID_OFFSET		196	/* 0xc4 */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/signal.h linux-2.4.5-lia/include/as=
m-ia64/signal.h
--- linux-davidm/include/asm-ia64/signal.h	Wed Feb  9 19:45:43 2000
+++ linux-2.4.5-lia/include/asm-ia64/signal.h	Tue Jun 26 22:34:54 2001
@@ -56,7 +56,7 @@
  * SA_FLAGS values:
  *
  * SA_ONSTACK indicates that a registered stack_t will be used.
- * SA_INTERRUPT is a no-op, but left due to historical reasons. Use the
+ * SA_INTERRUPT is a no-op, but left due to historical reasons.
  * SA_RESTART flag to get restarting signals (which were the default long =
ago)
  * SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
  * SA_RESETHAND clears the handler when the signal is delivered.
@@ -105,7 +105,6 @@
 #define SA_PROBE		SA_ONESHOT
 #define SA_SAMPLE_RANDOM	SA_RESTART
 #define SA_SHIRQ		0x04000000
-#define SA_LEGACY		0x02000000	/* installed via a legacy irq? */
=20
 #endif /* __KERNEL__ */
=20
diff -urN linux-davidm/include/asm-ia64/smp.h linux-2.4.5-lia/include/asm-i=
a64/smp.h
--- linux-davidm/include/asm-ia64/smp.h	Tue Jun 26 22:55:38 2001
+++ linux-2.4.5-lia/include/asm-ia64/smp.h	Tue Jun 26 22:35:08 2001
@@ -35,7 +35,7 @@
=20
 extern char no_int_routing __initdata;
=20
-extern unsigned long cpu_online_map;
+extern volatile unsigned long cpu_online_map;
 extern unsigned long ipi_base_addr;
 extern unsigned char smp_int_redirect;
 extern int smp_num_cpus;
diff -urN linux-davidm/include/linux/devfs_fs_kernel.h linux-2.4.5-lia/incl=
ude/linux/devfs_fs_kernel.h
--- linux-davidm/include/linux/devfs_fs_kernel.h	Sun Apr 29 15:50:52 2001
+++ linux-2.4.5-lia/include/linux/devfs_fs_kernel.h	Tue Jun 26 22:35:22 2001
@@ -81,6 +81,9 @@
 extern devfs_handle_t devfs_get_next_sibling (devfs_handle_t de);
 extern void devfs_auto_unregister (devfs_handle_t master,devfs_handle_t sl=
ave);
 extern devfs_handle_t devfs_get_unregister_slave (devfs_handle_t master);
+#ifdef CONFIG_DEVFS_GUID
+extern void devfs_unregister_slave (devfs_handle_t master);
+#endif
 extern const char *devfs_get_name (devfs_handle_t de, unsigned int *namele=
n);
 extern int devfs_register_chrdev (unsigned int major, const char *name,
 				  struct file_operations *fops);
diff -urN linux-davidm/include/linux/genhd.h linux-2.4.5-lia/include/linux/=
genhd.h
--- linux-davidm/include/linux/genhd.h	Mon Apr  2 19:01:59 2001
+++ linux-2.4.5-lia/include/linux/genhd.h	Tue Jun 26 22:35:35 2001
@@ -13,6 +13,10 @@
 #include <linux/types.h>
 #include <linux/major.h>
=20
+#ifdef CONFIG_DEVFS_GUID
+#include <asm/efi.h>
+#endif
+
 /* These three have identical behaviour; use the second one if DOS fdisk g=
ets
    confused about extended/logical partitions starting past cylinder 1023.=
 */
 #define DOS_EXTENDED_PARTITION 5
@@ -51,6 +55,9 @@
 	long start_sect;
 	long nr_sects;
 	devfs_handle_t de;              /* primary (master) devfs entry  */
+#ifdef CONFIG_DEVFS_GUID
+	efi_guid_t *guid;
+#endif
 };
=20
 #define GENHD_FL_REMOVABLE  1
diff -urN linux-davidm/include/linux/irq.h linux-2.4.5-lia/include/linux/ir=
q.h
--- linux-davidm/include/linux/irq.h	Tue Jun 26 22:55:38 2001
+++ linux-2.4.5-lia/include/linux/irq.h	Tue Jun 26 22:35:47 2001
@@ -54,7 +54,6 @@
=20
 #include <asm/hw_irq.h> /* the arch dependent stuff */
=20
-extern void do_IRQ_per_cpu (unsigned long irq, struct pt_regs *regs);
 extern int handle_IRQ_event(unsigned int, struct pt_regs *, struct irqacti=
on *);
 extern int setup_irq(unsigned int , struct irqaction * );
=20
diff -urN linux-davidm/include/linux/sched.h linux-2.4.5-lia/include/linux/=
sched.h
--- linux-davidm/include/linux/sched.h	Sun Apr 29 15:50:54 2001
+++ linux-2.4.5-lia/include/linux/sched.h	Tue Jun 26 22:40:35 2001
@@ -537,7 +537,7 @@
 extern unsigned long volatile jiffies;
 extern unsigned long itimer_ticks;
 extern unsigned long itimer_next;
-extern struct timeval xtime;
+extern volatile struct timeval xtime;
 extern void do_timer(struct pt_regs *);
=20
 extern unsigned int * prof_buffer;
diff -urN linux-davidm/include/linux/smp.h linux-2.4.5-lia/include/linux/sm=
p.h
--- linux-davidm/include/linux/smp.h	Sun Dec 31 11:10:17 2000
+++ linux-2.4.5-lia/include/linux/smp.h	Tue Jun 26 22:36:19 2001
@@ -53,7 +53,7 @@
 /*
  * True once the per process idle is forked
  */
-extern int smp_threads_ready;
+extern volatile int smp_threads_ready;
=20
 extern int smp_num_cpus;
=20
diff -urN linux-davidm/mm/memory.c linux-2.4.5-lia/mm/memory.c
--- linux-davidm/mm/memory.c	Tue Jun 26 22:55:39 2001
+++ linux-2.4.5-lia/mm/memory.c	Tue Jun 26 22:37:29 2001
@@ -103,8 +103,10 @@
 	}
 	pmd =3D pmd_offset(dir, 0);
 	pgd_clear(dir);
-	for (j =3D 0; j < PTRS_PER_PMD ; j++)
+	for (j =3D 0; j < PTRS_PER_PMD ; j++) {
+		asm volatile ("lfetch.excl [%0]" :: "r"(pmd + j + 16));
 		free_one_pmd(pmd+j);
+	}
 	pmd_free(pmd);
 }
=20



