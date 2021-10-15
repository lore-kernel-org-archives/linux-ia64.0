From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 15 Oct 2021 06:59:26 +0000
Subject: Re: [PATCH v2 08/13] asm-generic: Refactor dereference_[kernel]_function_descriptor()
Message-Id: <1634279175.w0z6ck2mpb.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
        <865b5c872814e3291fe7afabcc110f53b3457b56.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <865b5c872814e3291fe7afabcc110f53b3457b56.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 14, 2021 3:49 pm:
> dereference_function_descriptor() and
> dereference_kernel_function_descriptor() are identical on the
> three architectures implementing them.
> 
> Make them common and put them out-of-line in kernel/extable.c
> which is one of the users and has similar type of functions.

We should be moving more stuff out of extable.c (including all the
kernel address tests). lib/kimage.c or kelf.c or something. 

It could be after your series though.

> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/ia64/include/asm/sections.h    | 19 -------------------
>  arch/parisc/include/asm/sections.h  |  9 ---------
>  arch/parisc/kernel/process.c        | 21 ---------------------
>  arch/powerpc/include/asm/sections.h | 23 -----------------------
>  include/asm-generic/sections.h      |  2 ++
>  kernel/extable.c                    | 23 ++++++++++++++++++++++-
>  6 files changed, 24 insertions(+), 73 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
> index 1aaed8882294..96c9bb500c34 100644
> --- a/arch/ia64/include/asm/sections.h
> +++ b/arch/ia64/include/asm/sections.h
> @@ -31,23 +31,4 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
>  extern char __start_unwind[], __end_unwind[];
>  extern char __start_ivt_text[], __end_ivt_text[];
>  
> -#undef dereference_function_descriptor
> -static inline void *dereference_function_descriptor(void *ptr)
> -{
> -	struct fdesc *desc = ptr;
> -	void *p;
> -
> -	if (!get_kernel_nofault(p, (void *)&desc->addr))
> -		ptr = p;
> -	return ptr;
> -}
> -
> -#undef dereference_kernel_function_descriptor
> -static inline void *dereference_kernel_function_descriptor(void *ptr)
> -{
> -	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
> -		return ptr;
> -	return dereference_function_descriptor(ptr);
> -}
> -
>  #endif /* _ASM_IA64_SECTIONS_H */
> diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
> index 37b34b357cb5..6b1fe22baaf5 100644
> --- a/arch/parisc/include/asm/sections.h
> +++ b/arch/parisc/include/asm/sections.h
> @@ -13,13 +13,4 @@ typedef Elf64_Fdesc func_desc_t;
>  
>  extern char __alt_instructions[], __alt_instructions_end[];
>  
> -#ifdef CONFIG_64BIT
> -
> -#undef dereference_function_descriptor
> -void *dereference_function_descriptor(void *);
> -
> -#undef dereference_kernel_function_descriptor
> -void *dereference_kernel_function_descriptor(void *);
> -#endif
> -
>  #endif
> diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
> index 38ec4ae81239..7382576b52a8 100644
> --- a/arch/parisc/kernel/process.c
> +++ b/arch/parisc/kernel/process.c
> @@ -266,27 +266,6 @@ get_wchan(struct task_struct *p)
>  	return 0;
>  }
>  
> -#ifdef CONFIG_64BIT
> -void *dereference_function_descriptor(void *ptr)
> -{
> -	Elf64_Fdesc *desc = ptr;
> -	void *p;
> -
> -	if (!get_kernel_nofault(p, (void *)&desc->addr))
> -		ptr = p;
> -	return ptr;
> -}
> -
> -void *dereference_kernel_function_descriptor(void *ptr)
> -{
> -	if (ptr < (void *)__start_opd ||
> -			ptr >= (void *)__end_opd)
> -		return ptr;
> -
> -	return dereference_function_descriptor(ptr);
> -}
> -#endif
> -
>  static inline unsigned long brk_rnd(void)
>  {
>  	return (get_random_int() & BRK_RND_MASK) << PAGE_SHIFT;
> diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
> index 1322d7b2f1a3..fbfe1957edbe 100644
> --- a/arch/powerpc/include/asm/sections.h
> +++ b/arch/powerpc/include/asm/sections.h
> @@ -72,29 +72,6 @@ static inline int overlaps_kernel_text(unsigned long start, unsigned long end)
>  		(unsigned long)_stext < end;
>  }
>  
> -#ifdef PPC64_ELF_ABI_v1
> -
> -#undef dereference_function_descriptor
> -static inline void *dereference_function_descriptor(void *ptr)
> -{
> -	struct ppc64_opd_entry *desc = ptr;
> -	void *p;
> -
> -	if (!get_kernel_nofault(p, (void *)&desc->addr))
> -		ptr = p;
> -	return ptr;
> -}
> -
> -#undef dereference_kernel_function_descriptor
> -static inline void *dereference_kernel_function_descriptor(void *ptr)
> -{
> -	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
> -		return ptr;
> -
> -	return dereference_function_descriptor(ptr);
> -}
> -#endif /* PPC64_ELF_ABI_v1 */
> -
>  #endif
>  
>  #endif /* __KERNEL__ */
> diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
> index cbec7d5f1678..76163883c6ff 100644
> --- a/include/asm-generic/sections.h
> +++ b/include/asm-generic/sections.h
> @@ -60,6 +60,8 @@ extern __visible const void __nosave_begin, __nosave_end;
>  
>  /* Function descriptor handling (if any).  Override in asm/sections.h */
>  #ifdef HAVE_FUNCTION_DESCRIPTORS
> +void *dereference_function_descriptor(void *ptr);
> +void *dereference_kernel_function_descriptor(void *ptr);
>  #else
>  #define dereference_function_descriptor(p) ((void *)(p))
>  #define dereference_kernel_function_descriptor(p) ((void *)(p))
> diff --git a/kernel/extable.c b/kernel/extable.c
> index b0ea5eb0c3b4..013ccffade11 100644
> --- a/kernel/extable.c
> +++ b/kernel/extable.c
> @@ -3,6 +3,7 @@
>     Copyright (C) 2001 Rusty Russell, 2002 Rusty Russell IBM.
>  
>  */
> +#include <linux/elf.h>
>  #include <linux/ftrace.h>
>  #include <linux/memory.h>
>  #include <linux/extable.h>
> @@ -159,12 +160,32 @@ int kernel_text_address(unsigned long addr)
>  }
>  
>  /*
> - * On some architectures (PPC64, IA64) function pointers
> + * On some architectures (PPC64, IA64, PARISC) function pointers
>   * are actually only tokens to some data that then holds the
>   * real function address. As a result, to find if a function
>   * pointer is part of the kernel text, we need to do some
>   * special dereferencing first.
>   */
> +#ifdef HAVE_FUNCTION_DESCRIPTORS
> +void *dereference_function_descriptor(void *ptr)
> +{
> +	func_desc_t *desc = ptr;
> +	void *p;
> +
> +	if (!get_kernel_nofault(p, (void *)&desc->addr))
> +		ptr = p;

I know you're just copying existing code. This seems a bit risky though. 
I don't think anything good could come of just treating the descriptor
address like a function entry address if we failed to load from it for
whatever reason.

Existing callers might be benign but the API is not good. It should
give a nice fail return or BUG. If we change that then we should also
change the name and pass the correct type to it too.

Thanks,
Nick
