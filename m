From: Keith Owens <kaos@sgi.com>
Date: Sat, 10 May 2003 14:02:50 +0000
Subject: [Linux-ia64] Re: new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705722@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, 10 May 2003 04:19:20 -0700,=20
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>The kernel patch linux-2.5.69-ia64-030509.diff.gz is now available at
>
>Oh, Keith, you might like the fact that I added NEW_LOCK back again
>and it's even turned on by default!

A couple of months of experience inside SGI with my NEW_LOCK patch
resulted in some changes.

* Always save the return address in r28 in addition to b6 (btw, your
  patch still mentions b7).  b6 is not in minstate which means it is
  missing for INIT and MCA dumps, making it impossible to determine
  which code was in contention.  Also kernprof only gets the minstate
  data and it needs the return address to report the real contention
  code.  Using r28 as well as b6 makes INT, MCA and kernprof (with a
  patch to kernprof) useful again.

* Add more registers to the clobber list.  ar.ccv is really clobbered
  and is missing from the list.  Some of the optional code that is
  added to the contention path (e.g. exponential backoff) needs more
  registers.  Changing spinlock.h forces a complete recompile, so
  predefine a suitable set of free registers.

  There is also a problem with binary only modules, I hate them but
  they are a fact of life.  Changing the clobber list in spinlock.h
  will result in binary only modules that have an incorrect view of
  what the kernel is doing and will result in register corruption on
  contended locks.  I don't like the idea that tuning and debugging
  patches introduce Heisenbugs!

  Extending the predefined list of clobbers means that any reasonable
  code can be added to the contention path without causing problems for
  the rest of the kernel.  The extra registers do not cause any
  problems for gcc, the "memory" clobber means that only constants can
  be held in registers over the spinlock code, there are still 13 free
  registers to hold constant values or addresses, not to mention local
  stacked registers.


This patch has not even been compiled, it is just for discussion.


Index: 69.2/arch/ia64/kernel/head.S
--- 69.2/arch/ia64/kernel/head.S Sat, 10 May 2003 22:34:16 +1000 kaos (linu=
x-2.5/t/35_head.S 1.1.2.1.1.1.2.1.1.1.1.2 444)
+++ 69.2(w)/arch/ia64/kernel/head.S Sat, 10 May 2003 23:27:30 +1000 kaos (l=
inux-2.5/t/35_head.S 1.1.2.1.1.1.2.1.1.1.1.2 444)
@@ -747,14 +747,19 @@ SET_REG(b5);
 	 * - do not use any registers other than the ones listed below
 	 *
 	 * Inputs:
-	 *   ar.pfs - saved CFM of caller
-	 *   ar.ccv - 0 (and available for use)
-	 *   r28    - available for use.
-	 *   r29    - available for use.
-	 *   r30    - available for use.
-	 *   r31    - address of lock, available for use.
-	 *   b7     - return address
-	 *   p14    - available for use.
+	 *   ar.pfs	- saved CFM of caller
+	 *   ar.ccv	- 0 (and available for use)
+	 *   r12	- kernel stack pointer, but see above.
+	 *   r13	- current process.
+	 *   r28	- address of start of spin_lock code.  Used as a "return"
+	 *		  address from this contention path.  Do not change, b6
+	 *		  is not always dumped, r28 is always dumped.  kernprof
+	 *		  relies on getting r28 to work out what is contending.
+	 *   r31	- address of lock.
+	 *   r21-r27, r29, r30 - available for use.
+	 *   b6		- return address, do not use.
+	 *   p12-p15	- available for use.
+	 *   Rest	- caller's state, do not use, especially ar.pfs.
 	 *
 	 * If you patch this code to use more registers, do not forget to update
 	 * the clobber lists for spin_lock() in include/asm-ia64/spinlock.h.
@@ -765,16 +770,10 @@ SET_REG(b5);
 GLOBAL_ENTRY(ia64_spinlock_contention_pre3_4)
 	.prologue
 	.save ar.pfs, r0	// this code effectively has a zero frame size
-	.save rp, r28
-	.body
-	nop 0
-	nop 0
-	.restore sp		// pop existing prologue after next insn
-	mov b6 =3D r28
-	.prologue
-	.save ar.pfs, r0
-	.altrp b6
+	.spillreg rp, r28
 	.body
+	mov b6=3Dr28		// copy to b6 for return, preserve r28 for debug
+
 .wait:
 	// exponential backoff, kdb, lockmeter etc. go in here
 	hint @pause
@@ -792,6 +791,8 @@ GLOBAL_ENTRY(ia64_spinlock_contention)
 	.prologue
 	.altrp b6
 	.body
+	mov r28=B6		// copy return address to r28 for debug
+
 .wait:
 	// exponential backoff, kdb, lockmeter etc. go in here
 	hint @pause
Index: 69.2/include/asm-ia64/spinlock.h
--- 69.2/include/asm-ia64/spinlock.h Sat, 10 May 2003 22:34:16 +1000 kaos (=
linux-2.5/D/c/9_spinlock.h 1.1.2.1.1.1.1.1.1.4 444)
+++ 69.2(w)/include/asm-ia64/spinlock.h Sun, 11 May 2003 00:02:09 +1000 kao=
s (linux-2.5/D/c/9_spinlock.h 1.1.2.1.1.1.1.1.1.4 444)
@@ -30,9 +30,26 @@ typedef struct {
  * ia64_spinlock_contention().  We do not use a normal call because that w=
ould force all
  * callers of spin_lock() to be non-leaf routines.  Instead, ia64_spinlock=
_contention() is
  * carefully coded to touch only those registers that spin_lock() marks "c=
lobbered".
+ *
+ * ia64_spinlock_contention is entered with :-
+ *   r28 - address of start of spin_lock code.  Used as a "return" address
+ *         from the contention path.
+ *   r31 - address of lock.
+ *   r21-r27, r29, r30 - available for use.
+ *   b6  - available for use.
+ *   p12-p15 - available for use.
+ *
+ * If you patch ia64_spinlock_contention to use more registers, do not for=
get to
+ * update the clobber list below.  Although the inline code does not use
+ * r21-r27, r29, p12, p14, p15, they are marked as clobbers so the content=
ion
+ * path has a decent set of registers to use without requiring changes to =
this
+ * file and forcing a complete kernel rebuild, not to mention invalidating=
 every
+ * module in a way that cannot be detected by modversions.
  */
=20
-#define IA64_SPINLOCK_CLOBBERS "ar.pfs", "p14", "r28", "r29", "r30", "b6",=
 "memory"
+#define IA64_SPINLOCK_CLOBBERS "ar.ccv", "ar.pfs",					\
+		  "r21", "r22", "r23", "r24", "r25", "r26", "r27", "r28", "r29", "r30", \
+		  "b6", "p12", "p13", "p14", "p15", "memory"
=20
 static inline void
 _raw_spin_lock (spinlock_t *lock)


