From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 25 Oct 2001 04:30:42 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805390@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

An updated ia64 patch for 2.4.13 is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

        linux-2.4.11-ia64-011010.diff*

change log:

	- support readahead() syscall added by 2.4.13 (both for ia64 and ia32)
	- console log level fix by Jesper Juhl
	- half-hearted attempt add supporting reading of "default LDT entry" in ia=
32
	  modify_ldt() syscall; someone who understands what this is supposed to do
	  should take a look at this...
	- palinfo update by Stephane Eranian
	- die() fix by Keith Owens
	- unaligned handler fix for rotating fp regs by Tony Luck
	- ACPI fix to get AGP bus scanned again by Chris Ahna
	- implementation ia64 version of wbinvd() for ACPI; this hasn't been tested
	  and may not work; shouldn't be an issue at the moment as this is needed =
only
	  for ACPI functionality that is not supported on Itanium; still someone w=
ho
	  knows ACPI better may want to take a look at this
	- update PCI DMA interface to support page-based mapping/unmapping and
	  the optional DAC interface

This kernel has been tested with gcc-3.0 on Big Sur, Lion, and HP
simulator.  Both UP and MP seem to compile fine.  As usual, your
mileage may vary.

Enjoy,

	--david

diff -urN linux-davidm/arch/i386/mm/fault.c linux-2.4.13-lia/arch/i386/mm/f=
ault.c
--- linux-davidm/arch/i386/mm/fault.c	Wed Oct 10 16:31:44 2001
+++ linux-2.4.13-lia/arch/i386/mm/fault.c	Wed Oct 24 18:11:25 2001
@@ -27,8 +27,6 @@
=20
 extern void die(const char *,struct pt_regs *,long);
=20
-extern int console_loglevel;
-
 /*
  * Ugly, ugly, but the goto's result in better assembly..
  */
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.13-lia/arch/ia=
64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Wed Oct 24 18:54:52 2001
+++ linux-2.4.13-lia/arch/ia64/ia32/ia32_entry.S	Wed Oct 24 18:11:48 2001
@@ -400,7 +400,7 @@
 	data8 sys_ni_syscall		/* reserved for TUX */
 	data8 sys_ni_syscall		/* reserved for Security */
 	data8 sys_gettid
-	data8 sys_ni_syscall	  /* 225 */
+	data8 sys_readahead	  /* 225 */
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
diff -urN linux-davidm/arch/ia64/ia32/ia32_ldt.c linux-2.4.13-lia/arch/ia64=
/ia32/ia32_ldt.c
--- linux-davidm/arch/ia64/ia32/ia32_ldt.c	Wed Oct 24 18:54:52 2001
+++ linux-2.4.13-lia/arch/ia64/ia32/ia32_ldt.c	Wed Oct 24 18:12:38 2001
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 Hewlett-Packard Co
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Adapted from arch/i386/kernel/ldt.c
  */
@@ -60,6 +60,25 @@
 }
=20
 static int
+read_default_ldt (void * ptr, unsigned long bytecount)
+{
+	unsigned long size;
+	int err;
+
+	/* XXX fix me: should return equivalent of default_ldt[0] */
+	err =3D 0;
+	size =3D 8;
+	if (size > bytecount)
+		size =3D bytecount;
+
+	err =3D size;
+	if (clear_user(ptr, size))
+		err =3D -EFAULT;
+
+	return err;
+}
+
+static int
 write_ldt (void * ptr, unsigned long bytecount, int oldmode)
 {
 	struct ia32_modify_ldt_ldt_s ldt_info;
@@ -116,6 +135,9 @@
 		break;
 	      case 1:
 		ret =3D write_ldt(P(ptr), bytecount, 1);
+		break;
+	      case 2:
+		ret =3D read_default_ldt(P(ptr), bytecount);
 		break;
 	      case 0x11:
 		ret =3D write_ldt(P(ptr), bytecount, 0);
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.13-lia/arch/ia64/=
kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Oct 24 18:54:52 2001
+++ linux-2.4.13-lia/arch/ia64/kernel/entry.S	Wed Oct 24 18:13:32 2001
@@ -4,7 +4,7 @@
  * Kernel entry points.
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999 Asit Mallick <Asit.K.Mallick@intel.com>
@@ -15,7 +15,7 @@
  * kernel stack. This allows us to handle interrupts without changing
  * to physical mode.
  *
- * Jonathan Nickin	<nicklin@missioncriticallinux.com>
+ * Jonathan Nicklin	<nicklin@missioncriticallinux.com>
  * Patrick O'Rourke	<orourke@missioncriticallinux.com>
  * 11/07/2000
  /
@@ -1130,7 +1130,7 @@
 	data8 sys_clone2
 	data8 sys_getdents64
 	data8 sys_getunwind			// 1215
-	data8 ia64_ni_syscall
+	data8 sys_readahead
 	data8 ia64_ni_syscall
 	data8 ia64_ni_syscall
 	data8 ia64_ni_syscall
diff -urN linux-davidm/arch/ia64/kernel/fw-emu.c linux-2.4.13-lia/arch/ia64=
/kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Wed Oct 24 18:54:52 2001
+++ linux-2.4.13-lia/arch/ia64/kernel/fw-emu.c	Wed Oct 24 18:13:46 2001
@@ -174,6 +174,43 @@
 "	;;\n"
 "	mov ar.lc=3Dr9\n"
 "	mov r8=3Dr0\n"
+"	;;\n"
+"1:	cmp.eq p6,p7=15,r28		/* PAL_PERF_MON_INFO */\n"
+"(p7)	br.cond.sptk.few 1f\n"
+"	mov r8=3D0			/* status =3D 0 */\n"
+"	movl r9 =3D0x12082004		/* generic=3D4 width2 retired=3D8 cycles=18 */\n"
+"	mov r10=3D0			/* reserved */\n"
+"	mov r11=3D0			/* reserved */\n"
+"	mov r16=3D0xffff			/* implemented PMC */\n"
+"	mov r17=3D0xffff			/* implemented PMD */\n"
+"	add r18=3D8,r29			/* second index */\n"
+"	;;\n"
+"	st8 [r29]=3Dr16,16		/* store implemented PMC */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	;;\n"
+"	st8 [r29]=3Dr0,16			/* store implemented PMC */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	;;\n"
+"	st8 [r29]=3Dr17,16		/* store implemented PMD */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	mov r16=3D0xf0			/* cycles count capable PMC */\n"
+"	;;\n"
+"	st8 [r29]=3Dr0,16			/* store implemented PMC */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	mov r17=3D0x10			/* retired bundles capable PMC */\n"
+"	;;\n"
+"	st8 [r29]=3Dr16,16		/* store cycles capable */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	;;\n"
+"	st8 [r29]=3Dr0,16			/* store implemented PMC */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	;;\n"
+"	st8 [r29]=3Dr17,16		/* store retired bundle capable */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	;;\n"
+"	st8 [r29]=3Dr0,16			/* store implemented PMC */\n"
+"	st8 [r18]=3Dr0,16			/* clear remaining bits  */\n"
+"	;;\n"
 "1:	br.cond.sptk.few rp\n"
 "stacked:\n"
 "	br.ret.sptk.few rp\n"
diff -urN linux-davidm/arch/ia64/kernel/palinfo.c linux-2.4.13-lia/arch/ia6=
4/kernel/palinfo.c
--- linux-davidm/arch/ia64/kernel/palinfo.c	Thu Apr  5 12:51:47 2001
+++ linux-2.4.13-lia/arch/ia64/kernel/palinfo.c	Wed Oct 24 18:14:08 2001
@@ -6,12 +6,13 @@
  * Intel IA-64 Architecture Software Developer's Manual v1.0.
  *
  *
- * Copyright (C) 2000 Hewlett-Packard Co
- * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 2000-2001 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
  *
  * 05/26/2000	S.Eranian	initial release
  * 08/21/2000	S.Eranian	updated to July 2000 PAL specs
  * 02/05/2001   S.Eranian	fixed module support
+ * 10/23/2001	S.Eranian	updated pal_perf_mon_info bug fixes
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -32,8 +33,9 @@
=20
 MODULE_AUTHOR("Stephane Eranian <eranian@hpl.hp.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 PAL");
+MODULE_LICENSE("GPL");
=20
-#define PALINFO_VERSION "0.4"
+#define PALINFO_VERSION "0.5"
=20
 #ifdef CONFIG_SMP
 #define cpu_is_online(i) (cpu_online_map & (1UL << i))
@@ -606,15 +608,6 @@
=20
 	if (ia64_pal_perf_mon_info(pm_buffer, &pm_info) !=3D 0) return 0;
=20
-#ifdef IA64_PAL_PERF_MON_INFO_BUG
-	/*
-	 * This bug has been fixed in PAL 2.2.9 and higher
-	 */
-	pm_buffer[5]=3D0x3;
-	pm_info.pal_perf_mon_info_s.cycles  =3D 0x12;
-	pm_info.pal_perf_mon_info_s.retired =3D 0x08;
-#endif
-
 	p +=3D sprintf(p, "PMC/PMD pairs                 : %d\n" \
 			"Counter width                 : %d bits\n" \
 			"Cycle event number            : %d\n" \
@@ -636,6 +629,14 @@
 	p =3D bitregister_process(p, pm_buffer+8, 256);
=20
 	p +=3D sprintf(p, "\nRetired bundles count capable : ");
+
+#ifdef CONFIG_ITANIUM
+	/*
+	 * PAL_PERF_MON_INFO reports that only PMC4 can be used to count CPU_CYCL=
ES
+	 * which is wrong, both PMC4 and PMD5 support it.
+	 */
+	if (pm_buffer[12] =3D 0x10) pm_buffer[12]=3D0x30;
+#endif
=20
 	p =3D bitregister_process(p, pm_buffer+12, 256);
=20
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.13-lia/arch/ia6=
4/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed Oct 24 18:54:52 2001
+++ linux-2.4.13-lia/arch/ia64/kernel/process.c	Wed Oct 24 18:14:43 2001
@@ -460,7 +460,7 @@
 	if (task->thread.pfm_context)
 		pfm_context_exit(task);
=20
-	if(atomic_read(&task->thread.pfm_notifiers_check) >0)
+	if (atomic_read(&task->thread.pfm_notifiers_check) > 0)
 		pfm_cleanup_notifiers(task);
 }
 #endif
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.13-lia/arch/ia64/=
kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Wed Oct 24 18:54:52 2001
+++ linux-2.4.13-lia/arch/ia64/kernel/traps.c	Wed Oct 24 18:15:16 2001
@@ -87,23 +87,34 @@
 void
 die (const char *str, struct pt_regs *regs, long err)
 {
-	static spinlock_t die_lock =3D SPIN_LOCK_UNLOCKED;
+	static struct {
+		spinlock_t lock;
+		int lock_owner;
+		int lock_owner_depth;
+	} die =3D {
+		lock:			SPIN_LOCK_UNLOCKED,
+		lock_owner:		-1,
+		lock_owner_depth:	0
+	};
=20
-	console_verbose();
-	spin_lock_irq(&die_lock);
-	bust_spinlocks(1);
-	printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
-	show_regs(regs);
-	bust_spinlocks(0);
-	spin_unlock_irq(&die_lock);
-
-	if (current->thread.flags & IA64_KERNEL_DEATH) {
-		printk("die_if_kernel recursion detected.\n");
-		sti();
-		while (1);
+	if (die.lock_owner !=3D smp_processor_id()) {
+		console_verbose();
+		spin_lock_irq(&die.lock);
+		die.lock_owner =3D smp_processor_id();
+		die.lock_owner_depth =3D 0;
+		bust_spinlocks(1);
 	}
-	current->thread.flags |=3D IA64_KERNEL_DEATH;
-	do_exit(SIGSEGV);
+
+	if (++die.lock_owner_depth < 3) {
+		printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
+		show_regs(regs);
+  	} else
+		printk(KERN_ERR "Recursive die() failure, output suppressed\n");
+
+	bust_spinlocks(0);
+	die.lock_owner =3D -1;
+	spin_unlock_irq(&die.lock);
+  	do_exit(SIGSEGV);
 }
=20
 void
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c linux-2.4.13-lia/arch/i=
a64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Oct 24 18:54:52 2001
+++ linux-2.4.13-lia/arch/ia64/kernel/unaligned.c	Wed Oct 24 18:15:29 2001
@@ -5,6 +5,7 @@
  * Copyright (C) 1999-2000 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
+ * 2001/10/11	Fix unaligned access to rotating registers in s/w pipelined =
loops.
  * 2001/08/13	Correct size of extended floats (float_fsz) from 16 to 10 by=
tes.
  * 2001/01/17	Add support emulation of unaligned kernel accesses.
  */
@@ -283,9 +284,19 @@
 	unsigned long rnats, nat_mask;
 	unsigned long on_kbs;
 	long sof =3D (regs->cr_ifs) & 0x7f;
+	long sor =3D 8 * ((regs->cr_ifs >> 14) & 0xf);
+	long rrb_gr =3D (regs->cr_ifs >> 18) & 0x7f;
+	long ridx;
+
+	if ((r1 - 32) > sor)
+		ridx =3D -sof + (r1 - 32);
+	else if ((r1 - 32) < (sor - rrb_gr))
+		ridx =3D -sof + (r1 - 32) + rrb_gr;
+	else
+		ridx =3D -sof + (r1 - 32) - (sor - rrb_gr);
=20
-	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld\n",
-	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) &=
 0x7f);
+	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld rid=
x=3D%ld\n",
+	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) &=
 0x7f, ridx);
=20
 	if ((r1 - 32) >=3D sof) {
 		/* this should never happen, as the "rsvd register fault" has higher pri=
ority */
@@ -294,7 +305,7 @@
 	}
=20
 	on_kbs =3D ia64_rse_num_regs(kbs, (unsigned long *) sw->ar_bspstore);
-	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + (r1=
 - 32));
+	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, ridx);
 	if (addr >=3D kbs) {
 		/* the register is on the kernel backing store: easy... */
 		rnat_addr =3D ia64_rse_rnat_addr(addr);
@@ -319,12 +330,12 @@
 		return;
 	}
=20
-	bspstore =3D (unsigned long *) regs->ar_bspstore;
+	bspstore =3D (unsigned long *)regs->ar_bspstore;
 	ubs_end =3D ia64_rse_skip_regs(bspstore, on_kbs);
 	bsp     =3D ia64_rse_skip_regs(ubs_end, -sof);
-	addr    =3D ia64_rse_skip_regs(bsp, r1 - 32);
+	addr    =3D ia64_rse_skip_regs(bsp, ridx + sof);
=20
-	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%px\n", (void *) ubs_end, (void *) b=
sp, (void *) addr);
+	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%p\n", (void *) ubs_end, (void *) bs=
p, (void *) addr);
=20
 	ia64_poke(current, sw, (unsigned long) ubs_end, (unsigned long) addr, val=
);
=20
@@ -354,9 +365,19 @@
 	unsigned long rnats, nat_mask;
 	unsigned long on_kbs;
 	long sof =3D (regs->cr_ifs) & 0x7f;
+	long sor =3D 8 * ((regs->cr_ifs >> 14) & 0xf);
+	long rrb_gr =3D (regs->cr_ifs >> 18) & 0x7f;
+	long ridx;
+
+	if ((r1 - 32) > sor)
+		ridx =3D -sof + (r1 - 32);
+	else if ((r1 - 32) < (sor - rrb_gr))
+		ridx =3D -sof + (r1 - 32) + rrb_gr;
+	else
+		ridx =3D -sof + (r1 - 32) - (sor - rrb_gr);
=20
-	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld\n",
-	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) &=
 0x7f);
+	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld rid=
x=3D%ld\n",
+	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) &=
 0x7f, ridx);
=20
 	if ((r1 - 32) >=3D sof) {
 		/* this should never happen, as the "rsvd register fault" has higher pri=
ority */
@@ -365,7 +386,7 @@
 	}
=20
 	on_kbs =3D ia64_rse_num_regs(kbs, (unsigned long *) sw->ar_bspstore);
-	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + (r1=
 - 32));
+	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, ridx);
 	if (addr >=3D kbs) {
 		/* the register is on the kernel backing store: easy... */
 		*val =3D *addr;
@@ -391,7 +412,7 @@
 	bspstore =3D (unsigned long *)regs->ar_bspstore;
 	ubs_end =3D ia64_rse_skip_regs(bspstore, on_kbs);
 	bsp     =3D ia64_rse_skip_regs(ubs_end, -sof);
-	addr    =3D ia64_rse_skip_regs(bsp, r1 - 32);
+	addr    =3D ia64_rse_skip_regs(bsp, ridx + sof);
=20
 	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%p\n", (void *) ubs_end, (void *) bs=
p, (void *) addr);
=20
diff -urN linux-davidm/arch/parisc/kernel/traps.c linux-2.4.13-lia/arch/par=
isc/kernel/traps.c
--- linux-davidm/arch/parisc/kernel/traps.c	Wed Oct 10 16:31:44 2001
+++ linux-2.4.13-lia/arch/parisc/kernel/traps.c	Wed Oct 24 18:17:29 2001
@@ -43,7 +43,6 @@
=20
 static inline void console_verbose(void)
 {
-	extern int console_loglevel;
 	console_loglevel =3D 15;
 }
=20
diff -urN linux-davidm/drivers/acpi/include/acutils.h linux-2.4.13-lia/driv=
ers/acpi/include/acutils.h
--- linux-davidm/drivers/acpi/include/acutils.h	Mon Sep 24 15:06:42 2001
+++ linux-2.4.13-lia/drivers/acpi/include/acutils.h	Wed Oct 24 18:17:40 2001
@@ -383,6 +383,7 @@
 /* Method name strings */
=20
 #define METHOD_NAME__HID        "_HID"
+#define METHOD_NAME__CID        "_CID"
 #define METHOD_NAME__UID        "_UID"
 #define METHOD_NAME__ADR        "_ADR"
 #define METHOD_NAME__STA        "_STA"
@@ -396,6 +397,11 @@
 	NATIVE_CHAR             *object_name,
 	acpi_namespace_node     *device_node,
 	acpi_integer            *address);
+
+acpi_status
+acpi_ut_execute_CID (
+	acpi_namespace_node     *device_node,
+	ACPI_DEVICE_ID          *cid);
=20
 acpi_status
 acpi_ut_execute_HID (
diff -urN linux-davidm/drivers/acpi/include/platform/acgcc.h linux-2.4.13-l=
ia/drivers/acpi/include/platform/acgcc.h
--- linux-davidm/drivers/acpi/include/platform/acgcc.h	Wed Oct 24 10:17:44 =
2001
+++ linux-2.4.13-lia/drivers/acpi/include/platform/acgcc.h	Wed Oct 24 18:17=
:50 2001
@@ -42,11 +42,32 @@
=20
 /*! [Begin] no source code translation */
=20
+#include <linux/interrupt.h>
+
+#include <asm/processor.h>
 #include <asm/pal.h>
=20
 #define halt()              ia64_pal_halt_light()           /* PAL_HALT[_L=
IGHT] */
 #define safe_halt()         ia64_pal_halt(1)                /* PAL_HALT */
=20
+static inline void
+wbinvd (void)
+{
+	unsigned long flags, vector, position =3D 0;
+	long status;
+
+	do {
+		ia64_clear_ic(flags);
+		status =3D ia64_pal_cache_flush(0x3, (PAL_CACHE_FLUSH_INVALIDATE
+						    | PAL_CACHE_FLUSH_CHK_INTRS),
+					      &position, &vector);
+		local_irq_restore(flags);
+		if (status =3D 1) {
+			ia64_eoi();
+			hw_resend_irq(NULL, vector);
+		}
+	} while (status =3D 1);
+}
=20
 #define ACPI_ACQUIRE_GLOBAL_LOCK(GLptr, Acq) \
 	do { \
diff -urN linux-davidm/drivers/acpi/namespace/nsxfobj.c linux-2.4.13-lia/dr=
ivers/acpi/namespace/nsxfobj.c
--- linux-davidm/drivers/acpi/namespace/nsxfobj.c	Mon Sep 24 15:06:43 2001
+++ linux-2.4.13-lia/drivers/acpi/namespace/nsxfobj.c	Wed Oct 24 18:18:06 2=
001
@@ -588,6 +588,7 @@
 	acpi_namespace_node     *node;
 	u32                     flags;
 	ACPI_DEVICE_ID          device_id;
+	ACPI_DEVICE_ID          compatible_id;
 	ACPI_GET_DEVICES_INFO   *info;
=20
=20
@@ -628,7 +629,17 @@
 		}
=20
 		if (STRNCMP (device_id.buffer, info->hid, sizeof (device_id.buffer)) !=
=3D 0) {
-			return (AE_OK);
+			status =3D acpi_ut_execute_CID (node, &compatible_id);
+			if (status =3D AE_NOT_FOUND) {
+				return (AE_OK);
+			}
+			else if (ACPI_FAILURE (status)) {
+				return (AE_CTRL_DEPTH);
+			}
+
+			if (STRNCMP (compatible_id.buffer, info->hid, sizeof (compatible_id.buf=
fer)) !=3D 0) {
+				return (AE_OK);
+			}
 		}
 	}
=20
diff -urN linux-davidm/drivers/acpi/utilities/uteval.c linux-2.4.13-lia/dri=
vers/acpi/utilities/uteval.c
--- linux-davidm/drivers/acpi/utilities/uteval.c	Mon Sep 24 15:06:47 2001
+++ linux-2.4.13-lia/drivers/acpi/utilities/uteval.c	Wed Oct 24 18:18:19 20=
01
@@ -115,6 +115,93 @@
=20
 /*************************************************************************=
******
  *
+ * FUNCTION:    Acpi_ut_execute_CID
+ *
+ * PARAMETERS:  Device_node         - Node for the device
+ *              *Cid                - Where the CID is returned
+ *
+ * RETURN:      Status
+ *
+ * DESCRIPTION: Executes the _CID control method that returns the compatib=
le
+ *              ID of the device.
+ *
+ *              NOTE: Internal function, no parameter validation
+ *
+ *************************************************************************=
*****/
+
+acpi_status
+acpi_ut_execute_CID (
+	acpi_namespace_node     *device_node,
+	ACPI_DEVICE_ID          *cid)
+{
+	acpi_operand_object     *obj_desc;
+	acpi_status             status;
+
+
+	FUNCTION_TRACE ("Ut_execute_CID");
+
+
+	/* Execute the method */
+
+	status =3D acpi_ns_evaluate_relative (device_node,
+			 METHOD_NAME__CID, NULL, &obj_desc);
+	if (ACPI_FAILURE (status)) {
+		if (status =3D AE_NOT_FOUND) {
+			ACPI_DEBUG_PRINT ((ACPI_DB_INFO, "_CID on %4.4s was not found\n",
+				&device_node->name));
+		}
+
+		else {
+			ACPI_DEBUG_PRINT ((ACPI_DB_ERROR, "_CID on %4.4s failed %s\n",
+				&device_node->name, acpi_format_exception (status)));
+		}
+
+		return_ACPI_STATUS (status);
+	}
+
+	/* Did we get a return object? */
+
+	if (!obj_desc) {
+		ACPI_DEBUG_PRINT ((ACPI_DB_ERROR, "No object was returned from _CID\n"));
+		return_ACPI_STATUS (AE_TYPE);
+	}
+
+	/*
+	 *  A _CID can return either a Number (32 bit compressed EISA ID) or
+	 *  a string
+	 */
+	if ((obj_desc->common.type !=3D ACPI_TYPE_INTEGER) &&
+		(obj_desc->common.type !=3D ACPI_TYPE_STRING)) {
+		status =3D AE_TYPE;
+		ACPI_DEBUG_PRINT ((ACPI_DB_ERROR,
+			"Type returned from _CID not a number or string: %s(%X) \n",
+			acpi_ut_get_type_name (obj_desc->common.type), obj_desc->common.type));
+	}
+
+	else {
+		if (obj_desc->common.type =3D ACPI_TYPE_INTEGER) {
+			/* Convert the Numeric CID to string */
+
+			acpi_ex_eisa_id_to_string ((u32) obj_desc->integer.value, cid->buffer);
+		}
+
+		else {
+			/* Copy the String CID from the returned object */
+
+			STRNCPY(cid->buffer, obj_desc->string.pointer, sizeof(cid->buffer));
+		}
+	}
+
+
+	/* On exit, we must delete the return object */
+
+	acpi_ut_remove_reference (obj_desc);
+
+	return_ACPI_STATUS (status);
+}
+
+/*************************************************************************=
******
+ *
  * FUNCTION:    Acpi_ut_execute_HID
  *
  * PARAMETERS:  Device_node         - Node for the device
diff -urN linux-davidm/drivers/pci/pci.c linux-2.4.13-lia/drivers/pci/pci.c
--- linux-davidm/drivers/pci/pci.c	Wed Oct 24 18:55:31 2001
+++ linux-2.4.13-lia/drivers/pci/pci.c	Wed Oct 24 10:21:19 2001
@@ -1552,10 +1552,10 @@
=20
 	switch (rqst) {
 	case PM_SAVE_STATE:
-		error =3D pci_pm_save_state((u32)data);
+		error =3D pci_pm_save_state((unsigned long)data);
 		break;
 	case PM_SUSPEND:
-		error =3D pci_pm_suspend((u32)data);
+		error =3D pci_pm_suspend((unsigned long)data);
 		break;
 	case PM_RESUME:
 		error =3D pci_pm_resume();
@@ -1873,16 +1873,16 @@
 	int			map, block;
=20
 	if ((page =3D pool_find_page (pool, dma)) =3D 0) {
-		printk (KERN_ERR "pci_pool_free %s/%s, %p/%x (bad dma)\n",
+		printk (KERN_ERR "pci_pool_free %s/%s, %p/%lx (bad dma)\n",
 			pool->dev ? pool->dev->slot_name : NULL,
-			pool->name, vaddr, (int) (dma & 0xffffffff));
+			pool->name, vaddr, (unsigned long) dma);
 		return;
 	}
 #ifdef	CONFIG_PCIPOOL_DEBUG
 	if (((dma - page->dma) + (void *)page->vaddr) !=3D vaddr) {
 		printk (KERN_ERR "pci_pool_free %s/%s, %p (bad vaddr)/%x\n",
 			pool->dev ? pool->dev->slot_name : NULL,
-			pool->name, vaddr, (int) (dma & 0xffffffff));
+			pool->name, vaddr, dma);
 		return;
 	}
 #endif
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.13-lia/include/=
asm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Wed Oct 24 18:54:53 2001
+++ linux-2.4.13-lia/include/asm-ia64/offsets.h	Wed Oct 24 18:30:40 2001
@@ -8,7 +8,7 @@
  */
 #define PT_PTRACED_BIT		0
 #define PT_TRACESYS_BIT		1
-#define IA64_TASK_SIZE			3920	/* 0xf50 */
+#define IA64_TASK_SIZE			3408	/* 0xd50 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
@@ -20,9 +20,9 @@
 #define IA64_TASK_SIGPENDING_OFFSET	16	/* 0x10 */
 #define IA64_TASK_NEED_RESCHED_OFFSET	40	/* 0x28 */
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
-#define IA64_TASK_THREAD_OFFSET		1472	/* 0x5c0 */
-#define IA64_TASK_THREAD_KSP_OFFSET	1472	/* 0x5c0 */
-#define IA64_TASK_PFM_MUST_BLOCK_OFFSET	2096	/* 0x830 */
+#define IA64_TASK_THREAD_OFFSET		976	/* 0x3d0 */
+#define IA64_TASK_THREAD_KSP_OFFSET	976	/* 0x3d0 */
+#define IA64_TASK_PFM_MUST_BLOCK_OFFSET	1600	/* 0x640 */
 #define IA64_TASK_PID_OFFSET		220	/* 0xdc */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/pal.h linux-2.4.13-lia/include/asm-=
ia64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Wed Oct 24 18:54:53 2001
+++ linux-2.4.13-lia/include/asm-ia64/pal.h	Wed Oct 24 18:20:46 2001
@@ -776,10 +776,12 @@
  * initialized to zero before calling this for the first time..
  */
 static inline s64
-ia64_pal_cache_flush (u64 cache_type, u64 invalidate, u64 *progress)
+ia64_pal_cache_flush (u64 cache_type, u64 invalidate, u64 *progress, u64 *=
vector)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL_IC_OFF(iprv, PAL_CACHE_FLUSH, cache_type, invalidate, *progress);
+	if (vector)
+		*vector =3D iprv.v0;
 	*progress =3D iprv.v1;
 	return iprv.status;
 }
diff -urN linux-davidm/include/asm-ia64/pci.h linux-2.4.13-lia/include/asm-=
ia64/pci.h
--- linux-davidm/include/asm-ia64/pci.h	Wed Oct 24 18:54:53 2001
+++ linux-2.4.13-lia/include/asm-ia64/pci.h	Wed Oct 24 18:32:34 2001
@@ -10,9 +10,9 @@
 #include <asm/scatterlist.h>
=20
 /*
- * Can be used to override the logic in pci_scan_bus for skipping
- * already-configured bus numbers - to be used for buggy BIOSes or
- * architectures with incomplete PCI setup by the loader.
+ * Can be used to override the logic in pci_scan_bus for skipping already-=
configured bus
+ * numbers - to be used for buggy BIOSes or architectures with incomplete =
PCI setup by the
+ * loader.
  */
 #define pcibios_assign_all_busses()     0
=20
@@ -56,6 +56,19 @@
 {
 	return 1;
 }
+
+#define pci_map_page(dev,pg,off,size,dir)				\
+	pci_map_single((dev), page_address(pg) + (off), (size), (dir))
+#define pci_unmap_page(dev,dma_addr,size,dir)				\
+	pci_unmap_single((dev), (dma_addr), (size), (dir)
+
+/* The ia64 platform always supports 64-bit addressing. */
+#define pci_dac_dma_supported(pci_dev, mask)	(1)
+
+#define pci_dac_page_to_dma(dev,pg,off,dir)	((dma64_addr_t) page_to_bus(pg=
) + (off))
+#define pci_dac_dma_to_page(dev,dma_addr)	(virt_to_page(bus_to_virt(dma_ad=
dr)))
+#define pci_dac_dma_to_offset(dev,dma_addr)	((dma_addr) & ~PAGE_MASK)
+#define pci_dac_dma_sync_single(dev,dma_addr,len,dir)	do { /* nothing */ }=
 while (0)
=20
 /* Return the index of the PCI controller for device PDEV. */
 #define pci_controller_num(PDEV)	(0)
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.13-lia/includ=
e/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed Oct 24 18:54:53 2001
+++ linux-2.4.13-lia/include/asm-ia64/processor.h	Wed Oct 24 18:32:17 2001
@@ -170,7 +170,6 @@
 #define IA64_THREAD_KRBS_SYNCED	(__IA64_UL(1) << 5)	/* krbs synced with pr=
ocess vm? */
 #define IA64_THREAD_FPEMU_NOPRINT (__IA64_UL(1) << 6)	/* don't log any fps=
wa faults */
 #define IA64_THREAD_FPEMU_SIGFPE  (__IA64_UL(1) << 7)	/* send a SIGFPE for=
 fpswa faults */
-#define IA64_KERNEL_DEATH	(__IA64_UL(1) << 63)	/* see die_if_kernel()... */
=20
 #define IA64_THREAD_UAC_SHIFT	3
 #define IA64_THREAD_UAC_MASK	(IA64_THREAD_UAC_NOPRINT | IA64_THREAD_UAC_SI=
GBUS)
@@ -958,6 +957,42 @@
=20
 	asm ("mov %0=3Dgp" : "=3Dr"(val));
 	return val;
+}
+
+static inline void
+ia64_set_ibr (__u64 regnum, __u64 value)
+{
+	asm volatile ("mov ibr[%0]=3D%1" :: "r"(regnum), "r"(value));
+}
+
+static inline void
+ia64_set_dbr (__u64 regnum, __u64 value)
+{
+	asm volatile ("mov dbr[%0]=3D%1" :: "r"(regnum), "r"(value));
+#ifdef CONFIG_ITANIUM
+	asm volatile (";; srlz.d");
+#endif
+}
+
+static inline __u64
+ia64_get_ibr (__u64 regnum)
+{
+	__u64 retval;
+
+	asm volatile ("mov %0=3Dibr[%1]" : "=3Dr"(retval) : "r"(regnum));
+	return retval;
+}
+
+static inline __u64
+ia64_get_dbr (__u64 regnum)
+{
+	__u64 retval;
+
+	asm volatile ("mov %0=DBr[%1]" : "=3Dr"(retval) : "r"(regnum));
+#ifdef CONFIG_ITANIUM
+	asm volatile (";; srlz.d");
+#endif
+	return retval;
 }
=20
 /* XXX remove the handcoded version once we have a sufficiently clever com=
piler... */
diff -urN linux-davidm/include/asm-ia64/unistd.h linux-2.4.13-lia/include/a=
sm-ia64/unistd.h
--- linux-davidm/include/asm-ia64/unistd.h	Wed Oct 24 18:54:53 2001
+++ linux-2.4.13-lia/include/asm-ia64/unistd.h	Wed Oct 24 18:21:34 2001
@@ -205,6 +205,7 @@
 #define __NR_clone2			1213
 #define __NR_getdents64			1214
 #define __NR_getunwind			1215
+#define __NR_readahead			1216
=20
 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)
=20
diff -urN linux-davidm/include/linux/kernel.h linux-2.4.13-lia/include/linu=
x/kernel.h
--- linux-davidm/include/linux/kernel.h	Wed Oct 10 16:32:16 2001
+++ linux-2.4.13-lia/include/linux/kernel.h	Wed Oct 24 18:22:22 2001
@@ -36,6 +36,13 @@
 #define	KERN_INFO	"<6>"	/* informational			*/
 #define	KERN_DEBUG	"<7>"	/* debug-level messages			*/
=20
+extern int console_printk[];
+
+#define console_loglevel (console_printk[0])
+#define default_message_loglevel (console_printk[1])
+#define minimum_console_loglevel (console_printk[2])
+#define default_console_loglevel (console_printk[3])
+
 # define NORET_TYPE    /**/
 # define ATTRIB_NORET  __attribute__((noreturn))
 # define NORET_AND     noreturn,
@@ -79,8 +86,6 @@
=20
 asmlinkage int printk(const char * fmt, ...)
 	__attribute__ ((format (printf, 1, 2)));
-
-extern int console_loglevel;
=20
 static inline void console_silent(void)
 {
diff -urN linux-davidm/kernel/exec_domain.c linux-2.4.13-lia/kernel/exec_do=
main.c
--- linux-davidm/kernel/exec_domain.c	Wed Oct 10 16:32:16 2001
+++ linux-2.4.13-lia/kernel/exec_domain.c	Wed Oct 24 18:22:52 2001
@@ -196,8 +196,10 @@
=20
 	put_exec_domain(oep);
=20
+#if 0
 	printk(KERN_DEBUG "[%s:%d]: set personality to %lx\n",
 			current->comm, current->pid, personality);
+#endif
 	return 0;
 }
=20
diff -urN linux-davidm/kernel/printk.c linux-2.4.13-lia/kernel/printk.c
--- linux-davidm/kernel/printk.c	Wed Oct 24 18:54:53 2001
+++ linux-2.4.13-lia/kernel/printk.c	Wed Oct 24 18:29:37 2001
@@ -16,6 +16,7 @@
  *	01Mar01 Andrew Morton <andrewm@uow.edu.au>
  */
=20
+#include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/tty.h>
 #include <linux/tty_driver.h>
@@ -27,7 +28,11 @@
=20
 #include <asm/uaccess.h>
=20
+#if 0
 #define LOG_BUF_LEN	(16384)			/* This must be a power of two */
+#else
+#define LOG_BUF_LEN	(65536)			/* This must be a power of two */
+#endif
 #define LOG_BUF_MASK	(LOG_BUF_LEN-1)
=20
 /* printk's without a loglevel use this.. */
@@ -39,11 +44,12 @@
=20
 DECLARE_WAIT_QUEUE_HEAD(log_wait);
=20
-/* Keep together for sysctl support */
-int console_loglevel =3D DEFAULT_CONSOLE_LOGLEVEL;
-int default_message_loglevel =3D DEFAULT_MESSAGE_LOGLEVEL;
-int minimum_console_loglevel =3D MINIMUM_CONSOLE_LOGLEVEL;
-int default_console_loglevel =3D DEFAULT_CONSOLE_LOGLEVEL;
+int console_printk[4] =3D {
+	DEFAULT_CONSOLE_LOGLEVEL,	/* console_loglevel */
+	DEFAULT_MESSAGE_LOGLEVEL,	/* default_message_loglevel */
+	MINIMUM_CONSOLE_LOGLEVEL,	/* minimum_console_loglevel */
+	DEFAULT_CONSOLE_LOGLEVEL,	/* default_console_loglevel */
+};
=20
 int oops_in_progress;
=20

