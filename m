From: Daniel Axtens <dja@axtens.net>
Date: Thu, 14 Oct 2021 22:17:33 +0000
Subject: Re: [PATCH v2 03/13] powerpc: Remove func_descr_t
Message-Id: <874k9j45fm.fsf@dja-thinkpad.axtens.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
 <16eef6afbf7322d0c07760ebf827b8f9f50f7c6e.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <16eef6afbf7322d0c07760ebf827b8f9f50f7c6e.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Christophe Leroy <christophe.leroy@csgroup.eu> writes:

> 'func_descr_t' is redundant with 'struct ppc64_opd_entry'

So, if I understand the overall direction of the series, you're
consolidating powerpc around one single type for function descriptors,
and then you're creating a generic typedef so that generic code can
always do ((func_desc_t)x)->addr to get the address of a function out of
a function descriptor regardless of arch. (And regardless of whether the
arch uses function descriptors or not.)

So:

 - why pick ppc64_opd_entry over func_descr_t?

 - Why not make our struct just called func_desc_t - why have a
   ppc64_opd_entry type or a func_descr_t typedef?

 - Should this patch wait until after you've made the generic
   func_desc_t change and move directly to that new interface? (rather
   than move from func_descr_t -> ppc64_opd_entry -> ...) Or is there a
   particular reason arch specific code should use an arch-specific
   struct or named type?

> Remove it.
>
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/powerpc/include/asm/code-patching.h | 2 +-
>  arch/powerpc/include/asm/types.h         | 6 ------
>  arch/powerpc/kernel/signal_64.c          | 8 ++++----
>  3 files changed, 5 insertions(+), 11 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/code-patching.h b/arch/powerpc/include/asm/code-patching.h
> index 4ba834599c4d..f3445188d319 100644
> --- a/arch/powerpc/include/asm/code-patching.h
> +++ b/arch/powerpc/include/asm/code-patching.h
> @@ -110,7 +110,7 @@ static inline unsigned long ppc_function_entry(void *func)
>  	 * function's descriptor. The first entry in the descriptor is the
>  	 * address of the function text.
>  	 */
> -	return ((func_descr_t *)func)->entry;
> +	return ((struct ppc64_opd_entry *)func)->addr;
>  #else
>  	return (unsigned long)func;
>  #endif
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

I was a little concerned about going from a 3-element struct to a
2-element struct (as ppc64_opd_entry doesn't have an element for env) -
but we don't seem to take the sizeof this anywhere, nor do we use env
anywhere, nor do we do funky macro stuff with it in the signal handling
code that might implictly use the 3rd element, so I guess this will
work. Still, func_descr_t seems to describe the underlying ABI better
than ppc64_opd_entry...

>  #endif /* __ASSEMBLY__ */
>  
>  #endif /* _ASM_POWERPC_TYPES_H */
> diff --git a/arch/powerpc/kernel/signal_64.c b/arch/powerpc/kernel/signal_64.c
> index 1831bba0582e..63ddbe7b108c 100644
> --- a/arch/powerpc/kernel/signal_64.c
> +++ b/arch/powerpc/kernel/signal_64.c
> @@ -933,11 +933,11 @@ int handle_rt_signal64(struct ksignal *ksig, sigset_t *set,
>  		 * descriptor is the entry address of signal and the second
>  		 * entry is the TOC value we need to use.
>  		 */
> -		func_descr_t __user *funct_desc_ptr > -			(func_descr_t __user *) ksig->ka.sa.sa_handler;
> +		struct ppc64_opd_entry __user *funct_desc_ptr > +			(struct ppc64_opd_entry __user *)ksig->ka.sa.sa_handler;
>  
> -		err |= get_user(regs->ctr, &funct_desc_ptr->entry);
> -		err |= get_user(regs->gpr[2], &funct_desc_ptr->toc);
> +		err |= get_user(regs->ctr, &funct_desc_ptr->addr);
> +		err |= get_user(regs->gpr[2], &funct_desc_ptr->r2);

Likewise, r2 seems like a worse name than toc. I guess we could clean
that up another time though.

Kind regards,
Daniel

>  	}
>  
>  	/* enter the signal handler in native-endian mode */
> -- 
> 2.31.1
