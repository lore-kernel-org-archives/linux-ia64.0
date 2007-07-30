From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 30 Jul 2007 17:21:15 +0000
Subject: Re: [PATCH] remove unused TIF_NOTIFY_RESUME (take 2)
Message-Id: <20070730102115.cac237ea.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070730093034.GD25162@frankl.hpl.hp.com>
In-Reply-To: <20070730093034.GD25162@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: linux-kernel@vger.kernel.org, ak@suse.de, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Mon, 30 Jul 2007 02:30:34 -0700 Stephane Eranian <eranian@hpl.hp.com> wrote:

> This following patch removes the TIF_NOTIFY_RESUME flag for thread_info. It is unused
> on all but the IA-64 architecture. This is take 2 of this patch. In this version,
> The definition is removed but no re-numbering of the TIF flags is done to minimize
> the possibility of errors and reduce the size of the patch.
> 
> For IA-64, we ran out of low-order bits (first 7 bits). Adding a bit for perfmon
> would cause important code rescheduling changes in the kernel entry/exit path. Instead,
> we replace TIF_NOTIFY_RESUME with TIF_PERFMON_WORK. This way we get very close to what the
> new perfmon code base is doing.

This has been (painfully) maintained in -mm for quite a long time.  I've
been waiting for everyone else to merge their stuff so I can get it in
without disrupting them.  This has now happened.

I think it'd be better to merge the larger patch - it's a bit tidier and
more tested, OK?



From: Stephane Eranian <eranian@hpl.hp.com>

Remove unused TIF_NOTIFY_RESUME flag for all processor architectures.  The
flag was not used excecpt on IA-64 where the patch replaces it with
TIF_PERFMON_WORK.

Signed-off-by: stephane eranian <eranian@hpl.hp.com>
Cc: <linux-arch@vger.kernel.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/arm/kernel/entry-common.S      |    2 -
 arch/arm26/kernel/entry.S           |    2 -
 arch/ia64/kernel/perfmon.c          |    4 +-
 arch/powerpc/kernel/entry_64.S      |    1 
 arch/x86_64/kernel/entry.S          |    6 ++--
 include/asm-alpha/thread_info.h     |   24 +++++++----------
 include/asm-arm/thread_info.h       |    7 +----
 include/asm-arm26/thread_info.h     |    7 +----
 include/asm-avr32/thread_info.h     |   18 +++++--------
 include/asm-blackfin/thread_info.h  |   14 ++++------
 include/asm-cris/thread_info.h      |    6 +---
 include/asm-frv/thread_info.h       |   12 +++-----
 include/asm-h8300/thread_info.h     |   12 +++-----
 include/asm-i386/thread_info.h      |   18 +++++--------
 include/asm-ia64/thread_info.h      |   20 +++++++-------
 include/asm-m32r/thread_info.h      |   10 ++-----
 include/asm-m68knommu/thread_info.h |   10 ++-----
 include/asm-mips/thread_info.h      |   10 ++-----
 include/asm-parisc/thread_info.h    |   16 +++++------
 include/asm-powerpc/thread_info.h   |   36 ++++++++++++--------------
 include/asm-sh/thread_info.h        |   10 ++-----
 include/asm-v850/thread_info.h      |   10 ++-----
 include/asm-x86_64/thread_info.h    |    2 -
 include/asm-xtensa/thread_info.h    |   14 ++++------
 24 files changed, 116 insertions(+), 155 deletions(-)

diff -puN arch/arm26/kernel/entry.S~remove-unused-tif_notify_resume-flag arch/arm26/kernel/entry.S
--- a/arch/arm26/kernel/entry.S~remove-unused-tif_notify_resume-flag
+++ a/arch/arm26/kernel/entry.S
@@ -194,7 +194,7 @@ fast_work_pending:
 work_pending:
 	tst	r1, #_TIF_NEED_RESCHED
 	bne	work_resched
-	tst	r1, #_TIF_NOTIFY_RESUME | _TIF_SIGPENDING
+	tst	r1, #_TIF_SIGPENDING
 	beq	no_work_pending
 	mov	r0, sp				@ 'regs'
 	mov	r2, why				@ 'syscall'
diff -puN arch/arm/kernel/entry-common.S~remove-unused-tif_notify_resume-flag arch/arm/kernel/entry-common.S
--- a/arch/arm/kernel/entry-common.S~remove-unused-tif_notify_resume-flag
+++ a/arch/arm/kernel/entry-common.S
@@ -46,7 +46,7 @@ fast_work_pending:
 work_pending:
 	tst	r1, #_TIF_NEED_RESCHED
 	bne	work_resched
-	tst	r1, #_TIF_NOTIFY_RESUME | _TIF_SIGPENDING
+	tst	r1, #_TIF_SIGPENDING
 	beq	no_work_pending
 	mov	r0, sp				@ 'regs'
 	mov	r2, why				@ 'syscall'
diff -puN arch/ia64/kernel/perfmon.c~remove-unused-tif_notify_resume-flag arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c~remove-unused-tif_notify_resume-flag
+++ a/arch/ia64/kernel/perfmon.c
@@ -591,13 +591,13 @@ pfm_set_task_notify(struct task_struct *
 	struct thread_info *info;
 
 	info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
-	set_bit(TIF_NOTIFY_RESUME, &info->flags);
+	set_bit(TIF_PERFMON_WORK, &info->flags);
 }
 
 static inline void
 pfm_clear_task_notify(void)
 {
-	clear_thread_flag(TIF_NOTIFY_RESUME);
+	clear_thread_flag(TIF_PERFMON_WORK);
 }
 
 static inline void
diff -puN arch/powerpc/kernel/entry_64.S~remove-unused-tif_notify_resume-flag arch/powerpc/kernel/entry_64.S
--- a/arch/powerpc/kernel/entry_64.S~remove-unused-tif_notify_resume-flag
+++ a/arch/powerpc/kernel/entry_64.S
@@ -546,7 +546,6 @@ END_FW_FTR_SECTION_IFSET(FW_FEATURE_ISER
 	rfid
 	b	.	/* prevent speculative execution */
 
-/* Note: this must change if we start using the TIF_NOTIFY_RESUME bit */
 do_work:
 #ifdef CONFIG_PREEMPT
 	andi.	r0,r3,MSR_PR	/* Returning to user mode? */
diff -puN arch/x86_64/kernel/entry.S~remove-unused-tif_notify_resume-flag arch/x86_64/kernel/entry.S
--- a/arch/x86_64/kernel/entry.S~remove-unused-tif_notify_resume-flag
+++ a/arch/x86_64/kernel/entry.S
@@ -282,7 +282,7 @@ sysret_careful:
 sysret_signal:
 	TRACE_IRQS_ON
 	sti
-	testl $(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz    1f
 
 	/* Really a signal */
@@ -375,7 +375,7 @@ int_very_careful:
 	jmp int_restore_rest
 	
 int_signal:
-	testl $(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz 1f
 	movq %rsp,%rdi		# &ptregs -> arg1
 	xorl %esi,%esi		# oldset -> arg2
@@ -599,7 +599,7 @@ retint_careful:
 	jmp retint_check
 	
 retint_signal:
-	testl $(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz    retint_swapgs
 	TRACE_IRQS_ON
 	sti
diff -puN include/asm-alpha/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-alpha/thread_info.h
--- a/include/asm-alpha/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-alpha/thread_info.h
@@ -67,28 +67,24 @@ register struct thread_info *__current_t
  * TIF_SYSCALL_TRACE is known to be 0 via blbs.
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_POLLING_NRFLAG	4	/* poll_idle is polling NEED_RESCHED */
-#define TIF_DIE_IF_KERNEL	5	/* dik recursion lock */
-#define TIF_UAC_NOPRINT		6	/* see sysinfo.h */
-#define TIF_UAC_NOFIX		7
-#define TIF_UAC_SIGBUS		8
-#define TIF_MEMDIE		9
-#define TIF_RESTORE_SIGMASK	10	/* restore signal mask in do_signal */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_POLLING_NRFLAG	3	/* poll_idle is polling NEED_RESCHED */
+#define TIF_DIE_IF_KERNEL	4	/* dik recursion lock */
+#define TIF_UAC_NOPRINT		5	/* see sysinfo.h */
+#define TIF_UAC_NOFIX		6
+#define TIF_UAC_SIGBUS		7
+#define TIF_MEMDIE		8
+#define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 
 /* Work to do on interrupt/exception return.  */
-#define _TIF_WORK_MASK		(_TIF_NOTIFY_RESUME	\
-				 | _TIF_SIGPENDING	\
-				 | _TIF_NEED_RESCHED)
+#define _TIF_WORK_MASK		(_TIF_SIGPENDING | _TIF_NEED_RESCHED)
 
 /* Work to do on any return to userspace.  */
 #define _TIF_ALLWORK_MASK	(_TIF_WORK_MASK		\
diff -puN include/asm-arm26/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-arm26/thread_info.h
--- a/include/asm-arm26/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-arm26/thread_info.h
@@ -110,21 +110,18 @@ extern void free_thread_info(struct thre
 /*
  * thread information flags:
  *  TIF_SYSCALL_TRACE	- syscall trace active
- *  TIF_NOTIFY_RESUME	- resumption notification requested
  *  TIF_SIGPENDING	- signal pending
  *  TIF_NEED_RESCHED	- rescheduling necessary
  *  TIF_USEDFPU		- FPU was used by this task this quantum (SMP)
  *  TIF_POLLING_NRFLAG	- true if poll_idle() is polling TIF_NEED_RESCHED
  */
-#define TIF_NOTIFY_RESUME	0
-#define TIF_SIGPENDING		1
-#define TIF_NEED_RESCHED	2
+#define TIF_SIGPENDING		0
+#define TIF_NEED_RESCHED	1
 #define TIF_SYSCALL_TRACE	8
 #define TIF_USED_FPU		16
 #define TIF_POLLING_NRFLAG	17
 #define TIF_MEMDIE		18
 
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
diff -puN include/asm-arm/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-arm/thread_info.h
--- a/include/asm-arm/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-arm/thread_info.h
@@ -134,22 +134,19 @@ extern void iwmmxt_task_switch(struct th
 /*
  * thread information flags:
  *  TIF_SYSCALL_TRACE	- syscall trace active
- *  TIF_NOTIFY_RESUME	- resumption notification requested
  *  TIF_SIGPENDING	- signal pending
  *  TIF_NEED_RESCHED	- rescheduling necessary
  *  TIF_USEDFPU		- FPU was used by this task this quantum (SMP)
  *  TIF_POLLING_NRFLAG	- true if poll_idle() is polling TIF_NEED_RESCHED
  */
-#define TIF_NOTIFY_RESUME	0
-#define TIF_SIGPENDING		1
-#define TIF_NEED_RESCHED	2
+#define TIF_SIGPENDING		0
+#define TIF_NEED_RESCHED	1
 #define TIF_SYSCALL_TRACE	8
 #define TIF_POLLING_NRFLAG	16
 #define TIF_USING_IWMMXT	17
 #define TIF_MEMDIE		18
 #define TIF_FREEZE		19
 
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
diff -puN include/asm-avr32/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-avr32/thread_info.h
--- a/include/asm-avr32/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-avr32/thread_info.h
@@ -74,20 +74,18 @@ static inline struct thread_info *curren
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE       0       /* syscall trace active */
-#define TIF_NOTIFY_RESUME       1       /* resumption notification requested */
-#define TIF_SIGPENDING          2       /* signal pending */
-#define TIF_NEED_RESCHED        3       /* rescheduling necessary */
-#define TIF_POLLING_NRFLAG      4       /* true if poll_idle() is polling
+#define TIF_SIGPENDING          1       /* signal pending */
+#define TIF_NEED_RESCHED        2       /* rescheduling necessary */
+#define TIF_POLLING_NRFLAG      3       /* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_BREAKPOINT		5	/* true if we should break after return */
-#define TIF_SINGLE_STEP		6	/* single step after next break */
-#define TIF_MEMDIE		7
-#define TIF_RESTORE_SIGMASK	8	/* restore signal mask in do_signal */
-#define TIF_CPU_GOING_TO_SLEEP	9	/* CPU is entering sleep 0 mode */
+#define TIF_BREAKPOINT		4	/* true if we should break after return */
+#define TIF_SINGLE_STEP		5	/* single step after next break */
+#define TIF_MEMDIE		6
+#define TIF_RESTORE_SIGMASK	7	/* restore signal mask in do_signal */
+#define TIF_CPU_GOING_TO_SLEEP	8	/* CPU is entering sleep 0 mode */
 #define TIF_USERSPACE		31      /* true if FS sets userspace */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
diff -puN include/asm-blackfin/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-blackfin/thread_info.h
--- a/include/asm-blackfin/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-blackfin/thread_info.h
@@ -118,18 +118,16 @@ static inline struct thread_info *curren
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_MEMDIE              5
-#define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
-#define TIF_FREEZE              7       /* is freezing for suspend */
+#define TIF_MEMDIE              4
+#define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
+#define TIF_FREEZE              6       /* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff -puN include/asm-cris/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-cris/thread_info.h
--- a/include/asm-cris/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-cris/thread_info.h
@@ -79,14 +79,12 @@ struct thread_info {
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff -puN include/asm-frv/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-frv/thread_info.h
--- a/include/asm-frv/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-frv/thread_info.h
@@ -108,18 +108,16 @@ register struct thread_info *__current_t
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
-#define TIF_IRET		5	/* return with iret */
-#define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_SINGLESTEP		3	/* restore singlestep on return to user mode */
+#define TIF_IRET		4	/* return with iret */
+#define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17	/* OOM killer killed process */
 #define TIF_FREEZE		18	/* freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
diff -puN include/asm-h8300/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-h8300/thread_info.h
--- a/include/asm-h8300/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-h8300/thread_info.h
@@ -86,17 +86,15 @@ static inline struct thread_info *curren
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_MEMDIE		5
-#define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
+#define TIF_MEMDIE		4
+#define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff -puN include/asm-i386/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-i386/thread_info.h
--- a/include/asm-i386/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-i386/thread_info.h
@@ -124,15 +124,14 @@ static inline struct thread_info *curren
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
-#define TIF_IRET		5	/* return with iret */
-#define TIF_SYSCALL_EMU		6	/* syscall emulation active */
-#define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
-#define TIF_SECCOMP		8	/* secure computing */
-#define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_SINGLESTEP		3	/* restore singlestep on return to user mode */
+#define TIF_IRET		4	/* return with iret */
+#define TIF_SYSCALL_EMU		5	/* syscall emulation active */
+#define TIF_SYSCALL_AUDIT	6	/* syscall auditing active */
+#define TIF_SECCOMP		7	/* secure computing */
+#define TIF_RESTORE_SIGMASK	8	/* restore signal mask in do_signal() */
 #define TIF_MEMDIE		16
 #define TIF_DEBUG		17	/* uses debug registers */
 #define TIF_IO_BITMAP		18	/* uses I/O bitmap */
@@ -140,7 +139,6 @@ static inline struct thread_info *curren
 #define TIF_NOTSC		20	/* TSC is not accessible in userland */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
diff -puN include/asm-ia64/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-ia64/thread_info.h
--- a/include/asm-ia64/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-ia64/thread_info.h
@@ -79,13 +79,13 @@ struct thread_info {
  * - pending work-to-be-done flags are in least-significant 16 bits, other flags
  *   in top 16 bits
  */
-#define TIF_NOTIFY_RESUME	0	/* resumption notification requested */
-#define TIF_SIGPENDING		1	/* signal pending */
-#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
-#define TIF_SYSCALL_TRACE	3	/* syscall trace active */
-#define TIF_SYSCALL_AUDIT	4	/* syscall auditing active */
-#define TIF_SINGLESTEP		5	/* restore singlestep on return to user mode */
-#define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
+#define TIF_SIGPENDING		0	/* signal pending */
+#define TIF_NEED_RESCHED	1	/* rescheduling necessary */
+#define TIF_SYSCALL_TRACE	2	/* syscall trace active */
+#define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
+#define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
+#define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
+#define TIF_PERFMON_WORK	6	/* work for pfm_handle_work() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
@@ -96,8 +96,8 @@ struct thread_info {
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
 #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
+#define _TIF_PERFMON_WORK	(1 << TIF_PERFMON_WORK)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
@@ -106,7 +106,9 @@ struct thread_info {
 #define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 /* "work to do on user-return" bits */
-#define TIF_ALLWORK_MASK	(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_RESTORE_SIGMASK)
+#define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_PERFMON_WORK|_TIF_SYSCALL_AUDIT|\
+				 _TIF_NEED_RESCHED| _TIF_SYSCALL_TRACE|\
+				 _TIF_RESTORE_SIGMASK)
 /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
 #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
 
diff -puN include/asm-m32r/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-m32r/thread_info.h
--- a/include/asm-m32r/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-m32r/thread_info.h
@@ -146,17 +146,15 @@ static inline unsigned int get_thread_fa
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
-#define TIF_IRET		5	/* return with iret */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_SINGLESTEP		3	/* restore singlestep on return to user mode */
+#define TIF_IRET		4	/* return with iret */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 					/* 31..28 fault code */
 #define TIF_MEMDIE		17
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
diff -puN include/asm-m68knommu/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-m68knommu/thread_info.h
--- a/include/asm-m68knommu/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-m68knommu/thread_info.h
@@ -83,16 +83,14 @@ static inline struct thread_info *curren
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_MEMDIE		5
+#define TIF_MEMDIE		4
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff -puN include/asm-mips/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-mips/thread_info.h
--- a/include/asm-mips/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-mips/thread_info.h
@@ -109,11 +109,10 @@ register struct thread_info *__current_t
  * - pending work-to-be-done flags are in LSW
  * - other flags in MSW
  */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_SYSCALL_AUDIT	4	/* syscall auditing active */
-#define TIF_SECCOMP		5	/* secure computing */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
+#define TIF_SECCOMP		4	/* secure computing */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_USEDFPU		16	/* FPU was used by this task this quantum (SMP) */
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling TIF_NEED_RESCHED */
@@ -122,7 +121,6 @@ register struct thread_info *__current_t
 #define TIF_SYSCALL_TRACE	31	/* syscall trace active */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
diff -puN include/asm-parisc/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-parisc/thread_info.h
--- a/include/asm-parisc/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-parisc/thread_info.h
@@ -56,23 +56,21 @@ struct thread_info {
  * thread information flags
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_32BIT               5       /* 32 bit binary */
-#define TIF_MEMDIE		6
-#define TIF_RESTORE_SIGMASK	7	/* restore saved signal mask */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling TIF_NEED_RESCHED */
+#define TIF_32BIT               4       /* 32 bit binary */
+#define TIF_MEMDIE		5
+#define TIF_RESTORE_SIGMASK	6	/* restore saved signal mask */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_32BIT		(1 << TIF_32BIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
 
-#define _TIF_USER_WORK_MASK     (_TIF_NOTIFY_RESUME | _TIF_SIGPENDING | \
+#define _TIF_USER_WORK_MASK     (_TIF_SIGPENDING | \
                                  _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)
 
 #endif /* __KERNEL__ */
diff -puN include/asm-powerpc/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-powerpc/thread_info.h
--- a/include/asm-powerpc/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-powerpc/thread_info.h
@@ -107,28 +107,26 @@ static inline struct thread_info *curren
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_32BIT		5	/* 32 bit binary */
-#define TIF_PERFMON_WORK	6	/* work for pfm_handle_work() */
-#define TIF_PERFMON_CTXSW	7	/* perfmon needs ctxsw calls */
-#define TIF_SYSCALL_AUDIT	8	/* syscall auditing active */
-#define TIF_SINGLESTEP		9	/* singlestepping active */
-#define TIF_MEMDIE		10
-#define TIF_SECCOMP		11	/* secure computing */
-#define TIF_RESTOREALL		12	/* Restore all regs (implies NOERROR) */
-#define TIF_NOERROR		14	/* Force successful syscall return */
-#define TIF_RESTORE_SIGMASK	15	/* Restore signal mask in do_signal */
-#define TIF_FREEZE		16	/* Freezing for suspend */
-#define TIF_RUNLATCH		17	/* Is the runlatch enabled? */
-#define TIF_ABI_PENDING		18	/* 32/64 bit switch needed */
+#define TIF_32BIT		4	/* 32 bit binary */
+#define TIF_PERFMON_WORK	5	/* work for pfm_handle_work() */
+#define TIF_PERFMON_CTXSW	6	/* perfmon needs ctxsw calls */
+#define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
+#define TIF_SINGLESTEP		8	/* singlestepping active */
+#define TIF_MEMDIE		9
+#define TIF_SECCOMP		10	/* secure computing */
+#define TIF_RESTOREALL		11	/* Restore all regs (implies NOERROR) */
+#define TIF_NOERROR		12	/* Force successful syscall return */
+#define TIF_RESTORE_SIGMASK	13	/* Restore signal mask in do_signal */
+#define TIF_FREEZE		14	/* Freezing for suspend */
+#define TIF_RUNLATCH		15	/* Is the runlatch enabled? */
+#define TIF_ABI_PENDING		16	/* 32/64 bit switch needed */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
@@ -146,7 +144,7 @@ static inline struct thread_info *curren
 #define _TIF_ABI_PENDING	(1<<TIF_ABI_PENDING)
 #define _TIF_SYSCALL_T_OR_A	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SECCOMP)
 
-#define _TIF_USER_WORK_MASK	(_TIF_NOTIFY_RESUME | _TIF_SIGPENDING | \
+#define _TIF_USER_WORK_MASK	( _TIF_SIGPENDING | \
 				 _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)
 #define _TIF_PERSYSCALL_MASK	(_TIF_RESTOREALL|_TIF_NOERROR)
 
diff -puN include/asm-sh/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-sh/thread_info.h
--- a/include/asm-sh/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-sh/thread_info.h
@@ -107,18 +107,16 @@ static inline struct thread_info *curren
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_RESTORE_SIGMASK	4	/* restore signal mask in do_signal() */
-#define TIF_SINGLESTEP		5	/* singlestepping active */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_RESTORE_SIGMASK	3	/* restore signal mask in do_signal() */
+#define TIF_SINGLESTEP		4	/* singlestepping active */
 #define TIF_USEDFPU		16	/* FPU was used by this task this quantum (SMP) */
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		18
 #define TIF_FREEZE		19
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
diff -puN include/asm-v850/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-v850/thread_info.h
--- a/include/asm-v850/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-v850/thread_info.h
@@ -77,16 +77,14 @@ struct thread_info {
  * thread information flag bit numbers
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_POLLING_NRFLAG	4	/* true if poll_idle() is polling
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_MEMDIE		5
+#define TIF_MEMDIE		4
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff -puN include/asm-x86_64/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-x86_64/thread_info.h
--- a/include/asm-x86_64/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-x86_64/thread_info.h
@@ -107,7 +107,6 @@ static inline struct thread_info *stack_
  * Warning: layout of LSW is hardcoded in entry.S
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SINGLESTEP		4	/* reenable singlestep on user return*/
@@ -126,7 +125,6 @@ static inline struct thread_info *stack_
 #define TIF_FREEZE		23	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
diff -puN include/asm-xtensa/thread_info.h~remove-unused-tif_notify_resume-flag include/asm-xtensa/thread_info.h
--- a/include/asm-xtensa/thread_info.h~remove-unused-tif_notify_resume-flag
+++ a/include/asm-xtensa/thread_info.h
@@ -110,17 +110,15 @@ static inline struct thread_info *curren
  * - other flags in MSW
  */
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
-#define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
-#define TIF_SIGPENDING		2	/* signal pending */
-#define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
-#define TIF_IRET		5	/* return with iret */
-#define TIF_MEMDIE		6
-#define TIF_RESTORE_SIGMASK	7	/* restore signal mask in do_signal() */
+#define TIF_SIGPENDING		1	/* signal pending */
+#define TIF_NEED_RESCHED	2	/* rescheduling necessary */
+#define TIF_SINGLESTEP		3	/* restore singlestep on return to user mode */
+#define TIF_IRET		4	/* return with iret */
+#define TIF_MEMDIE		5
+#define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
-#define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
_

