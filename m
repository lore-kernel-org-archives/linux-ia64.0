From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 16 Jan 2018 07:53:38 +0000
Subject: Re: consolidate swiotlb dma_map implementations
Message-Id: <20180116075338.GB12693@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
In-Reply-To: <20180110080932.14157-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <ckoenig.leichtzumerken@gmail.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

I've pulled this into the dma-mapping for-next tree, including the
missing free_pages noted.  I'd be fine to rebase another day or two
for additional reviews or important fixes.
