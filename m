From: David Howells <dhowells@redhat.com>
Date: Fri, 08 Dec 2017 15:51:51 +0000
Subject: [PATCH 4/5] Expand the INIT_SIGNALS and INIT_SIGHAND macros and remove
Message-Id: <151274831156.9961.11214505146256879075.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
In-Reply-To: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org

There doesn't seem to be any need to have the INIT_SIGNALS and INIT_SIGHAND
macros, so expand them in their single places of use and remove them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/init_task.h |   43 ++++---------------------------------------
 init/init_task.c          |   30 ++++++++++++++++++++++++++++--
 2 files changed, 32 insertions(+), 41 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index b1385e1dca63..5b5f41328115 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -23,6 +23,9 @@
 
 extern struct files_struct init_files;
 extern struct fs_struct init_fs;
+extern struct nsproxy init_nsproxy;
+extern struct group_info init_groups;
+extern struct cred init_cred;
 
 #ifndef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
 #define INIT_PREV_CPUTIME(x)	.prev_cputime = {			\
@@ -33,52 +36,16 @@ extern struct fs_struct init_fs;
 #endif
 
 #ifdef CONFIG_POSIX_TIMERS
-#define INIT_POSIX_TIMERS(s)						\
-	.posix_timers = LIST_HEAD_INIT(s.posix_timers),
 #define INIT_CPU_TIMERS(s)						\
 	.cpu_timers = {							\
 		LIST_HEAD_INIT(s.cpu_timers[0]),			\
 		LIST_HEAD_INIT(s.cpu_timers[1]),			\
-		LIST_HEAD_INIT(s.cpu_timers[2]),								\
-	},
-#define INIT_CPUTIMER(s)						\
-	.cputimer	= { 						\
-		.cputime_atomic	= INIT_CPUTIME_ATOMIC,			\
-		.running	= false,				\
-		.checking_timer = false,				\
+		LIST_HEAD_INIT(s.cpu_timers[2]),			\
 	},
 #else
-#define INIT_POSIX_TIMERS(s)
 #define INIT_CPU_TIMERS(s)
-#define INIT_CPUTIMER(s)
 #endif
 
-#define INIT_SIGNALS(sig) {						\
-	.nr_threads	= 1,						\
-	.thread_head	= LIST_HEAD_INIT(init_task.thread_node),	\
-	.wait_chldexit	= __WAIT_QUEUE_HEAD_INITIALIZER(sig.wait_chldexit),\
-	.shared_pending	= { 						\
-		.list = LIST_HEAD_INIT(sig.shared_pending.list),	\
-		.signal =  {{0}}},					\
-	INIT_POSIX_TIMERS(sig)						\
-	INIT_CPU_TIMERS(sig)						\
-	.rlim		= INIT_RLIMITS,					\
-	INIT_CPUTIMER(sig)						\
-	INIT_PREV_CPUTIME(sig)						\
-	.cred_guard_mutex =						\
-		 __MUTEX_INITIALIZER(sig.cred_guard_mutex),		\
-}
-
-extern struct nsproxy init_nsproxy;
-
-#define INIT_SIGHAND(sighand) {						\
-	.count		= ATOMIC_INIT(1), 				\
-	.action		= { { { .sa_handler = SIG_DFL, } }, },		\
-	.siglock	= __SPIN_LOCK_UNLOCKED(sighand.siglock),	\
-	.signalfd_wqh	= __WAIT_QUEUE_HEAD_INITIALIZER(sighand.signalfd_wqh),	\
-}
-
-extern struct group_info init_groups;
 
 #define INIT_STRUCT_PID {						\
 	.count 		= ATOMIC_INIT(1),				\
@@ -103,8 +70,6 @@ extern struct group_info init_groups;
 	.pid = &init_struct_pid,				\
 }
 
-extern struct cred init_cred;
-
 #define INIT_TASK_COMM "swapper"
 
 /* Attach to the init_task data structure for proper alignment */
diff --git a/init/init_task.c b/init/init_task.c
index aa4030a939e5..3ac6e754cf64 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -13,8 +13,34 @@
 #include <asm/pgtable.h>
 #include <linux/uaccess.h>
 
-static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
-static struct sighand_struct init_sighand = INIT_SIGHAND(init_sighand);
+static struct signal_struct init_signals = {
+	.nr_threads	= 1,
+	.thread_head	= LIST_HEAD_INIT(init_task.thread_node),
+	.wait_chldexit	= __WAIT_QUEUE_HEAD_INITIALIZER(init_signals.wait_chldexit),
+	.shared_pending	= {
+		.list = LIST_HEAD_INIT(init_signals.shared_pending.list),
+		.signal =  {{0}}
+	},
+	.rlim		= INIT_RLIMITS,
+	.cred_guard_mutex = __MUTEX_INITIALIZER(init_signals.cred_guard_mutex),
+#ifdef CONFIG_POSIX_TIMERS
+	.posix_timers = LIST_HEAD_INIT(init_signals.posix_timers),
+	.cputimer	= {
+		.cputime_atomic	= INIT_CPUTIME_ATOMIC,
+		.running	= false,
+		.checking_timer = false,
+	},
+#endif
+	INIT_CPU_TIMERS(init_signals)
+	INIT_PREV_CPUTIME(init_signals)
+};
+
+static struct sighand_struct init_sighand = {
+	.count		= ATOMIC_INIT(1),
+	.action		= { { { .sa_handler = SIG_DFL, } }, },
+	.siglock	= __SPIN_LOCK_UNLOCKED(init_sighand.siglock),
+	.signalfd_wqh	= __WAIT_QUEUE_HEAD_INITIALIZER(init_sighand.signalfd_wqh),
+};
 
 /*
  * Set up the first task table, touch at your own risk!. Base=0,

