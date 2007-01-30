From: "bibo,mao" <bibo.mao@intel.com>
Date: Tue, 30 Jan 2007 03:02:19 +0000
Subject: [Resend] ia64 find thread for user rbs address
Message-Id: <45BEB53B.9060506@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050701070603080605070009"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050701070603080605070009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

hi,
  I encountered one problem when running ptrace test case which
is in the attachment, the situation is this: traced process's
syscall parameter needs to be accessed, but for sys_clone system
call with clone_flag (CLONE_VFORK | CLONE_VM | SIGCHLD) parameter.
This syscall's parameter accessing result is wrong.

  The reason is that vforked child process mm point is the same,
but tgid is different. Without this patch find_thread_for_addr
will return vforked process if vforked process is also stopped,
but not the thread which calls vfork syscall.

thanks
bibo,mao

------------------------------------------------------------------
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index aa705e4..2131db4 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -607,7 +607,7 @@ find_thread_for_addr (struct task_struct
 	 */
  	list_for_each_safe(this, next, &current->children) {
 		p = list_entry(this, struct task_struct, sibling);
-		if (p->mm != mm)
+		if (p->tgid != child->tgid)
 			continue;
 		if (thread_matches(p, addr)) {
 			child = p;

--------------050701070603080605070009
Content-Type: text/plain;
 name="vfork.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vfork.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
#include <sched.h>
#include <asm/rse.h>
//#include <asm/ptrace.h>
#include <asm/ptrace_offsets.h>

#define PTRACE_EVENT_FORK 1
#define PTRACE_EVENT_VFORK 2
#define PTRACE_EVENT_CLONE 3
#define PTRACE_EVENT_EXEC 4
#define PTRACE_EVENT_VFORK_DONE 5
#define PTRACE_EVENT_EXIT 6
#define PTRACE_SETOPTIONS 0x4200
#define PTRACE_GETEVENTMSG 0x4201
#define PTRACE_O_TRACESYSGOOD 0x00000001
#define PTRACE_O_TRACEFORK 0x00000002
#define PTRACE_O_TRACEVFORK 0x00000004
#define PTRACE_O_TRACECLONE 0x00000008
#define PTRACE_O_TRACEEXEC 0x00000010
#define PTRACE_O_TRACEVFORKDONE 0x00000020
#define PTRACE_O_TRACEEXIT 0x00000040
#define PALL PTRACE_O_TRACEFORK | PTRACE_O_TRACEVFORK | PTRACE_O_TRACECLONE \
	| PTRACE_O_TRACEEXEC | PTRACE_O_TRACEVFORKDONE | PTRACE_O_TRACEEXIT

void fetch_clone_flags(pid_t pid, unsigned long* clone_flags)
{
	struct pt_all_user_regs ptregs;
	unsigned long bsp, cfm, sof, sol;
	unsigned long addr;
	long ret;

	ret = ptrace(PTRACE_GETREGS, pid, 0, (unsigned long)&ptregs);
	bsp = ptrace (PTRACE_PEEKUSER, pid, PT_AR_BSP, 0);
	cfm = ptrace (PTRACE_PEEKUSER, pid, PT_CFM, 0);
	sof = (cfm >> 0) & 0x7f;
	sol = (cfm >> 7) & 0x7f;
	bsp = (unsigned long) ia64_rse_skip_regs((void *) bsp, -sof + sol);
	addr= (unsigned long) ia64_rse_skip_regs((void *) bsp, 0);
	ret = ptrace (PTRACE_PEEKTEXT, pid, addr, (unsigned long) clone_flags);
	*clone_flags = ret;
}

/* Wrapper function for waitpid which handles EINTR.  */
static int my_waitpid (int pid, int *status, int flags)
{
  int ret;
  int old_status = status ? *status : 0;
  do {
      ret = waitpid (pid, status, flags);
    }
  while (ret == -1 && errno == EINTR);

  if (ret == 0 && status != 0) 
      *status = old_status;

  return ret;
}

int main() {
	unsigned long pid, npid ;
	int status, event,ret, child_status;
	char *stack ;
	unsigned long clone_flags;

	pid = fork();
	if(pid == 0)
	{
		ptrace(PTRACE_TRACEME,0,NULL,NULL) ;
		kill (getpid (), SIGSTOP);
		if (vfork() == 0){
			execve("/bin/true",NULL,NULL) ;
		}
		exit(0) ;
	}

	ret =  my_waitpid(pid, &status, 0);
	if (!WIFSTOPPED(status)) {
		perror("waitpid failed unexpected tstatus \n");
		return -1;
	}
	if (ptrace(PTRACE_SETOPTIONS,pid,NULL,PALL) < 0) {
		perror("PTRACE_SETOPTIONS not supported\n");
		return -1;
	}
	if (ptrace(PTRACE_CONT,pid,0,0) < 0) {
		perror("PTRACE_CONT \n");
		return -1;
	}
	if ( my_waitpid(pid,&status,0) < 0) {
		perror("wait4 failed");
		return -1;
	}
	event = (status >> 16) & 0xffff ;
	if (event == PTRACE_EVENT_FORK 
	    || event == PTRACE_EVENT_VFORK
	    || event == PTRACE_EVENT_CLONE) {
		if (ptrace(PTRACE_GETEVENTMSG,pid,NULL,&npid) < 0) {
			perror("PTRACE_GETEVENTMSG\n");
			return -1;
		}
		sleep(1);
		fetch_clone_flags(pid, &clone_flags);
		if (clone_flags == (CLONE_VFORK | CLONE_VM | SIGCHLD))
			printf("PTRACE_PEEKUSER succeed\n");	
		else
			printf("PTRACE_PEEKUSER failed\n");	
		if (my_waitpid(npid,&child_status,0) < 0) {
			perror("waitpid \n"); 
			return -1;
		}
		ptrace (PTRACE_KILL, npid, 0, 0);
		ptrace (PTRACE_KILL, pid, 0, 0); 
		//ptrace(PTRACE_CONT, npid, 0, WSTOPSIG(child_status));
		//ptrace(PTRACE_CONT, pid, 0, WSTOPSIG(status));
		my_waitpid(-1,&status,0);
	} 
	return 0 ;
}

--------------050701070603080605070009--
