From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 18 Jun 2021 00:33:13 +0000
Subject: Re: [PATCH -tip v7 09/13] kprobes: Setup instruction pointer in __kretprobe_trampoline_handler
Message-Id: <20210618093313.de8528635c61880cccf743d7@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162209754288.436794.3904335049560916855.stgit@devnote2>
        <162209762943.436794.874947392889792501.stgit@devnote2>
        <20210617043909.fgu2lhnkxflmy5mk@treble>
        <20210617044032.txng4enhiduacvt6@treble>
        <20210617234001.54cd2ff60410ff82a39a2020@kernel.org>
        <20210618000239.f95de17418beae6d84ce783d@kernel.org>
        <CAEf4Bzbob_M0aS-GUY5XaqePZr_prxUag3RLHtp=HY8Uu__10g@mail.gmail.com>
        <20210617182159.ka227nkmhe4yu2de@treble>
        <CAEf4BzbQxxAWEvE7BfrBPCPzBjrAEVL9cg-duwbFNzEmbPPW2w@mail.gmail.com>
        <20210617192608.4nt6sdass6gw5ehl@treble>
        <CAEf4BzbGp6aGuv9CY_uAJ9JxeQy9uNDNYRCtgZSksorEcSWp6A@mail.gmail.com>
In-Reply-To: <CAEf4BzbGp6aGuv9CY_uAJ9JxeQy9uNDNYRCtgZSksorEcSWp6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrii Nakryiko <andrii.nakryiko@gmail.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, open list <linux-kernel@vger.kernel.org>, bpf <bpf@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Kernel Team <kernel-team@fb.com>, Yonghong Song <yhs@fb.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Thu, 17 Jun 2021 12:46:19 -0700
Andrii Nakryiko <andrii.nakryiko@gmail.com> wrote:

> On Thu, Jun 17, 2021 at 12:26 PM Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> >
> > On Thu, Jun 17, 2021 at 11:31:03AM -0700, Andrii Nakryiko wrote:
> > > On Thu, Jun 17, 2021 at 11:22 AM Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> > > >
> > > > On Thu, Jun 17, 2021 at 10:45:41AM -0700, Andrii Nakryiko wrote:
> > > > > > > > > I know I suggested this patch, but I believe it would only be useful in
> > > > > > > > > combination with the use of UNWIND_HINT_REGS in SAVE_REGS_STRING.  But I
> > > > > > > > > think that would be tricky to pull off correctly.  Instead, we have
> > > > > > > > > UNWIND_HINT_FUNC, which is working fine.
> > > > > > > > >
> > > > > > > > > So I'd suggest dropping this patch, as the unwinder isn't actually
> > > > > > > > > reading regs->ip after all.
> > > > > > > >
> > > > > > > > ... and I guess this means patches 6-8 are no longer necessary.
> > > > > > >
> > > > > > > OK, I also confirmed that dropping those patche does not make any change
> > > > > > > on the stacktrace.
> > > > > > > Let me update the series without those.
> > > > > >
> > > > > > Oops, Andrii, can you also test the kernel without this patch?
> > > > > > (you don't need to drop patch 6-8)
> > > > >
> > > > > Hi Masami,
> > > > >
> > > > > Dropping this patch and leaving all the other in place breaks stack
> > > > > traces from kretprobes for BPF. I double checked with and without this
> > > > > patch. Without this patch we are back to having broken stack traces. I
> > > > > see either
> > > > >
> > > > >   kretprobe_trampoline+0x0
> > > > >
> > > > > or
> > > > >
> > > > >   ftrace_trampoline+0xc8
> > > > >   kretprobe_trampoline+0x0
> >
> > Do the stack traces end there?  Or do they continue normally after that?
> 
> That's the entire stack trace.

So, there are 2 cases of the stacktrace from inside the kretprobe handler.

1) Call stack_trace_save() in the handler. This will unwind stack from the
  handler's context. This is the case of the ftrace dynamic events.

2) Call stack_trace_save_regs(regs) in the handler with the pt_regs passed
  by the kretprobe. This is the case of ebpf.

For the case 1, these patches can be dropped because ORC can unwind the
stack with UNWIND_HINT_FUNC. For the case 2, regs->ip must be set to the
correct (return) address so that ORC can find the correct entry from that
ip.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
