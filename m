From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 29 Jul 2003 22:51:14 +0000
Subject: Re: A new patch for hint_pause
Message-Id: <marc-linux-ia64-105951916520159@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 02 July 2003 7:04 pm, you wrote:
> Attached is a new patch that should work only if the correct version of
> binutil is installed.  Let me know if you are okay with this.

I (finally) applied the attached patch for 2.4.  It's slightly different
than what you sent me because I reworked the processor.h changes
slightly to reduce the diff with 2.5.

I don't think this patch went to linux-ia64 originally, so I'm copying it
just as a heads-up.  (And to encourage people to copy the list so
we have a convenient archive).

Bjorn


#### AUTHOR rohit.seth@intel.com
#### COMMENT START
### Comments for ChangeSet
ia64: use "hint @pause" in cpu_relax() and spinlock contention.
### Comments for arch/ia64/scripts/make_gas_hint_test.c
Test case to determine whether gas supports "hint @pause".
### Comments for arch/ia64/scripts/make_gas_hint_test.c
BitKeeper file /home/helgaas/linux/testing/arch/ia64/scripts/make_gas_hint_test.c
### Comments for arch/ia64/Makefile
Check for binutils support of "hint @pause" and use -DGAS_HAS_HINT_INSN appropriately.
### Comments for arch/ia64/kernel/head.S
(ia64_spinlock_contention): Use "hint @pause".
### Comments for include/asm-ia64/processor.h
(cpu_relax): Use "hint @pause".
### Comments for include/asm-ia64/spinlock.h
(spin_lock, read_lock, write_lock): Use "hint @pause".
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1043  -> 1.1044 
#	  arch/ia64/Makefile	1.9     -> 1.10   
#	include/asm-ia64/spinlock.h	1.6     -> 1.7    
#	include/asm-ia64/processor.h	1.20    -> 1.21   
#	arch/ia64/kernel/head.S	1.9     -> 1.10   
#	               (new)	        -> 1.1     arch/ia64/scripts/make_gas_hint_test.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/29	bjorn.helgaas@hp.com	1.1044
# hint
# --------------------------------------------
#
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Tue Jul 29 17:18:01 2003
+++ b/arch/ia64/Makefile	Tue Jul 29 17:18:01 2003
@@ -24,6 +24,23 @@
 
 GCC_VERSION=$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f1 -d'.')
 
+CHECK_GAS_FOR_HINT=arch/ia64/scripts/check_gas_for_hint.o
+MAKE_GAS_HINT_TEST=arch/ia64/scripts/make_gas_hint_test
+
+ifneq (, $(shell ls $(CHECK_GAS_FOR_HINT)))
+$(shell rm $(CHECK_GAS_FOR_HINT))
+endif
+
+CHECK_GAS_CMD:=($(CC) $(MAKE_GAS_HINT_TEST).c -o $(MAKE_GAS_HINT_TEST) |$(AS) -o $(CHECK_GAS_FOR_HINT) -;rm $(MAKE_GAS_HINT_TEST))>&/dev/null
+$(shell $(CHECK_GAS_CMD))
+ifneq (, $(shell ls $(CHECK_GAS_FOR_HINT)))
+#Newer version of binutil is detected and "hint" instruction is in the kernel
+FLAGS := $(AFLAGS) -DGAS_HAS_HINT_INSN
+CFLAGS := $(CFLAGS) -DGAS_HAS_HINT_INSN
+else
+$(warning Warning: Please use binutil version 2.14.90.0.4.1 or higher to get the support of hint instruction in kernel.) 
+endif
+
 ifneq ($(GCC_VERSION),2)
 	CFLAGS += -frename-registers --param max-inline-insnsP00
 endif
diff -Nru a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
--- a/arch/ia64/kernel/head.S	Tue Jul 29 17:18:01 2003
+++ b/arch/ia64/kernel/head.S	Tue Jul 29 17:18:01 2003
@@ -782,6 +782,9 @@
 	;;
 	// delay a little...
 .wait:	sub tmp=tmp,timeout
+#ifdef GAS_HAS_HINT_INSN
+	hint @pause
+#endif
 	or delay=0xf,delay	// make sure delay is non-zero (otherwise we get stuck with 0)
 	;;
 	cmp.lt p15,p0=tmp,r0
diff -Nru a/arch/ia64/scripts/make_gas_hint_test.c b/arch/ia64/scripts/make_gas_hint_test.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/scripts/make_gas_hint_test.c	Tue Jul 29 17:18:01 2003
@@ -0,0 +1,15 @@
+// The code generates a test case which is used
+// to detect whether Binutil supports hint
+// instruction correctly or not.
+#include <string.h>
+#include <stdio.h>
+
+int main()
+{
+	char str[32766];
+	memset(str,'\n',32765);
+	str[32765]=0;
+	printf("%s(p7) hint @pause\n",str);
+
+	return 0;
+}
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Tue Jul 29 17:18:01 2003
+++ b/include/asm-ia64/processor.h	Tue Jul 29 17:18:01 2003
@@ -656,8 +656,18 @@
 	asm volatile ("mov cr.lrr0=%0;; srlz.d" :: "r"(val) : "memory");
 }
 
-#define cpu_relax()	do { } while (0)
+#ifdef GAS_HAS_HINT_INSN
+static inline void
+ia64_hint_pause (void)
+{
+	asm volatile ("hint @pause" ::: "memory");
+}
 
+#else
+#define ia64_hint_pause()	do { } while (0)
+#endif
+
+#define cpu_relax()	ia64_hint_pause()
 
 static inline void
 ia64_set_lrr1 (unsigned long val)
diff -Nru a/include/asm-ia64/spinlock.h b/include/asm-ia64/spinlock.h
--- a/include/asm-ia64/spinlock.h	Tue Jul 29 17:18:01 2003
+++ b/include/asm-ia64/spinlock.h	Tue Jul 29 17:18:01 2003
@@ -74,6 +74,12 @@
 #define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
 #define spin_lock_init(x)			((x)->lock = 0)
 
+#ifdef GAS_HAS_HINT_INSN
+#define HINT_PAUSE	";; (p7) hint @pause\n"
+#else
+#define HINT_PAUSE
+#endif										
+
 /*
  * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
  * rather than a simple xchg to avoid writing the cache-line when
@@ -87,6 +93,7 @@
 	"ld4 r2 = [%0]\n"					\
 	";;\n"							\
 	"cmp4.eq p0,p7 = r0,r2\n"				\
+	HINT_PAUSE 						\
 	"(p7) br.cond.spnt.few 1b \n"				\
 	"cmpxchg4.acq r2 = [%0], r29, ar.ccv\n"			\
 	";;\n"							\
@@ -115,20 +122,21 @@
 	int tmp = 0;								\
 	__asm__ __volatile__ ("1:\tfetchadd4.acq %0 = [%1], 1\n"		\
 			      ";;\n"						\
-			      "tbit.nz p6,p0 = %0, 31\n"			\
-			      "(p6) br.cond.sptk.few 2f\n"			\
+			      "tbit.nz p7,p0 = %0, 31\n"			\
+			      "(p7) br.cond.sptk.few 2f\n"			\
 			      ".section .text.lock,\"ax\"\n"			\
 			      "2:\tfetchadd4.rel %0 = [%1], -1\n"		\
 			      ";;\n"						\
 			      "3:\tld4.acq %0 = [%1]\n"				\
 			      ";;\n"						\
-			      "tbit.nz p6,p0 = %0, 31\n"			\
-			      "(p6) br.cond.sptk.few 3b\n"			\
+			      "tbit.nz p7,p0 = %0, 31\n"			\
+			      HINT_PAUSE					\
+			      "(p7) br.cond.sptk.few 3b\n"			\
 			      "br.cond.sptk.few 1b\n"				\
 			      ";;\n"						\
 			      ".previous\n"					\
 			      : "=&r" (tmp)					\
-			      : "r" (rw) : "p6", "memory");			\
+			      : "r" (rw) : "p7", "memory");			\
 } while(0)
 
 #define read_unlock(rw)								\
@@ -150,6 +158,7 @@
 		"ld4 r2 = [%0]\n"						\
 		";;\n"								\
 		"cmp4.eq p0,p7 = r0,r2\n"					\
+		HINT_PAUSE							\
 		"(p7) br.cond.spnt.few 1b \n"					\
 		"cmpxchg4.acq r2 = [%0], r29, ar.ccv\n"				\
 		";;\n"								\

