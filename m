From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 11 Nov 2017 04:49:32 +0000
Subject: Re: [PATCHv4 5/6] symbol lookup: introduce dereference_symbol_descriptor()
Message-Id: <20171111044932.GB596@tigerII.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
 <20171109234830.5067-6-sergey.senozhatsky@gmail.com>
 <20171110180931.xhhi35osclzceba2@agluck-desk>
In-Reply-To: <20171110180931.xhhi35osclzceba2@agluck-desk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (11/10/17 10:09), Luck, Tony wrote:
> On Fri, Nov 10, 2017 at 08:48:29AM +0900, Sergey Senozhatsky wrote:
> > -Examples::
> > -
> > -	printk("Going to call: %pF\n", gettimeofday);
> > -	printk("Going to call: %pF\n", p->func);
> > -	printk("%s: called from %pS\n", __func__, (void *)_RET_IP_);
> > -	printk("%s: called from %pS\n", __func__,
> > -				(void *)__builtin_return_address(0));
> > -	printk("Faulted at %pS\n", (void *)regs->ip);
> > -	printk(" %s%pB\n", (reliable ? "" : "? "), (void *)*stack);
> 
> Did you mean to delete the Examples completely?  Wouldn't it
> be better to just update (s/%pF/%pS/g)?

good question. yes, I think I did it deliberately :) we still
kinda have some sort of "examples", right at the beginning of
section "Symbols/Function Pointers"


>  Symbols/Function Pointers
>  ============>
>  ::
>
>         %pS     versatile_init+0x0/0x110
>          %ps     versatile_init
>          %pF     versatile_init+0x0/0x110
>          %pf     versatile_init
>          %pSR    versatile_init+0x9/0x110
>                 (with __builtin_extract_return_addr() translation)
>          %pB     prev_fn_of_versatile_init+0x88/0x88
>
>  The ``S`` and ``s`` specifiers are used for printing a pointer in symbolic
>  format. They result in the symbol name with (``S``) or without (``s``)
>  offsets. If KALLSYMS are disabled then the symbol address is printed instead.
>
>  Note, that the ``F`` and ``f`` specifiers are identical to ``S`` (``s``)
>  and thus deprecated. We have ``F`` and ``f`` because on ia64, ppc64 and
>  parisc64 function pointers are indirect and, in fact, are function
>  descriptors, which require additional dereferencing before we can lookup
>  the symbol. As of now, ``S`` and ``s`` perform dereferencing on those
>  platforms (when needed), so ``F`` and ``f`` exist for compatibility
>  reasons only.
>
>  The ``B`` specifier results in the symbol name with offsets and should be
>  used when printing stack backtraces. The specifier takes into
>  consideration the effect of compiler optimisations which may occur
>  when tail-call``s are used and marked with the noreturn GCC attribute.

I can return Examples back. don't really have a strong opinion
on this. let me know.

	-ss
