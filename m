From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Apr 2003 20:24:19 +0000
Subject: [Linux-ia64] print backtrace from OS INIT handler
Message-Id: <marc-linux-ia64-105590723705506@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The patch below is relative to 2.5.67 and adds support to print a
backtrace from the OS INIT handler.  The complete INIT output looks
now something like shown below.  The example is for the case when INIT
is received while a CPU is idle in PAL_LIGHT_HALT.  Caveat: at the
moment, the INIT handler doing this dumping is called only on the
bootstrap CPU.  Hopefully, this can be extended to cover the other
CPUs without too much trouble (hint hint... ;-).

	--david

Entered OS INIT handler
Delaying for 5 seconds...
NaT bits        0000000000000000
pr              fffffffffffe598d
b0              e000000004417810 ia64_pal_call_static+0x70/0xa0
ar.rsc          0000000000000003
cr.iip          e00000003ff5eec2 0xe00000003ff5eec2
cr.ipsr         0000141008020038
cr.ifs          8000000000003060
xip             e000000004417820 ia64_pal_call_static+0x80/0xa0
xpsr            0000101008026038
xfs             8000000000003060
b1              80000000ffee0000 0x80000000ffee0000

static registers r0-r15:
 r0- 3 0000000000000000 e00000000502ab10 e000000004b2fe50 0000000000000001
 r4- 7 0000000000000000 0000000000000000 0000000000000000 80000000fed00000
 r8-11 fffffffffffffffe 0000000000000000 0000000000000000 0000000000000000
r11-15 e000000004b2fdb0 e000000004b28000 00000000000006c2 00020c1000002f0f

bank 0:
r16-19 e000000004b29320 0000000000000308 0000000000000000 0000000000000000
r20-23 e00000000502ab10 e000000004402f80 e00000003d148f30 0000000000000000
r24-27 0000000000000000 0000000000000000 0000000000000188 0000000000000003
r28-31 e000000004417820 0000101008026038 8000000000003060 fffffffffffe510d

bank 1:
r16-19 02800000ff440000 fffffffffffe518d 000000001f000604 0000001008022038
r20-23 0000000000000588 0000001400000000 0000001008022038 0000000000000000
r24-27 0000001008020000 0000001008020000 0bad0bad0bad0bad e000000004b290d0
r28-31 000000000000001d 0000000000000000 0000000000000000 0000000000000000

Call Trace:
 [<e000000004417820>] ia64_pal_call_static+0x80/0xa0
                sp=E000000004b2fdb0 bsp=E000000004b29018
 [<e000000004425990>] default_idle+0x90/0x100
                sp=E000000004b2fdb0 bsp=E000000004b29000
 [<e000000004425b00>] cpu_idle+0x100/0x180
                sp=E000000004b2fe50 bsp=E000000004b28f88
 [<e000000004aecea0>] 0xe000000004aecea0
                sp=E000000004b2fe50 bsp=E000000004b28f30
 [<e000000004408200>] _start+0x200/0x220
                sp=E000000004b2fe60 bsp=E000000004b28f30

INIT dump complete.  Please reboot now.

---
=3D=3D=3D arch/ia64/kernel/mca.c 1.23 vs edited =3D=3D--- 1.23/arch/ia64/ke=
rnel/mca.c	Fri Apr 11 18:18:35 2003
+++ edited/arch/ia64/kernel/mca.c	Tue Apr 15 12:20:54 2003
@@ -239,17 +239,91 @@
 	       minstate->pmsa_bank1_gr[14], minstate->pmsa_bank1_gr[15]);
 }
=20
-/*
- * This routine will be used to deal with platform specific handling
- * of the init, i.e. drop into the kernel debugger on server machine,
- * or if the processor is part of some parallel machine without a
- * console, then we would call the appropriate debug hooks here.
- */
-unsigned long tr_val[32], tr_idx;
-
-void
-init_handler_platform (sal_log_processor_info_t *proc_ptr, struct pt_regs =
*regs)
+static void
+fetch_min_state (pal_min_state_area_t *ms, struct pt_regs *pt, struct swit=
ch_stack *sw)
 {
+	u64 *dst_banked, *src_banked, bit, shift, nat_bits;
+	int i;
+
+	/*
+	 * First, update the pt-regs and switch-stack structures with the content=
s stored
+	 * in the min-state area:
+	 */
+	if (((struct ia64_psr *) &ms->pmsa_ipsr)->ic =3D 0) {
+		pt->cr_ipsr =3D ms->pmsa_xpsr;
+		pt->cr_iip =3D ms->pmsa_xip;
+		pt->cr_ifs =3D ms->pmsa_xfs;
+	} else {
+		pt->cr_ipsr =3D ms->pmsa_ipsr;
+		pt->cr_iip =3D ms->pmsa_iip;
+		pt->cr_ifs =3D ms->pmsa_ifs;
+	}
+	pt->ar_rsc =3D ms->pmsa_rsc;
+	pt->pr =3D ms->pmsa_pr;
+	pt->r1 =3D ms->pmsa_gr[0];
+	pt->r2 =3D ms->pmsa_gr[1];
+	pt->r3 =3D ms->pmsa_gr[2];
+	sw->r4 =3D ms->pmsa_gr[3];
+	sw->r5 =3D ms->pmsa_gr[4];
+	sw->r6 =3D ms->pmsa_gr[5];
+	sw->r7 =3D ms->pmsa_gr[6];
+	pt->r8 =3D ms->pmsa_gr[7];
+	pt->r9 =3D ms->pmsa_gr[8];
+	pt->r10 =3D ms->pmsa_gr[9];
+	pt->r11 =3D ms->pmsa_gr[10];
+	pt->r12 =3D ms->pmsa_gr[11];
+	pt->r13 =3D ms->pmsa_gr[12];
+	pt->r14 =3D ms->pmsa_gr[13];
+	pt->r15 =3D ms->pmsa_gr[14];
+	dst_banked =3D &pt->r16;		/* r16-r31 are contiguous in struct pt_regs */
+	src_banked =3D ms->pmsa_bank1_gr;
+	for (i =3D 0; i < 16; ++i)
+		*dst_banked =3D *src_banked;
+	pt->b0 =3D ms->pmsa_br0;
+	sw->b1 =3D ms->pmsa_br1;
+
+	/* construct the NaT bits for the pt-regs structure: */
+#	define PUT_NAT_BIT(dst, addr)					\
+	do {								\
+		bit =3D nat_bits & 1; nat_bits >>=3D 1;			\
+		shift =3D ((unsigned long) addr >> 3) & 0x3f;		\
+		dst =3D ((dst) & ~(1UL << shift)) | (bit << shift);	\
+	} while (0)
+
+	/* Rotate the saved NaT bits such that bit 0 corresponds to pmsa_gr[0]: */
+	shift =3D ((unsigned long) &ms->pmsa_gr[0] >> 3) & 0x3f;
+	nat_bits =3D (ms->pmsa_nat_bits >> shift) | (ms->pmsa_nat_bits << (64 - s=
hift));
+
+	PUT_NAT_BIT(sw->caller_unat, &pt->r1);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r2);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r3);
+	PUT_NAT_BIT(sw->ar_unat, &sw->r4);
+	PUT_NAT_BIT(sw->ar_unat, &sw->r5);
+	PUT_NAT_BIT(sw->ar_unat, &sw->r6);
+	PUT_NAT_BIT(sw->ar_unat, &sw->r7);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r8);	PUT_NAT_BIT(sw->caller_unat, &pt->=
r9);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r10);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r11);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r12);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r13);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r14);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r15);
+	nat_bits >>=3D 16;	/* skip over bank0 NaT bits */
+	PUT_NAT_BIT(sw->caller_unat, &pt->r16);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r17);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r18);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r19);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r20);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r21);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r22);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r23);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r24);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r25);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r26);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r27);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r28);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r29);
+	PUT_NAT_BIT(sw->caller_unat, &pt->r30);	PUT_NAT_BIT(sw->caller_unat, &pt-=
>r31);
+}
+
+void
+init_handler_platform (sal_log_processor_info_t *proc_ptr,
+		       struct pt_regs *pt, struct switch_stack *sw)
+{
+	unsigned long ip, sp, bsp;
+	struct unw_frame_info info;
+	char buf[80];
+
 	/* if a kernel debugger is available call it here else just dump the regi=
sters */
=20
 	/*
@@ -262,6 +336,23 @@
 	udelay(5*1000000);
 	show_min_state(&SAL_LPI_PSI_INFO(proc_ptr)->min_state_area);
=20
+	fetch_min_state(&SAL_LPI_PSI_INFO(proc_ptr)->min_state_area, pt, sw);
+
+	printk("\nCall Trace:\n");
+	unw_init_from_interruption(&info, current, pt, sw);
+	do {
+		unw_get_ip(&info, &ip);
+		if (ip =3D 0)
+			break;
+
+		unw_get_sp(&info, &sp);
+		unw_get_bsp(&info, &bsp);
+		snprintf(buf, sizeof(buf), " [<%016lx>] %%s\n\t\tsp=3D%016lx bsp=3D%016l=
x\n",
+			 ip, sp, bsp);
+		print_symbol(buf, ip);
+	} while (unw_unwind(&info) >=3D 0);
+
+	printk("\nINIT dump complete.  Please reboot now.\n");
 	while (1);			/* hang city if no debugger */
 }
=20
@@ -1133,7 +1224,7 @@
  *
  */
 void
-ia64_init_handler (struct pt_regs *regs)
+ia64_init_handler (struct pt_regs *pt, struct switch_stack *sw)
 {
 	sal_log_processor_info_t *proc_ptr;
 	ia64_err_rec_t *plog_ptr;
@@ -1160,7 +1251,7 @@
 	/* Clear the INIT SAL logs now that they have been saved in the OS buffer=
 */
 	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
=20
-	init_handler_platform(proc_ptr, regs);		/* call platform specific routine=
s */
+	init_handler_platform(proc_ptr, pt, sw);	/* call platform specific routin=
es */
 }
=20
 /*
@@ -2210,7 +2301,8 @@
 	switch(sal_info_type) {
 	      case SAL_INFO_TYPE_MCA:
 		prfunc("+BEGIN HARDWARE ERROR STATE AT MCA\n");
-		platform_err =3D ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_i=
nfo_type), prfunc);
+		platform_err =3D ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_i=
nfo_type),
+							    prfunc);
 		prfunc("+END HARDWARE ERROR STATE AT MCA\n");
 		break;
 	      case SAL_INFO_TYPE_INIT:
=3D=3D=3D arch/ia64/kernel/mca_asm.S 1.7 vs edited =3D=3D--- 1.7/arch/ia64/=
kernel/mca_asm.S	Fri Apr 11 18:18:35 2003
+++ edited/arch/ia64/kernel/mca_asm.S	Mon Apr 14 13:51:58 2003
@@ -796,10 +796,12 @@
 	//
 	// Let's call the C handler to get the rest of the state info
 	//
-	alloc r14=3Dar.pfs,0,0,1,0		// now it's safe (must be first in insn group=
!)
-	;;					//
+	alloc r14=3Dar.pfs,0,0,2,0		// now it's safe (must be first in insn group=
!)
+	;;
 	adds out0=16,sp				// out0 =3D pointer to pt_regs
 	;;
+	DO_SAVE_SWITCH_STACK
+	adds out1=16,sp				// out0 =3D pointer to switch_stack
=20
 	br.call.sptk.many rp=3Dia64_init_handler
 .ret1:
=3D=3D=3D arch/ia64/kernel/process.c 1.31 vs edited =3D=3D--- 1.31/arch/ia6=
4/kernel/process.c	Fri Apr 11 18:18:35 2003
+++ edited/arch/ia64/kernel/process.c	Tue Apr 15 11:58:36 2003
@@ -57,7 +57,7 @@
=20
 		unw_get_sp(info, &sp);
 		unw_get_bsp(info, &bsp);
-		snprintf(buf, sizeof(buf), " [<%016lx>] %%s sp=3D0x%016lx bsp=3D0x%016lx=
\n",
+		snprintf(buf, sizeof(buf), " [<%016lx>] %%s\n\t\tsp=3D%016lx bsp=3D%016l=
x\n",
 			 ip, sp, bsp);
 		print_symbol(buf, ip);
 	} while (unw_unwind(info) >=3D 0);
=3D=3D=3D arch/ia64/kernel/unwind.c 1.19 vs edited =3D=3D--- 1.19/arch/ia64=
/kernel/unwind.c	Tue Mar 25 04:49:15 2003
+++ edited/arch/ia64/kernel/unwind.c	Tue Apr 15 11:40:31 2003
@@ -1888,22 +1888,21 @@
 	return -1;
 }
=20
-void
-unw_init_frame_info (struct unw_frame_info *info, struct task_struct *t, s=
truct switch_stack *sw)
+static void
+init_frame_info (struct unw_frame_info *info, struct task_struct *t,
+		 struct switch_stack *sw, unsigned long stktop)
 {
-	unsigned long rbslimit, rbstop, stklimit, stktop, sol;
+	unsigned long rbslimit, rbstop, stklimit;
 	STAT(unsigned long start, flags;)
=20
 	STAT(local_irq_save(flags); ++unw.stat.api.inits; start =3D ia64_get_itc(=
));
=20
 	/*
-	 * Subtle stuff here: we _could_ unwind through the
-	 * switch_stack frame but we don't want to do that because it
-	 * would be slow as each preserved register would have to be
-	 * processed.  Instead, what we do here is zero out the frame
-	 * info and start the unwind process at the function that
-	 * created the switch_stack frame.  When a preserved value in
-	 * switch_stack needs to be accessed, run_script() will
+	 * Subtle stuff here: we _could_ unwind through the switch_stack frame bu=
t we
+	 * don't want to do that because it would be slow as each preserved regis=
ter would
+	 * have to be processed.  Instead, what we do here is zero out the frame =
info and
+	 * start the unwind process at the function that created the switch_stack=
 frame.
+	 * When a preserved value in switch_stack needs to be accessed, run_scrip=
t() will
 	 * initialize the appropriate pointer on demand.
 	 */
 	memset(info, 0, sizeof(*info));
@@ -1914,7 +1913,6 @@
 		rbstop =3D rbslimit;
=20
 	stklimit =3D (unsigned long) t + IA64_STK_OFFSET;
-	stktop   =3D (unsigned long) sw - 16;
 	if (stktop <=3D rbstop)
 		stktop =3D rbstop;
=20
@@ -1924,34 +1922,56 @@
 	info->memstk.top   =3D stktop;
 	info->task =3D t;
 	info->sw  =3D sw;
-	info->sp =3D info->psp =3D (unsigned long) (sw + 1) - 16;
-	info->pt =3D 0;
+	info->sp =3D info->psp =3D stktop;
+	info->pr =3D sw->pr;
+	UNW_DPRINT(3, "unwind.%s:\n"
+		   "  task   0x%lx\n"
+		   "  rbs =3D [0x%lx-0x%lx)\n"
+		   "  stk =3D [0x%lx-0x%lx)\n"
+		   "  pr     0x%lx\n"
+		   "  sw     0x%lx\n"
+		   "  sp     0x%lx\n",
+		   __FUNCTION__, (unsigned long) task, rbslimit, rbstop, stktop, stklimi=
t,
+		   info->pr, (unsigned long) info->sw, info->sp);
+	STAT(unw.stat.api.init_time +=3D ia64_get_itc() - start; local_irq_restor=
e(flags));
+}
+
+void
+unw_init_from_interruption (struct unw_frame_info *info, struct task_struc=
t *t,
+			    struct pt_regs *pt, struct switch_stack *sw)
+{
+	unsigned long sof;
+
+	init_frame_info(info, t, sw, pt->r12);
+	info->cfm_loc =3D &pt->cr_ifs;
+	sof =3D *info->cfm_loc & 0x7f;
+	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
regstk.top, -sof);
+	info->ip =3D pt->cr_iip + ia64_psr(pt)->ri;
+	info->pt =3D (unsigned long) pt;
+	UNW_DPRINT(3, "unwind.%s:\n"
+		   "  bsp    0x%lx\n"
+		   "  sof    0x%lx\n"
+		   "  ip     0x%lx\n",
+		   info->bsp, sof, info->ip);
+	find_save_locs(info);
+}
+
+void
+unw_init_frame_info (struct unw_frame_info *info, struct task_struct *t, s=
truct switch_stack *sw)
+{
+	unsigned long sol;
+
+	init_frame_info(info, t, sw, (unsigned long) (sw + 1) - 16);
 	info->cfm_loc =3D &sw->ar_pfs;
 	sol =3D (*info->cfm_loc >> 7) & 0x7f;
 	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
regstk.top, -sol);
 	info->ip =3D sw->b0;
-	info->pr =3D sw->pr;
-	UNW_DPRINT(3,
-			"unwind.%s\n"
-			"  rbslimit 0x%lx\n"
-			"  rbstop   0x%lx\n"
-			"  stklimit 0x%lx\n"
-			"  stktop   0x%lx\n"
-			"  task     0x%lx\n"
-			"  sw       0x%lx\n",
-			__FUNCTION__, rbslimit, rbstop, stklimit, stktop,
-			(unsigned long)(info->task),
-			(unsigned long)(info->sw));
-	UNW_DPRINT(3,
-			"  sp/psp   0x%lx\n"
-			"  sol      0x%lx\n"
-			"  bsp      0x%lx\n"
-			"  ip       0x%lx\n"
-			"  pr       0x%lx\n",
-			info->sp, sol, info->bsp, info->ip, info->pr);
-
+	UNW_DPRINT(3, "unwind.%s:\n"
+		   "  bsp    0x%lx\n"
+		   "  sol    0x%lx\n"
+		   "  ip     0x%lx\n",
+		   info->bsp, sol, info->ip);
 	find_save_locs(info);
-	STAT(unw.stat.api.init_time +=3D ia64_get_itc() - start; local_irq_restor=
e(flags));
 }
=20
 void
=3D=3D=3D include/asm-ia64/unwind.h 1.4 vs edited =3D=3D--- 1.4/include/asm=
-ia64/unwind.h	Mon Mar  3 16:00:00 2003
+++ edited/include/asm-ia64/unwind.h	Tue Apr 15 11:12:37 2003
@@ -2,8 +2,8 @@
 #define _ASM_IA64_UNWIND_H
=20
 /*
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2000, 2003 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * A simple API for unwinding kernel stacks.  This is used for
  * debugging and error reporting purposes.  The kernel doesn't need
@@ -106,6 +106,13 @@
  * Prepare to unwind blocked task t.
  */
 extern void unw_init_from_blocked_task (struct unw_frame_info *info, struc=
t task_struct *t);
+
+/*
+ * Prepare to unwind from interruption.  The pt-regs and switch-stack stru=
ctures must have
+ * be "adjacent" (no state modifications between pt-regs and switch-stack).
+ */
+extern void unw_init_from_interruption (struct unw_frame_info *info, struc=
t task_struct *t,
+					struct pt_regs *pt, struct switch_stack *sw);
=20
 extern void unw_init_frame_info (struct unw_frame_info *info, struct task_=
struct *t,
 				 struct switch_stack *sw);

