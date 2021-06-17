From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 17 Jun 2021 14:40:01 +0000
Subject: Re: [PATCH -tip v7 09/13] kprobes: Setup instruction pointer in __kretprobe_trampoline_handler
Message-Id: <20210617234001.54cd2ff60410ff82a39a2020@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162209754288.436794.3904335049560916855.stgit@devnote2>
        <162209762943.436794.874947392889792501.stgit@devnote2>
        <20210617043909.fgu2lhnkxflmy5mk@treble>
        <20210617044032.txng4enhiduacvt6@treble>
In-Reply-To: <20210617044032.txng4enhiduacvt6@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Wed, 16 Jun 2021 23:40:32 -0500
Josh Poimboeuf <jpoimboe@redhat.com> wrote:

> On Wed, Jun 16, 2021 at 11:39:11PM -0500, Josh Poimboeuf wrote:
> > On Thu, May 27, 2021 at 03:40:29PM +0900, Masami Hiramatsu wrote:
> > > To simplify the stacktrace with pt_regs from kretprobe handler,
> > > set the correct return address to the instruction pointer in
> > > the pt_regs before calling kretprobe handlers.
> > > 
> > > Suggested-by: Josh Poimboeuf <jpoimboe@redhat.com>
> > > Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> > > Tested-by: Andrii Nakryik <andrii@kernel.org>
> > > ---
> > >  Changes in v3:
> > >   - Cast the correct_ret_addr to unsigned long.
> > > ---
> > >  kernel/kprobes.c |    3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/kernel/kprobes.c b/kernel/kprobes.c
> > > index 54e5b89aad67..1598aca375c9 100644
> > > --- a/kernel/kprobes.c
> > > +++ b/kernel/kprobes.c
> > > @@ -1914,6 +1914,9 @@ unsigned long __kretprobe_trampoline_handler(struct pt_regs *regs,
> > >  		BUG_ON(1);
> > >  	}
> > >  
> > > +	/* Set the instruction pointer to the correct address */
> > > +	instruction_pointer_set(regs, (unsigned long)correct_ret_addr);
> > > +
> > >  	/* Run them. */
> > >  	first = current->kretprobe_instances.first;
> > >  	while (first) {
> > > 
> > 
> > Hi Masami,
> > 
> > I know I suggested this patch, but I believe it would only be useful in
> > combination with the use of UNWIND_HINT_REGS in SAVE_REGS_STRING.  But I
> > think that would be tricky to pull off correctly.  Instead, we have
> > UNWIND_HINT_FUNC, which is working fine.
> > 
> > So I'd suggest dropping this patch, as the unwinder isn't actually
> > reading regs->ip after all.
> 
> ... and I guess this means patches 6-8 are no longer necessary.

OK, I also confirmed that dropping those patche does not make any change
on the stacktrace. 
Let me update the series without those. 

Thank you,

> 
> -- 
> Josh
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
