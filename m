From: Nicholas Piggin <npiggin@gmail.com>
Date: Mon, 18 Oct 2021 06:27:17 +0000
Subject: Re: [PATCH v3 04/12] powerpc: Prepare func_desc_t for refactorisation
Message-Id: <1634536863.oq0s171f8c.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
        <86c393ce0a6f603f94e6d2ceca08d535f654bb23.1634457599.git.christophe.leroy@csgroup.eu>
In-Reply-To: <86c393ce0a6f603f94e6d2ceca08d535f654bb23.1634457599.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 17, 2021 10:38 pm:
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

I'm not quite following why this change is done. I guess it is so you 
can move this func_desc_t type into core code, but why do that? Is it
just to avoid using the preprocessor?

On its own this patch looks okay.

Acked-by: Nicholas Piggin <npiggin@gmail.com>
