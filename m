From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sat, 10 Jul 2021 01:41:04 +0000
Subject: Re: [PATCH -tip v8 05/13] x86/kprobes: Add UNWIND_HINT_FUNC on kretprobe_trampoline code
Message-Id: <20210710104104.3a270168811ac38420093276@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
        <162399996966.506599.810050095040575221.stgit@devnote2>
        <YOK8pzp8B2V+1EaU@gmail.com>
        <20210710003140.8e561ad33d42f9ac78de6a15@kernel.org>
In-Reply-To: <20210710003140.8e561ad33d42f9ac78de6a15@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Masami Hiramatsu <mhiramat@kernel.org>

Hi Ingo and Josh,

On Sat, 10 Jul 2021 00:31:40 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> > > +STACK_FRAME_NON_STANDARD(kretprobe_trampoline);
> > > +#undef UNWIND_HINT_FUNC
> > > +#define UNWIND_HINT_FUNC
> > > +#endif
> > >  /*
> > >   * When a retprobed function returns, this code saves registers and
> > >   * calls trampoline_handler() runs, which calls the kretprobe's handler.
> > > @@ -1031,6 +1044,7 @@ asm(
> > >  	/* We don't bother saving the ss register */
> > >  #ifdef CONFIG_X86_64
> > >  	"	pushq %rsp\n"
> > > +	UNWIND_HINT_FUNC
> > >  	"	pushfq\n"
> > >  	SAVE_REGS_STRING
> > >  	"	movq %rsp, %rdi\n"
> > > @@ -1041,6 +1055,7 @@ asm(
> > >  	"	popfq\n"
> > >  #else
> > >  	"	pushl %esp\n"
> > > +	UNWIND_HINT_FUNC
> > >  	"	pushfl\n"
> > >  	SAVE_REGS_STRING
> > >  	"	movl %esp, %eax\n"
> > 
> > Why not provide an appropriate annotation method in <asm/unwind_hints.h>, 
> > so that other future code can use it too instead of reinventing the wheel?

I think I got what you meant. Let me summarize the issue.

In case of CONFIG_FRAME_POINTER=n, it is OK just adding UNWIND_HINT_FUNC.

In case of CONFIG_FRAME_POINTER=y, without STACK_FRAME_NON_STANDARD(),
the objtool complains that a CALL instruction without the frame pointer.
---
  arch/x86/kernel/kprobes/core.o: warning: objtool: __kretprobe_trampoline()+0x25: call without frame pointer save/setup
---

If we just add STACK_FRAME_NON_STANDARD() with UNWIND_HINT_FUNC macro,
the objtool complains that non-standard function has unwind hint.
---
arch/x86/kernel/kprobes/core.o: warning: objtool: __kretprobe_trampoline()+0x1: BUG: why am I validating an ignored function?
---

Thus, add STACK_FRAME_NON_STANDARD() and undefine UNWIND_HINT_FUNC macro,
the objtool doesn't complain.

This means that the STACK_FRAME_NON_STANDARD() and UNWIND_HINT_FUNC macro
are mutually exclusive. However, those macros are used different way.
The STACK_FRAME_NON_STANDARD() will have the target symbol and the
UNWIND_HINT_FUNC needs to be embedded in the target code.
Thus we can not combine them in general.

If we can have something like UNWIND_HINT_FUNC_NO_FP, it may solve this
issue without ugly #ifdef and #undef.

Is that correct?

Maybe I can add UNWIND_HINT_TYPE_FUNC_NO_FP for UNWIND_HINT and make objtool
ignore the call without frame pointer. This makes an exception that the
kretprobe_trampoline will be noted in '.discard.unwind_hints' section
instead of '.discard.func_stack_frame_non_standard' section. 

Or another idea is to introduce ANNOTATE_NO_FP_FUNCTION_CALL with a new
'.discard.no_fp_function_calls' section.

What do you think these ideas?

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
