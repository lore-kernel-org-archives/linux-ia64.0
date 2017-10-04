From: Petr Mladek <pmladek@suse.com>
Date: Wed, 04 Oct 2017 09:00:43 +0000
Subject: Re: [PATCHv3 2/7] sections: split dereference_function_descriptor()
Message-Id: <20171004090043.GD20084@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-3-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-3-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sat 2017-09-30 11:53:14, Sergey Senozhatsky wrote:
> There are two format specifiers to print out a pointer in symbolic
> format: '%pS/%ps' and '%pF/%pf'. On most architectures, the two
> mean exactly the same thing, but some architectures (ia64, ppc64,
> parisc64) use an indirect pointer for C function pointers, where
> the function pointer points to a function descriptor (which in
> turn contains the actual pointer to the code). The '%pF/%pf, when
> used appropriately, automatically does the appropriate function
> descriptor dereference on such architectures.
> 
> The "when used appropriately" part is tricky. Basically this is
> a subtle ABI detail, specific to some platforms, that made it to
> the API level and people can be unaware of it and miss the whole
> "we need to dereference the function" business out. [1] proves
> that point (note that it fixes only '%pF' and '%pS', there might
> be '%pf' and '%ps' cases as well).
> 
> It appears that we can handle everything within the affected
> arches and make '%pS/%ps' smart enough to retire '%pF/%pf'.
> Function descriptors live in .opd elf section and all affected
> arches (ia64, ppc64, parisc64) handle it properly for kernel
> and modules. So we, technically, can decide if the dereference
> is needed by simply looking at the pointer: if it belongs to
> .opd section then we need to dereference it.

Great catch. I really like this approach!

> diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
> index e5da44eddd2f..387f22c41e0d 100644
> --- a/include/asm-generic/sections.h
> +++ b/include/asm-generic/sections.h
> @@ -29,6 +29,7 @@
>   *	__ctors_start, __ctors_end
>   *	__irqentry_text_start, __irqentry_text_end
>   *	__softirqentry_text_start, __softirqentry_text_end
> + *	__start_opd, __end_opd
>   */
>  extern char _text[], _stext[], _etext[];
>  extern char _data[], _sdata[], _edata[];
> @@ -47,12 +48,15 @@ extern char __softirqentry_text_start[], __softirqentry_text_end[];
>  /* Start and end of .ctors section - used for constructor calls. */
>  extern char __ctors_start[], __ctors_end[];
>  
> +/* Start and end of .opd section - used for function descriptors. */
> +extern char __start_opd[], __end_opd[];
> +
>  extern __visible const void __nosave_begin, __nosave_end;
>  
> -/* function descriptor handling (if any).  Override
> - * in asm/sections.h */
> +/* Function descriptor handling (if any).  Override in asm/sections.h */
>  #ifndef dereference_function_descriptor
>  #define dereference_function_descriptor(p) (p)
> +#define dereference_kernel_function_descriptor(p) (p)
>  #endif
>  
>  /* random extra sections (if any).  Override
> diff --git a/include/linux/moduleloader.h b/include/linux/moduleloader.h
> index 4d0cb9bba93e..172904e9cded 100644
> --- a/include/linux/moduleloader.h
> +++ b/include/linux/moduleloader.h
> @@ -85,6 +85,10 @@ void module_arch_cleanup(struct module *mod);
>  /* Any cleanup before freeing mod->module_init */
>  void module_arch_freeing_init(struct module *mod);
>  
> +/* Dereference module function descriptor */
> +unsigned long dereference_module_function_descriptor(struct module *mod,
> +						     unsigned long addr);
> +

The function is used when the module is already loaded. IMHO,
include/linux/module.h would be a better place.

One advantage would be that we could use the same trick
as in include/asm-generic/sections.h. I mean:

#define dereference_module_function_descriptor(mod, addr) (addr)

and redefine it in the three affected
arch/<arch>/include/asm/module.h headers. Then it might be completely
optimized out on all architectures.

Anyway, we need to get ack from Jessica for this change.

Best Regards,
Petr
