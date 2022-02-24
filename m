From: Stafford Horne <shorne@gmail.com>
Date: Thu, 24 Feb 2022 08:29:34 +0000
Subject: Re: [PATCH v2 13/18] uaccess: generalize access_ok()
Message-Id: <YhdB7tNDvtsYLUzr@antec>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
 <20220216131332.1489939-14-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-14-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org

On Wed, Feb 16, 2022 at 02:13:27PM +0100, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> There are many different ways that access_ok() is defined across
> architectures, but in the end, they all just compare against the
> user_addr_max() value or they accept anything.
> 
> Provide one definition that works for most architectures, checking
> against TASK_SIZE_MAX for user processes or skipping the check inside
> of uaccess_kernel() sections.
> 
> For architectures without CONFIG_SET_FS(), this should be the fastest
> check, as it comes down to a single comparison of a pointer against a
> compile-time constant, while the architecture specific versions tend to
> do something more complex for historic reasons or get something wrong.
> 
> Type checking for __user annotations is handled inconsistently across
> architectures, but this is easily simplified as well by using an inline
> function that takes a 'const void __user *' argument. A handful of
> callers need an extra __user annotation for this.
> 
> Some architectures had trick to use 33-bit or 65-bit arithmetic on the
> addresses to calculate the overflow, however this simpler version uses
> fewer registers, which means it can produce better object code in the
> end despite needing a second (statically predicted) branch.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Mark Rutland <mark.rutland@arm.com> [arm64, asm-generic]
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
...
>  arch/openrisc/include/asm/uaccess.h   | 19 +--------
...
>  include/asm-generic/access_ok.h       | 59 +++++++++++++++++++++++++++
>  include/asm-generic/uaccess.h         | 21 +---------
>  include/linux/uaccess.h               |  7 ----
>  32 files changed, 109 insertions(+), 366 deletions(-)
> 
...
> diff --git a/arch/openrisc/include/asm/uaccess.h b/arch/openrisc/include/asm/uaccess.h
> index 120f5005461b..8f049ec99b3e 100644
> --- a/arch/openrisc/include/asm/uaccess.h
> +++ b/arch/openrisc/include/asm/uaccess.h
> @@ -45,21 +45,7 @@
>  
>  #define uaccess_kernel()	(get_fs() = KERNEL_DS)
>  
> -/* Ensure that the range from addr to addr+size is all within the process'
> - * address space
> - */
> -static inline int __range_ok(unsigned long addr, unsigned long size)
> -{
> -	const mm_segment_t fs = get_fs();
> -
> -	return size <= fs && addr <= (fs - size);
> -}
> -
> -#define access_ok(addr, size)						\
> -({ 									\
> -	__chk_user_ptr(addr);						\
> -	__range_ok((unsigned long)(addr), (size));			\
> -})
> +#include <asm-generic/access_ok.h>

I was going to ask why we are missing __chk_user_ptr in the generic version.
But this is basically now a no-op so I think its OK.

>  /*
>   * These are the main single-value transfer routines.  They automatically
> @@ -268,9 +254,6 @@ clear_user(void __user *addr, unsigned long size)
>  	return size;
>  }
>  
> -#define user_addr_max() \
> -	(uaccess_kernel() ? ~0UL : TASK_SIZE)
> -
>  extern long strncpy_from_user(char *dest, const char __user *src, long count);
>  
>  extern __must_check long strnlen_user(const char __user *str, long n);

...
> diff --git a/include/asm-generic/access_ok.h b/include/asm-generic/access_ok.h
> new file mode 100644
> index 000000000000..1aad8964d2ed
> --- /dev/null
> +++ b/include/asm-generic/access_ok.h
> @@ -0,0 +1,59 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef __ASM_GENERIC_ACCESS_OK_H__
> +#define __ASM_GENERIC_ACCESS_OK_H__
> +
> +/*
> + * Checking whether a pointer is valid for user space access.
> + * These definitions work on most architectures, but overrides can
> + * be used where necessary.
> + */
> +
> +/*
> + * architectures with compat tasks have a variable TASK_SIZE and should
> + * override this to a constant.
> + */
> +#ifndef TASK_SIZE_MAX
> +#define TASK_SIZE_MAX			TASK_SIZE
> +#endif
> +
> +#ifndef uaccess_kernel
> +#ifdef CONFIG_SET_FS
> +#define uaccess_kernel()		(get_fs().seg = KERNEL_DS.seg)
> +#else
> +#define uaccess_kernel()		(0)
> +#endif
> +#endif
> +
> +#ifndef user_addr_max
> +#define user_addr_max()			(uaccess_kernel() ? ~0UL : TASK_SIZE_MAX)
> +#endif
> +
> +#ifndef __access_ok
> +/*
> + * 'size' is a compile-time constant for most callers, so optimize for
> + * this case to turn the check into a single comparison against a constant
> + * limit and catch all possible overflows.
> + * On architectures with separate user address space (m68k, s390, parisc,
> + * sparc64) or those without an MMU, this should always return true.
> + *
> + * This version was originally contributed by Jonas Bonn for the
> + * OpenRISC architecture, and was found to be the most efficient
> + * for constant 'size' and 'limit' values.
> + */
> +static inline int __access_ok(const void __user *ptr, unsigned long size)
> +{
> +	unsigned long limit = user_addr_max();
> +	unsigned long addr = (unsigned long)ptr;
> +
> +	if (IS_ENABLED(CONFIG_ALTERNATE_USER_ADDRESS_SPACE))
> +		return true;
> +
> +	return (size <= limit) && (addr <= (limit - size));
> +}
> +#endif
> +
> +#ifndef access_ok
> +#define access_ok(addr, size) likely(__access_ok(addr, size))
> +#endif
> +
> +#endif
> diff --git a/include/asm-generic/uaccess.h b/include/asm-generic/uaccess.h
> index 0870fa11a7c5..ebc685dc8d74 100644
> --- a/include/asm-generic/uaccess.h
> +++ b/include/asm-generic/uaccess.h
> @@ -114,28 +114,9 @@ static inline void set_fs(mm_segment_t fs)
>  }
>  #endif
>  
> -#ifndef uaccess_kernel
> -#define uaccess_kernel() (get_fs().seg = KERNEL_DS.seg)
> -#endif
> -
> -#ifndef user_addr_max
> -#define user_addr_max() (uaccess_kernel() ? ~0UL : TASK_SIZE)
> -#endif
> -
>  #endif /* CONFIG_SET_FS */
>  
> -#define access_ok(addr, size) __access_ok((unsigned long)(addr),(size))
> -
> -/*
> - * The architecture should really override this if possible, at least
> - * doing a check on the get_fs()
> - */
> -#ifndef __access_ok
> -static inline int __access_ok(unsigned long addr, unsigned long size)
> -{
> -	return 1;
> -}
> -#endif
> +#include <asm-generic/access_ok.h>
>  
>  /*
>   * These are the main single-value transfer routines.  They automatically
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index 67e9bc94dc40..2c31667e62e0 100644
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -33,13 +33,6 @@ typedef struct {
>  	/* empty dummy */
>  } mm_segment_t;
>  
> -#ifndef TASK_SIZE_MAX
> -#define TASK_SIZE_MAX			TASK_SIZE
> -#endif
> -
> -#define uaccess_kernel()		(false)
> -#define user_addr_max()			(TASK_SIZE_MAX)
> -
>  static inline mm_segment_t force_uaccess_begin(void)
>  {
>  	return (mm_segment_t) { };


Acked-by: Stafford Horne <shorne@gmail.com> [openrisc, asm-generic]

Thanks!
