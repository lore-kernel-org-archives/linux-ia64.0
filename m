From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 06 Jul 2021 07:55:03 +0000
Subject: Re: [PATCH -tip v8 11/13] x86/unwind: Recover kretprobe trampoline entry
Message-Id: <YOQMV8uE/2bVkPOY@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162400002631.506599.2413605639666466945.stgit@devnote2>
 <YOLurg5mGHdBc+fz@hirez.programming.kicks-ass.net>
 <20210706004257.9e282b98f447251a380f658f@kernel.org>
In-Reply-To: <20210706004257.9e282b98f447251a380f658f@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Tue, Jul 06, 2021 at 12:42:57AM +0900, Masami Hiramatsu wrote:
> On Mon, 5 Jul 2021 13:36:14 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Fri, Jun 18, 2021 at 04:07:06PM +0900, Masami Hiramatsu wrote:
> > > @@ -549,7 +548,15 @@ bool unwind_next_frame(struct unwind_state *state)
> > >  					 (void *)orig_ip);
> > >  			goto err;
> > >  		}
> > > -
> > > +		/*
> > > +		 * There is a small chance to interrupt at the entry of
> > > +		 * kretprobe_trampoline where the ORC info doesn't exist.
> > > +		 * That point is right after the RET to kretprobe_trampoline
> > > +		 * which was modified return address. So the @addr_p must
> > > +		 * be right before the regs->sp.
> > > +		 */
> > > +		state->ip = unwind_recover_kretprobe(state, state->ip,
> > > +				(unsigned long *)(state->sp - sizeof(long)));
> > >  		state->regs = (struct pt_regs *)sp;
> > >  		state->prev_regs = NULL;
> > >  		state->full_regs = true;
> > > @@ -562,6 +569,9 @@ bool unwind_next_frame(struct unwind_state *state)
> > >  					 (void *)orig_ip);
> > >  			goto err;
> > >  		}
> > > +		/* See UNWIND_HINT_TYPE_REGS case comment. */
> > > +		state->ip = unwind_recover_kretprobe(state, state->ip,
> > > +				(unsigned long *)(state->sp - sizeof(long)));
> > >  
> > >  		if (state->full_regs)
> > >  			state->prev_regs = state->regs;
> > 
> > Why doesn't the ftrace case have this? That is, why aren't both return
> > trampolines having the same general shape?
> 
> Ah, this strongly depends what the trampoline code does.
> For the kretprobe case, the PUSHQ at the entry of the kretprobe_trampoline()
> does not covered by UNWIND_HINT_FUNC. Thus it needs to find 'correct_ret_addr'
> by the frame pointer (which is next to the sp).
> 
>         "kretprobe_trampoline:\n"
> #ifdef CONFIG_X86_64
>         /* Push fake return address to tell the unwinder it's a kretprobe */
>         "       pushq $kretprobe_trampoline\n"
>         UNWIND_HINT_FUNC
> 
> But I'm not so sure how ftrace treat it. It seems that the return_to_handler()
> doesn't care such case. (anyway, return_to_handler() does not return but jump
> to the original call-site, in that case, the information will be lost.)

I find it bothersome (OCD, sorry :-) that both return trampolines behave
differently. Doubly so because I know people (Steve in particular) have
been talking about unifying them.

Steve, can you clarify the ftrace side here? Afaict return_to_handler()
is similarly affected.
