From: Petr Mladek <pmladek@suse.com>
Date: Wed, 04 Oct 2017 08:24:14 +0000
Subject: Re: [PATCHv3 1/7] switch dereference_function_descriptor() to `unsigned long'
Message-Id: <20171004082414.GC20084@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-2-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-2-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sat 2017-09-30 11:53:13, Sergey Senozhatsky wrote:
> Convert dereference_function_descriptor() to accept and return
> `unsigned long'. There will be two new ARCH function for kernel
> and module function pointer dereference, which will work with
> `unsigned long', so the patch unifies interfaces.
> 
> Besides, dereference_function_descriptor() mostly work with
> `unsigned long':
> 
> Convert dereference_function_descriptor() users tree-wide.

I am not sure if this is a real win. If I count correctly,
the net result is 6 additional casts in this patch. Many
casts are still needed also in the other patches.


> diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
> index 2ab2003698ef..de6bfa1ef8fb 100644
> --- a/arch/ia64/include/asm/sections.h
> +++ b/arch/ia64/include/asm/sections.h
> @@ -27,13 +27,13 @@ extern char __start_unwind[], __end_unwind[];
>  extern char __start_ivt_text[], __end_ivt_text[];
>  
>  #undef dereference_function_descriptor
> -static inline void *dereference_function_descriptor(void *ptr)
> +static inline unsigned long dereference_function_descriptor(unsigned long ptr)

I would also expect that a function called "dereference*" would work with
a pointer. The parameter is called ptr but it is unsigned long.

>  {
> -	struct fdesc *desc = ptr;
> +	struct fdesc *desc = (struct fdesc *)ptr;
>  	void *p;
>  
>  	if (!probe_kernel_address(&desc->ip, p))
> -		ptr = p;
> +		ptr = (unsigned long)p;
>  	return ptr;
>  }
>  
> diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
> index 1ca9a2b4239f..06e1b79e2946 100644
> --- a/arch/parisc/mm/init.c
> +++ b/arch/parisc/mm/init.c
> @@ -389,10 +389,10 @@ static void __init setup_bootmem(void)
>  static int __init parisc_text_address(unsigned long vaddr)
>  {
>  	static unsigned long head_ptr __initdata;
> +	unsigned long addr = (unsigned long)&parisc_kernel_start;
>  
>  	if (!head_ptr)
> -		head_ptr = PAGE_MASK & (unsigned long)
> -			dereference_function_descriptor(&parisc_kernel_start);
> +		head_ptr = PAGE_MASK & dereference_function_descriptor(addr);

IMHO, this is harder to read than the original. You need to
search the definition of "addr" and check its manipulation
to understand the meaning.

>  
>  	return core_kernel_text(vaddr) || vaddr = head_ptr;
>  }


To make it clear. All these comments are not a big deal and I do
not want to invalidate all the acked-by and tested-by just because
of them.

But please, consider removing this change if we need to do
another iteration of this patchset. IMHO, there is no real win
and it would just pollute the git history.

Best Regards,
Petr
