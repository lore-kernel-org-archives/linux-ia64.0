From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 02 Mar 2022 05:23:02 +0000
Subject: Re: [PATCH V3 04/30] powerpc/mm: Enable ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <87k0ddnd1l.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1646045273-9343-1-git-send-email-anshuman.khandual@arm.com>
 <1646045273-9343-5-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1646045273-9343-5-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, geert@linux-m68k.org, Anshuman Khandual <anshuman.khandual@arm.com>, Christoph Hellwig <hch@infradead.org>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-s390@vger.kernel.org, linux-riscv@lists.infradead.org, linux-alpha@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-parisc@vger.kernel.org, openrisc@lists.librecores.org, linux-um@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Paul Mackerras <paulus@samba.org>

Anshuman Khandual <anshuman.khandual@arm.com> writes:
> This defines and exports a platform specific custom vm_get_page_prot() via
> subscribing ARCH_HAS_VM_GET_PAGE_PROT. Subsequently all __SXXX and __PXXX
> macros can be dropped which are no longer needed. While here, this also
> localizes arch_vm_get_page_prot() as powerpc_vm_get_page_prot() and moves
> it near vm_get_page_prot().
>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/powerpc/Kconfig               |  1 +
>  arch/powerpc/include/asm/mman.h    | 12 ------
>  arch/powerpc/include/asm/pgtable.h | 19 ----------
>  arch/powerpc/mm/mmap.c             | 59 ++++++++++++++++++++++++++++++
>  4 files changed, 60 insertions(+), 31 deletions(-)

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers
