From: Petr Mladek <pmladek@suse.com>
Date: Wed, 04 Oct 2017 11:53:06 +0000
Subject: Re: [PATCHv3 6/7] symbol lookup: use new kernel and module dereference functions
Message-Id: <20171004115306.GH20084@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-7-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-7-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sat 2017-09-30 11:53:18, Sergey Senozhatsky wrote:
> Call appropriate function descriptor dereference ARCH callbacks:
> - dereference_kernel_function_descriptor() if the pointer is a
>   kernel symbol;
> 
> - dereference_module_function_descriptor() if the pointer is a
>   module symbol.
> 
> This patch also removes dereference_function_descriptor() from
> '%pF/%pf' vsprintf handler, because it has the same behavior with
> '%pS/%ps' now.

The description is pretty criptic. It should explain why
the dereference was moved from vsprintf to the symbol lookup
and if it is safe.

Note that kallsyms_lookup() and module_address_lookup() is used
in many other situations.

Also I would not be afraid to repeat description of the big picture
from the 2nd patch.

> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Tested-by: Helge Deller <deller@gmx.de> # parisc64
> Tested-by: Santosh Sivaraj <santosh@fossix.org> # powerpc64
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> # powerpc64
> Tested-by: Tony Luck <tony.luck@intel.com> # ia64
> ---
>  Documentation/printk-formats.txt | 20 ++++++++++----------
>  kernel/kallsyms.c                |  1 +
>  kernel/module.c                  |  1 +
>  lib/vsprintf.c                   |  5 +----
>  4 files changed, 13 insertions(+), 14 deletions(-)
> 
> diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
> index 361789df51ec..3adbc4fdd482 100644
> --- a/Documentation/printk-formats.txt
> +++ b/Documentation/printk-formats.txt
> @@ -50,26 +50,28 @@ Symbols/Function Pointers
>  
>  ::
>  
> +	%pS	versatile_init+0x0/0x110
> +	%ps	versatile_init
>  	%pF	versatile_init+0x0/0x110
>  	%pf	versatile_init
> -	%pS	versatile_init+0x0/0x110
>  	%pSR	versatile_init+0x9/0x110
>  		(with __builtin_extract_return_addr() translation)
> -	%ps	versatile_init
>  	%pB	prev_fn_of_versatile_init+0x88/0x88
>  
> -The ``F`` and ``f`` specifiers are for printing function pointers,
> -for example, f->func, &gettimeofday. They have the same result as
> -``S`` and ``s`` specifiers. But they do an extra conversion on
> -ia64, ppc64 and parisc64 architectures where the function pointers
> -are actually function descriptors.
> -
>  The ``S`` and ``s`` specifiers can be used for printing symbols
>  from direct addresses, for example, __builtin_return_address(0),
>  (void *)regs->ip. They result in the symbol name with (``S``) or
>  without (``s``) offsets. If KALLSYMS are disabled then the symbol
>  address is printed instead.

This paragraph makes the feeling that ``S`` is still only for direct
adresses. We should update it as well.


> +Note, that the ``F`` and ``f`` specifiers are identical to ``S`` (``s``)
> +and thus deprecated. We have ``F`` and ``f`` because on ia64, ppc64 and
> +parisc64 function pointers are indirect and, in fact, are function
> +descriptors, which require additional dereferencing before we can lookup
> +the symbol. As of now, ``S`` and ``s`` perform dereferencing on those
> +platforms (when needed), so ``F`` and ``f`` exist for compatibility
> +reasons only.
> +
>  The ``B`` specifier results in the symbol name with offsets and should be
>  used when printing stack backtraces. The specifier takes into
>  consideration the effect of compiler optimisations which may occur
> @@ -77,8 +79,6 @@ when tail-call``s are used and marked with the noreturn GCC attribute.
>  
>  Examples::
>  
> -	printk("Going to call: %pF\n", gettimeofday);
> -	printk("Going to call: %pF\n", p->func);
>  	printk("%s: called from %pS\n", __func__, (void *)_RET_IP_);
>  	printk("%s: called from %pS\n", __func__,
>  				(void *)__builtin_return_address(0));

We should either replace %pF with %pS or remove all examples.
It is strange to keep only half of them.


> diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
> index 127e7cfafa55..e2fc09ea9509 100644
> --- a/kernel/kallsyms.c
> +++ b/kernel/kallsyms.c
> @@ -322,6 +322,7 @@ const char *kallsyms_lookup(unsigned long addr,
>  	if (is_ksym_addr(addr)) {

is_ksym_addr() ignores the special .opd elf sections if
CONFIG_KALLSYMS_ALL is disabled. We should dereference before
this call.

>  		unsigned long pos;
>  
> +		addr = dereference_kernel_function_descriptor(addr);
>  		pos = get_symbol_pos(addr, symbolsize, offset);

I still wonder if doing the dereference in the widely used kallsyms
might cause any regression.

One possible problem is that this function returns "offset".
One might expect that it is offset against "addr" but
it is not if the dereference happens here.

Also get_symbol_pos() is called in several other helpers
but the dereference is done only here. It would be
confusing if for example kallsyms_lookup_size_offset()
and kallsyms_lookup() give different result.

I would feel much more comfortable if we keep the derefenrece
only in vsprintf.


In each case, we need approval from Jessica for the
change in module.c.

Best Regards,
Petr
