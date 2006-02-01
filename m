From: Akinobu Mita <mita@miraclelinux.com>
Date: Wed, 01 Feb 2006 09:03:05 +0000
Subject: [patch 41/44] make thread_info.flags an unsigned long
Message-Id: <20060201090335.476045000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090224.536581000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-ia64@vger.kernel.org, linuxsh-dev@lists.sourceforge.net, Andi Kleen <ak@suse.de>, Akinobu Mita <mita@miraclelinux.com>

The *_bit() routines are defined to work on a pointer to unsigned long.
And the thread_info.flags is passed to *_bit() routines in
include/linux/thread_info.h. But

 - alpha: flags is unsigned int
 - ia64, sh, x86_64: flags is __u32

So flags should be changed to unsigned long instead.

The only affected 64-platforms are little endian, so it will work
without this change. But it's better to change it before people copy the
code to a big endian platform.

Signed-off-by: Akinobu Mita <mita@miraclelinux.com>
 include/asm-alpha/thread_info.h  |    2 +-
 include/asm-ia64/thread_info.h   |    2 +-
 include/asm-sh/thread_info.h     |    2 +-
 include/asm-x86_64/thread_info.h |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

Index: 2.6-git/include/asm-alpha/thread_info.h
=================================--- 2.6-git.orig/include/asm-alpha/thread_info.h
+++ 2.6-git/include/asm-alpha/thread_info.h
@@ -14,7 +14,7 @@ struct thread_info {
 	struct pcb_struct	pcb;		/* palcode state */
 
 	struct task_struct	*task;		/* main task structure */
-	unsigned int		flags;		/* low level flags */
+	unsigned long		flags;		/* low level flags */
 	unsigned int		ieee_state;	/* see fpu.h */
 
 	struct exec_domain	*exec_domain;	/* execution domain */
Index: 2.6-git/include/asm-ia64/thread_info.h
=================================--- 2.6-git.orig/include/asm-ia64/thread_info.h
+++ 2.6-git/include/asm-ia64/thread_info.h
@@ -24,7 +24,7 @@
 struct thread_info {
 	struct task_struct *task;	/* XXX not really needed, except for dup_task_struct() */
 	struct exec_domain *exec_domain;/* execution domain */
-	__u32 flags;			/* thread_info flags (see TIF_*) */
+	unsigned long flags;		/* thread_info flags (see TIF_*) */
 	__u32 cpu;			/* current CPU */
 	mm_segment_t addr_limit;	/* user-level address space limit */
 	int preempt_count;		/* 0=premptable, <0=BUG; will also serve as bh-counter */
Index: 2.6-git/include/asm-sh/thread_info.h
=================================--- 2.6-git.orig/include/asm-sh/thread_info.h
+++ 2.6-git/include/asm-sh/thread_info.h
@@ -18,7 +18,7 @@
 struct thread_info {
 	struct task_struct	*task;		/* main task structure */
 	struct exec_domain	*exec_domain;	/* execution domain */
-	__u32			flags;		/* low level flags */
+	unsigned long		flags;		/* low level flags */
 	__u32			cpu;
 	int			preempt_count; /* 0 => preemptable, <0 => BUG */
 	struct restart_block	restart_block;
Index: 2.6-git/include/asm-x86_64/thread_info.h
=================================--- 2.6-git.orig/include/asm-x86_64/thread_info.h
+++ 2.6-git/include/asm-x86_64/thread_info.h
@@ -26,7 +26,7 @@ struct exec_domain;
 struct thread_info {
 	struct task_struct	*task;		/* main task structure */
 	struct exec_domain	*exec_domain;	/* execution domain */
-	__u32			flags;		/* low level flags */
+	unsigned long		flags;		/* low level flags */
 	__u32			status;		/* thread synchronous flags */
 	__u32			cpu;		/* current CPU */
 	int 			preempt_count;	/* 0 => preemptable, <0 => BUG */

--
