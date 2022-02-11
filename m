From: Kees Cook <keescook@chromium.org>
Date: Fri, 11 Feb 2022 00:54:52 +0000
Subject: Re: [PATCH v3 04/12] powerpc: Prepare func_desc_t for refactorisation
Message-Id: <202202101653.9128E58B84@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
 <86c393ce0a6f603f94e6d2ceca08d535f654bb23.1634457599.git.christophe.leroy@csgroup.eu>
In-Reply-To: <86c393ce0a6f603f94e6d2ceca08d535f654bb23.1634457599.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 17, 2021 at 02:38:17PM +0200, Christophe Leroy wrote:
> In preparation of making func_desc_t generic, change the ELFv2
> version to a struct containing 'addr' element.
> 
> This allows using single helpers common to ELFv1 and ELFv2.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/powerpc/kernel/module_64.c | 32 ++++++++++++++------------------
>  1 file changed, 14 insertions(+), 18 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
> index a89da0ee25e2..b687ef88c4c4 100644
> --- a/arch/powerpc/kernel/module_64.c
> +++ b/arch/powerpc/kernel/module_64.c
> @@ -33,19 +33,13 @@
>  #ifdef PPC64_ELF_ABI_v2
>  
>  /* An address is simply the address of the function. */
> -typedef unsigned long func_desc_t;
> +typedef struct {
> +	unsigned long addr;
> +} func_desc_t;
>  
>  static func_desc_t func_desc(unsigned long addr)
>  {
> -	return addr;
> -}
> -static unsigned long func_addr(unsigned long addr)
> -{
> -	return addr;
> -}
> -static unsigned long stub_func_addr(func_desc_t func)
> -{
> -	return func;
> +	return (func_desc_t){addr};

There's only 1 element in the struct, so okay, but it hurt my eyes a
little. I would have been happier with:

	return (func_desc_t){ .addr = addr; };

But of course that also looks bonkers because it starts with "return".
So no matter what I do my eyes bug out. ;)

So it's fine either way. :)

Reviewed-by: Kees Cook <keescook@chromium.org>


>  }
>  
>  /* PowerPC64 specific values for the Elf64_Sym st_other field.  */
> @@ -70,14 +64,6 @@ static func_desc_t func_desc(unsigned long addr)
>  {
>  	return *(struct func_desc *)addr;
>  }
> -static unsigned long func_addr(unsigned long addr)
> -{
> -	return func_desc(addr).addr;
> -}
> -static unsigned long stub_func_addr(func_desc_t func)
> -{
> -	return func.addr;
> -}
>  static unsigned int local_entry_offset(const Elf64_Sym *sym)
>  {
>  	return 0;
> @@ -93,6 +79,16 @@ void *dereference_module_function_descriptor(struct module *mod, void *ptr)
>  }
>  #endif
>  
> +static unsigned long func_addr(unsigned long addr)
> +{
> +	return func_desc(addr).addr;
> +}
> +
> +static unsigned long stub_func_addr(func_desc_t func)
> +{
> +	return func.addr;
> +}
> +
>  #define STUB_MAGIC 0x73747562 /* stub */
>  
>  /* Like PPC32, we need little trampolines to do > 24-bit jumps (into
> -- 
> 2.31.1
> 

-- 
Kees Cook
