From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 20 Dec 2007 16:11:22 +0000
Subject: [PATCH 2/2] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <476A942A.5000601@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is a new trick.

Labeling previous implementation (assume system applied [1/2] only) as V.1,
it does:

  - At exit of kernel (ia64_leave_kernel), calculate cycles from last
    check point using last stamp (ac_stamp), then accumulate the cycle
    as "system's cycles" (ac_stime) and updates the stamp.
  - At entrance of kernel (break_fault etc.), calculate cycles from last
    check point using last stamp,  then accumulate the cycle as "user's
    cycles" (ac_utime) and updates the stamp.

It takes times from both of kernel entrance path and exit path, so it
results in considerable increase of system call overhead, unfortunately.

This 2 of 2 is magical patch to reduce the overhead.
Labeling new implementation (assume system applied [1/2] and [2/2]) as V.2,
it does:

  - At exit of kernel (ia64_leave_kernel), do nothing but only save the
    "leave time" as ac_leave separated from usual time stamp (ac_stamp).
  - At entrance of kernel (break_fault etc.):
     1. calculate cycles from last check point (in kernel) to "last leave"
        using ac_stamp and ac_leave, then accumulate the cycle to ac_stime.
     2. calculate cycles from "last leave" to now, then accumulate the
        cycle to ac_utime.
     3. updates the stamp (ac_stamp).

It can be said that this patch combines most part of separated jobs and
moves it to entrance side. The change is simple, however:

  - Exit path becomes quite simple. Only needed is posting value of ITC
    to memory. There were few registers and slots in bundles available
    for extra work, but fortunately I made it without increasing the
    number of bundles ;-)
  - Entry path becomes slightly complicated. But we can load/store data
    at once, and do not need to do it at both of exit/entrance anymore.

Following result of benchmark shows the performance impact of my patches.
(V.1 =3D 2.6.24-rc5 + [1/2],  V.2 =3D rc5 + [1/2] + [2/2],  orig. =3D rc5)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D                                INDEX V=
ALUES            RATIO(%)
TEST (Unixbench-v4.1.0)          V.1     V.2    orig.    V.1    V.2   orig.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D  =3D=3D=3D  =3D=
=3D=3D  =3D=3D=3D  =3D=3D=3D  =3D=3DDhrystone 2 using register var.  304.3 =
  304.3   304.4  100.0  100.0  100.0
Double-Precision Whetstone       171.3   171.3   171.1  100.1  100.1  100.0
Execl Throughput                 471.3   466.2   467.3  100.9   99.8  100.0
File Copy 1024 buf 2000 maxblks  496.6   511.1   507.1   97.9  100.8  100.0
File Copy 256 buf 500 maxblks    352.4   355.3   366.2   96.2   97.0  100.0
File Copy 4096 buf 8000 maxblks  765.8   768.6   778.1   98.4   98.8  100.0
Pipe Throughput                  422.0   427.0   416.1  101.4  102.6  100.0
Process Creation                 945.1   949.3   948.0   99.7  100.1  100.0
Shell Scripts (8 concurrent)    1646.7  1646.2  1654.5   99.5   99.5  100.0
System Call Overhead             695.4   732.1   820.0   84.8   89.3  100.0
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D  =3D=3D=3D  =3D=
=3D=3D  =3D=3D=3D  =3D=3D=3D  =3D=3DFINAL SCORE                      522.0 =
  527.1   533.9   97.8   98.7  100.0
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D(@ Madison 1.5GHz x 4)

Most affected is undoubtedly system call, which is originally well optimize=
d.
But from macro-viewpoint, unless you are a full-time-system-call-aholic, I
believe it's worthwhile to make a concession.

The faster hardware goes (or even the more active software becomes), the
more accuracy of traditional tick-sampling based CPU time accounting drops.
When would be the decision point?

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/asm-offsets.c |    1
 arch/ia64/kernel/entry.S       |   87 ++++++++++++++++++++++++++++++------=
-----
 arch/ia64/kernel/fsys.S        |   20 ++++++---
 arch/ia64/kernel/ivt.S         |   42 ++++++++++++-------
 include/asm-ia64/thread_info.h |    1
 5 files changed, 107 insertions(+), 44 deletions(-)

Index: linux-2.6.24-rc5/arch/ia64/kernel/asm-offsets.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24-rc5.orig/arch/ia64/kernel/asm-offs=
ets.c
+++ linux-2.6.24-rc5/arch/ia64/kernel/asm-offsets.c
@@ -41,6 +41,7 @@
 	DEFINE(TI_PRE_COUNT, offsetof(struct thread_info, preempt_count));
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	DEFINE(TI_AC_STAMP, offsetof(struct thread_info, ac_stamp));
+	DEFINE(TI_AC_LEAVE, offsetof(struct thread_info, ac_leave));
 	DEFINE(TI_AC_STIME, offsetof(struct thread_info, ac_stime));
 	DEFINE(TI_AC_UTIME, offsetof(struct thread_info, ac_utime));
 #endif
Index: linux-2.6.24-rc5/arch/ia64/kernel/entry.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24-rc5.orig/arch/ia64/kernel/entry.S
+++ linux-2.6.24-rc5/arch/ia64/kernel/entry.S
@@ -710,6 +710,16 @@
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
 .work_processed_syscall:
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	adds r2=3DPT(LOADRS)+16,r12
+(pUStk)	mov.m r22=3Dar.itc			// fetch time at leave
+	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
+	;;
+(p6)	ld4 r31=3D[r18]				// load current_thread_info()->flags
+	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
+	adds r3=3DPT(AR_BSPSTORE)+16,r12		// deferred
+	;;
+#else
 	adds r2=3DPT(LOADRS)+16,r12
 	adds r3=3DPT(AR_BSPSTORE)+16,r12
 	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
@@ -718,6 +728,7 @@
 	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
 	nop.i 0
 	;;
+#endif
 	mov r16=3Dar.bsp				// M2  get existing backing store pointer
 	ld8 r18=3D[r2],PT(R9)-PT(B6)		// load b6
 (p6)	and r15=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
@@ -737,12 +748,21 @@

 	ld8 r29=3D[r2],16		// M0|1 load cr.ipsr
 	ld8 r28=3D[r3],16		// M0|1 load cr.iip
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk) add r14=3DTI_AC_LEAVE+IA64_TASK_SIZE,r13
+	;;
+	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
+	ld8 r25=3D[r3],16		// M0|1 load ar.unat
+(pUStk) add r15=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	;;
+#else
 	mov r22=3Dr0		// A    clear r22
 	;;
 	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
 	ld8 r25=3D[r3],16		// M0|1 load ar.unat
 (pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
+#endif
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
 (pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts are disabled
 	nop 0
@@ -759,7 +779,11 @@
 	ld8.fill r1=3D[r3],16			// M0|1 load r1
 (pUStk) mov r17=3D1				// A
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk) st1 [r15]=3Dr17				// M2|3
+#else
 (pUStk) st1 [r14]=3Dr17				// M2|3
+#endif
 	ld8.fill r13=3D[r3],16			// M0|1
 	mov f8=F0				// F    clear f8
 	;;
@@ -775,12 +799,22 @@
 	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
 	cover				// B    add current frame into dirty partition & set cr.ifs
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	mov r19=3Dar.bsp			// M2   get new backing store pointer
+	st8 [r14]=3Dr22			// M	save time at leave
+	mov f10=F0			// F    clear f10
+
+	mov r22=3Dr0			// A	clear r22
+	movl r14=3D__kernel_syscall_via_epc // X
+	;;
+#else
 	mov r19=3Dar.bsp			// M2   get new backing store pointer
 	mov f10=F0			// F    clear f10

 	nop.m 0
 	movl r14=3D__kernel_syscall_via_epc // X
 	;;
+#endif
 	mov.m ar.csd=3Dr0			// M2   clear ar.csd
 	mov.m ar.ccv=3Dr0			// M2   clear ar.ccv
 	mov b7=3Dr14			// I0   clear b7 (hint with __kernel_syscall_via_epc)
@@ -913,10 +947,18 @@
 	adds r16=3DPT(CR_IPSR)+16,r12
 	adds r17=3DPT(CR_IIP)+16,r12

+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	.pred.rel.mutex pUStk,pKStk
+(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+(pUStk)	mov.m r22=3Dar.itc	// M  fetch time at leave
+	nop.i 0
+	;;
+#else
 (pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
 	nop.i 0
 	nop.i 0
 	;;
+#endif
 	ld8 r29=3D[r16],16	// load cr.ipsr
 	ld8 r28=3D[r17],16	// load cr.iip
 	;;
@@ -938,15 +980,37 @@
 	;;
 	ld8.fill r12=3D[r16],16
 	ld8.fill r13=3D[r17],16
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk)	adds r3=3DTI_AC_LEAVE+IA64_TASK_SIZE,r18
+#else
 (pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18
+#endif
 	;;
 	ld8 r20=3D[r16],16	// ar.fpsr
 	ld8.fill r15=3D[r17],16
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+(pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18	// deferred
+#endif
 	;;
 	ld8.fill r14=3D[r16],16
 	ld8.fill r2=3D[r17]
 (pUStk)	mov r17=3D1
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+	//  mmi_ :  ld8 st1 shr;;         mmi_ : st8 st1 shr;;
+	//  mib  :  mov add br        ->  mib  : ld8 add br
+	//  bbb_ :  br  nop cover;;       mbb_ : mov br  cover;;
+	//
+	//  no one require bsp in r16 if (pKStk) branch is selected.
+(pUStk)	st8 [r3]=3Dr22		// save time at leave
+(pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
+	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
+	;;
+	ld8.fill r3=3D[r16]	// deferred
+	LOAD_PHYS_STACK_REG_SIZE(r17)
+(pKStk)	br.cond.dpnt skip_rbs_switch
+	mov r16=3Dar.bsp		// get existing backing store pointer
+#else
 	ld8.fill r3=3D[r16]
 (pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
@@ -954,6 +1018,7 @@
 	mov r16=3Dar.bsp		// get existing backing store pointer
 	LOAD_PHYS_STACK_REG_SIZE(r17)
 (pKStk)	br.cond.dpnt skip_rbs_switch
+#endif

 	/*
 	 * Restore user backing store.
@@ -995,28 +1060,6 @@
 	shladd in0=3Dloc1,3,r17
 	mov in1=3D0
 	;;
-#ifdef CONFIG_VIRT_CPU_ACCOUNTING
-account_sys_leave:
-	// The size of current frame
-	//	(in * 2 + loc * N (N =3D 8 or 12) + out * 2)
-	// is enough to work, so just take care to keep in0,in1
-	mov loc0=3Dar.itc
-	mov loc1=3DIA64_KR(CURRENT)	// M2 (12 cycle read latency)
-	;;
-	add loc2=3DTI_AC_STAMP+IA64_TASK_SIZE,loc1
-	add loc3=3DTI_AC_STIME+IA64_TASK_SIZE,loc1
-	;;
-	ld8 loc4=3D[loc2]			// get last stamp
-	ld8 loc5=3D[loc3]			// cumulated stime
-	;;
-	sub loc4=3Dloc0,loc4		// elapsed time
-	;;
-	add loc5=3Dloc5,loc4		// sum
-	;;
-	st8 [loc2]=3Dloc0			// update stamp
-	st8 [loc3]=3Dloc5			// update stime
-	;;
-#endif
 	TEXT_ALIGN(32)
 rse_clear_invalid:
 #ifdef CONFIG_ITANIUM
Index: linux-2.6.24-rc5/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24-rc5.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.24-rc5/arch/ia64/kernel/fsys.S
@@ -689,17 +689,23 @@
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	// mov.m r30=3Dar.itc is called in advance
 	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r2
-	add r17=3DTI_AC_UTIME+IA64_TASK_SIZE,r2
+	add r17=3DTI_AC_LEAVE+IA64_TASK_SIZE,r2
 	;;
-	ld8 r18=3D[r16]			// get last stamp
-	ld8 r19=3D[r17]			// cumulated utime
+	ld8 r18=3D[r16],TI_AC_STIME-TI_AC_STAMP	// time at last check in kernel
+	ld8 r19=3D[r17],TI_AC_UTIME-TI_AC_LEAVE	// time at leave kernel
 	;;
-	sub r18=3Dr30,r18			// elapsed time
+	ld8 r20=3D[r16],TI_AC_STAMP-TI_AC_STIME	// cumulated stime
+	ld8 r21=3D[r17]				// cumulated utime
+	sub r22=3Dr19,r18				// stime before leave kernel
 	;;
-	add r19=3Dr19,r18			// sum
+	st8 [r16]=3Dr30,TI_AC_STIME-TI_AC_STAMP	// update stamp
+	sub r18=3Dr30,r19				// elapsed time in user mode
 	;;
-	st8 [r16]=3Dr30			// update stamp
-	st8 [r17]=3Dr19			// update utime
+	add r20=3Dr20,r22				// sum stime
+	add r21=3Dr21,r18				// sum utime
+	;;
+	st8 [r16]=3Dr20				// update stime
+	st8 [r17]=3Dr21				// update utime
 	;;
 #endif
 	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
Index: linux-2.6.24-rc5/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24-rc5.orig/arch/ia64/kernel/ivt.S
+++ linux-2.6.24-rc5/arch/ia64/kernel/ivt.S
@@ -841,18 +841,24 @@
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	// mov.m r30=3Dar.itc is called in advance, and r13 is current
 	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r13	// A
-	add r17=3DTI_AC_UTIME+IA64_TASK_SIZE,r13	// A
+	add r17=3DTI_AC_LEAVE+IA64_TASK_SIZE,r13	// A
 (pKStk)	br.cond.spnt .skip_accounting		// B	unlikely skip
 	;;
-	ld8 r18=3D[r16]			// M  get last stamp
-	ld8 r19=3D[r17]			// M  cumulated utime
+	ld8 r18=3D[r16],TI_AC_STIME-TI_AC_STAMP	// M  get last stamp
+	ld8 r19=3D[r17],TI_AC_UTIME-TI_AC_LEAVE	// M  time at leave
 	;;
-	sub r18=3Dr30,r18			// A  elapsed time
+	ld8 r20=3D[r16],TI_AC_STAMP-TI_AC_STIME	// M  cumulated stime
+	ld8 r21=3D[r17]				// M  cumulated utime
+	sub r22=3Dr19,r18				// A  stime before leave
 	;;
-	add r19=3Dr19,r18			// A  sum
+	st8 [r16]=3Dr30,TI_AC_STIME-TI_AC_STAMP	// M  update stamp
+	sub r18=3Dr30,r19				// A  elapsed time in user
 	;;
-	st8 [r16]=3Dr30			// M  update stamp
-	st8 [r17]=3Dr19			// M  update utime
+	add r20=3Dr20,r22				// A  sum stime
+	add r21=3Dr21,r18				// A  sum utime
+	;;
+	st8 [r16]=3Dr20				// M  update stime
+	st8 [r17]=3Dr21				// M  update utime
 	;;
 .skip_accounting:
 #endif
@@ -1131,18 +1137,24 @@
 ENTRY(account_sys_enter)
 	// mov.m r20=3Dar.itc is called in advance, and r13 is current
 	add r16=3DTI_AC_STAMP+IA64_TASK_SIZE,r13
-	add r17=3DTI_AC_UTIME+IA64_TASK_SIZE,r13
+	add r17=3DTI_AC_LEAVE+IA64_TASK_SIZE,r13
+	;;
+	ld8 r18=3D[r16],TI_AC_STIME-TI_AC_STAMP	// time at last check in kernel
+	ld8 r19=3D[r17],TI_AC_UTIME-TI_AC_LEAVE	// time at left from kernel
+        ;;
+	ld8 r23=3D[r16],TI_AC_STAMP-TI_AC_STIME	// cumulated stime
+	ld8 r21=3D[r17]				// cumulated utime
+	sub r22=3Dr19,r18				// stime before leave kernel
 	;;
-	ld8 r18=3D[r16]			// get last stamp
-	ld8 r19=3D[r17]			// cumulated utime
+	st8 [r16]=3Dr20,TI_AC_STIME-TI_AC_STAMP	// update stamp
+	sub r18=3Dr20,r19				// elapsed time in user mode
 	;;
-	sub r18=3Dr20,r18			// elapsed time
+	add r23=3Dr23,r22				// sum stime
+	add r21=3Dr21,r18				// sum utime
 	;;
-	add r19=3Dr19,r18			// sum
+	st8 [r16]=3Dr23				// update stime
+	st8 [r17]=3Dr21				// update utime
 	;;
-	st8 [r16]=3Dr20			// update stamp
-	st8 [r17]=3Dr19			// update utime
-        ;;
 	br.ret.sptk.many rp
 END(account_sys_enter)
 #endif
Index: linux-2.6.24-rc5/include/asm-ia64/thread_info.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.24-rc5.orig/include/asm-ia64/thread_i=
nfo.h
+++ linux-2.6.24-rc5/include/asm-ia64/thread_info.h
@@ -33,6 +33,7 @@
 	struct restart_block restart_block;
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	__u64 ac_stamp;
+	__u64 ac_leave;
 	__u64 ac_stime;
 	__u64 ac_utime;
 #endif


