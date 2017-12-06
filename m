From: Petr Mladek <pmladek@suse.com>
Date: Wed, 06 Dec 2017 10:32:41 +0000
Subject: Re: [PATCHv4 5/6] symbol lookup: introduce dereference_symbol_descriptor()
Message-Id: <20171206103241.t2jbljml7it7wsnz@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
 <20171109234830.5067-6-sergey.senozhatsky@gmail.com>
 <20171206043649.GB15885@jagdpanzerIV>
In-Reply-To: <20171206043649.GB15885@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Wed 2017-12-06 13:36:49, Sergey Senozhatsky wrote:
> Hello,
> 
> 	so we got a number of build-error reports [somehow I
> thought 0day has compile tested the patches already; well, I
> was wrong] basically on congifs that have no KALLSYMS.
> 
> 
> Petr, can we replace 0006 with the following patch?

Done. See comments below.

> From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Subject: [PATCH] symbol lookup: introduce dereference_symbol_descriptor()
> 
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

The new patch only shuffled the code to fix a compilation problem
with CONFIG_CALLSYMS undefined. It did not change the functionality.
Therefore I put back:

Tested-by: Tony Luck <tony.luck@intel.com> #ia64
Tested-by: Santosh Sivaraj <santosh@fossix.org> #powerpc
Tested-by: Helge Deller <deller@gmx.de> #parisc64

> ---
>  Documentation/printk-formats.txt | 42 ++++++++++++-------------------
>  include/linux/kallsyms.h         | 53 ++++++++++++++++++++++++++++++++++++++++
>  kernel/kallsyms.c                | 33 -------------------------
>  lib/vsprintf.c                   |  5 ++--
>  4 files changed, 71 insertions(+), 62 deletions(-)
> 
> diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
> index aa0a776c817a..02745028e909 100644
> --- a/Documentation/printk-formats.txt
> +++ b/Documentation/printk-formats.txt
> @@ -61,41 +61,31 @@ Symbols/Function Pointers
>  
>  ::
>  
> -	%pF	versatile_init+0x0/0x110
> -	%pf	versatile_init
> -	%pS	versatile_init+0x0/0x110
> -	%pSR	versatile_init+0x9/0x110
> +	%pS     versatile_init+0x0/0x110
> +	%ps     versatile_init
> +	%pF     versatile_init+0x0/0x110
> +	%pf     versatile_init
> +	%pSR    versatile_init+0x9/0x110
>  		(with __builtin_extract_return_addr() translation)
> -	%ps	versatile_init
> -	%pB	prev_fn_of_versatile_init+0x88/0x88
> +	%pB     prev_fn_of_versatile_init+0x88/0x88

I was curious why so many lines were changed here. You converted
the 2nd tab to spaces. I put back the tab. The result is:

--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -50,42 +50,31 @@ Symbols/Function Pointers
 
 ::
 
+	%pS	versatile_init+0x0/0x110
+	%ps	versatile_init
 	%pF	versatile_init+0x0/0x110
 	%pf	versatile_init
-	%pS	versatile_init+0x0/0x110
 	%pSR	versatile_init+0x9/0x110
 		(with __builtin_extract_return_addr() translation)
-	%ps	versatile_init
 	%pB	prev_fn_of_versatile_init+0x88/0x88
 
https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/commit/?h=for-4.16-deprecate-printk-pf&idx675fe41d57c2bf9cb671f0a85b369a5a156f0a

>  
> diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
> index bd118a6c60cb..1bcfe221e62c 100644
> --- a/include/linux/kallsyms.h
> +++ b/include/linux/kallsyms.h
> +static inline void *dereference_symbol_descriptor(void *ptr)
> +{
> +#ifdef HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR
> +	struct module *mod;
> +
> +	ptr = dereference_kernel_function_descriptor(ptr);
> +	if (is_ksym_addr((unsigned long)ptr))
> +		return ptr;
> +
> +	preempt_disable();
> +	mod = __module_address((unsigned long)ptr);
> +	preempt_enable();
> +
> +	if (mod)
> +		ptr = dereference_module_function_descriptor(mod, ptr);
> +#endif
> +	return ptr;
> +}

It is a bit too long for an inline function but I did not find a
better solution. It should always be defined and all suitable
.c files are compiled only under certain configuration. Well,
it is a nop on most architectures.

Best Regards,
Petr
