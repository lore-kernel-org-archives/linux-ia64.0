From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 27 Sep 2003 04:23:17 +0000
Subject: support INLINE_SYSCALL & INTERNAL_SYSCALL via new ia64 syscall stub
Message-Id: <marc-linux-ia64-106463661108126@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

[Resend due to mistyped linux-ia64 address; my fingers must be suffering
 from repressed memories as they typed linux-ia64@vger.rutgers.edu... ;-]

The patch below is relative to the CVS sysdep.h and adds support for
doing INLINE_SYSCALL and INTERNAL_SYSCALL via the new ia64 syscall
stubs (which enable light-weight system calls).  It's hasn't been
thoroughly tested (I'm just about to go on a trip and wanted to
getthis out), but it ought to work in theory and it has held up so
far.

With this patch, the number of "break" syscalls in libc.so drops from
~160 down to about 40 and those that are left probably won't go away
(they're in places where the new syscall stubs can't be used, e.g.,
clone2()).

Ian, do you think you could make the equivalent changes for your
NPTL-enabled libc packages?

	--david

diff -u -r1.17 sysdep.h
--- sysdeps/unix/sysv/linux/ia64/sysdep.h	16 Aug 2003 08:00:24 -0000	1.17
+++ sysdeps/unix/sysv/linux/ia64/sysdep.h	27 Sep 2003 04:12:02 -0000
@@ -23,6 +23,7 @@
=20
 #include <sysdeps/unix/sysdep.h>
 #include <sysdeps/ia64/sysdep.h>
+#include <tls.h>
=20
 /* For Linux we can use the system call table in the header file
 	/usr/include/asm/unistd.h
@@ -95,9 +96,32 @@
 	cmp.eq p6,p0=3D-1,r10;			\
 (p6)	br.cond.spnt.few __syscall_error;
=20
-#define DO_CALL(num)				\
+#define DO_CALL_VIA_BREAK(num)			\
 	mov r15=3Dnum;				\
-	break __BREAK_SYSCALL;
+	break __BREAK_SYSCALL
+
+#if defined HAVE_TLS_SUPPORT && (!defined NOT_IN_libc || defined IS_IN_lib=
pthread)
+
+/* Use the lightweight stub only if (a) we have a suitably modern
+   thread-control block (HAVE_TLS_SUPPORT) and (b) we're not compiling
+   the runtime loader (which might do syscalls before being fully
+   relocated). */
+
+#define DO_CALL(num)				\
+	.prologue;				\
+        adds r2 =3D SYSINFO_OFFSET, r13;;		\
+        ld8 r2 =3D [r2];				\
+	.save ar.pfs, r11;			\
+        mov r11 =3D ar.pfs;;			\
+	.body;					\
+	mov r15 =3D num;				\
+        mov b7 =3D r2;				\
+        br.call.sptk.many b6 =3D b7;;		\
+	.restore sp;				\
+        mov ar.pfs =3D r11
+#else
+#define DO_CALL(num)				DO_CALL_VIA_BREAK(num)
+#endif
=20
 #undef PSEUDO_END
 #define PSEUDO_END(name)	.endp C_SYMBOL_NAME(name);
@@ -144,6 +168,47 @@
    (non-negative) errno on error or the return value on success.
  */
 #undef INLINE_SYSCALL
+#undef INTERNAL_SYSCALL
+#if defined HAVE_TLS_SUPPORT && (!defined NOT_IN_libc || defined IS_IN_lib=
pthread)
+
+#define DO_INLINE_SYSCALL(name, nr, args...)							\
+    register long _r8 __asm ("r8");								\
+    register long _r10 __asm ("r10");								\
+    register long _r15 __asm ("r15") =3D __NR_##name;						\
+    long _retval;										\
+    LOAD_ARGS_##nr (args);									\
+    /*												\
+     * Don't specify any unwind info here.  We mark ar.pfs as clobbered.  =
This will force	\
+     * the compiler to save ar.pfs somewhere and emit appropriate unwind i=
nfo for that		\
+     * save.											\
+     */												\
+    __asm __volatile ("adds r2 =3D -8, r13;;\n"							\
+		      "ld8 r2 =3D [r2];;\n"							\
+		      "mov b7=3Dr2;\n"								\
+		      "br.call.sptk.many b6=B7;;\n"						\
+                      : "=3Dr" (_r8), "=3Dr" (_r10), "=3Dr" (_r15) ASM_OUT=
ARGS_##nr			\
+                      : "2" (_r15) ASM_ARGS_##nr						\
+		      : "memory", "ar.pfs" ASM_CLOBBERS_##nr);					\
+    _retval =3D _r8;
+
+#define INLINE_SYSCALL(name, nr, args...)	\
+  ({						\
+    DO_INLINE_SYSCALL(name, nr, args)		\
+    if (_r10 =3D -1)				\
+      {						\
+        __set_errno (_retval);			\
+        _retval =3D -1;				\
+      }						\
+    _retval; })
+
+#define INTERNAL_SYSCALL(name, err, nr, args...)	\
+  ({							\
+    DO_INLINE_SYSCALL(name, nr, args)			\
+    err =3D _r10;						\
+    _retval; })
+
+#else /* !new syscall-stub */
+
 #define INLINE_SYSCALL(name, nr, args...)			\
   ({								\
     register long _r8 asm ("r8");				\
@@ -164,10 +229,6 @@
       }								\
     _retval; })
=20
-#undef INTERNAL_SYSCALL_DECL
-#define INTERNAL_SYSCALL_DECL(err) long int err
-
-#undef INTERNAL_SYSCALL
 #define INTERNAL_SYSCALL(name, err, nr, args...)		\
   ({								\
     register long _r8 asm ("r8");				\
@@ -183,6 +244,11 @@
     _retval =3D _r8;						\
     err =3D _r10;							\
     _retval; })
+
+#endif /* !new syscall-stub */
+
+#undef INTERNAL_SYSCALL_DECL
+#define INTERNAL_SYSCALL_DECL(err) long int err
=20
 #undef INTERNAL_SYSCALL_ERROR_P
 #define INTERNAL_SYSCALL_ERROR_P(val, err)	(err =3D -1)
