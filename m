From: Joel GUILLET <Joel.Guillet@bull.net>
Date: Mon, 16 Dec 2002 16:07:18 +0000
Subject: [Linux-ia64] Use of __ia64_syscall() - syscall interface
Message-Id: <marc-linux-ia64-105590709805570@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello!

I tried to compile a C program using the sched_set/getaffinity interface
of the O(1) scheduler. (kernel 2.5.45 - ia64).
The problem is that the syscall is not implemented yet in the glibc (i'm
working with a 2.2.4, but I saw it wasn't either with 2.2.5).

Here is the way I _declared_ the syscall :

***********************************************
#ifndef _AFFINITY_H
#define _AFFINITY_H

#include <sched.h>
#include <unistd.h>
#include <linux/unistd.h>

#ifndef __NR_sched_setaffinity
#define __NR_sched_setaffinity 1231
#define __NR_sched_getaffinity 1232

_syscall3 (int, sched_setaffinity, pid_t, pid, unsigned int, len, unsigned long *, new_mask_ptr)
_syscall3 (int, sched_getaffinity, pid_t, pid, unsigned int *, user_len_ptr, unsigned long *, user_mask_ptr)

#endif /* __NR_sched_setaffinity */
#endif /* _AFFINITY_H */
***********************************************

This doesn't compile on a Itanium.
I got a "undefined reference to __ia64_syscall()"

So I found 2 ways to resolve my problem  :
- Using _syscall3(). The problem is that there is a "define" in
/usr/include/asm/unistd.h that converts this call into a __ia64_syscall(),
which is not exported by the glibc. So I extracted sysdep.o from libc.a
and I compiled my program with it. This works fine.

But, this method doesn't seem to be very clean.

- I found an other way of compiling it :
As I saw in some mail-lists, we should use the syscall() interface, I
changed the "define" in the headers file of my system
/usr/include/asm/unistd.h so that the pre-processor replaces _syscall3()
with a call to syscall() instead of __ia64_syscall() function.
If this solution is better, the headers file (/asm/unistd.h)
should perhaps be modified (please see the following diff file)


Is this a problem coming from my program, the libc, or the kernel headers ?
Is there another solution "cleaner" than these ones ?
Should we update the header file ?
Use directly another function to be able to use the syscall, in my program ?

Thanks for your help.

Joel GUILLET


*********************************

--- unistd.h.ref	Fri Dec 13 14:04:32 2002
+++ unistd.h	Fri Dec 13 14:12:08 2002
@@ -208,7 +208,7 @@

 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)

-extern long __ia64_syscall (long a0, long a1, long a2, long a3, long a4, long nr);
+/*extern long int syscall (long int a0, long a1, long a2, long a3, long a4, long nr);*/

 #define _syscall0(type,name)						\
 type									\
@@ -220,7 +220,7 @@
 	register long dummy4 __asm__ ("out3");				\
 	register long dummy5 __asm__ ("out4");				\
 									\
-	return __ia64_syscall(dummy1, dummy2, dummy3, dummy4, dummy5,	\
+	return syscall(dummy1, dummy2, dummy3, dummy4, dummy5,	\
 			      __NR_##name);				\
 }

@@ -233,7 +233,7 @@
 	register long dummy4 __asm__ ("out3");				\
 	register long dummy5 __asm__ ("out4");				\
 									\
-	return __ia64_syscall((long) arg1, dummy2, dummy3, dummy4,	\
+	return syscall((long) arg1, dummy2, dummy3, dummy4,	\
 			      dummy5, __NR_##name);			\
 }

@@ -245,7 +245,7 @@
 	register long dummy4 __asm__ ("out3");				\
 	register long dummy5 __asm__ ("out4");				\
 									\
-	return __ia64_syscall((long) arg1, (long) arg2, dummy3, dummy4,	\
+	return syscall((long) arg1, (long) arg2, dummy3, dummy4,	\
 			      dummy5, __NR_##name);			\
 }

@@ -256,7 +256,7 @@
 	register long dummy4 __asm__ ("out3");				\
 	register long dummy5 __asm__ ("out4");				\
 									\
-	return __ia64_syscall((long) arg1, (long) arg2, (long) arg3,	\
+	return syscall((long) arg1, (long) arg2, (long) arg3,	\
 			      dummy4, dummy5, __NR_##name);		\
 }

@@ -266,7 +266,7 @@
 {										\
 	register long dummy5 __asm__ ("out4");					\
 										\
-	return __ia64_syscall((long) arg1, (long) arg2, (long) arg3,		\
+	return syscall((long) arg1, (long) arg2, (long) arg3,		\
 			      (long) arg4, dummy5, __NR_##name);		\
 }

@@ -274,7 +274,7 @@
 type											\
 name (type1 arg1, type2 arg2, type3 arg3, type4 arg4, type5 arg5)			\
 {											\
-	return __ia64_syscall((long) arg1, (long) arg2, (long) arg3,			\
+	return syscall((long) arg1, (long) arg2, (long) arg3,			\
 			      (long) arg4, (long) arg5, __NR_##name);			\
 }




