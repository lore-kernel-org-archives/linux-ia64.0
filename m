From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 05 Jul 2021 11:36:14 +0000
Subject: Re: [PATCH -tip v8 11/13] x86/unwind: Recover kretprobe trampoline entry
Message-Id: <YOLurg5mGHdBc+fz@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162400002631.506599.2413605639666466945.stgit@devnote2>
In-Reply-To: <162400002631.506599.2413605639666466945.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Fri, Jun 18, 2021 at 04:07:06PM +0900, Masami Hiramatsu wrote:
> @@ -549,7 +548,15 @@ bool unwind_next_frame(struct unwind_state *state)
>  					 (void *)orig_ip);
>  			goto err;
>  		}
> -
> +		/*
> +		 * There is a small chance to interrupt at the entry of
> +		 * kretprobe_trampoline where the ORC info doesn't exist.
> +		 * That point is right after the RET to kretprobe_trampoline
> +		 * which was modified return address. So the @addr_p must
> +		 * be right before the regs->sp.
> +		 */
> +		state->ip = unwind_recover_kretprobe(state, state->ip,
> +				(unsigned long *)(state->sp - sizeof(long)));
>  		state->regs = (struct pt_regs *)sp;
>  		state->prev_regs = NULL;
>  		state->full_regs = true;
> @@ -562,6 +569,9 @@ bool unwind_next_frame(struct unwind_state *state)
>  					 (void *)orig_ip);
>  			goto err;
>  		}
> +		/* See UNWIND_HINT_TYPE_REGS case comment. */
> +		state->ip = unwind_recover_kretprobe(state, state->ip,
> +				(unsigned long *)(state->sp - sizeof(long)));
>  
>  		if (state->full_regs)
>  			state->prev_regs = state->regs;

Why doesn't the ftrace case have this? That is, why aren't both return
trampolines having the same general shape?
