From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Mar 2003 10:19:37 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806055@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, 11 Mar 2003 17:59:56 -0800,=20
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>Seriously though: I think the main problem is trying to do branch to
>out-of-line code without the compiler knowing about it.  The main
>reason I wanted to do that is to avoid turning leaf routines into
>interior routines just because of a spinlock acquisition.

This patch against 2.4.20-ia64-021220 has had minimal testing, it works
for me (TM).  kdb and lkcd diagnosis of hung cpus is much easier with
the patch.

The inline code for an uncontended lock drops from 5 to 4 bundles for
each use of spin_lock().  The uncontended path has one less memory
access.

ia64_spinlock_contention in head.S is the basic framework for the out
of line contention code, it can be expanded for exponential backoff,
kdb, lock monitoring, detection of hung locks, whatever we want.
Calling another function from the contention path is possible, but
tricky.

This code works for spin_lock() in built in code and for modules.  It
does not affect the status of leaf functions, no change to ar.pfs or b0.

Index: 20.5/include/asm-ia64/spinlock.h
--- 20.5/include/asm-ia64/spinlock.h Fri, 01 Mar 2002 11:01:28 +1100 kaos (=
linux-2.4/s/28_spinlock.h 1.1.3.1.1.1.2.1 644)
+++ 20.5(w)/include/asm-ia64/spinlock.h Wed, 12 Mar 2003 17:33:55 +1100 kao=
s (linux-2.4/s/28_spinlock.h 1.1.3.1.1.1.2.1 644)
@@ -15,10 +15,6 @@
 #include <asm/bitops.h>
 #include <asm/atomic.h>
=20
-#undef NEW_LOCK
-
-#ifdef NEW_LOCK
-
 typedef struct {
 	volatile unsigned int lock;
 } spinlock_t;
@@ -27,81 +23,48 @@ typedef struct {
 #define spin_lock_init(x)			((x)->lock =3D 0)
=20
 /*
- * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
- * rather than a simple xchg to avoid writing the cache-line when
- * there is contention.
+ * Try to get the lock.  If we fail to get the lock, branch (not call) to
+ * ia64_spinlock_contention.  We do not use call because that stamps on ar=
.pfs
+ * which has unwanted side effects on the routine using spin_lock().
+ *
+ * ia64_spinlock_contention is entered with :-
+ *   r27 - available for use.
+ *   r28 - address of start of spin_lock code.  Used as a "return" address
+ *         from the contention path.  mov r28=3Dip must be in the first bu=
ndle.
+ *   r29 - available for use.
+ *   r30 - available for use.
+ *   r31 - address of lock.
+ *   b7  - available for use.
+ *   p15 - available for use.
  */
-#define spin_lock(x)									\
-{											\
+#define spin_lock(x) 									\
+({											\
 	register char *addr __asm__ ("r31") =3D (char *) &(x)->lock;			\
 											\
 	__asm__ __volatile__ (								\
-		"mov r30=3D1\n"								\
+		"1:\n"		/* force a new bundle, r28 points here */		\
 		"mov ar.ccv=3Dr0\n"							\
+		"mov r28=3Dip\n"								\
+		"mov r30=3D1\n"								\
 		";;\n"									\
 		"cmpxchg4.acq r30=3D[%0],r30,ar.ccv\n"					\
+		"movl r29=3Dia64_spinlock_contention\n"					\
 		";;\n"									\
 		"cmp.ne p15,p0=3Dr30,r0\n"						\
-		"(p15) br.call.spnt.few b7=3Dia64_spinlock_contention\n"			\
+		"mov b7=3Dr29\n"								\
 		";;\n"									\
-		"1:\n"				/* force a new bundle */		\
-		:: "r"(addr)								\
-		: "ar.ccv", "ar.pfs", "b7", "p15", "r28", "r29", "r30", "memory");	\
-}
-
-#define spin_trylock(x)									\
-({											\
-	register long result;								\
-											\
-	__asm__ __volatile__ (								\
-		"mov ar.ccv=3Dr0\n"							\
+		"(p15) br.cond.spnt.few b7\n"						\
 		";;\n"									\
-		"cmpxchg4.acq %0=3D[%2],%1,ar.ccv\n"					\
-		: "=3Dr"(result) : "r"(1), "r"(&(x)->lock) : "ar.ccv", "memory");		\
-	(result =3D 0);									\
+		"2:\n"		/* force a new bundle */				\
+		:: "r"(addr)								\
+		: "ar.ccv", "r28", "r29", "r30", "b7", "p15", "memory");		\
 })
=20
 #define spin_is_locked(x)	((x)->lock !=3D 0)
-#define spin_unlock(x)		do { barrier(); ((spinlock_t *) x)->lock =3D 0;} w=
hile (0)
-#define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)
-
-#else /* !NEW_LOCK */
-
-typedef struct {
-	volatile unsigned int lock;
-} spinlock_t;
-
-#define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
-#define spin_lock_init(x)			((x)->lock =3D 0)
-
-/*
- * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
- * rather than a simple xchg to avoid writing the cache-line when
- * there is contention.
- */
-#define spin_lock(x) __asm__ __volatile__ (			\
-	"mov ar.ccv =3D r0\n"					\
-	"mov r29 =3D 1\n"						\
-	";;\n"							\
-	"1:\n"							\
-	"ld4 r2 =3D [%0]\n"					\
-	";;\n"							\
-	"cmp4.eq p0,p7 =3D r0,r2\n"				\
-	"(p7) br.cond.spnt.few 1b \n"				\
-	"cmpxchg4.acq r2 =3D [%0], r29, ar.ccv\n"			\
-	";;\n"							\
-	"cmp4.eq p0,p7 =3D r0, r2\n"				\
-	"(p7) br.cond.spnt.few 1b\n"				\
-	";;\n"							\
-	:: "r"(&(x)->lock) : "ar.ccv", "p7", "r2", "r29", "memory")
-
-#define spin_is_locked(x)	((x)->lock !=3D 0)
 #define spin_unlock(x)		do { barrier(); ((spinlock_t *) x)->lock =3D 0; } =
while (0)
 #define spin_trylock(x)		(cmpxchg_acq(&(x)->lock, 0, 1) =3D 0)
 #define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)
=20
-#endif /* !NEW_LOCK */
-
 typedef struct {
 	volatile int read_counter:31;
 	volatile int write_lock:1;
Index: 20.5/arch/ia64/kernel/ia64_ksyms.c
--- 20.5/arch/ia64/kernel/ia64_ksyms.c Wed, 11 Dec 2002 20:58:53 +1100 kaos=
 (linux-2.4/r/c/35_ia64_ksyms 1.1.3.1.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/ia64_ksyms.c Wed, 12 Mar 2003 17:28:13 +1100 k=
aos (linux-2.4/r/c/35_ia64_ksyms 1.1.3.1.3.1.1.1.1.3 644)
@@ -165,3 +165,9 @@ EXPORT_SYMBOL(machvec_noop);
 EXPORT_SYMBOL(pfm_install_alternate_syswide_subsystem);
 EXPORT_SYMBOL(pfm_remove_alternate_syswide_subsystem);
 #endif
+
+/* Spinlock contention path is entered via direct branch, not using a func=
tion
+ * pointer.  Fudge the declaration so we do not generate a function descri=
ptor.
+ */
+extern char ia64_spinlock_contention[];
+EXPORT_SYMBOL(ia64_spinlock_contention);
Index: 20.5/arch/ia64/kernel/head.S
--- 20.5/arch/ia64/kernel/head.S Wed, 11 Dec 2002 20:58:53 +1100 kaos (linu=
x-2.4/s/c/11_head.S 1.1.4.1.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/head.S Wed, 12 Mar 2003 17:36:46 +1100 kaos (l=
inux-2.4/s/c/11_head.S 1.1.4.1.3.1.1.1.1.3 644)
@@ -742,69 +742,51 @@ SET_REG(b5);
 #ifdef CONFIG_SMP
=20
 	/*
-	 * This routine handles spinlock contention.  It uses a simple exponentia=
l backoff
-	 * algorithm to reduce unnecessary bus traffic.  The initial delay is sel=
ected from
-	 * the low-order bits of the cycle counter (a cheap "randomizer").  I'm s=
ure this
-	 * could use additional tuning, especially on systems with a large number=
 of CPUs.
-	 * Also, I think the maximum delay should be made a function of the numbe=
r of CPUs in
-	 * the system. --davidm 00/08/05
+	 * This routine handles spinlock contention, using non-standard entry
+	 * conventions.  To avoid converting leaf routines into non-leaf, the
+	 * inline spin_lock() code uses br.cond (not br.call) to enter this
+	 * code.  r28 contains the start of the inline spin_lock() code.
 	 *
-	 * WARNING: This is not a normal procedure.  It gets called from C code w=
ithout
-	 * the compiler knowing about it.  Thus, we must not use any scratch regi=
sters
-	 * beyond those that were declared "clobbered" at the call-site (see spin=
_lock()
-	 * macro).  We may not even use the stacked registers, because that could=
 overwrite
-	 * output registers.  Similarly, we can't use the scratch stack area as i=
t may be
-	 * in use, too.
+	 * Do not use gp relative variables, this code is called from the kernel
+	 * and from modules, r1 is undefined.  Do not use stacked registers, the
+	 * caller owns them.  Do not use the scratch stack space, the caller
+	 * owns it.  Do not change ar.pfs, the caller owns it.
 	 *
 	 * Inputs:
-	 *	ar.ccv =3D 0 (and available for use)
-	 *	r28 =3D available for use
-	 *	r29 =3D available for use
-	 *	r30 =3D non-zero (and available for use)
-	 *	r31 =3D address of lock we're trying to acquire
-	 *	p15 =3D available for use
+	 *   ar.ccv - 0 (and available for use)
+	 *   r12    - kernel stack pointer, but see above.
+	 *   r13    - current process.
+	 *   r28    - address of start of spin_lock code.  Used as a "return"
+	 *            address from this contention path.  Available for use
+	 *            after it has been saved.
+	 *   r29    - available for use.  Used to hold dummy ar.pfs to get good
+	 *            unwind data.
+	 *   r30    - available for use.
+	 *   r31    - address of lock.
+	 *   b7     - available for use.
+	 *   p15    - available for use.
+	 *   Rest   - caller's state, do not use, especially ar.pfs.
 	 */
=20
-#	define delay	r28
-#	define timeout	r29
-#	define tmp	r30
-
 GLOBAL_ENTRY(ia64_spinlock_contention)
-	mov tmp=3Dar.itc
-	;;
-	and delay=3D0x3f,tmp
-	;;
-
-.retry:	add timeout=3Dtmp,delay
-	shl delay=DElay,1
-	;;
-	dep delay=DElay,r0,0,13	// limit delay to 8192 cycles
-	;;
-	// delay a little...
-.wait:	sub tmp=3Dtmp,timeout
-	or delay=3D0xf,delay	// make sure delay is non-zero (otherwise we get stu=
ck with 0)
-	;;
-	cmp.lt p15,p0=3Dtmp,r0
-	mov tmp=3Dar.itc
-(p15)	br.cond.sptk .wait
-	;;
-	ld4 tmp=3D[r31]
-	;;
-	cmp.ne p15,p0=3Dtmp,r0
-	mov tmp=3Dar.itc
-(p15)	br.cond.sptk .retry	// lock is still busy
-	;;
-	// try acquiring lock (we know ar.ccv is still zero!):
-	mov tmp=3D1
-	;;
-	cmpxchg4.acq tmp=3D[r31],tmp,ar.ccv
-	;;
-	cmp.eq p15,p0=3Dtmp,r0
-
-	mov tmp=3Dar.itc
-(p15)	br.ret.sptk.many b7	// got lock -> return
-	br .retry		// still no luck, retry
+	// To get decent unwind data, lie about our state
+	.prologue
+	.altrp b7
+	.save ar.pfs, r29
+	mov b7=3Dr28		// my "return" address
+	mov r29=3D0		// dummy ar.pfs, pretend zero frame size
+	;;
+	.body
+.retry:
+	// exponential backoff, kdb, lockmeter etc. go in here
+	//
+	;;
+	ld4 r28=3D[r31]
+	;;
+	cmp4.eq p15,p0=3Dr28,r0
+(p15)	br.cond.spnt.few b7	// lock is now free, try to acquire
+	br.cond.sptk.few .retry
=20
 END(ia64_spinlock_contention)
=20
-#endif
+#endif	// CONFIG_SMP


kdb backtrace from an interrupt while in the contention path.  The
arguments for the first two entries are associated with the wrong label,
apart from that we get a clean backtrace on lock contention, I will
investigate the unwind problem later.  r31 contains the lock address.

Lock acquire has no unwind problems, it is normal inline code.

[6]kdb> bt
Stack traceback for pid 0
0xe0000030071e0000	  0	   0  1	   6   R  0xe0000030071e07d0 *swapper
0xe002000000008f30 ia64_spinlock_contention+0x30
	args (0x0, 0x1, 0x0, 0xe00210000084d500, 0x6)
	kernel .text 0xe002000000000000 0xe002000000008f00 0xe002000000008f60
0xe0020000000ce390 scheduler_tick+0x370
	kernel .text 0xe002000000000000 0xe0020000000ce020 0xe0020000000cede0
0xe0020000000f2250 update_process_times+0x50
	args (0x0, 0x1, 0xe002000000047ab0, 0x184)
	kernel .text 0xe002000000000000 0xe0020000000f2200 0xe0020000000f2280
0xe002000000047ab0 smp_do_timer+0x90
	args (0xe0000030071e7cd0, 0xe002000000032480, 0x813)
	kernel .text 0xe002000000000000 0xe002000000047a20 0xe002000000047ae0
0xe002000000032480 timer_interrupt+0x220
	args (0x6ef, 0x0, 0xe0000030071e7cd0, 0x2fdc609dda, 0xe0021000009e92d8)
	kernel .text 0xe002000000000000 0xe002000000032260 0xe002000000032700
0xe002000000012e40 handle_IRQ_event+0x100
	args (0x6ef, 0xe0000030071e7cd0, 0xe0021000008ddaf0, 0xe002100000948000, 0=
x20000001)
	kernel .text 0xe002000000000000 0xe002000000012d40 0xe002000000012ee0
0xe0020000000133d0 do_IRQ+0x130
	args (0x6ef, 0xe0000030071e7cd0, 0xe00000343bf0f788, 0xe002100000948000, 0=
x6ef)
	kernel .text 0xe002000000000000 0xe0020000000132a0 0xe002000000013680
0xe002000000015790 ia64_handle_irq+0xb0
	args (0xef, 0xe0000030071e7cd0, 0xfd, 0x0, 0xe0021000008fe328)
	kernel .text 0xe002000000000000 0xe0020000000156e0 0xe0020000000158c0
0xe00200000000ec00 ia64_leave_kernel
	args (0xef, 0xe0000030071e7cd0)
	kernel .text 0xe002000000000000 0xe00200000000ec00 0xe00200000000ee90
0xe002000000016970 cpu_idle+0xb0
	args (0xe0021000008e5708, 0xa000000000008418, 0x1e0008, 0xa000000000008410=
, 0xfffffffffffffffd)
	kernel .text 0xe002000000000000 0xe0020000000168c0 0xe002000000016b60
0xe002000000671cc0 start_secondary+0x80
	args (0xe0020000000084c0, 0x207)
	kernel .text.init 0xe002000000668000 0xe002000000671c40 0xe002000000671ce0
0xe0020000000084c0 start_ap+0x2a0
	args (0xffed0000, 0x1b004182300, 0xffc3a3b0, 0x207)
	kernel .text 0xe002000000000000 0xe002000000008220 0xe0020000000084f0
[6]kdb> r
 psr: 0x0000101008022018   ifs: 0x8000000000000389    ip: 0xe002000000008f30
unat: 0x0000000000000000   pfs: 0x0000000000000208   rsc: 0x0000000000000003
rnat: 0xefe566b88bd12bcc  bsps: 0x000000000000bb56    pr: 0x80000000ff659165
ldrs: 0x0000000000000000   ccv: 0x0000000000000000  fpsr: 0x0009804c0270033f
  b0: 0xe0020000000f2250    b6: 0xe002000000032260    b7: 0xe0020000000ce390
  r1: 0xe002100000948000    r2: 0xe0000030071e7888    r3: 0xe0000030071e7889
  r8: 0x00000000000000ef    r9: 0x0000000000000013   r10: 0x0000000000000000
 r11: 0x80000000ff661265   r12: 0xe0000030071e7cc0   r13: 0xe0000030071e0000
 r14: 0xe0021000008fe2f0   r15: 0x0000000000000001   r16: 0x00000000000125bf
 r17: 0xe00210000084e6e8   r18: 0x0000000000000300   r19: 0x0000000000000001
 r20: 0x00000000000000e7   r21: 0x0000000000000001   r22: 0xe0000030071e003c
 r23: 0x7fffffff00000000   r24: 0x0000000000000000   r25: 0x7fffffff00000000
 r26: 0x0000000000000000   r27: 0xe0000030071e7890   r28: 0x0000000000000000
 r29: 0x0000000000000000   r30: 0x0000000000000001   r31: 0xe00210000084d500
&regs =3D e0000030071e7b30
[6]kdb> 0xe00210000084d500
0xe00210000084d500 =3D 0xe00210000084d500 (runqueues+0x8100)


