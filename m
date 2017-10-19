From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Thu, 19 Oct 2017 06:45:04 +0000
Subject: Re: [PATCHv3 4/7] powerpc64: Add .opd based function descriptor dereference
Message-Id: <20171019064504.GD449@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-5-sergey.senozhatsky@gmail.com>
 <20171004092108.GF20084@pathway.suse.cz>
In-Reply-To: <20171004092108.GF20084@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On (10/04/17 11:21), Petr Mladek wrote:
[..]
> > +#ifdef PPC64_ELF_ABI_v1
> > +unsigned long dereference_module_function_descriptor(struct module *mod,
> > +						     unsigned long addr)
> > +{
> > +	if (addr < mod->arch.start_opd || addr >= mod->arch.end_opd)
> > +		return addr;
> > +
> > +	return dereference_function_descriptor(addr);
> > +}
> > +#endif /* PPC64_ELF_ABI_v1 */
> 
> I would personally move this up in the source file. It is related to
> the definition of func_desc() and other functions that are
> also PPC_ELF_ABI-specific.
> 
> Otherwise, it looks good to me.
> 
> Reviewed-by: Petr Mladek <pmladek@suse.com>

OK, will move.

	-ss
