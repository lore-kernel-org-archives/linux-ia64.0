From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 19 Mar 2021 12:23:01 +0000
Subject: [PATCH -tip v3 07/11] ia64: Add instruction_pointer_set() API
Message-Id: <161615658087.306069.12036720803234007510.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <161615650355.306069.17260992641363840330.stgit@devnote2>
In-Reply-To: <161615650355.306069.17260992641363840330.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org

Add instruction_pointer_set() API for ia64.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 arch/ia64/include/asm/ptrace.h |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrace.h
index b3aa46090101..e382f1a6bff3 100644
--- a/arch/ia64/include/asm/ptrace.h
+++ b/arch/ia64/include/asm/ptrace.h
@@ -45,6 +45,7 @@
 #include <asm/current.h>
 #include <asm/page.h>
 
+# define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)
 /*
  * We use the ia64_psr(regs)->ri to determine which of the three
  * instructions in bundle (16 bytes) took the sample. Generate
@@ -71,6 +72,12 @@ static inline long regs_return_value(struct pt_regs *regs)
 		return -regs->r8;
 }
 
+static inline void instruction_pointer_set(struct pt_regs *regs, unsigned long val)
+{
+	ia64_psr(regs)->ri = (val & 0xf);
+	regs->cr_iip = (val & ~0xfULL);
+}
+
 /* Conserve space in histogram by encoding slot bits in address
  * bits 2 and 3 rather than bits 0 and 1.
  */
@@ -87,7 +94,6 @@ static inline long regs_return_value(struct pt_regs *regs)
 
   /* given a pointer to a task_struct, return the user's pt_regs */
 # define task_pt_regs(t)		(((struct pt_regs *) ((char *) (t) + IA64_STK_OFFSET)) - 1)
-# define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)
 # define user_mode(regs)		(((struct ia64_psr *) &(regs)->cr_ipsr)->cpl != 0)
 # define user_stack(task,regs)	((long) regs - (long) task = IA64_STK_OFFSET - sizeof(*regs))
 # define fsys_mode(task,regs)					\
