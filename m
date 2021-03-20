From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sat, 20 Mar 2021 13:05:43 +0000
Subject: Re: [PATCH -tip v3 05/11] x86/kprobes: Add UNWIND_HINT_FUNC on kretprobe_trampoline code
Message-Id: <20210320220543.e1558ce3a351554c6be3ea26@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161615650355.306069.17260992641363840330.stgit@devnote2>
        <161615655969.306069.4545805781593088526.stgit@devnote2>
        <20210320211616.a976fc66d0c51e13d3121e2f@kernel.org>
In-Reply-To: <20210320211616.a976fc66d0c51e13d3121e2f@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org

On Sat, 20 Mar 2021 21:16:16 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> On Fri, 19 Mar 2021 21:22:39 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > From: Josh Poimboeuf <jpoimboe@redhat.com>
> > 
> > Add UNWIND_HINT_FUNC on kretporbe_trampoline code so that ORC
> > information is generated on the kretprobe_trampoline correctly.
> > 
> 
> Test bot also found a new warning for this.
> 
> > >> arch/x86/kernel/kprobes/core.o: warning: objtool: kretprobe_trampoline()+0x25: call without frame pointer save/setup
> 
> With CONFIG_FRAME_POINTER=y.
> 
> Of course this can be fixed with additional "push %bp; mov %sp, %bp" before calling
> trampoline_handler. But actually we know that this function has a bit special
> stack frame too. 
> 
> Can I recover STACK_FRAME_NON_STANDARD(kretprobe_trampoline) when CONFIG_FRAME_POINTER=y ?

So something like this. Does it work?

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index b31058a152b6..651f337dc880 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -760,6 +760,10 @@ int kprobe_int3_handler(struct pt_regs *regs)
 }
 NOKPROBE_SYMBOL(kprobe_int3_handler);
 
+#ifdef CONFIG_FRAME_POINTER
+#undef UNWIND_HINT_FUNC
+#define UNWIND_HINT_FUNC
+#endif
 /*
  * When a retprobed function returns, this code saves registers and
  * calls trampoline_handler() runs, which calls the kretprobe's handler.
@@ -797,7 +801,14 @@ asm(
 	".size kretprobe_trampoline, .-kretprobe_trampoline\n"
 );
 NOKPROBE_SYMBOL(kretprobe_trampoline);
-
+#ifdef CONFIG_FRAME_POINTER
+/*
+ * kretprobe_trampoline skips updating frame pointer. The frame pointer
+ * saved in trampoline_handler points to the real caller function's
+ * frame pointer.
+ */
+STACK_FRAME_NON_STANDARD(kretprobe_trampoline);
+#endif
 
 /*
  * Called from kretprobe_trampoline

-- 
Masami Hiramatsu <mhiramat@kernel.org>
