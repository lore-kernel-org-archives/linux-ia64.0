From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 11 Mar 2008 03:33:44 +0000
Subject: Re: [PATCH -mm] ia64: make IOMMU respect the segment boundary
Message-Id: <20080310203344.acf50d71.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310221538U.tomof@acm.org>
In-Reply-To: <20080310221538U.tomof@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, tomof@acm.org

On Mon, 10 Mar 2008 22:17:20 +0900 FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> This patch is another sequel to my patchset that fixes iommu segment
> boundary problems, that is, IOMMUs allocate memory areas without
> considering a low level driver's segment boundary limits:
> 
> http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg11919.html

Please make this easier.

afacit the patches to which you refer are already in mainline, so this is
*not* a "-mm" patch.  It is needed in mainline, correct?

> This patchset fixes the IA64 IOMMU code.

And if it fixes a bug then it is needed in 2.6.25.

Is that correct?

> This assumes that ioc->ibase is on iovp_size boundary. If not, please
> let me know. I'll fix the patch.

Who is the person who who knows the answer to this?

Does this mean that the patch wasn't runtime tested?  If so, how do you
know there is a bug?

> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH -mm] ia64: make IOMMU respect the segment boundary limits
> 
> This makes IA64's IOMMU implementation not allocate a memory area
> spanning LLD's segment boundary.

This changelog doesn't actually tell us that this patch fixed a bug.

It should tell us what the bug is, and how it fixed it, please.

> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  arch/ia64/Kconfig               |    3 ++
>  arch/ia64/hp/common/sba_iommu.c |   56 +++++++++++++++++++++++++++------------

