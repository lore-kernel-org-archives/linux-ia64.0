From: Petr Mladek <pmladek@suse.com>
Date: Wed, 04 Oct 2017 10:40:16 +0000
Subject: Re: [PATCHv3 5/7] parisc64: Add .opd based function descriptor dereference
Message-Id: <20171004104016.GG20084@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-6-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-6-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sat 2017-09-30 11:53:17, Sergey Senozhatsky wrote:
> We are moving towards separate kernel and module function descriptor
> dereference callbacks. This patch enables it for parisc64.
> 
> For pointers that belong to the kernel
> -  Added __start_opd and __end_opd pointers, to track the kernel
>    .opd section address range;
> 
> -  Added dereference_kernel_function_descriptor(). Now we
>    will dereference only function pointers that are within
>    [__start_opd, __end_opd];
> 
> For pointers that belong to a module
> -  Added dereference_module_function_descriptor() to handle module
>    function descriptor dereference. Now we will dereference only
>    pointers that are within [module->opd.start, module->opd.end].

> diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
> index f1a76935a314..28f89b3dcc11 100644
> --- a/arch/parisc/kernel/module.c
> +++ b/arch/parisc/kernel/module.c
> @@ -954,3 +955,19 @@ void module_arch_cleanup(struct module *mod)
>  {
>  	deregister_unwind_table(mod);
>  }
> +
> +#ifdef CONFIG_64BIT
> +unsigned long dereference_module_function_descriptor(struct module *mod,
> +						     unsigned long addr)
> +{
> +	unsigned long start_opd = (Elf64_Addr)mod->core_layout.base +
> +				   mod->arch.fdesc_offset;
> +	unsigned long end_opd = start_opd +
> +				mod->arch.fdesc_count * sizeof(Elf64_Fdesc);

I know that this is used in rather slow paths. But it still might
make sense to have these section borders pre-computed and
stored in struct mod_arch_specific. I mean to do similar
thing that we do on powerpc.

Well, we could do this in a followup patch if parisc people
wanted it.


> +	if (addr < start_opd || addr >= end_opd)
> +		return addr;
> +
> +	return dereference_function_descriptor(addr);
> +}
> +#endif

Otherwise the patch looks fine to me.

Reviewed-by: Petr Mladek <pmladek@suse.com>

Best Regards,
Petr
