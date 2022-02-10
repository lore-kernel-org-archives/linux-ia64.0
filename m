From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 10 Feb 2022 10:30:43 +0000
Subject: Re: [PATCH v3 08/12] asm-generic: Refactor dereference_[kernel]_function_descriptor()
Message-Id: <8735kr814c.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
 <93a2006a5d90292baf69cb1c34af5785da53efde.1634457599.git.christophe.leroy@csgroup.eu>
In-Reply-To: <93a2006a5d90292baf69cb1c34af5785da53efde.1634457599.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Christophe Leroy <christophe.leroy@csgroup.eu> writes:
> diff --git a/kernel/extable.c b/kernel/extable.c
> index b0ea5eb0c3b4..1ef13789bea9 100644
> --- a/kernel/extable.c
> +++ b/kernel/extable.c
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
> +#ifdef CONFIG_HAVE_FUNCTION_DESCRIPTORS
> +void *dereference_function_descriptor(void *ptr)
> +{
> +	func_desc_t *desc = ptr;
> +	void *p;
> +
> +	if (!get_kernel_nofault(p, (void *)&desc->addr))
> +		ptr = p;
> +	return ptr;
> +}

This needs an EXPORT_SYMBOL_GPL(), otherwise the build breaks after
patch 10 with CONFIG_LKDTM=m.

cheers
