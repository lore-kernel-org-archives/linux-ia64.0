From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 12 Oct 2021 07:10:32 +0000
Subject: Re: [PATCH v1 01/10] powerpc: Move 'struct ppc64_opd_entry' back into asm/elf.h
Message-Id: <878ryy7m6v.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <8ff3ec195d695033b652e9971fba2dc5528f7151.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <8ff3ec195d695033b652e9971fba2dc5528f7151.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Christophe Leroy <christophe.leroy@csgroup.eu> writes:
> 'struct ppc64_opd_entry' doesn't belong to uapi/asm/elf.h

Agree, but ...

> It was initially in module_64.c and commit 2d291e902791 ("Fix compile
> failure with non modular builds") moved it into asm/elf.h
>
> But it was by mistake added outside of __KERNEL__ section,
> therefore commit c3617f72036c ("UAPI: (Scripted) Disintegrate
> arch/powerpc/include/asm") moved it to uapi/asm/elf.h

... it's been visible to userspace since the first commit moved it, ~13
years ago in 2008, v2.6.27.

> Move it back into asm/elf.h, this brings it back in line with
> IA64 and PARISC architectures.

Removing it from the uapi header risks breaking userspace, I doubt
anything uses it, but who knows.

Given how long it's been there I think it's a bit risky to remove it :/

> diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
> index b8425e3cfd81..64b523848cd7 100644
> --- a/arch/powerpc/include/asm/elf.h
> +++ b/arch/powerpc/include/asm/elf.h
> @@ -176,4 +176,11 @@ do {									\
>  /* Relocate the kernel image to @final_address */
>  void relocate(unsigned long final_address);
>  
> +/* There's actually a third entry here, but it's unused */
> +struct ppc64_opd_entry
> +{
> +	unsigned long funcaddr;
> +	unsigned long r2;
> +};
> +
>  #endif /* _ASM_POWERPC_ELF_H */
> diff --git a/arch/powerpc/include/uapi/asm/elf.h b/arch/powerpc/include/uapi/asm/elf.h
> index 860c59291bfc..308857123a08 100644
> --- a/arch/powerpc/include/uapi/asm/elf.h
> +++ b/arch/powerpc/include/uapi/asm/elf.h
> @@ -289,12 +289,4 @@ typedef elf_fpreg_t elf_vsrreghalf_t32[ELF_NVSRHALFREG];
>  /* Keep this the last entry.  */
>  #define R_PPC64_NUM		253
>  
> -/* There's actually a third entry here, but it's unused */
> -struct ppc64_opd_entry
> -{
> -	unsigned long funcaddr;
> -	unsigned long r2;
> -};

Rather than removing it we can make it uapi only with:

#ifndef __KERNEL__
/* There's actually a third entry here, but it's unused */
struct ppc64_opd_entry
{
	unsigned long funcaddr;
	unsigned long r2;
};
#endif


And then we can do whatever we want with the kernel internal version.

cheers
