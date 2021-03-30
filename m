From: Josh Poimboeuf <jpoimboe@redhat.com>
Date: Tue, 30 Mar 2021 04:58:15 +0000
Subject: Re: [PATCH -tip v4 10/12] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210330045815.boogfo65is5yywnn@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
 <161639530062.895304.16962383429668412873.stgit@devnote2>
 <20210323223007.GG4746@worktop.programming.kicks-ass.net>
 <20210324104058.7c06aaeb0408e24db6ba46f8@kernel.org>
 <20210326030503.7fa72da34e25ad35cf5ed3de@kernel.org>
 <20210326210349.22f6d34b229dd3a139a53686@kernel.org>
 <20210326102009.265f359c@gandalf.local.home>
In-Reply-To: <20210326102009.265f359c@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Masahiro Yamada <masahiroy@kernel.org>

On Fri, Mar 26, 2021 at 10:20:09AM -0400, Steven Rostedt wrote:
> On Fri, 26 Mar 2021 21:03:49 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > I confirmed this is not related to this series, but occurs when I build kernels with different
> > configs without cleanup.
> > 
> > Once I build kernel with CONFIG_UNWIND_GUESS=y (for testing), and after that,
> > I build kernel again with CONFIG_UNWIND_ORC=y (but without make clean), this
> > happened. In this case, I guess ORC data might be corrupted?
> > When I cleanup and rebuild, the stacktrace seems correct.
> 
> Hmm, that should be fixed. Seems like we are missing a dependency somewhere.

Thomas reported something similar: for example arch/x86/kernel/head_64.o
doesn't get rebuilt when changing unwinders.

  https://lkml.kernel.org/r/87tuqublrb.fsf@nanos.tec.linutronix.de

Masahiro, any idea how we can force a full tree rebuild when changing
the unwinder?

-- 
Josh
