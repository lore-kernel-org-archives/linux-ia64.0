From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 28 Jan 2009 01:04:13 +0000
Subject: RE: [PATCH -tip] IA64: fix the compile error on IA64_DIG_VTD
Message-Id: <20090128100454H.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090127144637.GA14728@elte.hu>
	<57C9024A16AD2D4C97DC78E552063EA35F1F9A94@orsmsx505.amr.corp.intel.com>
	<20090128100040J.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20090128100040J.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 28 Jan 2009 10:00:11 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> On Tue, 27 Jan 2009 09:17:58 -0800
> "Luck, Tony" <tony.luck@intel.com> wrote:
> 
> > > > > ---
> > > > >  arch/ia64/kernel/dma-mapping.c |    3 +++
> > > > >  arch/ia64/kernel/pci-swiotlb.c |    3 ---
> > > > >  2 files changed, 3 insertions(+), 3 deletions(-)
> > > >
> > > > Applied to tip/core/iommu, thanks!
> > >
> > > Tony, is this fix fine with you too?
> > 
> > It works ... and dma-mapping.c is OK as a location for the
> > definition.  But there seemes to be some small scope for a
> > related cleanup:
> > 
> > There are "extern" declarations for "iommu_detected" in both
> > <asm/iommu.h> (x86 and ia64) and also in <linux/dmar.h>
> 
> We can remove them in dmar.h. X86 exported iommu_detected and no_iommu
> in several IOMMU code and we merged them into dmar.h. Seems that we
                                                ~~~~~~
                                                asm/iommu.h
