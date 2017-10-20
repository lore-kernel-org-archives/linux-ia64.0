From: Petr Mladek <pmladek@suse.com>
Date: Fri, 20 Oct 2017 13:08:48 +0000
Subject: Re: [PATCHv3 6/7] symbol lookup: use new kernel and module dereference functions
Message-Id: <20171020130848.GC22070@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-7-sergey.senozhatsky@gmail.com>
 <20171004115306.GH20084@pathway.suse.cz>
 <20171019064235.GB449@jagdpanzerIV>
In-Reply-To: <20171019064235.GB449@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Thu 2017-10-19 15:42:35, Sergey Senozhatsky wrote:
> Sorry for the delay and thanks for taking a look.
> 
> I'll try to re-spin the patch set by the end of this week/early next
> week.
> 
> 
> On (10/04/17 13:53), Petr Mladek wrote:
> [..]
> > Note that kallsyms_lookup() and module_address_lookup() is used
> > in many other situations.
> 
> we dereference only things that can be dereferenced.
> so calling it on already dereferenced address, or address
> that does need to be dereferenced is OK.

My concern is that it changes the behavior. It will suddenly return
another information for addresses that were not dereference before.

> [..]
> > > diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
> > > index 127e7cfafa55..e2fc09ea9509 100644
> > > --- a/kernel/kallsyms.c
> > > +++ b/kernel/kallsyms.c
> > > @@ -322,6 +322,7 @@ const char *kallsyms_lookup(unsigned long addr,
> > >  	if (is_ksym_addr(addr)) {
> > 
> > is_ksym_addr() ignores the special .opd elf sections if
> > CONFIG_KALLSYMS_ALL is disabled. We should dereference before
> > this call.
> 
> I'll move it.
> 
> > >  		unsigned long pos;
> > >  
> > > +		addr = dereference_kernel_function_descriptor(addr);
> > >  		pos = get_symbol_pos(addr, symbolsize, offset);
> > 
> > I still wonder if doing the dereference in the widely used kallsyms
> > might cause any regression.
> 
> more testing wouldn't hurt, yes.
> 
> > Also get_symbol_pos() is called in several other helpers
> > but the dereference is done only here. It would be
> > confusing if for example kallsyms_lookup_size_offset()
> > and kallsyms_lookup() give different result.
> 
> hm, so there is no change in this regard, right? there was no
> deference before, there is no dereference now. what am I missing?

But there was no dereference in kallsyms_lookup() before
and there is dereference now.

I mean that both kallsyms_lookup_size_offset() and kallsyms_lookup()
always returned the same @symbolsize and @offset before this patch.
But they might give different results now because kallsyms_lookup()
might be newly working with dereferenced value.

It is non-consistent, unexpected behavior and might cause problems.

> I'm touching the pf/pF part in this patch set. if there are cases
> of missing dereferences anywhere else then we need to address it
> in a separate patch set, I think.

You are changing the behavior of kallsyms_lookup() and introduce
a possible inconsistency in this patchset.

It might be innocent if kallsyms are used only to display
debug messages. But there are even functional dependencies,
for example kallsyms_lookup() is called in ftrace_match_record().

> > I would feel much more comfortable if we keep the derefenrece
> > only in vsprintf.
> 
> at a price of extra module lookup, because we need `struct module *'
> for module address dereference.

It would be more code but it should not be slower. The module lookup
is just hidden in the kallsyms call now.

Another solution would be to add another helper function into kallsyms
that does the dereference and keep the current one as is.

I think that the dereference might make sense even in the kallsyms
code. But we need to make sure that it is safe and consistent.
This complicates review of this patchset.

Best Regards,
Petr
