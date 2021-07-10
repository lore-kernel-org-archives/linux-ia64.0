From: Josh Poimboeuf <jpoimboe@redhat.com>
Date: Sat, 10 Jul 2021 19:01:43 +0000
Subject: Re: [PATCH -tip v8 05/13] x86/kprobes: Add UNWIND_HINT_FUNC on kretprobe_trampoline code
Message-Id: <20210710190143.lrcsyal2ggubv43v@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162399996966.506599.810050095040575221.stgit@devnote2>
 <YOK8pzp8B2V+1EaU@gmail.com>
 <20210710003140.8e561ad33d42f9ac78de6a15@kernel.org>
 <20210710104104.3a270168811ac38420093276@kernel.org>
In-Reply-To: <20210710104104.3a270168811ac38420093276@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Sat, Jul 10, 2021 at 10:41:04AM +0900, Masami Hiramatsu wrote:
> Hi Ingo and Josh,
> 
> On Sat, 10 Jul 2021 00:31:40 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > > > +STACK_FRAME_NON_STANDARD(kretprobe_trampoline);
> > > > +#undef UNWIND_HINT_FUNC
> > > > +#define UNWIND_HINT_FUNC
> > > > +#endif
> > > >  /*
> > > >   * When a retprobed function returns, this code saves registers and
> > > >   * calls trampoline_handler() runs, which calls the kretprobe's handler.
> > > > @@ -1031,6 +1044,7 @@ asm(
> > > >  	/* We don't bother saving the ss register */
> > > >  #ifdef CONFIG_X86_64
> > > >  	"	pushq %rsp\n"
> > > > +	UNWIND_HINT_FUNC
> > > >  	"	pushfq\n"
> > > >  	SAVE_REGS_STRING
> > > >  	"	movq %rsp, %rdi\n"
> > > > @@ -1041,6 +1055,7 @@ asm(
> > > >  	"	popfq\n"
> > > >  #else
> > > >  	"	pushl %esp\n"
> > > > +	UNWIND_HINT_FUNC
> > > >  	"	pushfl\n"
> > > >  	SAVE_REGS_STRING
> > > >  	"	movl %esp, %eax\n"
> > > 
> > > Why not provide an appropriate annotation method in <asm/unwind_hints.h>, 
> > > so that other future code can use it too instead of reinventing the wheel?
> 
> I think I got what you meant. Let me summarize the issue.
> 
> In case of CONFIG_FRAME_POINTER=n, it is OK just adding UNWIND_HINT_FUNC.
> 
> In case of CONFIG_FRAME_POINTER=y, without STACK_FRAME_NON_STANDARD(),
> the objtool complains that a CALL instruction without the frame pointer.
> ---
>   arch/x86/kernel/kprobes/core.o: warning: objtool: __kretprobe_trampoline()+0x25: call without frame pointer save/setup
> ---
> 
> If we just add STACK_FRAME_NON_STANDARD() with UNWIND_HINT_FUNC macro,
> the objtool complains that non-standard function has unwind hint.
> ---
> arch/x86/kernel/kprobes/core.o: warning: objtool: __kretprobe_trampoline()+0x1: BUG: why am I validating an ignored function?

I'm thinking this latter warning indicates an objtool bug (as the BUG
warning claims).  If a function is ignored with
STACK_FRAME_NON_STANDARD() then objtool should probably also ignore its
hints.  Then we should be able to get rid of the #undef/#ifdef
UNWIND_HINT_FUNC silliness.

The other warning is correct and STACK_FRAME_NON_STANDARD() still needs
to be behind '#ifdef CONFIG_FRAME_POINTER' since the function is missing
a frame pointer.  So maybe we can make a STACK_FRAME_NON_STANDARD_FP()
or similar.

I'll post a few patches.

-- 
Josh
