From: Josh Poimboeuf <jpoimboe@redhat.com>
Date: Wed, 24 Mar 2021 16:01:43 +0000
Subject: Re: [PATCH -tip v4 10/12] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210324160143.wd43zribpeop2czn@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
 <161639530062.895304.16962383429668412873.stgit@devnote2>
 <20210323223007.GG4746@worktop.programming.kicks-ass.net>
 <20210324104058.7c06aaeb0408e24db6ba46f8@kernel.org>
In-Reply-To: <20210324104058.7c06aaeb0408e24db6ba46f8@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Wed, Mar 24, 2021 at 10:40:58AM +0900, Masami Hiramatsu wrote:
> On Tue, 23 Mar 2021 23:30:07 +0100
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Mon, Mar 22, 2021 at 03:41:40PM +0900, Masami Hiramatsu wrote:
> > >  	".global kretprobe_trampoline\n"
> > >  	".type kretprobe_trampoline, @function\n"
> > >  	"kretprobe_trampoline:\n"
> > >  #ifdef CONFIG_X86_64
> > 
> > So what happens if we get an NMI here? That is, after the RET but before
> > the push? Then our IP points into the trampoline but we've not done that
> > push yet.
> 
> Not only NMI, but also interrupts can happen. There is no cli/sti here.
> 
> Anyway, thanks for pointing!
> I think in UNWIND_HINT_TYPE_REGS and UNWIND_HINT_TYPE_REGS_PARTIAL cases
> ORC unwinder also has to check the state->ip and if it is kretprobe_trampoline,
> it should be recovered.
> What about this?

I think the REGS and REGS_PARTIAL cases can also be affected by function
graph tracing.  So should they use the generic unwind_recover_ret_addr()
instead of unwind_recover_kretprobe()?

-- 
Josh
