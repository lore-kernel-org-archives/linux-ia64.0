From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Thu, 30 Sep 2021 18:17:52 +0000
Subject: Re: [PATCH -tip v11 00/27] kprobes: Fix stacktrace with kretprobes on x86
Message-Id: <CAADnVQ+0v601toAz7wWPy2gxNtiJNZy6UpLmw_Dg+0G8ByJS6A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2> <20210929112408.35b0ffe06b372533455d890d@kernel.org>
In-Reply-To: <20210929112408.35b0ffe06b372533455d890d@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, bpf <bpf@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, Kernel Team <kernel-team@fb.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

On Tue, Sep 28, 2021 at 7:24 PM Masami Hiramatsu <mhiramat@kernel.org> wrote:
>
> Hi Ingo,
>
> Can you merge this series to -tip tree since if I understand correctly,
> all kprobes patches still should be merged via -tip tree.
> If you don't think so anymore, I would like to handle the kprobe related
> patches on my tree. Since many kprobes fixes/cleanups have not been
> merged these months, it seems unhealthy now.
>
> Thank you,

Linus,

please suggest how to move these patches forward.
We've been waiting for this fix for months now.

> On Tue, 14 Sep 2021 23:38:27 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
>
> > Hello,
> >
> > This is the 11th version of the series to fix the stacktrace with kretprobe on x86.
> >
> > The previous version is here;
> >
> >  https://lore.kernel.org/all/162756755600.301564.4957591913842010341.stgit@devnote2/
> >
> > This version is rebased on the latest tip/master branch and includes the kprobe cleanup
> > series[1][2]. No code change.
> >
> > [1] https://lore.kernel.org/bpf/162748615977.59465.13262421617578791515.stgit@devnote2/
> > [2] https://lore.kernel.org/linux-csky/20210727133426.2919710-1-punitagrawal@gmail.com/
> >
> >
> > With this series, unwinder can unwind stack correctly from ftrace as below;
