From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Wed, 06 Dec 2017 10:46:56 +0000
Subject: Re: [PATCHv4 5/6] symbol lookup: introduce dereference_symbol_descriptor()
Message-Id: <20171206104656.GC462@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
 <20171109234830.5067-6-sergey.senozhatsky@gmail.com>
 <20171206043649.GB15885@jagdpanzerIV>
 <20171206103241.t2jbljml7it7wsnz@pathway.suse.cz>
In-Reply-To: <20171206103241.t2jbljml7it7wsnz@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-parisc@vger.kernel.org, Helge Deller <deller@gmx.de>, Jessica Yu <jeyu@kernel.org>, James Bottomley <jejb@parisc-linux.org>, Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On (12/06/17 11:32), Petr Mladek wrote:
[..]
> > diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
> > index aa0a776c817a..02745028e909 100644
> > --- a/Documentation/printk-formats.txt
> > +++ b/Documentation/printk-formats.txt
> > @@ -61,41 +61,31 @@ Symbols/Function Pointers
> >  
> >  ::
> >  
> > -	%pF	versatile_init+0x0/0x110
> > -	%pf	versatile_init
> > -	%pS	versatile_init+0x0/0x110
> > -	%pSR	versatile_init+0x9/0x110
> > +	%pS     versatile_init+0x0/0x110
> > +	%ps     versatile_init
> > +	%pF     versatile_init+0x0/0x110
> > +	%pf     versatile_init
> > +	%pSR    versatile_init+0x9/0x110
> >  		(with __builtin_extract_return_addr() translation)
> > -	%ps	versatile_init
> > -	%pB	prev_fn_of_versatile_init+0x88/0x88
> > +	%pB     prev_fn_of_versatile_init+0x88/0x88
> 
> I was curious why so many lines were changed here. You converted
> the 2nd tab to spaces. I put back the tab. The result is:

ew... how did that happen. thanks for fixing up.

> > +static inline void *dereference_symbol_descriptor(void *ptr)
> > +{
> > +#ifdef HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR
> > +	struct module *mod;
> > +
> > +	ptr = dereference_kernel_function_descriptor(ptr);
> > +	if (is_ksym_addr((unsigned long)ptr))
> > +		return ptr;
> > +
> > +	preempt_disable();
> > +	mod = __module_address((unsigned long)ptr);
> > +	preempt_enable();
> > +
> > +	if (mod)
> > +		ptr = dereference_module_function_descriptor(mod, ptr);
> > +#endif
> > +	return ptr;
> > +}
> 
> It is a bit too long for an inline function but I did not find a
> better solution. It should always be defined and all suitable
> .c files are compiled only under certain configuration. Well,
> it is a nop on most architectures.

or we can move dereference_symbol_descriptor() to vsprintf.c,
since all the functions it depends on are now available either
as exported symbols or via kallsyms header file. not that it
annoys me, so we can keep it as it is.

	-ss
