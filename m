From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Oct 2021 06:59:02 +0000
Subject: Re: [PATCH v1 01/10] powerpc: Move 'struct ppc64_opd_entry' back into asm/elf.h
Message-Id: <202110122358.4AFDC0BC7@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <8ff3ec195d695033b652e9971fba2dc5528f7151.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <8ff3ec195d695033b652e9971fba2dc5528f7151.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 11, 2021 at 05:25:28PM +0200, Christophe Leroy wrote:
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
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>

I'd agree with Arnd: this is a reasonable cleanup and nothing should be
using it.

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
