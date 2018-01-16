From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Date: Tue, 16 Jan 2018 08:22:52 +0000
Subject: Re: consolidate swiotlb dma_map implementations
Message-Id: <76e47666-3de1-68cc-07ad-003491d26ef9@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
 <20180116075338.GB12693@infradead.org>
In-Reply-To: <20180116075338.GB12693@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Christoph Hellwig <hch@infradead.org>, Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

Hi Konrad,

can you send the first patch to Linus for inclusion in 4.15 if you 
haven't already done so?

I'm still getting reports from people complaining about the error message.

Thanks,
Christian.

Am 16.01.2018 um 08:53 schrieb Christoph Hellwig:
> I've pulled this into the dma-mapping for-next tree, including the
> missing free_pages noted.  I'd be fine to rebase another day or two
> for additional reviews or important fixes.

