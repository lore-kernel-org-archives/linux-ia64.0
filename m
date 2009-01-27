From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Jan 2009 17:17:58 +0000
Subject: RE: [PATCH -tip] IA64: fix the compile error on IA64_DIG_VTD
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35F1F9A94@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090127233530U.fujita.tomonori@lab.ntt.co.jp>
 <20090127144602.GA12183@elte.hu> <20090127144637.GA14728@elte.hu>
In-Reply-To: <20090127144637.GA14728@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> > > ---
> > >  arch/ia64/kernel/dma-mapping.c |    3 +++
> > >  arch/ia64/kernel/pci-swiotlb.c |    3 ---
> > >  2 files changed, 3 insertions(+), 3 deletions(-)
> >
> > Applied to tip/core/iommu, thanks!
>
> Tony, is this fix fine with you too?

It works ... and dma-mapping.c is OK as a location for the
definition.  But there seemes to be some small scope for a
related cleanup:

There are "extern" declarations for "iommu_detected" in both
<asm/iommu.h> (x86 and ia64) and also in <linux/dmar.h>

Does having both of these avoid some #include hell?

-Tony
