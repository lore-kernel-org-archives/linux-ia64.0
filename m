From: Keith Owens <kaos@sgi.com>
Date: Sat, 15 Mar 2003 01:10:38 +0000
Subject: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590709806125@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Patch is against 2.4.20-ia64-021210.

Reduce the uncontended spinlock path from 5 bundles to 3 (McKinley) or
4 (Itanium), both have one less memory access on the uncontended path.
Move the contended path out of line so we can do exponential backoff,
kdb, lock metering etc. in one place.

David, closing the 1 bundle unwind window was a bit harder than I
expected, it turns out that altrp does not specify where it applies, it
is prologue global.  To get altrp to apply after mov b7=3Dr28, I needed
multiple prologues and bodies.  AFAICT this will unwind correctly on
any instruction within ia64_spinlock_contention.  Could you verify that
on your simulator (assuming it supports .save ar.pfs,r0)?

Note 1.  The patch uses .save ar.pfs, r0 which requires the unwind code
         be updated to allow reading from r0.  You need one of these
         unwind patches as well :-

	 2.4.20           http://external-lists.valinux.com/archives/linux-ia64/20=
03-March/004940.html
	 2.4.21-pre5 + bk http://external-lists.valinux.com/archives/linux-ia64/20=
03-March/004939.html

Note 2.  For (CONFIG_MODULES=3Dy && CONFIG_MCKINLEY=3Dy), you need modutils
         2.4.23.  If you get this message then upgrade your modutils.

	   Unhandled relocation of type 72 for ia64_spinlock_contention

Index: 20.5/include/asm-ia64/spinlock.h
--- 20.5/include/asm-ia64/spinlock.h Fri, 01 Mar 2002 11:01:28 +1100 kaos (=
linux-2.4/s/28_spinlock.h 1.1.3.1.1.1.2.1 644)
+++ 20.5(w)/include/asm-ia64/spinlock.h Fri, 14 Mar 2003 16:10:55 +1100 kao=
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
@@ -27,81 +23,73 @@ typedef struct {
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
+ *   r28 - address of start of spin_lock code.  Used as a "return" address
+ *         from the contention path.  mov r28=3Dip must be in the first bu=
ndle.
+ *   r29 - available for use.
+ *   r30 - available for use.
+ *   r31 - address of lock.
+ *   b7  - available for use.
+ *   p15 - available for use.
+ *
+ * If you patch ia64_spinlock_contention to use more registers, do not for=
get to
+ * update the clobber lists below.
  */
-#define spin_lock(x)									\
-{											\
+
+#ifdef	CONFIG_MCKINLEY
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
 		";;\n"									\
 		"cmp.ne p15,p0=3Dr30,r0\n"						\
-		"(p15) br.call.spnt.few b7=3Dia64_spinlock_contention\n"			\
 		";;\n"									\
-		"1:\n"				/* force a new bundle */		\
+		"(p15) brl.cond.spnt.few ia64_spinlock_contention\n"			\
+		";;\n"									\
+		"2:\n"		/* force a new bundle */				\
 		:: "r"(addr)								\
-		: "ar.ccv", "ar.pfs", "b7", "p15", "r28", "r29", "r30", "memory");	\
-}
-
-#define spin_trylock(x)									\
+		: "ar.ccv", "r28", "r29", "r30", "b7", "p15", "memory");		\
+})
+#else	/* !CONFIG_MCKINLEY */
 ({											\
-	register long result;								\
+	register char *addr __asm__ ("r31") =3D (char *) &(x)->lock;			\
 											\
 	__asm__ __volatile__ (								\
+		"1:\n"		/* force a new bundle, r28 points here */		\
 		"mov ar.ccv=3Dr0\n"							\
+		"mov r28=3Dip\n"								\
+		"mov r30=3D1\n"								\
+		";;\n"									\
+		"cmpxchg4.acq r30=3D[%0],r30,ar.ccv\n"					\
+		"movl r29=3Dia64_spinlock_contention\n"					\
+		";;\n"									\
+		"cmp.ne p15,p0=3Dr30,r0\n"						\
+		"mov b7=3Dr29\n"								\
+		";;\n"									\
+		"(p15) br.cond.spnt.few b7\n"						\
 		";;\n"									\
-		"cmpxchg4.acq %0=3D[%2],%1,ar.ccv\n"					\
-		: "=3Dr"(result) : "r"(1), "r"(&(x)->lock) : "ar.ccv", "memory");		\
-	(result =3D 0);									\
+		"2:\n"		/* force a new bundle */				\
+		:: "r"(addr)								\
+		: "ar.ccv", "r28", "r29", "r30", "b7", "p15", "memory");		\
 })
-
-#define spin_is_locked(x)	((x)->lock !=3D 0)
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
+#endif	/* CONFIG_MCKINLEY */
=20
 #define spin_is_locked(x)	((x)->lock !=3D 0)
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
+++ 20.5(w)/arch/ia64/kernel/ia64_ksyms.c Fri, 14 Mar 2003 16:11:57 +1100 k=
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
+EXPORT_SYMBOL_NOVERS(ia64_spinlock_contention);
Index: 20.5/arch/ia64/kernel/head.S
--- 20.5/arch/ia64/kernel/head.S Wed, 11 Dec 2002 20:58:53 +1100 kaos (linu=
x-2.4/s/c/11_head.S 1.1.4.1.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/head.S Fri, 14 Mar 2003 16:14:06 +1100 kaos (l=
inux-2.4/s/c/11_head.S 1.1.4.1.3.1.1.1.1.3 644)
@@ -742,69 +742,62 @@ SET_REG(b5);
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
+	 *   r29    - available for use.
+	 *   r30    - available for use.
+	 *   r31    - address of lock.
+	 *   b7     - available for use.
+	 *   p15    - available for use.
+	 *   Rest   - caller's state, do not use, especially ar.pfs.
+	 *
+	 * If you patch this code to use more registers, do not forget to update
+	 * the clobber lists for spin_lock() in include/asm-ia64/spinlock.h.
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
+	.save ar.pfs, r0	// this code effectively has a zero frame size
+	.body
+	.label_state 1
+
+	.prologue
+	.save rp, r28		// r28 =3D my "return" address
+	.body
+	mov b7=3Dr28
+	.body
+	.copy_state 1
+
+	.prologue
+	.altrp b7		// altrp has no 'when' field, it needs its own prologue
+	.body
+
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



