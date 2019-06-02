From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Sun, 02 Jun 2019 06:13:35 +0000
Subject: [RFC] printk: Introduce per context console loglevel.
Message-Id: <c265f674-e293-332b-a037-895025354a69@i-love.sakura.ne.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190528002412.1625-1-dima@arista.com>
 <20190528041500.GB26865@jagdpanzerIV> <20190528044619.GA3429@jagdpanzerIV>
 <20190528134227.xyb3622gjwu52q4r@pathway.suse.cz>
 <82605abd-14d9-376a-446c-48475ae305dc@i-love.sakura.ne.jp>
In-Reply-To: <82605abd-14d9-376a-446c-48475ae305dc@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Dmitry Safonov <dima@arista.com>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, x86@kernel.org, linux-ia64@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net

Dmitry Safonov proposed KERN_UNSUPPRESSED loglevel which pretends as if
ignore_loglevel was specified for per printk() basis, for we can fail to
apply temporarily manipulated console loglevel because console loglevel
is evaluated when the message is printed to consoles rather than when
the message is stored into the buffer [1].

Temporary manipulation of console loglevel for SysRq is applied to only
the header line. At first I though that we also want to apply temporary
manipulation of console loglevel for SysRq to the body lines, for showing
only the header line is hardly helpful. But I realized that we should not
force showing the body lines because some users might be triggering SysRq
 from /proc and reading via syslog rather than via console output. Users
who need to read via console output should be able to manipulate console
loglevel by triggering SysRq from console.

Since we currently defer storing of the messages from NMI context and
recursive context, we would need to explicitly pass KERN_UNSUPPRESSED.
But Sergey Senozhatsky thinks that it might be fine to automatically
apply KERN_UNSUPPRESSED to printk() from NMI context and recursive
context, for messages from these contexts are likely important [2].
Then, we could avoid explicitly passing KERN_UNSUPPRESSED, by introducing
per context console loglevel.

This patch introduces per CPU console loglevel (for in_nmi(), in_irq() and
in_serving_softirq()) and per thread console loglevel (for in_task()), and
replaces temporary manipulation of global console_loglevel with temporary
manipulation of per context console_loglevel based on an assumption that
users who are temporarily manipulating global console_loglevel needs to
apply it to only current context. (Note that triggering SysRq-t from /proc
runs in in_task() context, and it should not disable preemption because it
may take long period. Thus, per thread console loglevel is used.)

If per context console_loglevel is 0 when printk() is called, global
console_loglevel is evaluated when the message is printed to consoles.
If per context console_loglevel is not 0 when printk() is called, per
context console_loglevel is evaluated when the message is stored, and
that result supersedes global console_loglevel evaluation.

With the combination of automatically applying CONSOLE_LOGLEVEL_MOTORMOUTH
for printk() from NMI context and recursive context, this patch does not
introduce KERN_UNSUPPRESSED loglevel. (Note that CONSOLE_LOGLEVEL_SILENT
is changed from 0 to -1 in order to make per context console_loglevel
evaluation simpler.)

[1] https://lkml.kernel.org/r/20190528002412.1625-1-dima@arista.com
[2] https://lkml.kernel.org/r/20190528044619.GA3429@jagdpanzerIV

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 arch/ia64/kernel/mca.c        | 36 ++++++++++++++-----------
 arch/x86/platform/uv/uv_nmi.c |  6 ++---
 drivers/tty/sysrq.c           | 10 +++----
 include/linux/printk.h        | 29 +++++++++++---------
 include/linux/sched.h         |  3 +++
 kernel/debug/kdb/kdb_bt.c     |  7 ++---
 kernel/debug/kdb/kdb_io.c     |  6 ++---
 kernel/debug/kdb/kdb_main.c   |  7 ++---
 kernel/printk/printk.c        | 63 +++++++++++++++++++++++++++++++++++++++----
 kernel/printk/printk_safe.c   |  4 +++
 10 files changed, 121 insertions(+), 50 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6a52d76..57b2c7c 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -189,19 +189,23 @@
 static unsigned long mlogbuf_timestamp = 0;
 
 static int loglevel_save = -1;
-#define BREAK_LOGLEVEL(__console_loglevel)		\
-	oops_in_progress = 1;				\
-	if (loglevel_save < 0)				\
-		loglevel_save = __console_loglevel;	\
-	__console_loglevel = 15;
-
-#define RESTORE_LOGLEVEL(__console_loglevel)		\
-	if (loglevel_save >= 0) {			\
-		__console_loglevel = loglevel_save;	\
-		loglevel_save = -1;			\
-	}						\
-	mlogbuf_finished = 0;				\
-	oops_in_progress = 0;
+#define BREAK_LOGLEVEL()					\
+	do {							\
+		oops_in_progress = 1;				\
+		if (loglevel_save < 0)				\
+			loglevel_save = get_local_loglevel();	\
+		set_local_loglevel(CONSOLE_LOGLEVEL_MOTORMOUTH);\
+	} while (0)
+
+#define RESTORE_LOGLEVEL()					\
+	do {							\
+		if (loglevel_save >= 0) {			\
+			set_local_loglevel(loglevel_save);	\
+			loglevel_save = -1;			\
+		}						\
+		mlogbuf_finished = 0;				\
+		oops_in_progress = 0;				\
+	} while (0)
 
 /*
  * Push messages into buffer, print them later if not urgent.
@@ -288,7 +292,7 @@ void ia64_mlogbuf_dump(void)
  */
 static void ia64_mlogbuf_finish(int wait)
 {
-	BREAK_LOGLEVEL(console_loglevel);
+	BREAK_LOGLEVEL();
 
 	spin_lock_init(&mlogbuf_rlock);
 	ia64_mlogbuf_dump();
@@ -1623,7 +1627,7 @@ static void mca_insert_tr(u64 iord)
 	 * To enable show_stack from INIT, we use oops_in_progress which should
 	 * be used in real oops. This would cause something wrong after INIT.
 	 */
-	BREAK_LOGLEVEL(console_loglevel);
+	BREAK_LOGLEVEL();
 	ia64_mlogbuf_dump_from_init();
 
 	printk(KERN_ERR "Processes interrupted by INIT -");
@@ -1648,7 +1652,7 @@ static void mca_insert_tr(u64 iord)
 		read_unlock(&tasklist_lock);
 	}
 	/* FIXME: This will not restore zapped printk locks. */
-	RESTORE_LOGLEVEL(console_loglevel);
+	RESTORE_LOGLEVEL();
 	return NOTIFY_DONE;
 }
 
diff --git a/arch/x86/platform/uv/uv_nmi.c b/arch/x86/platform/uv/uv_nmi.c
index 9d08ff5..a6c1a86 100644
--- a/arch/x86/platform/uv/uv_nmi.c
+++ b/arch/x86/platform/uv/uv_nmi.c
@@ -753,13 +753,13 @@ static void uv_nmi_dump_state(int cpu, struct pt_regs *regs, int master)
 	if (master) {
 		int tcpu;
 		int ignored = 0;
-		int saved_console_loglevel = console_loglevel;
+		int saved_loglevel = get_local_loglevel();
 
 		pr_alert("UV: tracing %s for %d CPUs from CPU %d\n",
 			uv_nmi_action_is("ips") ? "IPs" : "processes",
 			atomic_read(&uv_nmi_cpus_in_nmi), cpu);
 
-		console_loglevel = uv_nmi_loglevel;
+		set_local_loglevel(uv_nmi_loglevel);
 		atomic_set(&uv_nmi_slave_continue, SLAVE_EXIT);
 		for_each_online_cpu(tcpu) {
 			if (cpumask_test_cpu(tcpu, uv_nmi_cpu_mask))
@@ -772,7 +772,7 @@ static void uv_nmi_dump_state(int cpu, struct pt_regs *regs, int master)
 		if (ignored)
 			pr_alert("UV: %d CPUs ignored NMI\n", ignored);
 
-		console_loglevel = saved_console_loglevel;
+		set_local_loglevel(saved_loglevel);
 		pr_alert("UV: process trace complete\n");
 	} else {
 		while (!atomic_read(&uv_nmi_slave_continue))
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 573b205..18cb58e 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -541,8 +541,8 @@ void __handle_sysrq(int key, bool check_mask)
 	 * simply emit this at KERN_EMERG as that would change message
 	 * routing in the consumers of /proc/kmsg.
 	 */
-	orig_log_level = console_loglevel;
-	console_loglevel = CONSOLE_LOGLEVEL_DEFAULT;
+	orig_log_level = get_local_loglevel();
+	set_local_loglevel(CONSOLE_LOGLEVEL_DEFAULT);
 
         op_p = __sysrq_get_key_op(key);
         if (op_p) {
@@ -552,11 +552,11 @@ void __handle_sysrq(int key, bool check_mask)
 		 */
 		if (!check_mask || sysrq_on_mask(op_p->enable_mask)) {
 			pr_info("%s\n", op_p->action_msg);
-			console_loglevel = orig_log_level;
+			set_local_loglevel(orig_log_level);
 			op_p->handler(key);
 		} else {
 			pr_info("This sysrq operation is disabled.\n");
-			console_loglevel = orig_log_level;
+			set_local_loglevel(orig_log_level);
 		}
 	} else {
 		pr_info("HELP : ");
@@ -574,7 +574,7 @@ void __handle_sysrq(int key, bool check_mask)
 			}
 		}
 		pr_cont("\n");
-		console_loglevel = orig_log_level;
+		set_local_loglevel(orig_log_level);
 	}
 	rcu_read_unlock();
 	rcu_sysrq_end();
diff --git a/include/linux/printk.h b/include/linux/printk.h
index cefd374..78b357a 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -47,7 +47,7 @@ static inline const char *printk_skip_headers(const char *buffer)
 #define MESSAGE_LOGLEVEL_DEFAULT CONFIG_MESSAGE_LOGLEVEL_DEFAULT
 
 /* We show everything that is MORE important than this.. */
-#define CONSOLE_LOGLEVEL_SILENT  0 /* Mum's the word */
+#define CONSOLE_LOGLEVEL_SILENT -1 /* Mum's the word */
 #define CONSOLE_LOGLEVEL_MIN	 1 /* Minimum loglevel we let people use */
 #define CONSOLE_LOGLEVEL_DEBUG	10 /* issue debug messages */
 #define CONSOLE_LOGLEVEL_MOTORMOUTH 15	/* You can't shut this one up */
@@ -66,17 +66,6 @@ static inline const char *printk_skip_headers(const char *buffer)
 #define minimum_console_loglevel (console_printk[2])
 #define default_console_loglevel (console_printk[3])
 
-static inline void console_silent(void)
-{
-	console_loglevel = CONSOLE_LOGLEVEL_SILENT;
-}
-
-static inline void console_verbose(void)
-{
-	if (console_loglevel)
-		console_loglevel = CONSOLE_LOGLEVEL_MOTORMOUTH;
-}
-
 /* strlen("ratelimit") + 1 */
 #define DEVKMSG_STR_MAX_SIZE 10
 extern char devkmsg_log_str[];
@@ -205,6 +194,8 @@ extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
 extern void printk_safe_init(void);
 extern void printk_safe_flush(void);
 extern void printk_safe_flush_on_panic(void);
+int get_local_loglevel(void);
+void set_local_loglevel(int level);
 #else
 static inline __printf(1, 0)
 int vprintk(const char *s, va_list args)
@@ -280,8 +271,22 @@ static inline void printk_safe_flush(void)
 static inline void printk_safe_flush_on_panic(void)
 {
 }
+
+static inline int get_local_loglevel(void)
+{
+	return 0;
+}
+
+static inline void set_local_loglevel(int level)
+{
+}
 #endif
 
+static inline void console_verbose(void)
+{
+	set_local_loglevel(CONSOLE_LOGLEVEL_MOTORMOUTH);
+}
+
 extern int kptr_restrict;
 
 #ifndef pr_fmt
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1183741..283d0d2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -732,6 +732,9 @@ struct task_struct {
 	/* to be used once the psi infrastructure lands upstream. */
 	unsigned			use_memdelay:1;
 #endif
+#ifdef CONFIG_PRINTK
+	unsigned			printk_loglevel:8;
+#endif
 
 	unsigned long			atomic_flags; /* Flags requiring atomic access. */
 
diff --git a/kernel/debug/kdb/kdb_bt.c b/kernel/debug/kdb/kdb_bt.c
index 7e2379a..e2580d3 100644
--- a/kernel/debug/kdb/kdb_bt.c
+++ b/kernel/debug/kdb/kdb_bt.c
@@ -21,8 +21,9 @@
 
 static void kdb_show_stack(struct task_struct *p, void *addr)
 {
-	int old_lvl = console_loglevel;
-	console_loglevel = CONSOLE_LOGLEVEL_MOTORMOUTH;
+	int old_lvl = get_local_loglevel();
+
+	set_local_loglevel(CONSOLE_LOGLEVEL_MOTORMOUTH);
 	kdb_trap_printk++;
 	kdb_set_current_task(p);
 	if (addr) {
@@ -36,7 +37,7 @@ static void kdb_show_stack(struct task_struct *p, void *addr)
 	} else {
 		show_stack(p, NULL);
 	}
-	console_loglevel = old_lvl;
+	set_local_loglevel(old_lvl);
 	kdb_trap_printk--;
 }
 
diff --git a/kernel/debug/kdb/kdb_io.c b/kernel/debug/kdb/kdb_io.c
index 3a5184e..723d62d 100644
--- a/kernel/debug/kdb/kdb_io.c
+++ b/kernel/debug/kdb/kdb_io.c
@@ -715,8 +715,8 @@ int vkdb_printf(enum kdb_msgsrc src, const char *fmt, va_list ap)
 		}
 	}
 	if (logging) {
-		saved_loglevel = console_loglevel;
-		console_loglevel = CONSOLE_LOGLEVEL_SILENT;
+		saved_loglevel = get_local_loglevel();
+		set_local_loglevel(CONSOLE_LOGLEVEL_SILENT);
 		if (printk_get_level(kdb_buffer) || src = KDB_MSGSRC_PRINTK)
 			printk("%s", kdb_buffer);
 		else
@@ -845,7 +845,7 @@ int vkdb_printf(enum kdb_msgsrc src, const char *fmt, va_list ap)
 kdb_print_out:
 	suspend_grep = 0; /* end of what may have been a recursive call */
 	if (logging)
-		console_loglevel = saved_loglevel;
+		set_local_loglevel(saved_loglevel);
 	/* kdb_printf_cpu locked the code above. */
 	smp_store_release(&kdb_printf_cpu, old_cpu);
 	local_irq_restore(flags);
diff --git a/kernel/debug/kdb/kdb_main.c b/kernel/debug/kdb/kdb_main.c
index 9ecfa37..e1f55d8 100644
--- a/kernel/debug/kdb/kdb_main.c
+++ b/kernel/debug/kdb/kdb_main.c
@@ -1130,13 +1130,14 @@ static int kdb_reboot(int argc, const char **argv)
 
 static void kdb_dumpregs(struct pt_regs *regs)
 {
-	int old_lvl = console_loglevel;
-	console_loglevel = CONSOLE_LOGLEVEL_MOTORMOUTH;
+	int old_lvl = get_local_loglevel();
+
+	set_local_loglevel(CONSOLE_LOGLEVEL_MOTORMOUTH);
 	kdb_trap_printk++;
 	show_regs(regs);
 	kdb_trap_printk--;
 	kdb_printf("\n");
-	console_loglevel = old_lvl;
+	set_local_loglevel(old_lvl);
 }
 
 void kdb_set_current_task(struct task_struct *p)
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 1888f6a..9adb180 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -351,7 +351,9 @@ enum con_msg_format_flags {
  */
 
 enum log_flags {
-	LOG_NEWLINE	= 2,	/* text ended with a newline */
+	LOG_ALWAYS_CON  = 1,    /* Force suppress_message_printing() = false */
+	LOG_NEVER_CON   = 2,    /* Force suppress_message_printing() = true */
+	LOG_NEWLINE	= 4,	/* text ended with a newline */
 	LOG_CONT	= 8,	/* text is a fragment of a continuation line */
 };
 
@@ -1172,6 +1174,9 @@ void __init setup_log_buf(int early)
 }
 
 static bool __read_mostly ignore_loglevel;
+static DEFINE_PER_CPU(char, printk_loglevel_nmi);
+static DEFINE_PER_CPU(char, printk_loglevel_irq);
+static DEFINE_PER_CPU(char, printk_loglevel_softirq);
 
 static int __init ignore_loglevel_setup(char *str)
 {
@@ -1186,11 +1191,40 @@ static int __init ignore_loglevel_setup(char *str)
 MODULE_PARM_DESC(ignore_loglevel,
 		 "ignore loglevel setting (prints all kernel messages to the console)");
 
-static bool suppress_message_printing(int level)
+static bool suppress_message_printing(int flags, int level)
 {
+	if (flags & LOG_ALWAYS_CON)
+		return false;
+	if (flags & LOG_NEVER_CON)
+		return true;
 	return (level >= console_loglevel && !ignore_loglevel);
 }
 
+int get_local_loglevel(void)
+{
+	if (in_nmi())
+		return this_cpu_read(printk_loglevel_nmi);
+	if (in_irq())
+		return this_cpu_read(printk_loglevel_irq);
+	if (in_serving_softirq())
+		return this_cpu_read(printk_loglevel_softirq);
+	return current->printk_loglevel;
+}
+EXPORT_SYMBOL(get_local_loglevel);
+
+void set_local_loglevel(int level)
+{
+	if (in_nmi())
+		this_cpu_write(printk_loglevel_nmi, (char) level);
+	else if (in_irq())
+		this_cpu_write(printk_loglevel_irq, (char) level);
+	else if (in_serving_softirq())
+		this_cpu_write(printk_loglevel_softirq, (char) level);
+	else
+		current->printk_loglevel = (char) level;
+}
+EXPORT_SYMBOL(set_local_loglevel);
+
 #ifdef CONFIG_BOOT_PRINTK_DELAY
 
 static int boot_delay; /* msecs delay after each printk during bootup */
@@ -1220,7 +1254,7 @@ static void boot_delay_msec(int level)
 	unsigned long timeout;
 
 	if ((boot_delay = 0 || system_state >= SYSTEM_RUNNING)
-		|| suppress_message_printing(level)) {
+	    || suppress_message_printing(0, level)) {
 		return;
 	}
 
@@ -1934,6 +1968,25 @@ int vprintk_store(int facility, int level,
 	if (level = LOGLEVEL_DEFAULT)
 		level = default_message_loglevel;
 
+	{
+		int loglevel;
+
+		if (in_nmi())
+			loglevel = this_cpu_read(printk_loglevel_nmi);
+		else if (in_irq())
+			loglevel = this_cpu_read(printk_loglevel_irq);
+		else if (in_serving_softirq())
+			loglevel = this_cpu_read(printk_loglevel_softirq);
+		else
+			loglevel = current->printk_loglevel;
+		if (loglevel) {
+			if (level >= loglevel && !ignore_loglevel)
+				lflags |= LOG_NEVER_CON;
+			else
+				lflags |= LOG_ALWAYS_CON;
+		}
+	}
+
 	if (dict)
 		lflags |= LOG_NEWLINE;
 
@@ -2080,7 +2133,7 @@ static void call_console_drivers(const char *ext_text, size_t ext_len,
 				 const char *text, size_t len) {}
 static size_t msg_print_text(const struct printk_log *msg, bool syslog,
 			     bool time, char *buf, size_t size) { return 0; }
-static bool suppress_message_printing(int level) { return false; }
+static bool suppress_message_printing(int flags, int level) { return false; }
 
 #endif /* CONFIG_PRINTK */
 
@@ -2418,7 +2471,7 @@ void console_unlock(void)
 			break;
 
 		msg = log_from_idx(console_idx);
-		if (suppress_message_printing(msg->level)) {
+		if (suppress_message_printing(msg->flags, msg->level)) {
 			/*
 			 * Skip record we have buffered and already printed
 			 * directly to the console when we received it, and
diff --git a/kernel/printk/printk_safe.c b/kernel/printk/printk_safe.c
index b4045e7..0104ed6 100644
--- a/kernel/printk/printk_safe.c
+++ b/kernel/printk/printk_safe.c
@@ -186,6 +186,9 @@ static void __printk_safe_flush(struct irq_work *work)
 	unsigned long flags;
 	size_t len;
 	int i;
+	int level = get_local_loglevel();
+
+	set_local_loglevel(CONSOLE_LOGLEVEL_MOTORMOUTH);
 
 	/*
 	 * The lock has two functions. First, one reader has to flush all
@@ -232,6 +235,7 @@ static void __printk_safe_flush(struct irq_work *work)
 out:
 	report_message_lost(s);
 	raw_spin_unlock_irqrestore(&read_lock, flags);
+	set_local_loglevel(level);
 }
 
 /**
-- 
1.8.3.1

