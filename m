From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 15 Oct 2021 06:01:26 +0000
Subject: Re: [PATCH v2 02/13] powerpc: Rename 'funcaddr' to 'addr' in 'struct ppc64_opd_entry'
Message-Id: <1634277517.7t2t049cd5.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
        <49f59a8bf2c4d95cfaa03bd3dd3c1569822ad6ba.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <49f59a8bf2c4d95cfaa03bd3dd3c1569822ad6ba.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 14, 2021 3:49 pm:
> There are three architectures with function descriptors, try to
> have common names for the address they contain in order to
> refactor some functions into generic functions later.
> 
> powerpc has 'funcaddr'
> ia64 has 'ip'
> parisc has 'addr'
> 
> Vote for 'addr' and update 'struct ppc64_opd_entry' accordingly.

It is the "address of the entry point of the function" according to 
powerpc ELF spec, so addr seems fine.

Reviewed-by: Nicholas Piggin <npiggin@gmail.com>

> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/powerpc/include/asm/elf.h      | 2 +-
>  arch/powerpc/include/asm/sections.h | 2 +-
>  arch/powerpc/kernel/module_64.c     | 6 +++---
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
> index a4406714c060..bb0f278f9ed4 100644
> --- a/arch/powerpc/include/asm/elf.h
> +++ b/arch/powerpc/include/asm/elf.h
> @@ -178,7 +178,7 @@ void relocate(unsigned long final_address);
>  
>  /* There's actually a third entry here, but it's unused */
>  struct ppc64_opd_entry {
> -	unsigned long funcaddr;
> +	unsigned long addr;
>  	unsigned long r2;
>  };
>  
> diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
> index 6e4af4492a14..32e7035863ac 100644
> --- a/arch/powerpc/include/asm/sections.h
> +++ b/arch/powerpc/include/asm/sections.h
> @@ -77,7 +77,7 @@ static inline void *dereference_function_descriptor(void *ptr)
>  	struct ppc64_opd_entry *desc = ptr;
>  	void *p;
>  
> -	if (!get_kernel_nofault(p, (void *)&desc->funcaddr))
> +	if (!get_kernel_nofault(p, (void *)&desc->addr))
>  		ptr = p;
>  	return ptr;
>  }
> diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
> index 6baa676e7cb6..82908c9be627 100644
> --- a/arch/powerpc/kernel/module_64.c
> +++ b/arch/powerpc/kernel/module_64.c
> @@ -72,11 +72,11 @@ static func_desc_t func_desc(unsigned long addr)
>  }
>  static unsigned long func_addr(unsigned long addr)
>  {
> -	return func_desc(addr).funcaddr;
> +	return func_desc(addr).addr;
>  }
>  static unsigned long stub_func_addr(func_desc_t func)
>  {
> -	return func.funcaddr;
> +	return func.addr;
>  }
>  static unsigned int local_entry_offset(const Elf64_Sym *sym)
>  {
> @@ -187,7 +187,7 @@ static int relacmp(const void *_x, const void *_y)
>  static unsigned long get_stubs_size(const Elf64_Ehdr *hdr,
>  				    const Elf64_Shdr *sechdrs)
>  {
> -	/* One extra reloc so it's always 0-funcaddr terminated */
> +	/* One extra reloc so it's always 0-addr terminated */
>  	unsigned long relocs = 1;
>  	unsigned i;
>  
> -- 
> 2.31.1
> 
> 
> 
