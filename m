From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 25 Mar 2021 03:25:24 +0000
Subject: Re: [PATCH -tip v4 10/12] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210325122524.91bca1233c0c254fdc0678fc@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
        <161639530062.895304.16962383429668412873.stgit@devnote2>
        <20210323223007.GG4746@worktop.programming.kicks-ass.net>
        <20210324104058.7c06aaeb0408e24db6ba46f8@kernel.org>
        <20210324160143.wd43zribpeop2czn@treble>
        <20210325084741.74bdb2b1d2ed00fe68840cea@kernel.org>
        <20210324202613.7cad6f4f@oasis.local.home>
In-Reply-To: <20210324202613.7cad6f4f@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Wed, 24 Mar 2021 20:26:13 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Thu, 25 Mar 2021 08:47:41 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > > I think the REGS and REGS_PARTIAL cases can also be affected by function
> > > graph tracing.  So should they use the generic unwind_recover_ret_addr()
> > > instead of unwind_recover_kretprobe()?  
> > 
> > Yes, but I'm not sure this parameter can be applied.
> > For example, it passed "state->sp - sizeof(unsigned long)" as where the
> > return address stored address. Is that same on ftrace graph too?
> 
> Stack traces on the return side of function graph tracer has never
> worked. It's on my todo list, because that's one of the requirements to
> get right if we every manage to combine kretprobe and function graph
> tracers together.

OK, then at this point let's just fix the kretprobe side.

Thanks,

> 
> -- Steve


-- 
Masami Hiramatsu <mhiramat@kernel.org>
