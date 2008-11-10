From: Christoph Lameter <cl@linux-foundation.org>
Date: Mon, 10 Nov 2008 22:06:52 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <Pine.LNX.4.64.0811101600490.32282@quilx.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
In-Reply-To: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>

On Mon, 10 Nov 2008, Yasunori Goto wrote:

> Even if a device allows over 4G access and the driver doesn't specify
> GFP_DMA, dma_alloc_coherent() returns under 4G area.

GFP_DMA can become 0 for configurations that have
!CONFIG_ZONE_DMA. Then all of memory is available.

The call is subarch specific. So f.e. Altix sn_dma_alloc_coherent does
not set __GFP_DMA.

If you have an IA64 arch that only support 32bit I/O then __GFP_DMA in
dma_alloc_coherent makes sense.





