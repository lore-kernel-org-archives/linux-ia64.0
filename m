From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 30 Jan 2003 06:51:22 +0000
Subject: [Linux-ia64] glibc patch for fsyscall support
Message-Id: <marc-linux-ia64-105590709805778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

For those of you eager to "try out" (read: burn your fingers with) the
fsyscall support, here is a quick & dirty patch for libc.  It is
relative to the CVS at sources.redhat.com.  You'll need at least
gcc-3.2 and should configure glibc with "--enable-add-ons --with-tls
--without-__thread" as that's the only thing I tested.  Also, I'd
highly recommend to run "make check" to verify that things are
reasonably sane before trying to install the result on a live system.
As usual when messing with glibc, be prepared for having to recover
your root filesystem (a spare second disk come in real handy here...).

I haven't done a huge amount of testing, but I did install the new
libc on a dual-Itanium 2 zx6000 workstation and it booted fine and
worked as expected.  The "null" syscall reported by LMbench looks
nice, too:

Processor, Processes - times in microseconds - smaller is better
----------------------------------------------------------------
Host                 OS  Mhz null null      open selct sig  sig  fork exec =
sh
                             call  I/O stat clos TCP   inst hndl proc proc =
proc
--------- ------------- ---- ---- ---- ---- ---- ----- ---- ---- ---- ---- =
----
caldera.h  Linux 2.5.59 1000 0.38 0.54 2.76 4.09  16.8 0.61 2.43 223. 738. =
2661
caldera.h  Linux 2.5.59 1000 0.07 0.55 2.66 4.03  16.8 0.60 2.85 235. 738. =
2660
                             ^^^^
                              ;-)

(First one is with old glibc, second one with new one.)

On a related note, I just pushed my latest kernel changes into the
lia64 bk repository.  The latest changeset (see
http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.973) contains the
dynamic Erratum 9 workaround patching and the getppid() light-weight
system call.

Happy hacking,

	--david

Index: elf/dl-support.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/elf/dl-support.c,v
retrieving revision 1.67
diff -u -r1.67 dl-support.c
--- elf/dl-support.c	7 Jan 2003 18:50:59 -0000	1.67
+++ elf/dl-support.c	30 Jan 2003 06:28:23 -0000
@@ -161,6 +161,11 @@
       case AT_PHNUM:
 	GL(dl_phnum) =3D av->a_un.a_val;
 	break;
+#ifdef NEED_DL_SYSINFO
+      case AT_SYSINFO:
+	GL(dl_sysinfo) =3D av->a_un.a_val;
+	break;
+#endif
       }
 }
 #endif
Index: linuxthreads/descr.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/linuxthreads/descr.h,v
retrieving revision 1.8
diff -u -r1.8 descr.h
--- linuxthreads/descr.h	28 Dec 2002 10:14:16 -0000	1.8
+++ linuxthreads/descr.h	30 Jan 2003 06:28:23 -0000
@@ -109,6 +109,7 @@
=20
 struct _pthread_descr_struct {
   /* XXX Remove this union for IA-64 style TLS module */
+#if TLS_TCB_AT_TP
   union {
     struct {
       void *tcb;		/* Pointer to the TCB.  This is not always
@@ -122,6 +123,9 @@
     } data;
     void *__padding[16];
   } p_header;
+#else
+  /* New elements must be added at the beginning.  */
+#endif
   pthread_descr p_nextlive, p_prevlive;
                                 /* Double chaining of active threads */
   pthread_descr p_nextwaiting;  /* Next element in the queue holding the t=
hr */
@@ -180,7 +184,23 @@
 #endif
   size_t p_alloca_cutoff;	/* Maximum size which should be allocated
 				   using alloca() instead of malloc().  */
+#if TLS_TCB_AT_TP
   /* New elements must be added at the end.  */
+#else
+  union {
+    struct {
+      void *reserved[11];	/* reserve for future use */
+      void *tcb;		/* XXX do we really need this? */
+      union dtv *dtvp;		/* XXX do we really need this? */
+      pthread_descr self;	/* XXX do we really need this? */
+      int multiple_threads;
+#ifdef NEED_DL_SYSINFO
+      uintptr_t sysinfo;
+#endif
+    } data;
+    void *__padding[16];
+  } p_header __attribute__ ((aligned(32)));
+#endif
 } __attribute__ ((aligned(32))); /* We need to align the structure so that
 				    doubles are aligned properly.  This is 8
 				    bytes on MIPS and 16 bytes on MIPS64.
Index: linuxthreads/manager.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/linuxthreads/manager.c,v
retrieving revision 1.90
diff -u -r1.90 manager.c
--- linuxthreads/manager.c	12 Jan 2003 08:42:38 -0000	1.90
+++ linuxthreads/manager.c	30 Jan 2003 06:28:23 -0000
@@ -645,6 +666,8 @@
 #endif
   new_thread->p_header.data.self =3D new_thread;
   new_thread->p_header.data.multiple_threads =3D 1;
+  /* XXX why isn't this done already??? */
+  new_thread->p_header.data.sysinfo =3D GL(dl_sysinfo);
   new_thread->p_tid =3D new_thread_id;
   new_thread->p_lock =3D &(__pthread_handles[sseg].h_lock);
   new_thread->p_cancelstate =3D PTHREAD_CANCEL_ENABLE;
Index: linuxthreads/pthread.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/linuxthreads/pthread.c,v
retrieving revision 1.119
diff -u -r1.119 pthread.c
--- linuxthreads/pthread.c	16 Jan 2003 18:16:32 -0000	1.119
+++ linuxthreads/pthread.c	30 Jan 2003 06:28:23 -0000
@@ -353,6 +353,9 @@
=20
   self =3D THREAD_SELF;
=20
+  /* XXX why isn't this done already??? */
+  self->p_header.data.sysinfo =3D GL(dl_sysinfo);
+
   /* The memory for the thread descriptor was allocated elsewhere as
      part of the TLS allocation.  We have to initialize the data
      structure by hand.  This initialization must mirror the struct
@@ -614,6 +617,8 @@
   mgr->p_header.data.tcb =3D tcbp;
   mgr->p_header.data.self =3D mgr;
   mgr->p_header.data.multiple_threads =3D 1;
+  /* XXX why isn't this done already??? */
+  mgr->p_header.data.sysinfo =3D GL(dl_sysinfo);
   mgr->p_lock =3D &__pthread_handles[1].h_lock;
 # ifndef HAVE___THREAD
   mgr->p_errnop =3D &mgr->p_errno;
Index: linuxthreads/sysdeps/ia64/tcb-offsets.sym
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/linuxthreads/sysdeps/ia64=
/tcb-offsets.sym,v
retrieving revision 1.3
diff -u -r1.3 tcb-offsets.sym
--- linuxthreads/sysdeps/ia64/tcb-offsets.sym	16 Jan 2003 18:21:40 -0000	1.3
+++ linuxthreads/sysdeps/ia64/tcb-offsets.sym	30 Jan 2003 06:28:23 -0000
@@ -4,6 +4,7 @@
 --
 #ifdef USE_TLS
 MULTIPLE_THREADS_OFFSET offsetof (struct _pthread_descr_struct, p_header.d=
ata.multiple_threads) - sizeof (struct _pthread_descr_struct)
+SYSINFO_OFFSET		offsetof (struct _pthread_descr_struct, p_header.data.sysi=
nfo) - sizeof (struct _pthread_descr_struct)
 #else
 MULTIPLE_THREADS_OFFSET offsetof (tcbhead_t, multiple_threads)
 #endif
Index: linuxthreads/sysdeps/ia64/tls.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/linuxthreads/sysdeps/ia64=
/tls.h,v
retrieving revision 1.4
diff -u -r1.4 tls.h
--- linuxthreads/sysdeps/ia64/tls.h	16 Jan 2003 18:20:44 -0000	1.4
+++ linuxthreads/sysdeps/ia64/tls.h	30 Jan 2003 06:28:23 -0000
@@ -20,10 +20,13 @@
 #ifndef _TLS_H
 #define _TLS_H
=20
+#include <dl-sysdep.h>
+
 #ifndef __ASSEMBLER__
=20
 # include <pt-machine.h>
 # include <stddef.h>
+# include <stdint.h>
=20
 /* Type for the dtv.  */
 typedef union dtv
@@ -83,8 +86,10 @@
 /* Code to initially initialize the thread pointer.  This might need
    special attention since 'errno' is not yet available and if the
    operation can cause a failure 'errno' must not be touched.  */
-#  define TLS_INIT_TP(tcbp, secondcall) \
-  (__thread_self =3D (tcbp), NULL)
+#  define TLS_INIT_TP(tcbp, secondcall)			\
+  (__thread_self =3D (tcbp),				\
+   THREAD_SELF->p_header.data.sysinfo =3D GL(dl_sysinfo),	\
+   NULL)
=20
 /* Return the address of the dtv for the current thread.  */
 #  define THREAD_DTV() \
Index: linuxthreads/sysdeps/unix/sysv/linux/ia64/vfork.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/linuxthreads/sysdeps/unix=
/sysv/linux/ia64/vfork.S,v
retrieving revision 1.2
diff -u -r1.2 vfork.S
--- linuxthreads/sysdeps/unix/sysv/linux/ia64/vfork.S	14 Jan 2003 01:23:24 =
-0000	1.2
+++ linuxthreads/sysdeps/unix/sysv/linux/ia64/vfork.S	30 Jan 2003 06:28:23 =
-0000
@@ -36,9 +36,13 @@
 	mov out0=3DCLONE_VM+CLONE_VFORK+SIGCHLD
 	mov out1=3D0		/* Standard sp value.			*/
 	;;
+#if 0
 	DO_CALL (SYS_ify (clone))
+#else
+	mov r15=3DSYS_ify(clone)
+	break __BREAK_SYSCALL
+#endif
 	cmp.eq p6,p0=3D-1,r10
-	;;
 (p6)	br.cond.spnt.few __syscall_error
 	ret
 PSEUDO_END(__vfork)
Index: sysdeps/generic/libc-start.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/sysdeps/generic/libc-star=
t.c,v
retrieving revision 1.35
diff -u -r1.35 libc-start.c
--- sysdeps/generic/libc-start.c	28 Dec 2002 09:14:52 -0000	1.35
+++ sysdeps/generic/libc-start.c	30 Jan 2003 06:28:24 -0000
@@ -83,14 +83,6 @@
   ++auxvec;
   _dl_aux_init ((ElfW(auxv_t) *) auxvec);
 # endif
-# ifdef DL_SYSDEP_OSCHECK
-  if (!__libc_multiple_libcs)
-    {
-      /* This needs to run to initiliaze _dl_osversion before TLS
-	 setup might check it.  */
-      DL_SYSDEP_OSCHECK (__libc_fatal);
-    }
-# endif
=20
   /* Initialize the thread library at least a bit since the libgcc
      functions are using thread functions if these are available and
@@ -101,6 +93,15 @@
   if (__pthread_initialize_minimal)
 # endif
     __pthread_initialize_minimal ();
+
+# ifdef DL_SYSDEP_OSCHECK
+  if (!__libc_multiple_libcs)
+    {
+      /* This needs to run to initiliaze _dl_osversion before TLS
+	 setup might check it.  */
+      DL_SYSDEP_OSCHECK (__libc_fatal);
+    }
+# endif
=20
   /* Some security at this point.  Prevent starting a SUID binary where
      the standard file descriptors are not opened.  We have to do this
Index: sysdeps/unix/sysv/linux/ia64/clone2.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/i=
a64/clone2.S,v
retrieving revision 1.3
diff -u -r1.3 clone2.S
--- sysdeps/unix/sysv/linux/ia64/clone2.S	6 Jul 2001 04:56:17 -0000	1.3
+++ sysdeps/unix/sysv/linux/ia64/clone2.S	30 Jan 2003 06:28:24 -0000
@@ -24,31 +24,45 @@
 /* int  __clone2(int (*fn) (void *arg), void *child_stack_base, 	*/
 /* 	         size_t child_stack_size, int flags, void *arg) */
=20
+#define CHILD	p8
+#define PARENT	p9
+
 ENTRY(__clone2)
-	alloc r2=3Dar.pfs,5,2,3,0
+	.prologue
+	alloc r2=3Dar.pfs,5,3,3,0
 	cmp.eq p6,p0=3D0,in0
 	mov r8=3DEINVAL
 (p6)	br.cond.spnt.few __syscall_error
 	;;
-	flushrs			/* This is necessary, since the child	*/
-				/* will be running with the same 	*/
-				/* register backing store for a few 	*/
-				/* instructions.  We need to ensure	*/
-				/* that it will not read or write the	*/
-				/* backing store.			*/
 	mov loc0=3Din0		/* save fn	*/
 	mov loc1=3Din4		/* save arg	*/
 	mov out0=3Din3		/* Flags are first syscall argument.	*/
 	mov out1=3Din1		/* Stack address.			*/
 	mov out2=3Din2		/* Stack size.				*/
-        DO_CALL (SYS_ify (clone2))
-        cmp.eq p6,p0=3D-1,r10
+	/*
+	 * clone2() is special: the child cannot execute br.ret right after
+	 * the system call returns, because it starts out executing on an
+	 * empty stack.  Because of this, we can't use the new (lightweight)
+	 * syscall convention here.  Instead, we just fall back on always
+	 * using "break".
+	 */
+	mov r15=3DSYS_ify (clone2)
+	/*
+	 * The child will start with an empty stack.  To avoid unwinding
+	 * past invalid memory, we'll pretend now that __clone2() is
+	 * the end of the call-chain.  This is wrong for the parent, but
+	 * only until it returns from clone2() but it's better than the
+	 * alternative.
+	 */
+	mov b7=3Dr0
+	.prologue
+	.altrp b7
+	.body
+	break __BREAK_SYSCALL
 	;;
-(p6)	br.cond.spnt.few __syscall_error
-
-#	define CHILD p6
-#	define PARENT p7
 	cmp.eq CHILD,PARENT=3D0,r8 /* Are we the child?	*/
+        cmp.eq p6,p0=3D-1,r10
+(p6)	br.cond.spnt.few __syscall_error
 	;;
 (CHILD)	ld8 out1=3D[loc0],8	/* Retrieve code pointer.	*/
 (CHILD)	mov out0=3Dloc1		/* Pass proper argument	to fn */
@@ -56,7 +70,6 @@
 	;;
 	ld8 gp=3D[loc0]		/* Load function gp.		*/
 	mov b6=3Dout1
-	;;
 	br.call.dptk.few rp=B6	/* Call fn(arg) in the child 	*/
 	;;
 	mov out0=3Dr8		/* Argument to _exit		*/
Index: sysdeps/unix/sysv/linux/ia64/sysdep.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/i=
a64/sysdep.h,v
retrieving revision 1.10
diff -u -r1.10 sysdep.h
--- sysdeps/unix/sysv/linux/ia64/sysdep.h	9 Jan 2003 04:09:25 -0000	1.10
+++ sysdeps/unix/sysv/linux/ia64/sysdep.h	30 Jan 2003 06:28:24 -0000
@@ -23,6 +23,7 @@
=20
 #include <sysdeps/unix/sysdep.h>
 #include <sysdeps/ia64/sysdep.h>
+#include <tls.h>
=20
 /* For Linux we can use the system call table in the header file
 	/usr/include/asm/unistd.h
@@ -89,9 +90,30 @@
 	cmp.eq p6,p0=3D-1,r10;			\
 (p6)	br.cond.spnt.few __syscall_error;
=20
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
 #define DO_CALL(num)				\
 	mov r15=3Dnum;				\
 	break __BREAK_SYSCALL;
+#endif
=20
 #undef PSEUDO_END
 #define PSEUDO_END(name)	.endp C_SYMBOL_NAME(name);
Index: sysdeps/unix/sysv/linux/ia64/vfork.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/i=
a64/vfork.S,v
retrieving revision 1.4
diff -u -r1.4 vfork.S
--- sysdeps/unix/sysv/linux/ia64/vfork.S	31 Dec 2002 20:37:30 -0000	1.4
+++ sysdeps/unix/sysv/linux/ia64/vfork.S	30 Jan 2003 06:28:24 -0000
@@ -34,9 +34,13 @@
 	mov out0=3DCLONE_VM+CLONE_VFORK+SIGCHLD
 	mov out1=3D0		/* Standard sp value.			*/
 	;;
+#if 0
 	DO_CALL (SYS_ify (clone))
+#else
+	mov r15=3DSYS_ify(clone)
+	break __BREAK_SYSCALL
+#endif
 	cmp.eq p6,p0=3D-1,r10
-	;;
 (p6)	br.cond.spnt.few __syscall_error
 	ret
 PSEUDO_END(__vfork)

