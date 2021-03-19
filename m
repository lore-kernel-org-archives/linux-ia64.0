From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 19 Mar 2021 12:22:49 +0000
Subject: [PATCH -tip v3 06/11] ARC: Add instruction_pointer_set() API
Message-Id: <161615656974.306069.13884955082773738658.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <161615650355.306069.17260992641363840330.stgit@devnote2>
In-Reply-To: <161615650355.306069.17260992641363840330.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org

Add instruction_pointer_set() API for arc.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 arch/arc/include/asm/ptrace.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arc/include/asm/ptrace.h b/arch/arc/include/asm/ptrace.h
index 4c3c9be5bd16..cca8d6583e31 100644
--- a/arch/arc/include/asm/ptrace.h
+++ b/arch/arc/include/asm/ptrace.h
@@ -149,6 +149,11 @@ static inline long regs_return_value(struct pt_regs *regs)
 	return (long)regs->r0;
 }
 
+static inline void instruction_pointer_set(struct pt_regs *regs,
+					   unsigned long val)
+{
+	instruction_pointer(regs) = val;
+}
 #endif /* !__ASSEMBLY__ */
 
 #endif /* __ASM_PTRACE_H */
