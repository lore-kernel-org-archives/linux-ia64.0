From: Nicholas Piggin <npiggin@gmail.com>
Date: Mon, 18 Oct 2021 05:58:21 +0000
Subject: Re: [PATCH v3 01/12] powerpc: Move and rename func_descr_t
Message-Id: <1634536669.2nedzrtfjt.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
        <637a9a11263afa216fdfa7fb470a54479c67c61c.1634457599.git.christophe.leroy@csgroup.eu>
In-Reply-To: <637a9a11263afa216fdfa7fb470a54479c67c61c.1634457599.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 17, 2021 10:38 pm:
> There are three architectures with function descriptors, try to
> have common names for the address they contain in order to
> refactor some functions into generic functions later.
> 
> powerpc has 'entry'
> ia64 has 'ip'
> parisc has 'addr'
> 
> Vote for 'addr' and update 'func_descr_t' accordingly.
> 
> Move it in asm/elf.h to have it at the same place on all
> three architectures, remove the typedef which hides its real
> type, and change it to a smoother name 'struct func_desc'.
> 

Reviewed-by: Nicholas Piggin <npiggin@gmail.com>

> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/powerpc/include/asm/code-patching.h | 2 +-
>  arch/powerpc/include/asm/elf.h           | 6 ++++++
>  arch/powerpc/include/asm/types.h         | 6 ------
>  arch/powerpc/kernel/signal_64.c          | 8 ++++----
>  4 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/code-patching.h b/arch/powerpc/include/asm/code-patching.h
> index 4ba834599c4d..c6e805976e6f 100644
> --- a/arch/powerpc/include/asm/code-patching.h
> +++ b/arch/powerpc/include/asm/code-patching.h
> @@ -110,7 +110,7 @@ static inline unsigned long ppc_function_entry(void *func)
>  	 * function's descriptor. The first entry in the descriptor is the
>  	 * address of the function text.
>  	 */
> -	return ((func_descr_t *)func)->entry;
> +	return ((struct func_desc *)func)->addr;
>  #else
>  	return (unsigned long)func;
>  #endif
> diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
> index b8425e3cfd81..971589a21bc0 100644
> --- a/arch/powerpc/include/asm/elf.h
> +++ b/arch/powerpc/include/asm/elf.h
> @@ -176,4 +176,10 @@ do {									\
>  /* Relocate the kernel image to @final_address */
>  void relocate(unsigned long final_address);
>  
> +struct func_desc {
> +	unsigned long addr;
> +	unsigned long toc;
> +	unsigned long env;
> +};
> +
>  #endif /* _ASM_POWERPC_ELF_H */
> diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
> index f1630c553efe..97da77bc48c9 100644
> --- a/arch/powerpc/include/asm/types.h
> +++ b/arch/powerpc/include/asm/types.h
> @@ -23,12 +23,6 @@
>  
>  typedef __vector128 vector128;
>  
> -typedef struct {
> -	unsigned long entry;
> -	unsigned long toc;
> -	unsigned long env;
> -} func_descr_t;
> -
>  #endif /* __ASSEMBLY__ */
>  
>  #endif /* _ASM_POWERPC_TYPES_H */
> diff --git a/arch/powerpc/kernel/signal_64.c b/arch/powerpc/kernel/signal_64.c
> index 1831bba0582e..36537d7d5191 100644
> --- a/arch/powerpc/kernel/signal_64.c
> +++ b/arch/powerpc/kernel/signal_64.c
> @@ -933,11 +933,11 @@ int handle_rt_signal64(struct ksignal *ksig, sigset_t *set,
>  		 * descriptor is the entry address of signal and the second
>  		 * entry is the TOC value we need to use.
>  		 */
> -		func_descr_t __user *funct_desc_ptr =
> -			(func_descr_t __user *) ksig->ka.sa.sa_handler;
> +		struct func_desc __user *ptr =
> +			(struct func_desc __user *)ksig->ka.sa.sa_handler;
>  
> -		err |= get_user(regs->ctr, &funct_desc_ptr->entry);
> -		err |= get_user(regs->gpr[2], &funct_desc_ptr->toc);
> +		err |= get_user(regs->ctr, &ptr->addr);
> +		err |= get_user(regs->gpr[2], &ptr->toc);
>  	}
>  
>  	/* enter the signal handler in native-endian mode */
> -- 
> 2.31.1
> 
> 
> 
