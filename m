From: Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Aug 2018 07:29:47 +0000
Subject: Re: [PATCH] ia64: fix barrier placement for write* / dma mapping
Message-Id: <20180801072947.GD20224@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180731172031.4447-1-hch@lst.de> <20180731172031.4447-2-hch@lst.de> <c7ecb31e9a79d26ce9edb15f58e0880f@codeaurora.org>
In-Reply-To: <c7ecb31e9a79d26ce9edb15f58e0880f@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: okaya@codeaurora.org
Cc: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, okaya@kernel.org

On Tue, Jul 31, 2018 at 11:41:23PM -0700, okaya@codeaurora.org wrote:
> I asked this question to Tony Luck before. If I remember right,
> his answer was:
>
> CPU guarantees outstanding writes to be flushed when a register write
> instruction is executed and an additional barrier instruction is not
> needed.

That would be great.  It still doesn't explain the barriers in the
dma sync routines.  Those have been there since the following commit
in the history tree:

commit 66b99421d118a5ddd98a72913670b0fcf0a38d45
Author: Andrew Morton <akpm@osdl.org>
Date:   Sat Mar 13 17:05:37 2004 -0800

    [PATCH] DMA: Fill gaping hole in DMA API interfaces.

    From: "David S. Miller" <davem@redhat.com>

which in fact only added them for the HP zx1 platform, and doesn't
contain any good explanation of why we need a barrier.

So I guess the right answer might be to just remove these barriers
without replacement.
