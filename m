From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:49:51 +0000
Subject: syscall improvement patch [1/12]
Message-Id: <200503240049.j2O0npme022262@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: __ia64_syscall() is no longer used anywhere in the kernel.  Remove it.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/entry.S 1.82 vs edited ==--- 1.82/arch/ia64/kernel/entry.S	2005-03-23 11:09:53 -08:00
+++ edited/arch/ia64/kernel/entry.S	2005-03-23 11:07:29 -08:00
@@ -470,18 +470,6 @@
 	br.cond.sptk.many b7
 END(load_switch_stack)
 
-GLOBAL_ENTRY(__ia64_syscall)
-	.regstk 6,0,0,0
-	mov r15=in5				// put syscall number in place
-	break __BREAK_SYSCALL
-	movl r2=errno
-	cmp.eq p6,p7=-1,r10
-	;;
-(p6)	st4 [r2]=r8
-(p6)	mov r8=-1
-	br.ret.sptk.many rp
-END(__ia64_syscall)
-
 GLOBAL_ENTRY(execve)
 	mov r15=__NR_execve			// put syscall number in place
 	break __BREAK_SYSCALL
=== arch/ia64/kernel/ia64_ksyms.c 1.38 vs edited ==--- 1.38/arch/ia64/kernel/ia64_ksyms.c	2005-01-04 18:48:23 -08:00
+++ edited/arch/ia64/kernel/ia64_ksyms.c	2005-03-23 11:13:28 -08:00
@@ -58,9 +58,6 @@
 EXPORT_SYMBOL(__strncpy_from_user);
 EXPORT_SYMBOL(__strnlen_user);
 
-#include <asm/unistd.h>
-EXPORT_SYMBOL(__ia64_syscall);
-
 /* from arch/ia64/lib */
 extern void __divsi3(void);
 extern void __udivsi3(void);
