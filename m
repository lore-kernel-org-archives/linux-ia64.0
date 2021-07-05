From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Mon, 05 Jul 2021 10:03:28 +0000
Subject: Re: [PATCH -tip v8 03/13] kprobes: treewide: Remove trampoline_address from kretprobe_trampoline_han
Message-Id: <20210705190328.8cf3fb4397500f2dafb761f0@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
        <162399994996.506599.17672270294950096639.stgit@devnote2>
        <YOKut2jZ4f+oSKAI@gmail.com>
In-Reply-To: <YOKut2jZ4f+oSKAI@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

Hi Ingo,

On Mon, 5 Jul 2021 09:03:19 +0200
Ingo Molnar <mingo@kernel.org> wrote:

> 
> * Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > --- a/include/linux/kprobes.h
> > +++ b/include/linux/kprobes.h
> > @@ -197,15 +197,23 @@ extern void arch_prepare_kretprobe(struct kretprobe_instance *ri,
> >  				   struct pt_regs *regs);
> >  extern int arch_trampoline_kprobe(struct kprobe *p);
> >  
> > +void kretprobe_trampoline(void);
> > +/*
> > + * Since some architecture uses structured function pointer,
> > + * use dereference_function_descriptor() to get real function address.
> > + */
> > +static nokprobe_inline void *kretprobe_trampoline_addr(void)
> > +{
> > +	return dereference_kernel_function_descriptor(kretprobe_trampoline);
> > +}
> 
> Could we please also make 'kretprobe_trampoline' harder to use 
> accidentally, such by naming it appropriately?
> 
> __kretprobe_trampoline would be a good first step I guess.

Good idea! Let me update it.

Thank you,



-- 
Masami Hiramatsu <mhiramat@kernel.org>
