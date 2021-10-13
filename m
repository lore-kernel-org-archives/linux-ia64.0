From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Oct 2021 07:02:12 +0000
Subject: Re: [PATCH v1 06/10] asm-generic: Refactor dereference_[kernel]_function_descriptor()
Message-Id: <202110130002.A7C0A86@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <c215b244a19a07327ec81bf99f3c5f89c68af7b4.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <c215b244a19a07327ec81bf99f3c5f89c68af7b4.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 11, 2021 at 05:25:33PM +0200, Christophe Leroy wrote:
> dereference_function_descriptor() and
> dereference_kernel_function_descriptor() are identical on the
> three architectures implementing them.
> 
> Make it common.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/ia64/include/asm/sections.h    | 19 -------------------
>  arch/parisc/include/asm/sections.h  |  9 ---------
>  arch/parisc/kernel/process.c        | 21 ---------------------
>  arch/powerpc/include/asm/sections.h | 23 -----------------------
>  include/asm-generic/sections.h      | 18 ++++++++++++++++++
>  5 files changed, 18 insertions(+), 72 deletions(-)

A diffstat to love. :)

Reviewed-by: Kees Cook <keescook@chromium.org>


> 
> diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
> index 929b5c535620..d9addaea8339 100644
> --- a/arch/ia64/include/asm/sections.h
> +++ b/arch/ia64/include/asm/sections.h
> @@ -30,23 +30,4 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
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
> index 329e80f7af0a..b041fb32a300 100644
> --- a/arch/parisc/include/asm/sections.h
> +++ b/arch/parisc/include/asm/sections.h
> @@ -12,13 +12,4 @@ typedef Elf64_Fdesc funct_descr_t;
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
> index d0d5287fa568..8f8e95f234e2 100644
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
> index 436412d94054..5baaf9d7c671 100644
> --- a/include/asm-generic/sections.h
> +++ b/include/asm-generic/sections.h
> @@ -60,6 +60,24 @@ extern __visible const void __nosave_begin, __nosave_end;
>  
>  /* Function descriptor handling (if any).  Override in asm/sections.h */
>  #ifdef HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR
> +static inline void *dereference_function_descriptor(void *ptr)
> +{
> +	funct_descr_t *desc = ptr;
> +	void *p;
> +
> +	if (!get_kernel_nofault(p, (void *)&desc->addr))
> +		ptr = p;
> +	return ptr;
> +}
> +
> +static inline void *dereference_kernel_function_descriptor(void *ptr)
> +{
> +	if (ptr < (void *)__start_opd || ptr >= (void *)__end_opd)
> +		return ptr;
> +
> +	return dereference_function_descriptor(ptr);
> +}
> +
>  #else
>  #define dereference_function_descriptor(p) ((void *)(p))
>  #define dereference_kernel_function_descriptor(p) ((void *)(p))
> -- 
> 2.31.1
> 

-- 
Kees Cook
