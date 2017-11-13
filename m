From: Santosh Sivaraj <santosh@fossix.org>
Date: Mon, 13 Nov 2017 07:23:49 +0000
Subject: Re: [PATCHv4 3/6] powerpc64: Add .opd based function descriptor dereference
Message-Id: <20171113071149.crpthceuvtxtzj2s@santosiv.in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
 <20171109234830.5067-4-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-4-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

* Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote (on 2017-11-10 08:48:27 +0900):

> We are moving towards separate kernel and module function descriptor
> dereference callbacks. This patch enables it for powerpc64.
> 
> For pointers that belong to the kernel
> -  Added __start_opd and __end_opd pointers, to track the kernel
>    .opd section address range;
> 
> -  Added dereference_kernel_function_descriptor(). Now we
>    will dereference only function pointers that are within
>    [__start_opd, __end_opd);
> 
> For pointers that belong to a module
> -  Added dereference_module_function_descriptor() to handle module
>    function descriptor dereference. Now we will dereference only
>    pointers that are within [module->opd.start, module->opd.end).
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  arch/powerpc/include/asm/module.h   |  3 +++
>  arch/powerpc/include/asm/sections.h | 12 ++++++++++++
>  arch/powerpc/kernel/module_64.c     | 14 ++++++++++++++
>  arch/powerpc/kernel/vmlinux.lds.S   |  2 ++
>  4 files changed, 31 insertions(+)
>

Looks good on powerpc. If you wish:

Tested-by: Santosh Sivaraj <santosh@fossix.org> # for powerpc

Thanks,
Santosh

> diff --git a/arch/powerpc/include/asm/module.h b/arch/powerpc/include/asm/module.h
> index 6c0132c7212f..7e28442827f1 100644
> --- a/arch/powerpc/include/asm/module.h
> +++ b/arch/powerpc/include/asm/module.h
> @@ -45,6 +45,9 @@ struct mod_arch_specific {
>  	unsigned long tramp;
>  #endif
>  
> +	/* For module function descriptor dereference */
> +	unsigned long start_opd;
> +	unsigned long end_opd;
>  #else /* powerpc64 */
>  	/* Indices of PLT sections within module. */
>  	unsigned int core_plt_section;
> diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
> index 82bec63bbd4f..e335a8f846af 100644
> --- a/arch/powerpc/include/asm/sections.h
> +++ b/arch/powerpc/include/asm/sections.h
> @@ -66,6 +66,9 @@ static inline int overlaps_kvm_tmp(unsigned long start, unsigned long end)
>  }
>  
>  #ifdef PPC64_ELF_ABI_v1
> +
> +#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
> +
>  #undef dereference_function_descriptor
>  static inline void *dereference_function_descriptor(void *ptr)
>  {
> @@ -76,6 +79,15 @@ static inline void *dereference_function_descriptor(void *ptr)
>  		ptr = p;
>  	return ptr;
>  }
> +
> +#undef dereference_kernel_function_descriptor
> +static inline void *dereference_kernel_function_descriptor(void *ptr)
> +{
> +	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
> +		return ptr;
> +
> +	return dereference_function_descriptor(ptr);
> +}
>  #endif /* PPC64_ELF_ABI_v1 */
>  
>  #endif
> diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
> index 759104b99f9f..218971ac7e04 100644
> --- a/arch/powerpc/kernel/module_64.c
> +++ b/arch/powerpc/kernel/module_64.c
> @@ -93,6 +93,15 @@ static unsigned int local_entry_offset(const Elf64_Sym *sym)
>  {
>  	return 0;
>  }
> +
> +void *dereference_module_function_descriptor(struct module *mod, void *ptr)
> +{
> +	if (ptr < (void *)mod->arch.start_opd ||
> +			ptr >= (void *)mod->arch.end_opd)
> +		return ptr;
> +
> +	return dereference_function_descriptor(ptr);
> +}
>  #endif
>  
>  #define STUB_MAGIC 0x73747562 /* stub */
> @@ -344,6 +353,11 @@ int module_frob_arch_sections(Elf64_Ehdr *hdr,
>  		else if (strcmp(secstrings+sechdrs[i].sh_name,"__versions")=0)
>  			dedotify_versions((void *)hdr + sechdrs[i].sh_offset,
>  					  sechdrs[i].sh_size);
> +		else if (!strcmp(secstrings + sechdrs[i].sh_name, ".opd")) {
> +			me->arch.start_opd = sechdrs[i].sh_addr;
> +			me->arch.end_opd = sechdrs[i].sh_addr +
> +					   sechdrs[i].sh_size;
> +		}
>  
>  		/* We don't handle .init for the moment: rename to _init */
>  		while ((p = strstr(secstrings + sechdrs[i].sh_name, ".init")))
> diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
> index 0494e1566ee2..5dac5ab22fa2 100644
> --- a/arch/powerpc/kernel/vmlinux.lds.S
> +++ b/arch/powerpc/kernel/vmlinux.lds.S
> @@ -278,7 +278,9 @@ SECTIONS
>  	}
>  
>  	.opd : AT(ADDR(.opd) - LOAD_OFFSET) {
> +		__start_opd = .;
>  		*(.opd)
> +		__end_opd = .;
>  	}
>  
>  	. = ALIGN(256);

-- 
