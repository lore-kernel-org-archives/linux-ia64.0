From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Oct 2021 07:16:32 +0000
Subject: Re: [PATCH v1 10/10] lkdtm: Fix execute_[user]_location()
Message-Id: <202110130012.4608FFD38E@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <c551f3f4b803d1a4a184b0fa94475d405ba436d8.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <c551f3f4b803d1a4a184b0fa94475d405ba436d8.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 11, 2021 at 05:25:37PM +0200, Christophe Leroy wrote:
> execute_location() and execute_user_location() intent
> to copy do_nothing() text and execute it at a new location.
> However, at the time being it doesn't copy do_nothing() function
> but do_nothing() function descriptor which still points to the
> original text. So at the end it still executes do_nothing() at
> its original location allthough using a copied function descriptor.
> 
> So, fix that by really copying do_nothing() text and build a new
> function descriptor by copying do_nothing() function descriptor and
> updating the target address with the new location.
> 
> Also fix the displayed addresses by dereferencing do_nothing()
> function descriptor.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  drivers/misc/lkdtm/perms.c | 45 +++++++++++++++++++++++++++++++-------
>  1 file changed, 37 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
> index da16564e1ecd..1d03cd44c21d 100644
> --- a/drivers/misc/lkdtm/perms.c
> +++ b/drivers/misc/lkdtm/perms.c
> @@ -44,19 +44,42 @@ static noinline void do_overwritten(void)
>  	return;
>  }
>  
> +static void *setup_function_descriptor(funct_descr_t *fdesc, void *dst)
> +{
> +	int err;
> +
> +	if (!__is_defined(HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR))
> +		return dst;
> +
> +	err = copy_from_kernel_nofault(fdesc, do_nothing, sizeof(*fdesc));
> +	if (err < 0)
> +		return ERR_PTR(err);
> +
> +	fdesc->addr = (unsigned long)dst;
> +	barrier();
> +
> +	return fdesc;
> +}
> +
>  static noinline void execute_location(void *dst, bool write)
>  {
> -	void (*func)(void) = dst;
> +	void (*func)(void);
> +	funct_descr_t fdesc;
> +	void *do_nothing_text = dereference_symbol_descriptor(do_nothing);
>  
> -	pr_info("attempting ok execution at %px\n", do_nothing);
> +	pr_info("attempting ok execution at %px\n", do_nothing_text);
>  	do_nothing();
>  
>  	if (write = CODE_WRITE) {
> -		memcpy(dst, do_nothing, EXEC_SIZE);
> +		memcpy(dst, do_nothing_text, EXEC_SIZE);
>  		flush_icache_range((unsigned long)dst,
>  				   (unsigned long)dst + EXEC_SIZE);
>  	}
> -	pr_info("attempting bad execution at %px\n", func);
> +	func = setup_function_descriptor(&fdesc, dst);
> +	if (IS_ERR(func))
> +		return;

I think this error case should complain with some details. :) Maybe:

	pr_err("FAIL: could not build function descriptor for %px\n", dst);

> +
> +	pr_info("attempting bad execution at %px\n", dst);

And then leave this pr_info() as it was, before the
setup_function_descriptor() call.

>  	func();
>  	pr_err("FAIL: func returned\n");
>  }
> @@ -66,16 +89,22 @@ static void execute_user_location(void *dst)
>  	int copied;
>  
>  	/* Intentionally crossing kernel/user memory boundary. */
> -	void (*func)(void) = dst;
> +	void (*func)(void);
> +	funct_descr_t fdesc;
> +	void *do_nothing_text = dereference_symbol_descriptor(do_nothing);
>  
> -	pr_info("attempting ok execution at %px\n", do_nothing);
> +	pr_info("attempting ok execution at %px\n", do_nothing_text);
>  	do_nothing();
>  
> -	copied = access_process_vm(current, (unsigned long)dst, do_nothing,
> +	copied = access_process_vm(current, (unsigned long)dst, do_nothing_text,
>  				   EXEC_SIZE, FOLL_WRITE);
>  	if (copied < EXEC_SIZE)
>  		return;
> -	pr_info("attempting bad execution at %px\n", func);
> +	func = setup_function_descriptor(&fdesc, dst);
> +	if (IS_ERR(func))
> +		return;
> +
> +	pr_info("attempting bad execution at %px\n", dst);

Same here.

>  	func();
>  	pr_err("FAIL: func returned\n");
>  }
> -- 
> 2.31.1
> 

-- 
Kees Cook
