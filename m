From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 27 Jul 2005 22:14:03 +0000
Subject: Add ia64 specific prefetch switch stack implementation
Message-Id: <200507272214.j6RME4g18779@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>, "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This patch adds ia64 specific implementation to prefetch switch stack
structure.  It applies on top of "add prefetch switch stack hook ..."
posted earlier.  Using my favorite industry standard OLTP workload, we
measured 6.2X reduction on cache misses occurred in the context switch
code and yielded about 0.2% performance gain on large scale db setup.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.12/arch/ia64/kernel/entry.S.orig	2005-07-27 14:43:25.853236577 -0700
+++ linux-2.6.12/arch/ia64/kernel/entry.S	2005-07-27 14:47:24.634483652 -0700
@@ -470,6 +470,29 @@ ENTRY(load_switch_stack)
 	br.cond.sptk.many b7
 END(load_switch_stack)
 
+GLOBAL_ENTRY(prefetch_switch_stack)
+	add r14 = -IA64_SWITCH_STACK_SIZE, sp
+	add r15 = IA64_TASK_THREAD_KSP_OFFSET, in0
+	;;
+	ld8 r16 = [r15]				// load next's stack pointer
+	lfetch.fault.excl [r14], 128
+	;;
+	lfetch.fault.excl [r14], 128
+	lfetch.fault [r16], 128
+	;;
+	lfetch.fault.excl [r14], 128
+	lfetch.fault [r16], 128
+	;;
+	lfetch.fault.excl [r14], 128
+	lfetch.fault [r16], 128
+	;;
+	lfetch.fault.excl [r14], 128
+	lfetch.fault [r16], 128
+	;;
+	lfetch.fault [r16], 128
+	br.ret.sptk.many rp
+END(prefetch_switch_stack)
+
 GLOBAL_ENTRY(execve)
 	mov r15=__NR_execve			// put syscall number in place
 	break __BREAK_SYSCALL
--- linux-2.6.12/include/asm-ia64/system.h.orig	2005-07-27 14:43:49.209681604 -0700
+++ linux-2.6.12/include/asm-ia64/system.h	2005-07-27 14:44:03.389368930 -0700
@@ -274,6 +274,7 @@ extern void ia64_load_extra (struct task
  */
 #define __ARCH_WANT_UNLOCKED_CTXSW
 
+#define ARCH_HAS_PREFETCH_SWITCH_STACK
 #define ia64_platform_is(x) (strcmp(x, platform_name) = 0)
 
 void cpu_idle_wait(void);


