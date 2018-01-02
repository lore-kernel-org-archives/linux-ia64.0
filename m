From: David Howells <dhowells@redhat.com>
Date: Tue, 02 Jan 2018 14:33:50 +0000
Subject: Re: [PATCH 4/5] Expand the INIT_SIGNALS and INIT_SIGHAND macros and remove
Message-Id: <19929.1514903630@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.20.1712281559410.1899@nanos> <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk> <151274831156.9961.11214505146256879075.stgit@warthog.procyon.org.uk>
In-Reply-To: <alpine.DEB.2.20.1712281559410.1899@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: dhowells@redhat.com, linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org

Thomas Gleixner <tglx@linutronix.de> wrote:

> >  #define INIT_CPU_TIMERS(s)						\
> ...
> That macro is only used in init_task.c Why not moving it there and get rid
> of the whole macro maze in the header file?

The reason I didn't get rid of it is that it's got more than one expansion
point.  Same for INIT_PREV_CPUTIME and INIT_PID_LINK.

How about the attached patch?  Or do you think it's going a bit too far?

Possibly I could just move some of the #defines from the .h file to the .c
file, but otherwise leave them unexpanded.

David
---
commit ce4d0010bfc3b83f88322afa3cd9013b9c341c4d
Author: David Howells <dhowells@redhat.com>
Date:   Tue Jan 2 14:20:17 2018 +0000

    Expand some multi-use INIT_ macros and remove
    
    Expand INIT_CPU_TIMERS, INIT_PREV_CPUTIME and INIT_PID_LINK in place and
    remove the definitions.
    
    I'm not entirely sure we want to do this since each of these macros has
    multiple points of expansion - and not necessarily in the same structure in
    each case.
    
    Suggested-by: Thomas Gleixner <tglx@linutronix.de>
    Signed-off-by: David Howells <dhowells@redhat.com>

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index a454b8aeb938..f4d002b329cc 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -27,34 +27,6 @@ extern struct nsproxy init_nsproxy;
 extern struct group_info init_groups;
 extern struct cred init_cred;
 
-#ifndef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
-#define INIT_PREV_CPUTIME(x)	.prev_cputime = {			\
-	.lock = __RAW_SPIN_LOCK_UNLOCKED(x.prev_cputime.lock),		\
-},
-#else
-#define INIT_PREV_CPUTIME(x)
-#endif
-
-#ifdef CONFIG_POSIX_TIMERS
-#define INIT_CPU_TIMERS(s)						\
-	.cpu_timers = {							\
-		LIST_HEAD_INIT(s.cpu_timers[0]),			\
-		LIST_HEAD_INIT(s.cpu_timers[1]),			\
-		LIST_HEAD_INIT(s.cpu_timers[2]),			\
-	},
-#else
-#define INIT_CPU_TIMERS(s)
-#endif
-
-#define INIT_PID_LINK(type) 					\
-{								\
-	.node = {						\
-		.next = NULL,					\
-		.pprev = NULL,					\
-	},							\
-	.pid = &init_struct_pid,				\
-}
-
 #define INIT_TASK_COMM "swapper"
 
 /* Attach to the init_task data structure for proper alignment */
diff --git a/init/init_task.c b/init/init_task.c
index 3ac6e754cf64..136d9896acdb 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -30,9 +30,15 @@ static struct signal_struct init_signals = {
 		.running	= false,
 		.checking_timer = false,
 	},
+	.cpu_timers = {
+		LIST_HEAD_INIT(init_signals.cpu_timers[0]),
+		LIST_HEAD_INIT(init_signals.cpu_timers[1]),
+		LIST_HEAD_INIT(init_signals.cpu_timers[2]),
+	},
+#endif
+#ifndef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
+	.prev_cputime.lock = __RAW_SPIN_LOCK_UNLOCKED(init_signals.prev_cputime.lock),
 #endif
-	INIT_CPU_TIMERS(init_signals)
-	INIT_PREV_CPUTIME(init_signals)
 };
 
 static struct sighand_struct init_sighand = {
@@ -107,13 +113,19 @@ struct task_struct init_task
 	.blocked	= {{0}},
 	.alloc_lock	= __SPIN_LOCK_UNLOCKED(init_task.alloc_lock),
 	.journal_info	= NULL,
-	INIT_CPU_TIMERS(init_task)
+#ifdef CONFIG_POSIX_TIMERS
+	.cpu_timers = {
+		LIST_HEAD_INIT(init_task.cpu_timers[0]),
+		LIST_HEAD_INIT(init_task.cpu_timers[1]),
+		LIST_HEAD_INIT(init_task.cpu_timers[2]),
+	},
+#endif
 	.pi_lock	= __RAW_SPIN_LOCK_UNLOCKED(init_task.pi_lock),
 	.timer_slack_ns = 50000, /* 50 usec default slack */
 	.pids = {
-		[PIDTYPE_PID]  = INIT_PID_LINK(PIDTYPE_PID),
-		[PIDTYPE_PGID] = INIT_PID_LINK(PIDTYPE_PGID),
-		[PIDTYPE_SID]  = INIT_PID_LINK(PIDTYPE_SID),
+		[PIDTYPE_PID ].pid = &init_struct_pid,
+		[PIDTYPE_PGID].pid = &init_struct_pid,
+		[PIDTYPE_SID ].pid = &init_struct_pid,
 	},
 	.thread_group	= LIST_HEAD_INIT(init_task.thread_group),
 	.thread_node	= LIST_HEAD_INIT(init_signals.thread_head),
@@ -143,7 +155,9 @@ struct task_struct init_task
 	.pi_waiters	= RB_ROOT_CACHED,
 	.pi_top_task	= NULL,
 #endif
-	INIT_PREV_CPUTIME(init_task)
+#ifndef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
+	.prev_cputime.lock = __RAW_SPIN_LOCK_UNLOCKED(init_task.prev_cputime.lock),
+#endif
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING_GEN
 	.vtime.seqcount	= SEQCNT_ZERO(init_task.vtime_seqcount),
 	.vtime.starttime = 0,
