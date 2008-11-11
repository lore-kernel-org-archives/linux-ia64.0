From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 11 Nov 2008 05:53:46 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <20081111145418P.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
	<Pine.LNX.4.64.0811101600490.32282@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0811101600490.32282@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: cl@linux-foundation.org
Cc: y-goto@jp.fujitsu.com, tony.luck@intel.com, fujita.tomonori@lab.ntt.co.jp, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, joerg.roedel@amd.com

On Mon, 10 Nov 2008 16:06:52 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

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

Is it because it does some kinda address translation
(provider->dma_map_consistent) later? The zone flag is meaningless if
you do sorta address translation (e.g. hardware IOMMU like VT-d).
