From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Mon, 04 Jan 2016 11:20:26 +0000
Subject: Re: [PATCH 0/6] generic relative extable support
Message-Id: <20160104112026.GC4179@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451837157-447-1-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1451837157-447-1-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, hpa@zytor.com, mingo@redhat.com, schwidefsky@de.ibm.com, mattst88@gmail.com, ink@jurassic.park.msu.ru, rth@twiddle.net, tony.luck@intel.com, fenghua.yu@intel.com, catalin.marinas@arm.com, will.deacon@arm.com, arnd@arndb.de, akpm@linux-foundation.org, mark.rutland@arm.com, marc.zyngier@arm.com

On Sun, Jan 03, 2016 at 05:05:51PM +0100, Ard Biesheuvel wrote:
> There are currently four architectures (x86, ia64, alpha and s390) whose
> user-access exception tables are relative to the table entry address rather
> than absolute. Each of these architectures has its own search_extable() and
> sort_extable() implementation, which are not only mostly identical to each
> other, but also deviate very little from the generic absolute implementations
> in lib/extable.c that they override.
> 
> So before making arm64 the fifth architecture that reimplements this, let's
> refactor the existing code so that all of these architectures use common code
> for searching and sorting the relative extables. Archs may set
> ARCH_HAS_RELATIVE_EXTABLE to indicate that the table consists of a pair of
> relative ints, and may define swap_ex_entry_fixup() if the fixup member needs
> special treatment in the swapping step of the sorting routine (such as alpha).
> 
> Note that the s390 patch applies on top of the following patch:
> 
>   http://article.gmane.org/gmane.linux.kernel/2117036
> 
> which fixes a bug I spotted while working on this code. Since that probably
> needs to go to -stable, I broke it out and posted it separately.
> 
> Ard Biesheuvel (6):
>   extable: add support for relative extables to search and sort routines
>   alpha/extable: use generic search and sort routines
>   s390/extable: use generic search and sort routines
>   x86/extable: use generic search and sort routines
>   ia64/extable: use generic search and sort routines
>   arm64: switch to relative exception tables

For the s390 bits:

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

