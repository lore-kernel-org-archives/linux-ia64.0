From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 09 Apr 2003 02:38:45 +0000
Subject: [Linux-ia64] glibc fsyscall patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Message-Id: <marc-linux-ia64-105590723705444@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

An updated version of David M's patch posted at
https://lists.linuxia64.org/archives//linux-ia64/2003-February/004656.html
is attached.  The libc part should apply ontop libc cvs and the NPTL
part with NPTL 0.34.  To build I used

../libc/configure --with-tls --with-__thread
--with-headers=/usr/src/linux-2.5.64/include
--enable-add-ons=nptl --prefix=/usr CC=gcc-snap

where gcc-snap is the latest 3.3 snapshot [*].  You will obviously
need a kernel that is sufficient to run NPTL and have fsyscall support
enabled.

I can make some debian archives of this if it would help people to
test it.  It passes make check (except for known failures) and we here
at Gelato@UNSW will be using it internally, but at the moment all I
would say is "works for me".

Regards,

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

[*] I have seen problems with 3.3 snapshots locking up the system and
causing a machine check.  I would be interested if anyone using redhat
and their gcc 3.2 with the backported __thread changes sees this
problem.

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="libc-cvs-fsyscall.diff"

? fsyscall-libc.diff
? nptl
? nptl_db
Index: sysdeps/unix/sysv/linux/dl-osinfo.h
===================================================================
RCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/dl-osinfo.h,v
retrieving revision 1.13
diff -u -w -r1.13 dl-osinfo.h
--- sysdeps/unix/sysv/linux/dl-osinfo.h	1 Dec 2002 22:14:40 -0000	1.13
+++ sysdeps/unix/sysv/linux/dl-osinfo.h	9 Apr 2003 02:10:20 -0000
@@ -53,9 +53,12 @@
 	int parts;							      \
 	char *cp;							      \
 	struct utsname uts;						      \
+	int uname_err;								\
 									      \
-	/* Try the uname syscall */					      \
-	if (__uname (&uts))					      	      \
+ 	/* use an inline call incase TLS isn't setup and something 		\
+	   like fast syscalls are in use */					\
+	INTERNAL_SYSCALL(uname,uname_err,1,&uts);				\
+	if ( uname_err )							\
 	  {							      	      \
 	    /* This was not successful.  Now try reading the /proc	      \
 	       filesystem.  */						      \
Index: sysdeps/unix/sysv/linux/ia64/clone2.S
===================================================================
RCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/ia64/clone2.S,v
retrieving revision 1.7
diff -u -w -r1.7 clone2.S
--- sysdeps/unix/sysv/linux/ia64/clone2.S	13 Mar 2003 04:36:59 -0000	1.7
+++ sysdeps/unix/sysv/linux/ia64/clone2.S	9 Apr 2003 02:10:20 -0000
@@ -25,18 +25,16 @@
 /* 	         size_t child_stack_size, int flags, void *arg,		*/
 /*	         pid_t *parent_tid, void *tls, pid_t *child_tid)	*/
 
+#define CHILD	p8
+#define PARENT	p9
+	
 ENTRY(__clone2)
-	alloc r2=ar.pfs,8,2,6,0
+	.prologue
+	alloc r2=ar.pfs,8,3,6,0
 	cmp.eq p6,p0=0,in0
 	mov r8=EINVAL
 (p6)	br.cond.spnt.few __syscall_error
 	;;
-	flushrs			/* This is necessary, since the child	*/
-				/* will be running with the same 	*/
-				/* register backing store for a few 	*/
-				/* instructions.  We need to ensure	*/
-				/* that it will not read or write the	*/
-				/* backing store.			*/
 	mov loc0=in0		/* save fn	*/
 	mov loc1=in4		/* save arg	*/
 	mov out0=in3		/* Flags are first syscall argument.	*/
@@ -45,14 +43,30 @@
 	mov out3=in5		/* Parent TID Pointer			*/
 	mov out4=in7		/* Child TID Pointer			*/
  	mov out5=in6		/* TLS pointer				*/
-        DO_CALL (SYS_ify (clone2))
-        cmp.eq p6,p0=-1,r10
+	/*
+	 * clone2() is special: the child cannot execute br.ret right after
+	 * the system call returns, because it starts out executing on an
+	 * empty stack.  Because of this, we can't use the new (lightweight)
+	 * syscall convention here.  Instead, we just fall back on always
+	 * using "break".
+	 */
+	mov r15=SYS_ify (clone2)
+	/*
+	 * The child will start with an empty stack.  To avoid unwinding
+	 * past invalid memory, we'll pretend now that __clone2() is
+	 * the end of the call-chain.  This is wrong for the parent, but
+	 * only until it returns from clone2() but it's better than the
+	 * alternative.
+	 */
+	mov b7=r0
+	.prologue
+	.altrp b7
+	.body
+	break __BREAK_SYSCALL
 	;;
-(p6)	br.cond.spnt.few __syscall_error
-
-#	define CHILD p6
-#	define PARENT p7
 	cmp.eq CHILD,PARENT=0,r8 /* Are we the child?	*/
+	cmp.eq p6,p0=-1,r10
+(p6)	br.cond.spnt.few __syscall_error
 	;;
 (CHILD)	ld8 out1=[loc0],8	/* Retrieve code pointer.	*/
 (CHILD)	mov out0=loc1		/* Pass proper argument	to fn */
@@ -60,7 +74,6 @@
 	;;
 	ld8 gp=[loc0]		/* Load function gp.		*/
 	mov b6=out1
-	;;
 	br.call.dptk.few rp=b6	/* Call fn(arg) in the child 	*/
 	;;
 	mov out0=r8		/* Argument to _exit		*/
Index: sysdeps/unix/sysv/linux/ia64/sysdep.h
===================================================================
RCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/ia64/sysdep.h,v
retrieving revision 1.14
diff -u -w -r1.14 sysdep.h
--- sysdeps/unix/sysv/linux/ia64/sysdep.h	24 Mar 2003 07:54:28 -0000	1.14
+++ sysdeps/unix/sysv/linux/ia64/sysdep.h	9 Apr 2003 02:10:20 -0000
@@ -24,6 +24,8 @@
 #include <sysdeps/unix/sysdep.h>
 #include <sysdeps/ia64/sysdep.h>
 
+#include <tls.h>
+
 /* For Linux we can use the system call table in the header file
 	/usr/include/asm/unistd.h
    of the kernel.  But these symbols do not follow the SYS_* syntax
@@ -89,9 +91,30 @@
 	cmp.eq p6,p0=-1,r10;			\
 (p6)	br.cond.spnt.few __syscall_error;
 
+#if defined HAVE_TLS_SUPPORT && (!defined NOT_IN_libc || defined IS_IN_libpthread)
+
+/* Use the lightweight stub only if (a) we have a suitably modern
+   thread-control block (HAVE_TLS_SUPPORT) and (b) we're not compiling
+   the runtime loader (which might do syscalls before being fully
+   relocated). */
+
+#define DO_CALL(num)				\
+	.prologue;				\
+        adds r2 = SYSINFO_OFFSET, r13;;		\
+        ld8 r2 = [r2];				\
+	.save ar.pfs, r11;			\
+        mov r11 = ar.pfs;;			\
+	.body;					\
+	mov r15 = num;				\
+        mov b7 = r2;				\
+        br.call.sptk.many b6 = b7;;		\
+	.restore sp;				\
+        mov ar.pfs = r11
+#else
 #define DO_CALL(num)				\
 	mov r15=num;				\
 	break __BREAK_SYSCALL;
+#endif
 
 #undef PSEUDO_END
 #define PSEUDO_END(name)	.endp C_SYMBOL_NAME(name);
Index: sysdeps/unix/sysv/linux/ia64/vfork.S
===================================================================
RCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/ia64/vfork.S,v
retrieving revision 1.4
diff -u -w -r1.4 vfork.S
--- sysdeps/unix/sysv/linux/ia64/vfork.S	31 Dec 2002 20:37:30 -0000	1.4
+++ sysdeps/unix/sysv/linux/ia64/vfork.S	9 Apr 2003 02:10:20 -0000
@@ -34,9 +34,13 @@
 	mov out0=CLONE_VM+CLONE_VFORK+SIGCHLD
 	mov out1=0		/* Standard sp value.			*/
 	;;
+#if 0
 	DO_CALL (SYS_ify (clone))
+#else
+	mov r15=SYS_ify(clone)
+	break __BREAK_SYSCALL
+#endif
 	cmp.eq p6,p0=-1,r10
-	;;
 (p6)	br.cond.spnt.few __syscall_error
 	ret
 PSEUDO_END(__vfork)

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nptl-0-34-fsyscall.diff"

Index: allocatestack.c
===================================================================
RCS file: /home/ianw/cvs/nptl/allocatestack.c,v
retrieving revision 1.1.1.3
retrieving revision 1.5
diff -u -r1.1.1.3 -r1.5
Index: descr.h
===================================================================
RCS file: /home/ianw/cvs/nptl/descr.h,v
retrieving revision 1.1.1.3
retrieving revision 1.7
diff -u -r1.1.1.3 -r1.7
--- descr.h	3 Apr 2003 01:02:57 -0000	1.1.1.3
+++ descr.h	7 Apr 2003 02:54:09 -0000	1.7
@@ -62,10 +62,16 @@
 #if !TLS_DTV_AT_TP
     /* This overlaps the TCB as used for TLS without threads (see tls.h).  */
     tcbhead_t header;
-#elif TLS_MULTIPLE_THREADS_IN_TCB
+    /* For arch's who don't have room in the TCB */
+#elif (TLS_MULTIPLE_THREADS_IN_TCB || TLS_SYSINFO_IN_TCB)
     struct
     {
+      #if TLS_MULTIPLE_THREADS_IN_TCB
       int multiple_threads;
+      #endif
+      #if TLS_SYSINFO_IN_TCB
+      uintptr_t sysinfo;
+      #endif
     } header;
 #endif
 
Index: sysdeps/ia64/tcb-offsets.sym
===================================================================
RCS file: /home/ianw/cvs/nptl/sysdeps/ia64/tcb-offsets.sym,v
retrieving revision 1.1.1.2
retrieving revision 1.5
diff -u -r1.1.1.2 -r1.5
--- sysdeps/ia64/tcb-offsets.sym	31 Mar 2003 00:07:19 -0000	1.1.1.2
+++ sysdeps/ia64/tcb-offsets.sym	7 Apr 2003 02:54:09 -0000	1.5
@@ -2,3 +2,7 @@
 #include <tls.h>
 
 MULTIPLE_THREADS_OFFSET offsetof (struct pthread, header.multiple_threads) - sizeof (struct pthread)
+
+#ifdef TLS_SYSINFO_IN_TCB
+SYSINFO_OFFSET		offsetof (struct pthread, header.sysinfo) - sizeof (struct pthread)
+#endif
Index: sysdeps/ia64/tls.h
===================================================================
RCS file: /home/ianw/cvs/nptl/sysdeps/ia64/tls.h,v
retrieving revision 1.1.1.1
retrieving revision 1.6
diff -u -r1.1.1.1 -r1.6
--- sysdeps/ia64/tls.h	31 Mar 2003 00:06:49 -0000	1.1.1.1
+++ sysdeps/ia64/tls.h	7 Apr 2003 02:54:09 -0000	1.6
@@ -27,6 +27,22 @@
 # include <stdlib.h>
 # include <list.h>
 
+/* TLS LAYOUT
+
+ The IA64 ABI specifies that after the thread pointer there is a
+ pointer to the DTV and a private pointer.  Consequently in NPTL the
+ thread descriptor is placed directly before the thread pointer (this
+ is significantly cleaner than using indirection with the private
+ pointer).
+
+ [struct pthread][dtv][private][static tls block]
+     tp (r13)----^
+ [ in descr.h   ][ tcbhead_t  ]
+
+ Note that space is made for the descriptor during TLS setup with the
+ use of TCB_PRE_TCB_SIZE.
+
+*/
 
 /* Type for the dtv.  */
 typedef union dtv
@@ -35,14 +51,16 @@
   void *pointer;
 } dtv_t;
 
-
 typedef struct
 {
   dtv_t *dtv;
   void *private;
 } tcbhead_t;
 
+/* As TCB_DTV_AT_TP doesn't allow us more room in the tcbhead defined
+   above, we have extra pointers in our thread descriptor.  */
 # define TLS_MULTIPLE_THREADS_IN_TCB 1
+# define TLS_SYSINFO_IN_TCB 1
 
 #else /* __ASSEMBLER__ */
 # include <tcb-offsets.h>
@@ -100,11 +118,21 @@
 #  define GET_DTV(descr) \
   (((tcbhead_t *) (descr))->dtv)
 
+/* The room for the thread descriptor is allocated thanks to setting
+   TLS_PRE_TCB_SIZE so we are safe set this here */
+#if NEED_DL_SYSINFO
+# define INIT_SYSINFO \
+  THREAD_SELF->header.sysinfo = GL(dl_sysinfo)
+#else
+# define INIT_SYSINFO
+#endif
+
 /* Code to initially initialize the thread pointer.  This might need
    special attention since 'errno' is not yet available and if the
-   operation can cause a failure 'errno' must not be touched.  */
-# define TLS_INIT_TP(thrdescr, secondcall) \
-  (__thread_self = (thrdescr), NULL)
+   operation can cause a failure 'errno' must not be touched.  This
+   should return a string error, but we really can't fail */
+#define TLS_INIT_TP(thrdescr, secondcall) \
+ ( __thread_self = (thrdescr) , INIT_SYSINFO , NULL )
 
 /* Return the address of the dtv for the current thread.  */
 #  define THREAD_DTV() \
Index: sysdeps/pthread/createthread.c
===================================================================
RCS file: /home/ianw/cvs/nptl/sysdeps/pthread/createthread.c,v
retrieving revision 1.1.1.3
retrieving revision 1.4
diff -u -r1.1.1.3 -r1.4
--- sysdeps/pthread/createthread.c	31 Mar 2003 00:13:16 -0000	1.1.1.3
+++ sysdeps/pthread/createthread.c	7 Apr 2003 02:54:09 -0000	1.4
@@ -113,7 +113,7 @@
 	}
     }
 
-#ifdef NEED_DL_SYSINFO
+#ifdef NEED_DL_SYSINFO 
   assert (THREAD_GETMEM (THREAD_SELF, header.sysinfo) == pd->header.sysinfo);
 #endif
 
Index: sysdeps/unix/sysv/linux/ia64/dl-sysdep.h
===================================================================
RCS file: sysdeps/unix/sysv/linux/ia64/dl-sysdep.h
diff -N sysdeps/unix/sysv/linux/ia64/dl-sysdep.h
--- /dev/null	1 Jan 1970 00:00:00 -0000
+++ sysdeps/unix/sysv/linux/ia64/dl-sysdep.h	31 Mar 2003 00:12:36 -0000	1.1
@@ -0,0 +1,44 @@
+/* System-specific settings for dynamic linker code.  IA-64 version.
+   Copyright (C) 2003 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+   Contributed by David Mosberger <davidm@napali.hpl.hp.com>
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, write to the Free
+   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
+   02111-1307 USA.  */
+
+#ifndef _DL_SYSDEP_H
+#define _DL_SYSDEP_H	1
+
+#define NEED_DL_SYSINFO 1
+
+#ifndef __ASSEMBLER__
+/* Don't declare this as a function---we want it's entry-point, not
+   it's function descriptor... */
+extern int _dl_sysinfo_break attribute_hidden;
+# define DL_SYSINFO_DEFAULT ((uintptr_t) &_dl_sysinfo_break)
+# define DL_SYSINFO_IMPLEMENTATION			\
+  asm (".text\n\t"					\
+       ".hidden _dl_sysinfo_break\n\t"			\
+       ".proc _dl_sysinfo_break\n\t"			\
+       "_dl_sysinfo_break:\n\t"				\
+       ".prologue\n\t"					\
+       ".altrp b6\n\t"					\
+       ".body\n\t"					\
+       "break 0x100000;\n\t"				\
+       "br.ret.sptk.many b6;\n\t"			\
+       ".endp _dl_sysinfo_break");
+#endif
+
+#endif	/* dl-sysdep.h */
Index: sysdeps/unix/sysv/linux/ia64/lowlevellock.h
===================================================================
RCS file: /home/ianw/cvs/nptl/sysdeps/unix/sysv/linux/ia64/lowlevellock.h,v
retrieving revision 1.1.1.4
retrieving revision 1.2
diff -u -r1.1.1.4 -r1.2

--liOOAslEiF7prFVr--

