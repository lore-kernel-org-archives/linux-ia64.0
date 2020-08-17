From: Mike Rapoport <rppt@linux.ibm.com>
Date: Mon, 17 Aug 2020 07:33:33 +0000
Subject: Re: [PATCH v5] arch/ia64: Restore arch-specific pgd_offset_k implementation
Message-Id: <20200817073333.GK969206@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200813205521.5405-1-rppt@kernel.org>
In-Reply-To: <20200813205521.5405-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Anatoly Pugachev <matorola@gmail.com>, Sergei Trofimovich <slyfox@gentoo.org>, linux-mm@kvack.org, Frank Scheiner <frank.scheiner@web.de>

On Thu, Aug 13, 2020 at 11:55:21PM +0300, Mike Rapoport wrote:
> From: Jessica Clarke <jrtc27@jrtc27.com>
> 
> IA-64 is special and treats pgd_offset_k() differently to pgd_offset(),
> using different formulae to calculate the indices into the kernel and user
> PGDs.  The index into the user PGDs takes into account the region number,
> but the index into the kernel (init_mm) PGD always assumes a predefined
> kernel region number. Commit 974b9b2c68 ("mm: consolidate pte_index() and
> pte_offset_*() definitions") made IA-64 use a generic pgd_offset_k() which
> incorrectly used pgd_index() for kernel page tables.  As a result, the
> index into the kernel PGD was going out of bounds and the kernel hung
> during early boot.
> 
> Allow overrides of pgd_offset_k() and override it on IA-64 with the old
> implementation that will correctly index the kernel PGD.
> 
> Fixes: 974b9b2c68 ("mm: consolidate pte_index() and pte_offset_*() definitions")
> Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> Signed-off-by: Jessica Clarke <jrtc27@jrtc27.com>
> Tested-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
> Changes in v4:
> * Correct the comment that I missed in v4 :(
> 
> Changes since v3:
> * Correct commit message as Jessica suggested
> 
> Changes since v2:
> * Rephrase commit message and comment about pgd_offset_k()
> 
> Changes since v1:
>  * Fixed typo in commit message
>  * Slightly reworded commit message to sound less weird
>  * Included Adrian's Tested-by
>  arch/ia64/include/asm/pgtable.h | 9 +++++++++
>  include/linux/pgtable.h         | 2 ++
>  2 files changed, 11 insertions(+)

I can take this via my tree if there are no objections.

Tony?

-- 
Sincerely yours,
Mike.
