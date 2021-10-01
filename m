From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 01 Oct 2021 00:35:47 +0000
Subject: Re: [PATCH -tip v11 00/27] kprobes: Fix stacktrace with kretprobes on x86
Message-Id: <20211001093547.f08d8b2477783d36c310b77a@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
        <20210929112408.35b0ffe06b372533455d890d@kernel.org>
        <CAADnVQ+0v601toAz7wWPy2gxNtiJNZy6UpLmw_Dg+0G8ByJS6A@mail.gmail.com>
        <874ka17t8s.ffs@tglx>
        <20210930172206.1a34279b@oasis.local.home>
        <87wnmx64mn.ffs@tglx>
        <20211001082733.236bee605f506b2b62c055ef@kernel.org>
        <20210930193708.3b2caf23@oasis.local.home>
In-Reply-To: <20210930193708.3b2caf23@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, bpf <bpf@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, Kernel Team <kernel-team@fb.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

On Thu, 30 Sep 2021 19:37:08 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Fri, 1 Oct 2021 08:27:33 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > Let me explain how the patches are usually merged.
> > 
> > - kernel/kprobes.c related patches go through the tip tree.
> > - kernel/trace/* patches go through the tracing tree.
> 
> And arch/*/kprobe* usually goes through tip as well.
> 
> > 
> > So traditionally(?) I think this series go through the tip tree,
> > but since the biggest user of kprobes is tracing and the kprobes fix
> > now involves tree-wide fixes as you can see in this series, I think
> > it is a good timing to move kprobes to tracing tree.
> 
> I'll pick it up and take the burden off of Thomas.

Thank you very much!

> 
> Just to confirm, this is for the next merge window, right?

Yes, please push it to the next merge window.

Thanks,

> 
> -- Steve


-- 
Masami Hiramatsu <mhiramat@kernel.org>
