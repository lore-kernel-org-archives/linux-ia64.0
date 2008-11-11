From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Tue, 11 Nov 2008 05:39:18 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <20081111141430.D5C7.E1E9C6FF@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com> <Pine.LNX.4.64.0811101600490.32282@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0811101600490.32282@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>

> On Mon, 10 Nov 2008, Yasunori Goto wrote:
> 
> > Even if a device allows over 4G access and the driver doesn't specify
> > GFP_DMA, dma_alloc_coherent() returns under 4G area.
> 
> GFP_DMA can become 0 for configurations that have
> !CONFIG_ZONE_DMA. Then all of memory is available.
>
> The call is subarch specific. So f.e. Altix sn_dma_alloc_coherent does
> not set __GFP_DMA.

I heard that Altix has IOMMU and __GFP_DMA is not necessary.

> If you have an IA64 arch that only support 32bit I/O then __GFP_DMA in
> dma_alloc_coherent makes sense.

Agree. 
But our box supports both of 32bit I/O and 64bit I/O without IOMMU.
Is it abnormal platform? New interface is necessary for our box like Altix?


Bye.

-- 
Yasunori Goto 


