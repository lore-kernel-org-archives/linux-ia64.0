From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 27 Jan 2009 14:46:37 +0000
Subject: Re: [PATCH -tip] IA64: fix the compile error on IA64_DIG_VTD
Message-Id: <20090127144637.GA14728@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090127233530U.fujita.tomonori@lab.ntt.co.jp> <20090127144602.GA12183@elte.hu>
In-Reply-To: <20090127144602.GA12183@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> > ---
> >  arch/ia64/kernel/dma-mapping.c |    3 +++
> >  arch/ia64/kernel/pci-swiotlb.c |    3 ---
> >  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> Applied to tip/core/iommu, thanks!

Tony, is this fix fine with you too?

	Ingo
