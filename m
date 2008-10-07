From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 07 Oct 2008 00:35:39 +0000
Subject: Re: [PATCH 2/2]Add Variable Page Size and IA64 Support in Intel IOMMU: IA64 Specific Part
Message-Id: <20081007003539.GA5920@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165750.GA21272@linux-os.sc.intel.com> <200810030941.42800.bjorn.helgaas@hp.com> <A6AD88C3F2289247BE726C37303E1EB8844A6398@orsmsx505.amr.corp.intel.com> <200810060855.36880.bjorn.helgaas@hp.com>
In-Reply-To: <200810060855.36880.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> > Could you please point me to the doc that explicitly says that architecturally ia64 doesn't need cache flush?
> 
> The following sections in volume 2 of the SDM mention DMA:
> Part 1, Sec 4.4.3, Cacheability and Coherency Attribute:
> Part 2, Sec 2.5.4, DMA:
> 
> It sounds like the expectation is that DMA will be fully coherent
> and no flushes would be required, but there is wiggle room in that
> last paragraph for platforms that don't maintain coherency.

The cache coherency bit in VT-d is for root, context, and page tables which are for DMA management, not DMA data itself. VT-d DMA data should be cache coherent.The Intel IOMMU code doesn't need to deal with non cache coherency in DMA data traffic. But root, context, and page tables could be non cache coherent and this is handled by Intel IOMMU code.

Thanks.

-Fenghua
