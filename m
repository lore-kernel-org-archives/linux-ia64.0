From: David Howells <dhowells@redhat.com>
Date: Thu, 20 Jul 2017 12:50:41 +0000
Subject: [PATCH 4/5] Unroll the INIT_SIGNALS and INIT_SIGHAND macros
Message-Id: <150055504102.20414.1026964494664159485.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <150055501157.20414.14957264566013145790.stgit@warthog.procyon.org.uk>
In-Reply-To: <150055501157.20414.14957264566013145790.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@kernel.org
Cc: linux-arch@vger.kernel.org, dhowells@redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

There doesn't seem to be any need to have the INIT_SIGNALS and INIT_SIGHAND
macros, so unroll them in their single places of use.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/init_task.h |   45 ++++-----------------------------------------
 init/init_task.c          |   30 ++++++++++++++++++++++++++++--
 2 files changed, 32 insertions(+), 43 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 212a2bdfaf6c..fc51c709d19d 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -22,6 +22,9 @@
 
 extern struct files_struct init_files;
 extern struct fs_struct init_fs;
+extern struct nsproxy init_nsproxy;
+extern struct group_info init_groups;
+extern struct cred init_cred;
 
 #ifndef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
 #define INIT_PREV_CPUTIME(x)	.prev_cputime = {			\
@@ -32,52 +35,16 @@ extern struct fs_struct init_fs;
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
@@ -103,10 +70,6 @@ extern struct group_info init_groups;
 	.pid = &init_struct_pid,				\
 }
 
-
-
-extern struct cred init_cred;
-
 #define INIT_TASK_COMM "swapper"
 
 /* Attach to the init_task data structure for proper alignment */
diff --git a/init/init_task.c b/init/init_task.c
index 00d78cedc996..26776f6a1b7f 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -12,8 +12,34 @@
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

