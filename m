From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 02 Nov 2004 02:39:19 +0000
Subject: [PATCH] IA64 build broken... cond_syscall()... Fixes?
Message-Id: <16774.62295.469676.663865@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew.Morton.akpm@osdl.org, Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


Hi Folks,
   The kernel 2.6 IA64 build has been broken for several days (see
http://www.gelato.unsw.edu.au/kerncomp )

The reason is that cond_syscall() for IA64 is defined as:

  #define cond_syscall(x) asmlinkage long x (void) \
	__attribute__((weak,alias("sys_ni_syscall")))   

which of course doesn't work if there's a prototype in scope for x,
unless the type of x just happens to be the same as for sys_ni_syscall.

Changing to the type-safe version
   #define cond_syscall(x) __typeof__ (x) x \
	   __attribute__((weak,alias("sys_ni_syscall")));
gives an error, e.g., 
 error: `compat_sys_futex' defined both normally and as an alias

Most architectures use inline assembly language which avoids the
problem.  However, we don't want to do this for IA64, to allow
compilers other than gcc to be used (in general, gcc generated code
for IA64 is extremely poor).

There are several ways to fix this.  The simple way is to ensure that
there are no prototypes for any system calls included in kernel/sys.c
(the only place where cond_syscall is used).  That's what this patch
does:



=== kernel/sys.c 1.97 vs edited ==--- 1.97/kernel/sys.c	2004-10-28 07:35:17 +10:00
+++ edited/kernel/sys.c	2004-11-02 13:34:33 +11:00
@@ -5,7 +5,6 @@
  */
 
 #include <linux/config.h>
-#include <linux/compat.h>
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/utsname.h>
@@ -25,8 +24,9 @@
 #include <linux/dcookies.h>
 #include <linux/suspend.h>
 
-/* Don't include this - it breaks ia64's cond_syscall() implementation */
+/* Don't include these - they break ia64's cond_syscall() implementation */
 #if 0
+#include <linux/compat.h>
 #include <linux/syscalls.h>
 #endif
 



--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
