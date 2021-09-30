From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 30 Sep 2021 23:54:29 +0000
Subject: Re: [PATCH -tip v11 00/27] kprobes: Fix stacktrace with kretprobes on x86
Message-Id: <20211001085429.eb031708a65f2f738479e93f@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
        <20210929112408.35b0ffe06b372533455d890d@kernel.org>
        <CAADnVQ+0v601toAz7wWPy2gxNtiJNZy6UpLmw_Dg+0G8ByJS6A@mail.gmail.com>
        <874ka17t8s.ffs@tglx>
In-Reply-To: <874ka17t8s.ffs@tglx>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, bpf <bpf@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, Kernel Team <kernel-team@fb.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

On Thu, 30 Sep 2021 21:34:11 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Thu, Sep 30 2021 at 11:17, Alexei Starovoitov wrote:
> 
> > On Tue, Sep 28, 2021 at 7:24 PM Masami Hiramatsu <mhiramat@kernel.org> wrote:
> >>
> >> Hi Ingo,
> >>
> >> Can you merge this series to -tip tree since if I understand correctly,
> >> all kprobes patches still should be merged via -tip tree.
> >> If you don't think so anymore, I would like to handle the kprobe related
> >> patches on my tree. Since many kprobes fixes/cleanups have not been
> >> merged these months, it seems unhealthy now.
> >>
> >> Thank you,
> >
> > Linus,
> >
> > please suggest how to move these patches forward.
> > We've been waiting for this fix for months now.
> 
> Sorry, I've not paying attention to those as they are usually handled by
> Ingo who seems to be lost in space.
> 
> Masami, feel free to merge them over your tree. If not, let me know and
> I'll pick them up tomorrow morning.

Thank you Thomas for your proposal. As I send in the other mail,
if Steve can pick this as a part of tracing, I think that will be
better.

Thanks again,

> 
> Thanks,
> 
>         tglx


-- 
Masami Hiramatsu <mhiramat@kernel.org>
