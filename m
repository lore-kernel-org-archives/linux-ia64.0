From: Christoph Lameter <cl@linux-foundation.org>
Date: Tue, 11 Nov 2008 20:32:46 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <Pine.LNX.4.64.0811111431440.26610@quilx.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
 <Pine.LNX.4.64.0811101600490.32282@quilx.com> <20081111145418P.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20081111145418P.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: y-goto@jp.fujitsu.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, joerg.roedel@amd.com

On Tue, 11 Nov 2008, FUJITA Tomonori wrote:

> Is it because it does some kinda address translation
> (provider->dma_map_consistent) later? The zone flag is meaningless if
> you do sorta address translation (e.g. hardware IOMMU like VT-d).

Yes it can do address translation. Therefore a < 4G address can show up at
any 64 bit address. So no need for a special DMA zone. The same is true
for more x86_64 platforms that have an IOMMU.


