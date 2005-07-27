From: david mosberger <dmosberger@gmail.com>
Date: Wed, 27 Jul 2005 23:23:37 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <ed5aea4305072716233491f7f8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
	 <20050727161316.0593d762.akpm@osdl.org>
In-Reply-To: <20050727161316.0593d762.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Also, should this be called prefetch_stack() or perhaps even just
prefetch_task()?  Not every architecture defines a switch_stack
structure.

  --david

-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536

On 7/27/05, Andrew Morton <akpm@osdl.org> wrote:
> "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
> >
> > +#ifdef ARCH_HAS_PREFETCH_SWITCH_STACK
> >  +extern void prefetch_switch_stack(struct task_struct*);
> >  +#else
> >  +#define prefetch_switch_stack(task) do { } while (0)
> >  +#endif
> 
> It is better to use
> 
> static inline void prefetch_switch_stack(struct task_struct *t) { }
> 
> in the second case, rather than a macro.  It provides typechecking.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
