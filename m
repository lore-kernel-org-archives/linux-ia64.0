From: akpm@linux-foundation.org
Date: Fri, 28 Mar 2008 21:27:00 +0000
Subject: [patch 1/5] ia64: fix getpid and set_tid_address fast system calls for pid namespaces
Message-Id: <200803282127.m2SLR1Gt011039@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>

The sys_getpid() and sys_set_tid_address() behavior changed from

	return current->tgid

to

	struct pid *pid;
	pid = current->pids[PIDTYPE_PID].pid;
	return pid->numbers[pid->level].nr;

But the fast system calls on ia64 still operate the old way.  Patch them
appropriately to let ia64 work with pid namespaces.  Besides, this is one more
step in deprecating of pid and tgid on task_struct.

The fsys_getppid() is to be patched as well, but its logic is much
more complex now, so I will make it later.

One thing I'm not 100% sure is the trick with the IA64_UPID_SHIFT.  On order
to access the pid->level's element of an array I have to perform the following
calculations

	pid + sizeof(struct upid) * pid->level

The problem is that ia64 can only multiply float point registers, while all
the offsets I have in code are in rXX ones.  Fortunately, the sizeof(struct
upid) is 32 bytes on ia64 (and is very unlikely to ever change), so the
calculations get simpler:

	pid + pid->level << 5

So, I introduce the IA64_UPID_SHIFT and use the shl instruction.  I also
looked at how gcc compiles the similar place and found that it makes it with
shift as well.  Is this OK to do so?

Tested with ski emulator with 2.6.24 kernel, but fits 2.6.25-rc4 and
2.6.25-rc4-mm1 as well.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: David Mosberger-Tang <davidm@hpl.hp.com>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Amy Griffis <amy.griffis@hp.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/asm-offsets.c |    7 ++++++
 arch/ia64/kernel/fsys.S        |   34 +++++++++++++++++++++++++++----
 2 files changed, 37 insertions(+), 4 deletions(-)

diff -puN arch/ia64/kernel/asm-offsets.c~ia64-fix-getpid-and-set_tid_address-fast-system-calls-for-pid-namespaces arch/ia64/kernel/asm-offsets.c
--- a/arch/ia64/kernel/asm-offsets.c~ia64-fix-getpid-and-set_tid_address-fast-system-calls-for-pid-namespaces
+++ a/arch/ia64/kernel/asm-offsets.c
@@ -7,6 +7,7 @@
 #define ASM_OFFSETS_C 1
 
 #include <linux/sched.h>
+#include <linux/pid.h>
 #include <linux/clocksource.h>
 
 #include <asm-ia64/processor.h>
@@ -34,6 +35,9 @@ void foo(void)
 	DEFINE(SIGFRAME_SIZE, sizeof (struct sigframe));
 	DEFINE(UNW_FRAME_INFO_SIZE, sizeof (struct unw_frame_info));
 
+	BUILD_BUG_ON(sizeof(struct upid) != 32);
+	DEFINE(IA64_UPID_SHIFT, 5);
+
 	BLANK();
 
 	DEFINE(TI_FLAGS, offsetof(struct thread_info, flags));
@@ -51,6 +55,9 @@ void foo(void)
 	DEFINE(IA64_TASK_BLOCKED_OFFSET,offsetof (struct task_struct, blocked));
 	DEFINE(IA64_TASK_CLEAR_CHILD_TID_OFFSET,offsetof (struct task_struct, clear_child_tid));
 	DEFINE(IA64_TASK_GROUP_LEADER_OFFSET, offsetof (struct task_struct, group_leader));
+	DEFINE(IA64_TASK_TGIDLINK_OFFSET, offsetof (struct task_struct, pids[PIDTYPE_PID].pid));
+	DEFINE(IA64_PID_LEVEL_OFFSET, offsetof (struct pid, level));
+	DEFINE(IA64_PID_UPID_OFFSET, offsetof (struct pid, numbers[0]));
 	DEFINE(IA64_TASK_PENDING_OFFSET,offsetof (struct task_struct, pending));
 	DEFINE(IA64_TASK_PID_OFFSET, offsetof (struct task_struct, pid));
 	DEFINE(IA64_TASK_REAL_PARENT_OFFSET, offsetof (struct task_struct, real_parent));
diff -puN arch/ia64/kernel/fsys.S~ia64-fix-getpid-and-set_tid_address-fast-system-calls-for-pid-namespaces arch/ia64/kernel/fsys.S
--- a/arch/ia64/kernel/fsys.S~ia64-fix-getpid-and-set_tid_address-fast-system-calls-for-pid-namespaces
+++ a/arch/ia64/kernel/fsys.S
@@ -61,13 +61,29 @@ ENTRY(fsys_getpid)
 	.prologue
 	.altrp b6
 	.body
+	add r17=IA64_TASK_GROUP_LEADER_OFFSET,r16
+	;;
+	ld8 r17=[r17]				// r17 = current->group_leader
 	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
 	;;
 	ld4 r9=[r9]
-	add r8=IA64_TASK_TGID_OFFSET,r16
+	add r17=IA64_TASK_TGIDLINK_OFFSET,r17
 	;;
 	and r9=TIF_ALLWORK_MASK,r9
-	ld4 r8=[r8]				// r8 = current->tgid
+	ld8 r17=[r17]				// r17 = current->group_leader->pids[PIDTYPE_PID].pid
+	;;
+	add r8=IA64_PID_LEVEL_OFFSET,r17
+	;;
+	ld4 r8=[r8]				// r8 = pid->level
+	add r17=IA64_PID_UPID_OFFSET,r17	// r17 = &pid->numbers[0]
+	;;
+	shl r8=r8,IA64_UPID_SHIFT
+	;;
+	add r17=r17,r8				// r17 = &pid->numbers[pid->level]
+	;;
+	ld4 r8=[r17]				// r8 = pid->numbers[pid->level].nr
+	;;
+	mov r17=0
 	;;
 	cmp.ne p8,p0=0,r9
 (p8)	br.spnt.many fsys_fallback_syscall
@@ -126,15 +142,25 @@ ENTRY(fsys_set_tid_address)
 	.altrp b6
 	.body
 	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
+	add r17=IA64_TASK_TGIDLINK_OFFSET,r16
 	;;
 	ld4 r9=[r9]
 	tnat.z p6,p7=r32		// check argument register for being NaT
+	ld8 r17=[r17]				// r17 = current->pids[PIDTYPE_PID].pid
 	;;
 	and r9=TIF_ALLWORK_MASK,r9
-	add r8=IA64_TASK_PID_OFFSET,r16
+	add r8=IA64_PID_LEVEL_OFFSET,r17
 	add r18=IA64_TASK_CLEAR_CHILD_TID_OFFSET,r16
 	;;
-	ld4 r8=[r8]
+	ld4 r8=[r8]				// r8 = pid->level
+	add r17=IA64_PID_UPID_OFFSET,r17	// r17 = &pid->numbers[0]
+	;;
+	shl r8=r8,IA64_UPID_SHIFT
+	;;
+	add r17=r17,r8				// r17 = &pid->numbers[pid->level]
+	;;
+	ld4 r8=[r17]				// r8 = pid->numbers[pid->level].nr
+	;;
 	cmp.ne p8,p0=0,r9
 	mov r17=-1
 	;;
_
