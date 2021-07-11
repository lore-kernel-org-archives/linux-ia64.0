From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sun, 11 Jul 2021 01:26:27 +0000
Subject: Re: [PATCH -tip 6/6] kprobes: Use bool type for functions which returns boolean value
Message-Id: <20210711102627.aacd375107225da46473e2ee@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162592891873.1158485.768824457210707916.stgit@devnote2>
        <162592897337.1158485.13933847832718343850.stgit@devnote2>
        <dd3ec20d371703c121a18e91908ab8faa76c852d.camel@perches.com>
In-Reply-To: <dd3ec20d371703c121a18e91908ab8faa76c852d.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Joe Perches <joe@perches.com>
Cc: X86 ML <x86@kernel.org>, Ingo Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Sat, 10 Jul 2021 09:27:22 -0700
Joe Perches <joe@perches.com> wrote:

> On Sat, 2021-07-10 at 23:56 +0900, Masami Hiramatsu wrote:
> > Use the 'bool' type instead of 'int' for the functions which
> > returns a boolean value, because this makes clear that those
> > functions don't return any error code.
> []
> > diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
> []
> > @@ -104,25 +104,25 @@ struct kprobe {
> >  #define KPROBE_FLAG_FTRACE	8 /* probe is using ftrace */
> >  
> > 
> >  /* Has this kprobe gone ? */
> > -static inline int kprobe_gone(struct kprobe *p)
> > +static inline bool kprobe_gone(struct kprobe *p)
> >  {
> >  	return p->flags & KPROBE_FLAG_GONE;
> >  }
> 
> This change would also allow the removal of the !! from:
> 
> kernel/trace/trace_kprobe.c:104:        return !!(kprobe_gone(&tk->rp.kp));

Good catch! OK, I'll update 

Thank you,

> ---
>  kernel/trace/trace_kprobe.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
> index ea6178cb5e334..c6e0345a44e94 100644
> --- a/kernel/trace/trace_kprobe.c
> +++ b/kernel/trace/trace_kprobe.c
> @@ -101,7 +101,7 @@ static nokprobe_inline unsigned long trace_kprobe_offset(struct trace_kprobe *tk
>  
>  static nokprobe_inline bool trace_kprobe_has_gone(struct trace_kprobe *tk)
>  {
> -	return !!(kprobe_gone(&tk->rp.kp));
> +	return kprobe_gone(&tk->rp.kp);
>  }
>  
>  static nokprobe_inline bool trace_kprobe_within_module(struct trace_kprobe *tk,
> 
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
