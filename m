From: Masami Hiramatsu <mhiramat@redhat.com>
Date: Thu, 19 Mar 2009 21:10:16 +0000
Subject: [RFC][PATCH -tip 3/9] ia64: add kernel_trap_sp()
Message-Id: <49C2B4B8.1020507@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>
Cc: LKML <linux-kernel@vger.kernel.org>, systemtap-ml <systemtap@sources.redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, ia64 <linux-ia64@vger.kernel.org>

Add kernel_trap_sp() on ia64, based on systemtap's runtime/regs.h.

Signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
Cc: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/ptrace.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrace.h
index 14055c6..3a7dfcb 100644
--- a/arch/ia64/include/asm/ptrace.h
+++ b/arch/ia64/include/asm/ptrace.h
@@ -246,6 +246,12 @@ static inline unsigned long user_stack_pointer(struct pt_regs *regs)
 	return regs->ar_bspstore;
 }

+static inline unsigned long kernel_trap_sp(struct pt_regs *regs)
+{
+	/* interrupted task's memory stack pointer is r12 */
+	return regs->r12;
+}
+
 #define regs_return_value(regs) ((regs)->r8)

 /* Conserve space in histogram by encoding slot bits in address
-- 
Masami Hiramatsu

Software Engineer
Hitachi Computer Products (America) Inc.
Software Solutions Division

e-mail: mhiramat@redhat.com


