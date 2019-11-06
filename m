From: Dmitry Safonov <dima@arista.com>
Date: Wed, 06 Nov 2019 03:05:06 +0000
Subject: [PATCH 15/50] ia64: Pass log level as arg into ia64_do_show_stack()
Message-Id: <20191106030542.868541-16-dima@arista.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191106030542.868541-1-dima@arista.com>
In-Reply-To: <20191106030542.868541-1-dima@arista.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Dmitry Safonov <dima@arista.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Jiri Slaby <jslaby@suse.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Currently, the log-level of show_stack() depends on a platform
realization. It creates situations where the headers are printed with
lower log level or higher than the stacktrace (depending on
a platform or user).

Furthermore, it forces the logic decision from user to an architecture
side. In result, some users as sysrq/kdb/etc are doing tricks with
temporary rising console_loglevel while printing their messages.
And in result it not only may print unwanted messages from other CPUs,
but also omit printing at all in the unlucky case where the printk()
was deferred.

Introducing log-level parameter and KERN_UNSUPPRESSED [1] seems
an easier approach than introducing more printk buffers.
Also, it will consolidate printings with headers.

Add log level argument to ia64_do_show_stack() as a preparation to
introduce show_stack_loglvl().
Also, make ia64_do_show_stack() static as it's not used outside.

Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
[1]: https://lore.kernel.org/lkml/20190528002412.1625-1-dima@arista.com/T/#u
Signed-off-by: Dmitry Safonov <dima@arista.com>
---
 arch/ia64/include/asm/ptrace.h |  1 -
 arch/ia64/kernel/process.c     | 13 +++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrace.h
index 7ff574d56429..b3aa46090101 100644
--- a/arch/ia64/include/asm/ptrace.h
+++ b/arch/ia64/include/asm/ptrace.h
@@ -114,7 +114,6 @@ static inline long regs_return_value(struct pt_regs *regs)
   struct task_struct;			/* forward decl */
   struct unw_frame_info;		/* forward decl */
 
-  extern void ia64_do_show_stack (struct unw_frame_info *, void *);
   extern unsigned long ia64_get_user_rbs_end (struct task_struct *, struct pt_regs *,
 					      unsigned long *);
   extern long ia64_peek (struct task_struct *, struct switch_stack *, unsigned long,
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 968b5f33e725..0526cc51ff0b 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -64,12 +64,13 @@ EXPORT_SYMBOL(boot_option_idle_override);
 void (*pm_power_off) (void);
 EXPORT_SYMBOL(pm_power_off);
 
-void
+static void
 ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 {
 	unsigned long ip, sp, bsp;
+	const char *loglvl = arg;
 
-	printk("\nCall Trace:\n");
+	printk("%s\nCall Trace:\n", loglvl);
 	do {
 		unw_get_ip(info, &ip);
 		if (ip = 0)
@@ -77,9 +78,9 @@ ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 
 		unw_get_sp(info, &sp);
 		unw_get_bsp(info, &bsp);
-		printk(" [<%016lx>] %pS\n"
+		printk("%s [<%016lx>] %pS\n"
 			 "                                sp=%016lx bsp=%016lx\n",
-			 ip, (void *)ip, sp, bsp);
+			 loglvl, ip, (void *)ip, sp, bsp);
 	} while (unw_unwind(info) >= 0);
 }
 
@@ -87,12 +88,12 @@ void
 show_stack (struct task_struct *task, unsigned long *sp)
 {
 	if (!task)
-		unw_init_running(ia64_do_show_stack, NULL);
+		unw_init_running(ia64_do_show_stack, (void *)KERN_DEFAULT);
 	else {
 		struct unw_frame_info info;
 
 		unw_init_from_blocked_task(&info, task);
-		ia64_do_show_stack(&info, NULL);
+		ia64_do_show_stack(&info, (void *)KERN_DEFAULT);
 	}
 }
 
-- 
2.23.0
