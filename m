From: "bibo,mao" <bibo.mao@intel.com>
Date: Wed, 31 Jan 2007 09:50:31 +0000
Subject: [Patch] ia64 enable singlestep on system call
Message-Id: <45C06667.9080904@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000607080709000404050409"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Roland McGrath <roland@redhat.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>

This is a multi-part message in MIME format.
--------------000607080709000404050409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

hi,
 As is pointed out in 
http://www.gelato.org/community/view_linear.php?id=1_1036&from=authors&value=Ian%20Wienand#1_1039,
if single step on break instruction, the break fault has higher
priority than the single-step trap. When the break fault handler
is entered, it advances the IP by 1 instruction so break instruction
single-stepping is skipped, actually it is next instruction which
is single stepped.

 This patch modifies this, it adds TIF_SINGLESTEP bit for thread
flags, and generate a fake sigtrap when single stepping break
instruction. Test case in attachment can verify this. Any comments
is welcome.

Signed-off-by: bibo, mao <bibo.mao@intel.com>

thanks
bibo,mao 

--------------------------------------------------------
 arch/ia64/kernel/ptrace.c      |   12 ++++++------
 include/asm-ia64/thread_info.h |    4 +++-
 2 files changed, 9 insertions(+), 7 deletions(-)

diff -Nrup -X /root/dontdiff 2.6.20-rc6.org/arch/ia64/kernel/ptrace.c 2.6.20-rc6/arch/ia64/kernel/ptrace.c
--- 2.6.20-rc6.org/arch/ia64/kernel/ptrace.c	2006-09-25 15:20:42.000000000 +0800
+++ 2.6.20-rc6/arch/ia64/kernel/ptrace.c	2007-01-31 18:04:45.000000000 +0800
@@ -1405,6 +1405,7 @@ ptrace_disable (struct task_struct *chil
 	struct ia64_psr *child_psr = ia64_psr(task_pt_regs(child));
 
 	/* make sure the single step/taken-branch trap bits are not set: */
+	clear_tsk_thread_flag(child, TIF_SINGLESTEP);
 	child_psr->ss = 0;
 	child_psr->tb = 0;
 }
@@ -1525,6 +1526,7 @@ sys_ptrace (long request, pid_t pid, uns
 		 * Make sure the single step/taken-branch trap bits
 		 * are not set:
 		 */
+		clear_tsk_thread_flag(child, TIF_SINGLESTEP);
 		ia64_psr(pt)->ss = 0;
 		ia64_psr(pt)->tb = 0;
 
@@ -1556,6 +1558,7 @@ sys_ptrace (long request, pid_t pid, uns
 			goto out_tsk;
 
 		clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
+		set_tsk_thread_flag(child, TIF_SINGLESTEP);
 		if (request == PTRACE_SINGLESTEP) {
 			ia64_psr(pt)->ss = 1;
 		} else {
@@ -1595,13 +1598,9 @@ sys_ptrace (long request, pid_t pid, uns
 }
 
 
-void
+static void
 syscall_trace (void)
 {
-	if (!test_thread_flag(TIF_SYSCALL_TRACE))
-		return;
-	if (!(current->ptrace & PT_PTRACED))
-		return;
 	/*
 	 * The 0x80 provides a way for the tracing parent to
 	 * distinguish between a syscall stop and SIGTRAP delivery.
@@ -1664,7 +1663,8 @@ syscall_trace_leave (long arg0, long arg
 		audit_syscall_exit(success, result);
 	}
 
-	if (test_thread_flag(TIF_SYSCALL_TRACE)
+	if ((test_thread_flag(TIF_SYSCALL_TRACE)
+	    || test_thread_flag(TIF_SINGLESTEP))
 	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
 }
diff -Nrup -X /root/dontdiff 2.6.20-rc6.org/include/asm-ia64/thread_info.h 2.6.20-rc6/include/asm-ia64/thread_info.h
--- 2.6.20-rc6.org/include/asm-ia64/thread_info.h	2007-01-30 17:57:16.000000000 +0800
+++ 2.6.20-rc6/include/asm-ia64/thread_info.h	2007-01-31 18:01:48.000000000 +0800
@@ -84,6 +84,7 @@ struct thread_info {
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_SYSCALL_TRACE	3	/* syscall trace active */
 #define TIF_SYSCALL_AUDIT	4	/* syscall auditing active */
+#define TIF_SINGLESTEP		5	/* restore singlestep on return to user mode */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
@@ -92,7 +93,8 @@ struct thread_info {
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
-#define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT)
+#define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
+#define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)

--------------000607080709000404050409
Content-Type: text/plain;
 name="singlestep.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="singlestep.c"

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
//#include <asm/ptrace.h>
#include <asm/ptrace_offsets.h>

char *prog_name;

/* this is entry address in kernel gate page for break syscall 
 * this macro need be changed with kernel
 */
#define __kernel_syscall_via_break 0xa000000000010620UL

/* here is syscall_via_break code in kernel side, break instruction
 * is the first slot of the bundle
 * GLOBAL_ENTRY(__kernel_syscall_via_break)
 * { .mib
 *       break 0x100000
 *       nop.i 0
 *       br.ret.sptk.many b6
 *}
*/
static int singlestep_slot1, singlestep_slot2;
void print_instruction (int child_pid, int state)
{
	long ip, slot;
	unsigned long psr;

	ip = ptrace (PTRACE_PEEKUSER, child_pid, PT_CR_IIP, 0);
	psr = ptrace(PTRACE_PEEKUSER, child_pid, PT_CR_IPSR, 0);
	slot = (psr >> 41) & 0x3;
	if (ip == __kernel_syscall_via_break) {
		if (slot == 1)
			singlestep_slot1++;
		else if (slot == 2)
			singlestep_slot2++;
	} 
}

int main (int argc, char **argv, char **envp)
{
	int status, pid, child_pid, state = 1, arg = 1;
	int ret;

	singlestep_slot1 = singlestep_slot2 = 0;
	prog_name = argv[0];

	child_pid = fork ();
	if (child_pid == 0)
	{
		ptrace (PTRACE_TRACEME, 0, 0, 0);
		execve (argv[arg], argv + arg, envp);
		printf ("%s: execve failed (errno=%d)\n", prog_name, errno);
		exit(-2);
	}

	while (1)
	{
		pid = wait4 (-1, &status, 0, 0);
		if (pid == -1)
		{
			if (errno == EINTR)
				continue;

			printf ("%s: wait4() failed (errno=%d)\n", prog_name, errno);
		}
		if (WIFSIGNALED (status) || WIFEXITED (status)
				|| (WIFSTOPPED (status) && WSTOPSIG (status) != SIGTRAP))
		{
			if (WIFEXITED (status))
			{
				printf ("%s: exit status %d\n", prog_name, WEXITSTATUS (status));
				break;
			}
			else if (WIFSIGNALED (status))
			{
				printf ("%s: terminated by signal %d\n",
						prog_name, WTERMSIG (status));
			}
			else {
				printf ("%s: got signal %d\n", prog_name, WSTOPSIG (status));
			}
		}
		print_instruction (child_pid, state);
		ptrace (PTRACE_SINGLESTEP, child_pid, 0, 0);
	}
	if (WEXITSTATUS (status) == 0) {
		if (singlestep_slot1 == 0)
			printf("single step on syscall failed\n");
		else {
			printf("single step on syscall succeed\n");
			printf("single step on break bundle slot 0: %d slot 1: %d \n",
					singlestep_slot1, singlestep_slot2);
		}
	}
	return 0;
}

--------------000607080709000404050409--
