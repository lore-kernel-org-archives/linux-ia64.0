From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Wed, 24 Mar 2021 01:40:58 +0000
Subject: Re: [PATCH -tip v4 10/12] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210324104058.7c06aaeb0408e24db6ba46f8@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
        <161639530062.895304.16962383429668412873.stgit@devnote2>
        <20210323223007.GG4746@worktop.programming.kicks-ass.net>
In-Reply-To: <20210323223007.GG4746@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Tue, 23 Mar 2021 23:30:07 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Mar 22, 2021 at 03:41:40PM +0900, Masami Hiramatsu wrote:
> >  	".global kretprobe_trampoline\n"
> >  	".type kretprobe_trampoline, @function\n"
> >  	"kretprobe_trampoline:\n"
> >  #ifdef CONFIG_X86_64
> 
> So what happens if we get an NMI here? That is, after the RET but before
> the push? Then our IP points into the trampoline but we've not done that
> push yet.

Not only NMI, but also interrupts can happen. There is no cli/sti here.

Anyway, thanks for pointing!
I think in UNWIND_HINT_TYPE_REGS and UNWIND_HINT_TYPE_REGS_PARTIAL cases
ORC unwinder also has to check the state->ip and if it is kretprobe_trampoline,
it should be recovered.
What about this?

diff --git a/arch/x86/include/asm/unwind.h b/arch/x86/include/asm/unwind.h
index 332aa6174b10..36d3971c0a2c 100644
--- a/arch/x86/include/asm/unwind.h
+++ b/arch/x86/include/asm/unwind.h
@@ -101,6 +101,15 @@ void unwind_module_init(struct module *mod, void *orc_ip, size_t orc_ip_size,
 			void *orc, size_t orc_size) {}
 #endif
 
+static inline
+unsigned long unwind_recover_kretprobe(struct unwind_state *state,
+				       unsigned long addr, unsigned long *addr_p)
+{
+	return is_kretprobe_trampoline(addr) ?
+		kretprobe_find_ret_addr(state->task, addr_p, &state->kr_cur) :
+		addr;
+}
+
 /* Recover the return address modified by instrumentation (e.g. kretprobe) */
 static inline
 unsigned long unwind_recover_ret_addr(struct unwind_state *state,
@@ -110,10 +119,7 @@ unsigned long unwind_recover_ret_addr(struct unwind_state *state,
 
 	ret = ftrace_graph_ret_addr(state->task, &state->graph_idx,
 				    addr, addr_p);
-	if (is_kretprobe_trampoline(ret))
-		ret = kretprobe_find_ret_addr(state->task, addr_p,
-					      &state->kr_cur);
-	return ret;
+	return unwind_recover_kretprobe(state, ret, addr_p);
 }
 
 /*
diff --git a/arch/x86/kernel/unwind_orc.c b/arch/x86/kernel/unwind_orc.c
index 839a0698342a..cb59aeca6a4a 100644
--- a/arch/x86/kernel/unwind_orc.c
+++ b/arch/x86/kernel/unwind_orc.c
@@ -549,7 +549,15 @@ bool unwind_next_frame(struct unwind_state *state)
 					 (void *)orig_ip);
 			goto err;
 		}
-
+		/*
+		 * There is a small chance to interrupt at the entry of
+		 * kretprobe_trampoline where the ORC info doesn't exist.
+		 * That point is right after the RET to kretprobe_trampoline
+		 * which was modified return address. So the @addr_p must
+		 * be right before the regs->sp.
+		 */
+		state->ip = unwind_recover_kretprobe(state, state->ip,
+					state->sp - sizeof(unsigned long));
 		state->regs = (struct pt_regs *)sp;
 		state->prev_regs = NULL;
 		state->full_regs = true;
@@ -562,6 +570,9 @@ bool unwind_next_frame(struct unwind_state *state)
 					 (void *)orig_ip);
 			goto err;
 		}
+		/* See UNWIND_HINT_TYPE_REGS case comment. */
+		state->ip = unwind_recover_kretprobe(state, state->ip,
+					state->sp - sizeof(unsigned long));
 
 		if (state->full_regs)
 			state->prev_regs = state->regs;


-- 
Masami Hiramatsu <mhiramat@kernel.org>
