From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 13 Sep 2004 12:26:56 +0000
Subject: BUG: 2.6.8/2.6.9  register corruption with PTRACE_SYSCALL
Message-Id: <20040913122656.GC30808@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To all,


David and I have tracked down a very nasty bug in the 2.6.8 and higher versions
of the Linux/ia64 kernel. The bug turned out to be due to the compiler. Here is
the description of the problem.

What is affected:
-----------------
	- all usage of the PTRACE_SYSCALL facility, such as done by the strace tool.

Which kernel versions:
----------------------
	- 2.6.8 and higher with CONFIG_AUDIT turned off

Symptoms:
---------
	A program run under strace dies with SIGSEGV whereas it works
	perfectly when run by itself.

	The traced program would die upon return from system calls such
	as brk() or pipe(). 

	Which system call is affected depends on the version of libc and
	whether the program is linked statically or shared. Some older libc
	stubs may mask the problem unvolontarily.

	
Why is that happening?
----------------------
	When a program is traced with PTRACE_SYSCALL, a stacked register
	corruption occurs on the parameters to the system call.s

	When returning from the system call some of the parameters to the
	system call may be re-used. The kernel normally guarantees that
	the parameters are preserved through the call.  Because of the bug,
	the guarantee is broken and r32 (in0) or other stakced registers may
	contain bogus values.

	If the libc stub happens to use the parameters upon return from the
	system call, it may fail. This is the case, for instance, with
	pipe(), where the 2 file descriptors are returned in registers
	and libc copies them into the array using the address in r32.

	The corruption comes from the fact that the parameters to
	the syscall are not preserved. Note that those parameters are
	passed directly in registers without any copy. They must be
	preserved such that the system call may be restarted with its
	initial parameters when needed.

	The constraint is enforced by a special function attribute
	called syscall_linkage. In the kernel it is used via the 
	"asmlinkage" macro. When the compiler sees the attribute,
	it treats all parameters to the function as read-only. Any
	modification requires making a copy first.

	In 2.6.8 new auditing code has been added to the kernel
	including on the PTRACE_SYSCALL path. The call path to
	the syscall_trace() function in ia64/kernel/ptrace.c has
	been modified and two new functions syscall_trace_enter()
	and syscall_trace_leave() have been added. Both functions
	do have the asmlinkage macro because they are directly exposed
	to the user level system call parameters.


	When the auditing system is not configured, both enter and
	leave functions are very simple and boil down to calling
	the old syscall_trace() function. This function has lost its
	syscall_linkage attribute because it is, in theory, never directly
	exposed to the user level syscall parameters anymore. This function
	has no parameter but it uses the stacked registers for locals.

	The problem is that the compiler performs a sibling call
	optimization between syscall_trace_leave() and syscall_trace()
	because syscall_trace() is at the very end of the function.
	That means that syscall_trace_leave() directly branches to
	syscall_trace() using a br.may instead of the typical br.call.
	This is perfectly legal because the stacked registers of
	syscall_trace_leave() are now considered "dead" because we are
	at the very end of the function and it has no return value.
	Then syscall_trace() returns to the parent of syscall_trace_leave()
	directly. With this optimization you save a br.ret.

	The br.many does not cause any RSE activity, hence the user level
	syscall parameters are now directly exposed to syscall_trace() which
	rightfully modifies them thereby corrupting the registers for the libc
	stub. The alloc instruction in that function simply resizes the frame
	and that does not protect the syscall parameters. 

	The bug is that the compiler performs the sibling call
	optimization and breaks the guarantee offered by the syscall_linkage
	attribute. 

	For such a function, the compiler should not attempt
	the optimization because it cannot guarantee that the callee
	does not modify the registers.

How to fix the problem?
-----------------------
	The kernel must be compiled with sibling call optimization turned off.

	This is accomplish by adding the -fno-optimize-sibling-calls to the
	CFLAGS in arch/ia64/Makefile

	A bug has been filed for gcc. A patch for the Makefile has been submitted
	to Tony Luck.

-- 
-Stephane
