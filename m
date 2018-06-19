From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 19 Jun 2018 16:13:20 +0000
Subject: [PATCH -tip v6 19/27] ia64: kprobes: Don't call the ->break_handler() in ia64 kprobes code
Message-Id: <152942480045.15209.10715901482832337704.stgit@devbox>
List-Id: <linux-ia64.vger.kernel.org>
References: <152942424698.15209.15245996287444292393.stgit@devbox>
In-Reply-To: <152942424698.15209.15245996287444292393.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, Ananth N Mavinakayanahalli <ananth@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Don't call the ->break_handler() from the ia64 kprobes code,
because it was only used by jprobes which got removed.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/uapi/asm/break.h |    1 -
 arch/ia64/kernel/kprobes.c         |   10 ----------
 2 files changed, 11 deletions(-)

diff --git a/arch/ia64/include/uapi/asm/break.h b/arch/ia64/include/uapi/asm/break.h
index 5d742bcb0018..4ca110f0a94b 100644
--- a/arch/ia64/include/uapi/asm/break.h
+++ b/arch/ia64/include/uapi/asm/break.h
@@ -14,7 +14,6 @@
  */
 #define __IA64_BREAK_KDB		0x80100
 #define __IA64_BREAK_KPROBE		0x81000 /* .. 0x81fff */
-#define __IA64_BREAK_JPROBE		0x82000
 
 /*
  * OS-specific break numbers:
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 823e4bd03a18..74c8524e6309 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -817,14 +817,6 @@ static int __kprobes pre_kprobes_handler(struct die_args *args)
 			prepare_ss(p, regs);
 			kcb->kprobe_status = KPROBE_REENTER;
 			return 1;
-		} else if (args->err = __IA64_BREAK_JPROBE) {
-			/*
-			 * jprobe instrumented function just completed
-			 */
-			p = __this_cpu_read(current_kprobe);
-			if (p->break_handler && p->break_handler(p, regs)) {
-				goto ss_probe;
-			}
 		} else if (!is_ia64_break_inst(regs)) {
 			/* The breakpoint instruction was removed by
 			 * another cpu right after we hit, no further
@@ -867,7 +859,6 @@ static int __kprobes pre_kprobes_handler(struct die_args *args)
 		 */
 		return 1;
 
-ss_probe:
 #if !defined(CONFIG_PREEMPT)
 	if (p->ainsn.inst_flag = INST_FLAG_BOOSTABLE && !p->post_handler) {
 		/* Boost up -- we can execute copied instructions directly */
@@ -990,7 +981,6 @@ int __kprobes kprobe_exceptions_notify(struct notifier_block *self,
 	case DIE_BREAK:
 		/* err is break number from ia64_bad_break() */
 		if ((args->err >> 12) = (__IA64_BREAK_KPROBE >> 12)
-			|| args->err = __IA64_BREAK_JPROBE
 			|| args->err = 0)
 			if (pre_kprobes_handler(args))
 				ret = NOTIFY_STOP;

