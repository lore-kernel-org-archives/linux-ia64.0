From: Michael Ellerman <mpe@ellerman.id.au>
Date: Fri, 05 Mar 2021 12:12:17 +0000
Subject: Re: [PATCH V3] mm: Generalize HUGETLB_PAGE_SIZE_VARIABLE
Message-Id: <87pn0dre8u.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1614914928-22039-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1614914928-22039-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Anshuman Khandual <anshuman.khandual@arm.com> writes:
> HUGETLB_PAGE_SIZE_VARIABLE need not be defined for each individual
> platform subscribing it. Instead just make it generic.
>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Christophe Leroy <christophe.leroy@csgroup.eu>
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> This change was originally suggested in an earilier discussion. This
> applies on v5.12-rc1 and has been build tested on all applicable
> platforms i.e ia64 and powerpc.
>
> https://patchwork.kernel.org/project/linux-mm/patch/1613024531-19040-3-git-send-email-anshuman.khandual@arm.com/
>
> Changes in V3:
>
> - Dropped the bool desciption that enabled user selection
> - Dropped the dependency on HUGETLB_PAGE for HUGETLB_PAGE_SIZE_VARIABLE
>
> Changes in V2:
>
> https://patchwork.kernel.org/project/linux-mm/patch/1614661987-23881-1-git-send-email-anshuman.khandual@arm.com/
>
> - Added a description for HUGETLB_PAGE_SIZE_VARIABLE
> - Added HUGETLB_PAGE dependency while selecting HUGETLB_PAGE_SIZE_VARIABLE
>
> Changes in V1:
>
> https://patchwork.kernel.org/project/linux-mm/patch/1614577853-7452-1-git-send-email-anshuman.khandual@arm.com/
>
>  arch/ia64/Kconfig    | 6 +-----
>  arch/powerpc/Kconfig | 6 +-----

LGTM.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers
