From: Kees Cook <keescook@chromium.org>
Date: Fri, 15 Oct 2021 21:32:58 +0000
Subject: Re: [PATCH v2 11/13] lkdtm: Fix lkdtm_EXEC_RODATA()
Message-Id: <202110151432.D8203C19@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
 <44946ed0340013a52f8acdee7d6d0781f145cd6b.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <44946ed0340013a52f8acdee7d6d0781f145cd6b.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 14, 2021 at 07:50:00AM +0200, Christophe Leroy wrote:
> Behind its location, lkdtm_EXEC_RODATA() executes
> lkdtm_rodata_do_nothing() which is a real function,
> not a copy of do_nothing().
> 
> So executes it directly instead of using execute_location().
> 
> This is necessary because following patch will fix execute_location()
> to use a copy of the function descriptor of do_nothing() and
> function descriptor of lkdtm_rodata_do_nothing() might be different.
> 
> And fix displayed addresses by dereferencing the function descriptors.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>

I still don't understand this -- it doesn't look needed at all given the
changes in patch 12. (i.e. everything is using
dereference_function_descriptor() now)

Can't this patch be dropped?

-Kees

> ---
>  drivers/misc/lkdtm/perms.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
> index 035fcca441f0..5266dc28df6e 100644
> --- a/drivers/misc/lkdtm/perms.c
> +++ b/drivers/misc/lkdtm/perms.c
> @@ -153,7 +153,14 @@ void lkdtm_EXEC_VMALLOC(void)
>  
>  void lkdtm_EXEC_RODATA(void)
>  {
> -	execute_location(lkdtm_rodata_do_nothing, CODE_AS_IS);
> +	pr_info("attempting ok execution at %px\n",
> +		dereference_function_descriptor(do_nothing));
> +	do_nothing();
> +
> +	pr_info("attempting bad execution at %px\n",
> +		dereference_function_descriptor(lkdtm_rodata_do_nothing));
> +	lkdtm_rodata_do_nothing();
> +	pr_err("FAIL: func returned\n");
>  }
>  
>  void lkdtm_EXEC_USERSPACE(void)
> -- 
> 2.31.1
> 

-- 
Kees Cook
