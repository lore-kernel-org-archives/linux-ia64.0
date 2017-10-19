From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Thu, 19 Oct 2017 06:44:25 +0000
Subject: Re: [PATCHv3 5/7] parisc64: Add .opd based function descriptor dereference
Message-Id: <20171019064425.GC449@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-6-sergey.senozhatsky@gmail.com>
 <20171004104016.GG20084@pathway.suse.cz>
In-Reply-To: <20171004104016.GG20084@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On (10/04/17 12:40), Petr Mladek wrote:
> > +unsigned long dereference_module_function_descriptor(struct module *mod,
> > +						     unsigned long addr)
> > +{
> > +	unsigned long start_opd = (Elf64_Addr)mod->core_layout.base +
> > +				   mod->arch.fdesc_offset;
> > +	unsigned long end_opd = start_opd +
> > +				mod->arch.fdesc_count * sizeof(Elf64_Fdesc);
> 
> I know that this is used in rather slow paths. But it still might
> make sense to have these section borders pre-computed and
> stored in struct mod_arch_specific. I mean to do similar
> thing that we do on powerpc.
> 
> Well, we could do this in a followup patch if parisc people
> wanted it.
> 
> 
> > +	if (addr < start_opd || addr >= end_opd)
> > +		return addr;
> > +
> > +	return dereference_function_descriptor(addr);
> > +}
> > +#endif
> 
> Otherwise the patch looks fine to me.
> 
> Reviewed-by: Petr Mladek <pmladek@suse.com>

let's do it later, if need be.

	-ss
