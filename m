From: Keith Owens <kaos@sgi.com>
Date: Mon, 15 Mar 2004 00:24:36 +0000
Subject: [patch] 2.6.4 remove intermittent warnings from spinlock code
Message-Id: <2465.1079310276@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The spinlock code writes to p14.  If gcc reuses p14 in the bundles
immediately after the spinlock then we get warning messages.  Append a
stop bit to the spinlock code to remove the warnings.  gcc 3.2.3,
binutils 2.14.90.0.4.

{standard input}: Assembler messages:
{standard input}:2217: Warning: Use of 'tbit.z' violates WAW dependency 'PR%, % in 1 - 15' (impliedf), specific resource number is 14
{standard input}:2217: Warning: Only the first path encountering the conflict is reported
{standard input}:2211: Warning: This is the location of the conflicting usage

Index: linux-2.6.4/include/asm-ia64/spinlock.h
--- linux-2.6.4.orig/include/asm-ia64/spinlock.h	Thu Mar 11 13:55:22 2004
+++ linux-2.6.4/include/asm-ia64/spinlock.h	Mon Mar 15 10:39:18 2004
@@ -52,6 +52,7 @@
 		      "cmp4.ne p14, p0 = r30, r0\n\t"
 		      "mov b6 = r29;;\n"
 		      "(p14) br.cond.spnt.many b6"
+		      ";;"
 		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
 # else
 	asm volatile ("{\n\t"
@@ -62,6 +63,7 @@
 		      "cmpxchg4.acq r30 = [%1], r30, ar.ccv;;\n\t"
 		      "cmp4.ne p14, p0 = r30, r0\n"
 		      "(p14) brl.cond.spnt.many ia64_spinlock_contention_pre3_4"
+		      ";;"
 		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
 # endif /* CONFIG_MCKINLEY */
 #else
@@ -75,6 +77,7 @@
 		      "cmp4.ne p14, p0 = r30, r0\n\t"
 		      "mov b6 = r29;;\n"
 		      "(p14) br.call.spnt.many b6 = b6"
+		      ";;"
 		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
 # else
 	asm volatile ("mov r30 = 1\n\t"
@@ -82,6 +85,7 @@
 		      "cmpxchg4.acq r30 = [%0], r30, ar.ccv;;\n\t"
 		      "cmp4.ne p14, p0 = r30, r0\n\t"
 		      "(p14) brl.call.spnt.many b6=ia64_spinlock_contention"
+		      ";;"
 		      : "=r"(ptr) : "r"(ptr) : IA64_SPINLOCK_CLOBBERS);
 # endif /* CONFIG_MCKINLEY */
 #endif

