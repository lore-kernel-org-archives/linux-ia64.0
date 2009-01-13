From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 06:11:17 +0000
Subject: [PATCH 7/9] tracing/ftrace: separate events tracing and stats tracing engine
Message-Id: <20090113061148.416215451@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de, Steven Rostedt <srostedt@redhat.com>

From: Frederic Weisbecker <fweisbec@gmail.com>

Impact: tracing's Api change

Currently, the stat tracing depends on the events tracing.
When you switch to a new tracer, the stats files of the previous tracer
will disappear. But it's more scalable to separate those two engines.
This way, we can keep the stat files of one or several tracers when we
want, without bothering of multiple tracer stat files or tracer switching.

To build/destroys its stats files, a tracer just have to call
register_stat_tracer/unregister_stat_tracer everytimes it wants to.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 kernel/trace/trace.c        |    2 -
 kernel/trace/trace.h        |   20 -----
 kernel/trace/trace_branch.c |  108 ++++++++++++++-----------
 kernel/trace/trace_stat.c   |  191 ++++++++++++++++++-------------------------
 kernel/trace/trace_stat.h   |   31 +++++++
 5 files changed, 172 insertions(+), 180 deletions(-)
 create mode 100644 kernel/trace/trace_stat.h

diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 0418fc3..40217fb 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2353,7 +2353,6 @@ static int tracing_set_tracer(char *buf)
 		if (ret)
 			goto out;
 	}
-	init_tracer_stat(t);
 
 	trace_branch_enable(tr);
  out:
@@ -3218,7 +3217,6 @@ __init static int tracer_alloc_buffers(void)
 #else
 	current_trace = &nop_trace;
 #endif
-	init_tracer_stat(current_trace);
 	/* All seems OK, enable tracing */
 	tracing_disabled = 0;
 
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index b3f9ad1..79c8721 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -334,24 +334,6 @@ struct tracer_flags {
 /* Makes more easy to define a tracer opt */
 #define TRACER_OPT(s, b)	.name = #s, .bit = b
 
-/*
- * If you want to provide a stat file (one-shot statistics), fill
- * an iterator with stat_start/stat_next and a stat_show callbacks.
- * The others callbacks are optional.
- */
-struct tracer_stat {
-	/* The name of your stat file */
-	const char		*name;
-	/* Iteration over statistic entries */
-	void			*(*stat_start)(void);
-	void			*(*stat_next)(void *prev, int idx);
-	/* Compare two entries for sorting (optional) for stats */
-	int			(*stat_cmp)(void *p1, void *p2);
-	/* Print a stat entry */
-	int			(*stat_show)(struct seq_file *s, void *p);
-	/* Print the headers of your stat entries */
-	int			(*stat_headers)(struct seq_file *s);
-};
 
 /*
  * A specific tracer, represented by methods that operate on a trace array:
@@ -466,8 +448,6 @@ void tracing_start_sched_switch_record(void);
 int register_tracer(struct tracer *type);
 void unregister_tracer(struct tracer *type);
 
-void init_tracer_stat(struct tracer *trace);
-
 extern unsigned long nsecs_to_usecs(unsigned long nsecs);
 
 extern unsigned long tracing_max_latency;
diff --git a/kernel/trace/trace_branch.c b/kernel/trace/trace_branch.c
index da5cf3e..ca017e0 100644
--- a/kernel/trace/trace_branch.c
+++ b/kernel/trace/trace_branch.c
@@ -16,12 +16,12 @@
 #include <asm/local.h>
 
 #include "trace.h"
+#include "trace_stat.h"
 #include "trace_output.h"
 
-static struct tracer branch_trace;
-
 #ifdef CONFIG_BRANCH_TRACER
 
+static struct tracer branch_trace;
 static int branch_tracing_enabled __read_mostly;
 static DEFINE_MUTEX(branch_tracing_mutex);
 
@@ -191,6 +191,30 @@ static struct trace_event trace_branch_event = {
 	.binary		= trace_nop_print,
 };
 
+static struct tracer branch_trace __read_mostly +{
+	.name		= "branch",
+	.init		= branch_trace_init,
+	.reset		= branch_trace_reset,
+#ifdef CONFIG_FTRACE_SELFTEST
+	.selftest	= trace_selftest_startup_branch,
+#endif /* CONFIG_FTRACE_SELFTEST */
+};
+
+__init static int init_branch_tracer(void)
+{
+	int ret;
+
+	ret = register_ftrace_event(&trace_branch_event);
+	if (!ret) {
+		printk(KERN_WARNING "Warning: could not register "
+				    "branch events\n");
+		return 1;
+	}
+	return register_tracer(&branch_trace);
+}
+device_initcall(init_branch_tracer);
+
 #else
 static inline
 void trace_likely_condition(struct ftrace_branch_data *f, int val, int expect)
@@ -305,6 +329,29 @@ static int annotated_branch_stat_cmp(void *p1, void *p2)
 		return 0;
 }
 
+static struct tracer_stat annotated_branch_stats = {
+	.name = "branch_annotated",
+	.stat_start = annotated_branch_stat_start,
+	.stat_next = annotated_branch_stat_next,
+	.stat_cmp = annotated_branch_stat_cmp,
+	.stat_headers = annotated_branch_stat_headers,
+	.stat_show = branch_stat_show
+};
+
+__init static int init_annotated_branch_stats(void)
+{
+	int ret;
+
+	ret = register_stat_tracer(&annotated_branch_stats);
+	if (!ret) {
+		printk(KERN_WARNING "Warning: could not register "
+				    "annotated branches stats\n");
+		return 1;
+	}
+	return 0;
+}
+fs_initcall(init_annotated_branch_stats);
+
 #ifdef CONFIG_PROFILE_ALL_BRANCHES
 
 extern unsigned long __start_branch_profile[];
@@ -339,60 +386,25 @@ all_branch_stat_next(void *v, int idx)
 	return p;
 }
 
-static struct tracer_stat branch_stats[] = {
-	{.name = "annotated",
-	.stat_start = annotated_branch_stat_start,
-	.stat_next = annotated_branch_stat_next,
-	.stat_cmp = annotated_branch_stat_cmp,
-	.stat_headers = annotated_branch_stat_headers,
-	.stat_show = branch_stat_show},
-
-	{.name = "all",
+static struct tracer_stat all_branch_stats = {
+	.name = "branch_all",
 	.stat_start = all_branch_stat_start,
 	.stat_next = all_branch_stat_next,
 	.stat_headers = all_branch_stat_headers,
-	.stat_show = branch_stat_show},
-
-	{ }
-};
-#else
-static struct tracer_stat branch_stats[] = {
-	{.name = "annotated",
-	.stat_start = annotated_branch_stat_start,
-	.stat_next = annotated_branch_stat_next,
-	.stat_cmp = annotated_branch_stat_cmp,
-	.stat_headers = annotated_branch_stat_headers,
-	.stat_show = branch_stat_show},
-
-	{ }
+	.stat_show = branch_stat_show
 };
-#endif /* CONFIG_PROFILE_ALL_BRANCHES */
 
-
-static struct tracer branch_trace __read_mostly +__init static int all_annotated_branch_stats(void)
 {
-	.name		= "branch",
-#ifdef CONFIG_BRANCH_TRACER
-	.init		= branch_trace_init,
-	.reset		= branch_trace_reset,
-#ifdef CONFIG_FTRACE_SELFTEST
-	.selftest	= trace_selftest_startup_branch,
-#endif /* CONFIG_FTRACE_SELFTEST */
-#endif
-	.stats		= branch_stats
-};
-
-__init static int init_branch_trace(void)
-{
-#ifdef CONFIG_BRANCH_TRACER
 	int ret;
-	ret = register_ftrace_event(&trace_branch_event);
+
+	ret = register_stat_tracer(&all_branch_stats);
 	if (!ret) {
-		printk(KERN_WARNING "Warning: could not register branch events\n");
+		printk(KERN_WARNING "Warning: could not register "
+				    "all branches stats\n");
 		return 1;
 	}
-#endif
-
-	return register_tracer(&branch_trace);
+	return 0;
 }
-device_initcall(init_branch_trace);
+fs_initcall(all_annotated_branch_stats);
+#endif /* CONFIG_PROFILE_ALL_BRANCHES */
diff --git a/kernel/trace/trace_stat.c b/kernel/trace/trace_stat.c
index 1515f9e..cb29282 100644
--- a/kernel/trace/trace_stat.c
+++ b/kernel/trace/trace_stat.c
@@ -10,28 +10,32 @@
 
 
 #include <linux/list.h>
-#include <linux/seq_file.h>
 #include <linux/debugfs.h>
+#include "trace_stat.h"
 #include "trace.h"
 
 
 /* List of stat entries from a tracer */
 struct trace_stat_list {
-	struct list_head list;
-	void *stat;
+	struct list_head 	list;
+	void 			*stat;
 };
 
 /* A stat session is the stats output in one file */
 struct tracer_stat_session {
-	struct tracer_stat *ts;
-	struct list_head stat_list;
-	struct mutex stat_mutex;
+	struct list_head	session_list;
+	struct tracer_stat 	*ts;
+	struct list_head 	stat_list;
+	struct mutex 		stat_mutex;
+	struct dentry		*file;
 };
 
 /* All of the sessions currently in use. Each stat file embeed one session */
-static struct tracer_stat_session **all_stat_sessions;
-static int nb_sessions;
-static struct dentry *stat_dir, **stat_files;
+static LIST_HEAD(all_stat_sessions);
+static DEFINE_MUTEX(all_stat_sessions_mutex);
+
+/* The root directory for all stat files */
+static struct dentry *stat_dir;
 
 
 static void reset_stat_session(struct tracer_stat_session *session)
@@ -44,66 +48,77 @@ static void reset_stat_session(struct tracer_stat_session *session)
 	INIT_LIST_HEAD(&session->stat_list);
 }
 
-/* Called when a tracer is initialized */
-static int init_all_sessions(int nb, struct tracer_stat *ts)
+static void destroy_session(struct tracer_stat_session *session)
 {
-	int i, j;
-	struct tracer_stat_session *session;
+	debugfs_remove(session->file);
+	reset_stat_session(session);
+	mutex_destroy(&session->stat_mutex);
+	kfree(session);
+}
 
-	nb_sessions = 0;
 
-	if (all_stat_sessions) {
-		for (i = 0; i < nb_sessions; i++) {
-			session = all_stat_sessions[i];
-			reset_stat_session(session);
-			mutex_destroy(&session->stat_mutex);
-			kfree(session);
-		}
-	}
-	all_stat_sessions = kmalloc(sizeof(struct tracer_stat_session *) * nb,
-				    GFP_KERNEL);
-	if (!all_stat_sessions)
-		return -ENOMEM;
+static int init_stat_file(struct tracer_stat_session *session);
 
-	for (i = 0; i < nb; i++) {
-		session = kmalloc(sizeof(struct tracer_stat_session) * nb,
-				  GFP_KERNEL);
-		if (!session)
-			goto free_sessions;
+int register_stat_tracer(struct tracer_stat *trace)
+{
+	struct tracer_stat_session *session, *node, *tmp;
+	int ret;
+
+	if (!trace)
+		return -EINVAL;
+
+	if (!trace->stat_start || !trace->stat_next || !trace->stat_show)
+		return -EINVAL;
 
-		INIT_LIST_HEAD(&session->stat_list);
-		mutex_init(&session->stat_mutex);
-		session->ts = &ts[i];
-		all_stat_sessions[i] = session;
+	/* Already registered? */
+	mutex_lock(&all_stat_sessions_mutex);
+	list_for_each_entry_safe(node, tmp, &all_stat_sessions, session_list) {
+		if (node->ts = trace)
+			return -EINVAL;
 	}
-	nb_sessions = nb;
-	return 0;
+	mutex_unlock(&all_stat_sessions_mutex);
+
+	/* Init the session */
+	session = kmalloc(sizeof(struct tracer_stat_session), GFP_KERNEL);
+	if (!session)
+		return -ENOMEM;
 
-free_sessions:
+	session->ts = trace;
+	INIT_LIST_HEAD(&session->session_list);
+	INIT_LIST_HEAD(&session->stat_list);
+	mutex_init(&session->stat_mutex);
+	session->file = NULL;
 
-	for (j = 0; j < i; j++)
-		kfree(all_stat_sessions[i]);
+	ret = init_stat_file(session);
+	if (ret) {
+		destroy_session(session);
+		return ret;
+	}
 
-	kfree(all_stat_sessions);
-	all_stat_sessions = NULL;
+	/* Register */
+	mutex_lock(&all_stat_sessions_mutex);
+	list_add_tail(&session->session_list, &all_stat_sessions);
+	mutex_unlock(&all_stat_sessions_mutex);
 
-	return -ENOMEM;
+	return 0;
 }
 
-static int basic_tracer_stat_checks(struct tracer_stat *ts)
+void unregister_stat_tracer(struct tracer_stat *trace)
 {
-	int i;
+	struct tracer_stat_session *node, *tmp;
 
-	if (!ts)
-		return 0;
-
-	for (i = 0; ts[i].name; i++) {
-		if (!ts[i].stat_start || !ts[i].stat_next || !ts[i].stat_show)
-			return -EBUSY;
+	mutex_lock(&all_stat_sessions_mutex);
+	list_for_each_entry_safe(node, tmp, &all_stat_sessions, session_list) {
+		if (node->ts = trace) {
+			list_del(&node->session_list);
+			destroy_session(node);
+			break;
+		}
 	}
-	return i;
+	mutex_unlock(&all_stat_sessions_mutex);
 }
 
+
 /*
  * For tracers that don't provide a stat_cmp callback.
  * This one will force an immediate insertion on tail of
@@ -280,63 +295,7 @@ static const struct file_operations tracing_stat_fops = {
 	.release	= tracing_stat_release
 };
 
-
-static void destroy_trace_stat_files(void)
-{
-	int i;
-
-	if (stat_files) {
-		for (i = 0; i < nb_sessions; i++)
-			debugfs_remove(stat_files[i]);
-		kfree(stat_files);
-		stat_files = NULL;
-	}
-}
-
-static void init_trace_stat_files(void)
-{
-	int i;
-
-	if (!stat_dir || !nb_sessions)
-		return;
-
-	stat_files = kmalloc(sizeof(struct dentry *) * nb_sessions, GFP_KERNEL);
-
-	if (!stat_files) {
-		pr_warning("trace stat: not enough memory\n");
-		return;
-	}
-
-	for (i = 0; i < nb_sessions; i++) {
-		struct tracer_stat_session *session = all_stat_sessions[i];
-		stat_files[i] = debugfs_create_file(session->ts->name, 0644,
-						stat_dir,
-						session, &tracing_stat_fops);
-		if (!stat_files[i])
-			pr_warning("cannot create %s entry\n",
-				   session->ts->name);
-	}
-}
-
-void init_tracer_stat(struct tracer *trace)
-{
-	int nb = basic_tracer_stat_checks(trace->stats);
-
-	destroy_trace_stat_files();
-
-	if (nb < 0) {
-		pr_warning("stat tracing: missing stat callback on %s\n",
-			   trace->name);
-		return;
-	}
-	if (!nb)
-		return;
-
-	init_all_sessions(nb, trace->stats);
-	init_trace_stat_files();
-}
-
-static int __init tracing_stat_init(void)
+static int tracing_stat_init(void)
 {
 	struct dentry *d_tracing;
 
@@ -348,4 +307,16 @@ static int __init tracing_stat_init(void)
 			   "'trace_stat' entry\n");
 	return 0;
 }
-fs_initcall(tracing_stat_init);
+
+static int init_stat_file(struct tracer_stat_session *session)
+{
+	if (!stat_dir && tracing_stat_init())
+		return -ENODEV;
+
+	session->file = debugfs_create_file(session->ts->name, 0644,
+					    stat_dir,
+					    session, &tracing_stat_fops);
+	if (!session->file)
+		return -ENOMEM;
+	return 0;
+}
diff --git a/kernel/trace/trace_stat.h b/kernel/trace/trace_stat.h
new file mode 100644
index 0000000..202274c
--- /dev/null
+++ b/kernel/trace/trace_stat.h
@@ -0,0 +1,31 @@
+#ifndef __TRACE_STAT_H
+#define __TRACE_STAT_H
+
+#include <linux/seq_file.h>
+
+/*
+ * If you want to provide a stat file (one-shot statistics), fill
+ * an iterator with stat_start/stat_next and a stat_show callbacks.
+ * The others callbacks are optional.
+ */
+struct tracer_stat {
+	/* The name of your stat file */
+	const char		*name;
+	/* Iteration over statistic entries */
+	void			*(*stat_start)(void);
+	void			*(*stat_next)(void *prev, int idx);
+	/* Compare two entries for stats sorting */
+	int			(*stat_cmp)(void *p1, void *p2);
+	/* Print a stat entry */
+	int			(*stat_show)(struct seq_file *s, void *p);
+	/* Print the headers of your stat entries */
+	int			(*stat_headers)(struct seq_file *s);
+};
+
+/*
+ * Destroy or create a stat file
+ */
+extern int register_stat_tracer(struct tracer_stat *trace);
+extern void unregister_stat_tracer(struct tracer_stat *trace);
+
+#endif /* __TRACE_STAT_H */
-- 
1.5.6.5

-- 
