From: Christoph Lameter <cl@linux-foundation.org>
Date: Tue, 11 Nov 2008 20:34:21 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <Pine.LNX.4.64.0811111433030.26610@quilx.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
 <Pine.LNX.4.64.0811101600490.32282@quilx.com> <20081111141430.D5C7.E1E9C6FF@jp.fujitsu.com>
In-Reply-To: <20081111141430.D5C7.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>

On Tue, 11 Nov 2008, Yasunori Goto wrote:

> But our box supports both of 32bit I/O and 64bit I/O without IOMMU.
> Is it abnormal platform? New interface is necessary for our box like Altix?

No its like x86 with the GFP_DMA zone for < 16M addresses. The special
memory creates an imbalance that sometimes leads to weird VM behavior. I'd
make sure to set GFP_DMA only for devices that actually require < 4GB
memory and only use it if no IOMMU like stuff is available. Its best to
not use GFP_DMA.


