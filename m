From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 04 Jul 2008 20:36:21 +0000
Subject: Re: the printk problem
Message-Id: <20080704203620.GK14894@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, Peter Anvin <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, parisc-linux@parisc-linux.org

On Fri, Jul 04, 2008 at 01:02:05PM -0700, Linus Torvalds wrote:
> On Fri, 4 Jul 2008, Linus Torvalds wrote:
> > 
> > so I think we could easily just say that we extend %p in various ways:
> > 
> >  - %pS - print pointer as a symbol
> > 
> > and leave tons of room for future extensions for different kinds of 
> > pointers. 
> 
> So here's a totally untested example patch of this, which could probably 
> easily be extended to to other things.
> 
> I actually made it '%pF' and '%pS' for a Function descriptor pointer and 
> normal Symbolic pointer respectively, because of the stupid things ia64 
> and PPC64 do with the pointer indirection through function descriptors. 

It's also true for parisc, fwiw.  Added a cc to them.

> That function descriptor indirection is totally untested, and I did it 
> with a
> 
> 	pagefault_disable();
> 	__get_user(..)
> 	pagefault_enable();
> 
> thing because I thought it would be nice if printk() was always safe, and 
> passing bogus function pointers to '%pF' should try to work, but quite 
> frankly, I didn't even check that that part compiles, much less works.
> 
> ia64/ppc lists cc'd, just in case somebody wants to test this.
> 
> NOTE! There are no current actual users of this, but the _idea_ is that we 
> should be able to just do
> 
> 	printk("%pF\n", desc->handle_irq);
> 
> instead of using
> 
> 	print_symbol("%s\n", (unsigned long)desc->handle_irq);
> 
> The latter is from kernel/irq/internals.h, and actually looks incorrect - 
> shouldn't it use print_fn_descriptor_symbol(), since it's a C level 
> function pointer? We should use "print_symbol()" for return pointers we 
> find on the stack and data pointers, but not for stuff that actually has a 
> C type that is a function pointer?
> 
> Somebody who cares about the insane function descriptors should take a 
> deeper look.
> 
> NOTE AGAIN! UNTESTED! I could easily have screwed up printk() _entirely_, 
> since I had to factor out the string handling into a function of its own.
> 
> 		Linus
> ---
>  lib/vsprintf.c |  102 ++++++++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 74 insertions(+), 28 deletions(-)
> 
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 6021757..148b656 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -22,6 +22,7 @@
>  #include <linux/string.h>
>  #include <linux/ctype.h>
>  #include <linux/kernel.h>
> +#include <linux/kallsyms.h>
>  
>  #include <asm/page.h>		/* for PAGE_SIZE */
>  #include <asm/div64.h>
> @@ -482,6 +483,72 @@ static char *number(char *buf, char *end, unsigned long long num, int base, int
>  	return buf;
>  }
>  
> +static char *string(char *buf, char *end, char *s, int field_width, int precision, int flags)
> +{
> +	int len, i;
> +
> +	if ((unsigned long)s < PAGE_SIZE)
> +		s = "<NULL>";
> +
> +	len = strnlen(s, precision);
> +
> +	if (!(flags & LEFT)) {
> +		while (len < field_width--) {
> +			if (buf < end)
> +				*buf = ' ';
> +			++buf;
> +		}
> +	}
> +	for (i = 0; i < len; ++i) {
> +		if (buf < end)
> +			*buf = *s;
> +		++buf; ++s;
> +	}
> +	while (len < field_width--) {
> +		if (buf < end)
> +			*buf = ' ';
> +		++buf;
> +	}
> +	return buf;
> +}
> +
> +/*
> + * Show a '%p' thing.  A kernel extension is that the '%p' is followed
> + * by an extra set of alphanumeric characters that are extended format
> + * specifiers.  Right now we just handle 'F' (for symbolic Function
> + * pointers) and 'S' (for Symbolic data pointers), but this can easily
> + * be extended in the future (network address types etc).
> + *
> + * The difference between 'S' and 'F' is that on ia64 and ppc64 function
> + * pointers are really function descriptors, which contain a pointer the
> + * real address. 
> + */
> +static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int base, int size, int precision, int type)
> +{
> +	char sym[KSYM_SYMBOL_LEN];
> +	switch (*fmt) {
> +	case 'F':	/* Function pointer */
> +#if defined(CONFIG_IA64) || defined(CONFIG_PPC64)
> +		{ void *p;
> +		pagefault_disable();
> +		if (!__get_user((void **)ptr, &p))
> +			ptr = p;
> +		pagefault_enable();
> +		}
> +#endif
> +	/* Fallthrough */
> +	case 'S':	/* Other pointer */
> +#if CONFIG_KALLSYMS
> +		sprint_symbol(sym, (unsigned long) ptr);
> +		return string(buf, end, sym, size, precision, type);
> +#else
> +		type |= SPECIAL;
> +		break;
> +#endif
> +	}
> +	return number(buf, end, (unsigned long long) ptr, base, size, precision, type);
> +}
> +
>  /**
>   * vsnprintf - Format a string and place it in a buffer
>   * @buf: The buffer to place the result into
> @@ -502,11 +569,9 @@ static char *number(char *buf, char *end, unsigned long long num, int base, int
>   */
>  int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
>  {
> -	int len;
>  	unsigned long long num;
> -	int i, base;
> +	int base;
>  	char *str, *end, c;
> -	const char *s;
>  
>  	int flags;		/* flags to number() */
>  
> @@ -622,29 +687,7 @@ int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
>  				continue;
>  
>  			case 's':
> -				s = va_arg(args, char *);
> -				if ((unsigned long)s < PAGE_SIZE)
> -					s = "<NULL>";
> -
> -				len = strnlen(s, precision);
> -
> -				if (!(flags & LEFT)) {
> -					while (len < field_width--) {
> -						if (str < end)
> -							*str = ' ';
> -						++str;
> -					}
> -				}
> -				for (i = 0; i < len; ++i) {
> -					if (str < end)
> -						*str = *s;
> -					++str; ++s;
> -				}
> -				while (len < field_width--) {
> -					if (str < end)
> -						*str = ' ';
> -					++str;
> -				}
> +				str = string(str, end, va_arg(args, char *), field_width, precision, flags);
>  				continue;
>  
>  			case 'p':
> @@ -653,9 +696,12 @@ int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
>  					field_width = 2*sizeof(void *);
>  					flags |= ZEROPAD;
>  				}
> -				str = number(str, end,
> -						(unsigned long) va_arg(args, void *),
> +				str = pointer(fmt+1, str, end,
> +						va_arg(args, void *),
>  						16, field_width, precision, flags);
> +				/* Skip all alphanumeric pointer suffixes */
> +				while (isalnum(fmt[1]))
> +					fmt++;
>  				continue;
>  
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
