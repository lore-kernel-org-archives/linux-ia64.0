From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Feb 2003 08:37:05 +0000
Subject: [Linux-ia64] unwind info fix for ia64
Message-Id: <marc-linux-ia64-105590709805928@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a small bug-fix for libc's __syscall_error to get the unwind
info correct.  Did "make check" afterwards and ran a test program to
verify that unwinding works correctly now for this function.

	--david

2003-02-24    <davidm@hpl.hp.com>

	* sysdeps/unix/sysv/linux/ia64/sysdep.S (__syscall_error): Fix
	unwind info.

Index: sysdeps/unix/sysv/linux/ia64/sysdep.S
=================================RCS file: /cvs/glibc/libc/sysdeps/unix/sysv/linux/ia64/sysdep.S,v
retrieving revision 1.5
diff -u -r1.5 sysdep.S
--- sysdeps/unix/sysv/linux/ia64/sysdep.S	11 Oct 2002 10:51:24 -0000	1.5
+++ sysdeps/unix/sysv/linux/ia64/sysdep.S	25 Feb 2003 08:30:31 -0000
@@ -1,4 +1,4 @@
-/* Copyright (C) 1999, 2000, 2001 Free Software Foundation, Inc.
+/* Copyright (C) 1999, 2000, 2001, 2003 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
    Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
 
@@ -23,18 +23,19 @@
 ENTRY(__syscall_error)
 #ifdef _LIBC_REENTRANT
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(0)
-	alloc	r35=ar.pfs, 0, 4, 0, 0
+	alloc	r33=ar.pfs, 0, 4, 0, 0
 	mov	r32=rp
-	mov	r33=r8
+	.body
+	mov	r35=r8
 	mov	r34=r1
 	;;
-	br.call.sptk.many b0 = __errno_location#
+	br.call.sptk.many b0 = __errno_location
 .Lret0:		/* force new bundle */
-	st4	[r8]=r33
+	st4	[r8]=r35
 	mov	r1=r34
 	mov	rp=r32
 	mov	r8=-1
-	mov	ar.pfs=r35
+	mov	ar.pfs=r33
 #else /* _LIBC_REENTRANT */
 	/*
 	 * Note that the gp has to be set properly for this to work.

