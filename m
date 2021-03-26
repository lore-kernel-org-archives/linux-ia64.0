From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 26 Mar 2021 12:03:49 +0000
Subject: Re: [PATCH -tip v4 10/12] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210326210349.22f6d34b229dd3a139a53686@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
        <161639530062.895304.16962383429668412873.stgit@devnote2>
        <20210323223007.GG4746@worktop.programming.kicks-ass.net>
        <20210324104058.7c06aaeb0408e24db6ba46f8@kernel.org>
        <20210326030503.7fa72da34e25ad35cf5ed3de@kernel.org>
In-Reply-To: <20210326030503.7fa72da34e25ad35cf5ed3de@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Fri, 26 Mar 2021 03:05:03 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> On Wed, 24 Mar 2021 10:40:58 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > On Tue, 23 Mar 2021 23:30:07 +0100
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Mon, Mar 22, 2021 at 03:41:40PM +0900, Masami Hiramatsu wrote:
> > > >  	".global kretprobe_trampoline\n"
> > > >  	".type kretprobe_trampoline, @function\n"
> > > >  	"kretprobe_trampoline:\n"
> > > >  #ifdef CONFIG_X86_64
> > > 
> > > So what happens if we get an NMI here? That is, after the RET but before
> > > the push? Then our IP points into the trampoline but we've not done that
> > > push yet.
> > 
> > Not only NMI, but also interrupts can happen. There is no cli/sti here.
> > 
> > Anyway, thanks for pointing!
> > I think in UNWIND_HINT_TYPE_REGS and UNWIND_HINT_TYPE_REGS_PARTIAL cases
> > ORC unwinder also has to check the state->ip and if it is kretprobe_trampoline,
> > it should be recovered.
> > What about this?
> 
> Hmm, this seems to intoduce another issue on stacktrace from kprobes.
> 
>            <...>-137     [003] d.Z.    17.250714: p_full_proxy_read_5: (full_proxy_read+0x5/0x80)
>            <...>-137     [003] d.Z.    17.250737: <stack trace>
>  => kprobe_trace_func+0x1d0/0x2c0
>  => kprobe_dispatcher+0x39/0x60
>  => aggr_pre_handler+0x4f/0x90
>  => kprobe_int3_handler+0x152/0x1a0
>  => exc_int3+0x47/0x140
>  => asm_exc_int3+0x31/0x40
>  => 0
>  => 0
>  => 0
>  => 0
>  => 0
>  => 0
>  => 0
> 
> Let me check...

I confirmed this is not related to this series, but occurs when I build kernels with different
configs without cleanup.

Once I build kernel with CONFIG_UNWIND_GUESS=y (for testing), and after that,
I build kernel again with CONFIG_UNWIND_ORC=y (but without make clean), this
happened. In this case, I guess ORC data might be corrupted?
When I cleanup and rebuild, the stacktrace seems correct.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
