From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 15 Oct 2021 06:16:12 +0000
Subject: Re: [PATCH v2 06/13] asm-generic: Use HAVE_FUNCTION_DESCRIPTORS to define associated stubs
Message-Id: <1634278340.5yp7xtm7um.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
        <4fda65cda906e56aa87806b658e0828c64792403.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <4fda65cda906e56aa87806b658e0828c64792403.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 14, 2021 3:49 pm:
> Replace HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR by
> HAVE_FUNCTION_DESCRIPTORS and use it instead of
> 'dereference_function_descriptor' macro to know
> whether an arch has function descriptors.
> 
> To limit churn in one of the following patches, use
> an #ifdef/#else construct with empty first part
> instead of an #ifndef in asm-generic/sections.h

Is it worth putting this into Kconfig if you're going to
change it? In any case

Reviewed-by: Nicholas Piggin <npiggin@gmail.com>

> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/ia64/include/asm/sections.h    | 5 +++--
>  arch/parisc/include/asm/sections.h  | 6 ++++--
>  arch/powerpc/include/asm/sections.h | 6 ++++--
>  include/asm-generic/sections.h      | 3 ++-
>  include/linux/kallsyms.h            | 2 +-
>  5 files changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
> index 35f24e52149a..6e55e545bf02 100644
> --- a/arch/ia64/include/asm/sections.h
> +++ b/arch/ia64/include/asm/sections.h
> @@ -9,6 +9,9 @@
>  
>  #include <linux/elf.h>
>  #include <linux/uaccess.h>
> +
> +#define HAVE_FUNCTION_DESCRIPTORS 1
> +
>  #include <asm-generic/sections.h>
>  
>  extern char __phys_per_cpu_start[];
> @@ -27,8 +30,6 @@ extern char __start_gate_brl_fsys_bubble_down_patchlist[], __end_gate_brl_fsys_b
>  extern char __start_unwind[], __end_unwind[];
>  extern char __start_ivt_text[], __end_ivt_text[];
>  
> -#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
> -
>  #undef dereference_function_descriptor
>  static inline void *dereference_function_descriptor(void *ptr)
>  {
> diff --git a/arch/parisc/include/asm/sections.h b/arch/parisc/include/asm/sections.h
> index bb52aea0cb21..85149a89ff3e 100644
> --- a/arch/parisc/include/asm/sections.h
> +++ b/arch/parisc/include/asm/sections.h
> @@ -2,6 +2,10 @@
>  #ifndef _PARISC_SECTIONS_H
>  #define _PARISC_SECTIONS_H
>  
> +#ifdef CONFIG_64BIT
> +#define HAVE_FUNCTION_DESCRIPTORS 1
> +#endif
> +
>  /* nothing to see, move along */
>  #include <asm-generic/sections.h>
>  
> @@ -9,8 +13,6 @@ extern char __alt_instructions[], __alt_instructions_end[];
>  
>  #ifdef CONFIG_64BIT
>  
> -#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
> -
>  #undef dereference_function_descriptor
>  void *dereference_function_descriptor(void *);
>  
> diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
> index 32e7035863ac..bba97b8c38cf 100644
> --- a/arch/powerpc/include/asm/sections.h
> +++ b/arch/powerpc/include/asm/sections.h
> @@ -8,6 +8,10 @@
>  
>  #define arch_is_kernel_initmem_freed arch_is_kernel_initmem_freed
>  
> +#ifdef PPC64_ELF_ABI_v1
> +#define HAVE_FUNCTION_DESCRIPTORS 1
> +#endif
> +
>  #include <asm-generic/sections.h>
>  
>  extern bool init_mem_is_free;
> @@ -69,8 +73,6 @@ static inline int overlaps_kernel_text(unsigned long start, unsigned long end)
>  
>  #ifdef PPC64_ELF_ABI_v1
>  
> -#define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
> -
>  #undef dereference_function_descriptor
>  static inline void *dereference_function_descriptor(void *ptr)
>  {
> diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
> index d16302d3eb59..b677e926e6b3 100644
> --- a/include/asm-generic/sections.h
> +++ b/include/asm-generic/sections.h
> @@ -59,7 +59,8 @@ extern char __noinstr_text_start[], __noinstr_text_end[];
>  extern __visible const void __nosave_begin, __nosave_end;
>  
>  /* Function descriptor handling (if any).  Override in asm/sections.h */
> -#ifndef dereference_function_descriptor
> +#ifdef HAVE_FUNCTION_DESCRIPTORS
> +#else
>  #define dereference_function_descriptor(p) ((void *)(p))
>  #define dereference_kernel_function_descriptor(p) ((void *)(p))
>  #endif
> diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
> index a1d6fc82d7f0..9f277baeb559 100644
> --- a/include/linux/kallsyms.h
> +++ b/include/linux/kallsyms.h
> @@ -57,7 +57,7 @@ static inline int is_ksym_addr(unsigned long addr)
>  
>  static inline void *dereference_symbol_descriptor(void *ptr)
>  {
> -#ifdef HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR
> +#ifdef HAVE_FUNCTION_DESCRIPTORS
>  	struct module *mod;
>  
>  	ptr = dereference_kernel_function_descriptor(ptr);
> -- 
> 2.31.1
> 
> 
> 
