From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 19 Mar 2013 00:03:03 +0000
Subject: fsys_getppid is broken on ia64.
Message-Id: <87boagxnm0.fsf@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


In particular fsys_getppid always returns the ppid in the initial pid
namespace so it does not work for a process in a pid namespace.

It looks like fsys_getppid has been broken for 5 years.  It sounds like
Pavel intended to fix this years ago but has never got around to it.

Since no one seems to care my inclination is that we should just kill it
and make getppid use the slow path.  Something like the patch below.  I
don't have access to an ia64 machine, or even an ia64 compiler anymore
so I can't even begin to test.

Tony, Fenghua do you think one of you could look at this?

Eric

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index c4cd45d..abc6dee 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -90,53 +90,6 @@ ENTRY(fsys_getpid)
 	FSYS_RETURN
 END(fsys_getpid)
 
-ENTRY(fsys_getppid)
-	.prologue
-	.altrp b6
-	.body
-	add r17=IA64_TASK_GROUP_LEADER_OFFSET,r16
-	;;
-	ld8 r17=[r17]				// r17 = current->group_leader
-	add r9=TI_FLAGS+IA64_TASK_SIZE,r16
-	;;
-
-	ld4 r9=[r9]
-	add r17=IA64_TASK_REAL_PARENT_OFFSET,r17 // r17 = &current->group_leader->real_parent
-	;;
-	and r9=TIF_ALLWORK_MASK,r9
-
-1:	ld8 r18=[r17]				// r18 = current->group_leader->real_parent
-	;;
-	cmp.ne p8,p0=0,r9
-	add r8=IA64_TASK_TGID_OFFSET,r18	// r8 = &current->group_leader->real_parent->tgid
-	;;
-
-	/*
-	 * The .acq is needed to ensure that the read of tgid has returned its data before
-	 * we re-check "real_parent".
-	 */
-	ld4.acq r8=[r8]				// r8 = current->group_leader->real_parent->tgid
-#ifdef CONFIG_SMP
-	/*
-	 * Re-read current->group_leader->real_parent.
-	 */
-	ld8 r19=[r17]				// r19 = current->group_leader->real_parent
-(p8)	br.spnt.many fsys_fallback_syscall
-	;;
-	cmp.ne p6,p0=r18,r19			// did real_parent change?
-	mov r19=0			// i must not leak kernel bits...
-(p6)	br.cond.spnt.few 1b			// yes -> redo the read of tgid and the check
-	;;
-	mov r17=0			// i must not leak kernel bits...
-	mov r18=0			// i must not leak kernel bits...
-#else
-	mov r17=0			// i must not leak kernel bits...
-	mov r18=0			// i must not leak kernel bits...
-	mov r19=0			// i must not leak kernel bits...
-#endif
-	FSYS_RETURN
-END(fsys_getppid)
-
 ENTRY(fsys_set_tid_address)
 	.prologue
 	.altrp b6
@@ -614,7 +567,7 @@ paravirt_fsyscall_table:
 	data8 0				// chown
 	data8 0				// lseek		// 1040
 	data8 fsys_getpid		// getpid
-	data8 fsys_getppid		// getppid
+	data8 0				// getppid
 	data8 0				// mount
 	data8 0				// umount
 	data8 0				// setuid		// 1045


