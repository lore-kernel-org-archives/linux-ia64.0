From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 15 Oct 2021 05:57:56 +0000
Subject: Re: [PATCH v2 01/13] powerpc: Move 'struct ppc64_opd_entry' back into asm/elf.h
Message-Id: <1634277306.r82aohhn4e.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
        <42d2a571677e60082c0a5b3e52e855aa58c0b1fc.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <42d2a571677e60082c0a5b3e52e855aa58c0b1fc.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 14, 2021 3:49 pm:
> 'struct ppc64_opd_entry' doesn't belong to uapi/asm/elf.h
> 
> It was initially in module_64.c and commit 2d291e902791 ("Fix compile
> failure with non modular builds") moved it into asm/elf.h
> 
> But it was by mistake added outside of __KERNEL__ section,
> therefore commit c3617f72036c ("UAPI: (Scripted) Disintegrate
> arch/powerpc/include/asm") moved it to uapi/asm/elf.h
> 
> Move it back into asm/elf.h, this brings it back in line with
> IA64 and PARISC architectures.
> 
> Fixes: 2d291e902791 ("Fix compile failure with non modular builds")
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> ---
>  arch/powerpc/include/asm/elf.h      | 6 ++++++
>  arch/powerpc/include/uapi/asm/elf.h | 8 --------
>  2 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
> index b8425e3cfd81..a4406714c060 100644
> --- a/arch/powerpc/include/asm/elf.h
> +++ b/arch/powerpc/include/asm/elf.h
> @@ -176,4 +176,10 @@ do {									\
>  /* Relocate the kernel image to @final_address */
>  void relocate(unsigned long final_address);
>  
> +/* There's actually a third entry here, but it's unused */
> +struct ppc64_opd_entry {
> +	unsigned long funcaddr;
> +	unsigned long r2;
> +};

Reviewed-by: Nicholas Piggin <npiggin@gmail.com>

I wonder if we should add that third entry, just for completeness. And 
'r2' isn't a good name should probably be toc. And should it be packed? 
At any rate that's not for your series, a cleanup I might think about
for later.

Thanks,
Nick
