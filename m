From: Daniel Axtens <dja@axtens.net>
Date: Thu, 14 Oct 2021 21:35:56 +0000
Subject: Re: [PATCH v2 00/13] Fix LKDTM for PPC64/IA64/PARISC
Message-Id: <87a6jb47cz.fsf@dja-thinkpad.axtens.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Christophe Leroy <christophe.leroy@csgroup.eu> writes:

> PPC64/IA64/PARISC have function descriptors. LKDTM doesn't work
> on those three architectures because LKDTM messes up function
> descriptors with functions.

Just to nitpick, it's powerpc 64-bit using the ELFv1 ABI. [1]

The ELFv2 ABI [2] doesn't use function descriptors. (ELFv2 is used
primarily for ppc64le, but some people like musl support it for BE as
well.)

This doesn't affect the correctness or desirability of your changes, it
was just bugging me when I was reading the commit messages :-)

Kind regards,
Daniel

[1] See e.g. https://refspecs.linuxfoundation.org/ELF/ppc64/PPC-elf64abi.html
[2] https://openpowerfoundation.org/wp-content/uploads/2016/03/ABI64BitOpenPOWERv1.1_16July2015_pub4.pdf


> This series does some cleanup in the three architectures and
> refactors function descriptors so that it can then easily use it
> in a generic way in LKDTM.
>
> Patch 8 is not absolutely necessary but it is a good trivial cleanup.
>
> Changes in v2:
> - Addressed received comments
> - Moved dereference_[kernel]_function_descriptor() out of line
> - Added patches to remove func_descr_t and func_desc_t in powerpc
> - Using func_desc_t instead of funct_descr_t
> - Renamed HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR to HAVE_FUNCTION_DESCRIPTORS
> - Added a new lkdtm test to check protection of function descriptors
>
> Christophe Leroy (13):
>   powerpc: Move 'struct ppc64_opd_entry' back into asm/elf.h
>   powerpc: Rename 'funcaddr' to 'addr' in 'struct ppc64_opd_entry'
>   powerpc: Remove func_descr_t
>   powerpc: Prepare func_desc_t for refactorisation
>   ia64: Rename 'ip' to 'addr' in 'struct fdesc'
>   asm-generic: Use HAVE_FUNCTION_DESCRIPTORS to define associated stubs
>   asm-generic: Define 'func_desc_t' to commonly describe function
>     descriptors
>   asm-generic: Refactor dereference_[kernel]_function_descriptor()
>   lkdtm: Force do_nothing() out of line
>   lkdtm: Really write into kernel text in WRITE_KERN
>   lkdtm: Fix lkdtm_EXEC_RODATA()
>   lkdtm: Fix execute_[user]_location()
>   lkdtm: Add a test for function descriptors protection
>
>  arch/ia64/include/asm/elf.h              |  2 +-
>  arch/ia64/include/asm/sections.h         | 25 ++-------
>  arch/ia64/kernel/module.c                |  6 +--
>  arch/parisc/include/asm/sections.h       | 17 +++---
>  arch/parisc/kernel/process.c             | 21 --------
>  arch/powerpc/include/asm/code-patching.h |  2 +-
>  arch/powerpc/include/asm/elf.h           |  6 +++
>  arch/powerpc/include/asm/sections.h      | 30 ++---------
>  arch/powerpc/include/asm/types.h         |  6 ---
>  arch/powerpc/include/uapi/asm/elf.h      |  8 ---
>  arch/powerpc/kernel/module_64.c          | 38 +++++--------
>  arch/powerpc/kernel/signal_64.c          |  8 +--
>  drivers/misc/lkdtm/core.c                |  1 +
>  drivers/misc/lkdtm/lkdtm.h               |  1 +
>  drivers/misc/lkdtm/perms.c               | 68 ++++++++++++++++++++----
>  include/asm-generic/sections.h           | 13 ++++-
>  include/linux/kallsyms.h                 |  2 +-
>  kernel/extable.c                         | 23 +++++++-
>  18 files changed, 138 insertions(+), 139 deletions(-)
>
> -- 
> 2.31.1
