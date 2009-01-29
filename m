From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 29 Jan 2009 13:40:22 +0000
Subject: Re: [PATCH -tip 1/3] IA64: fix swiotlb alloc_coherent for non
Message-Id: <20090129134022.GG24391@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1233147198-30299-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1233147198-30299-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Yasunori Goto <y-goto@jp.fujitsu.com>


Applied them to tip:core/iommu:

 d7ab5c4: intel-iommu: make dma mapping functions static
 dfb805e: IA64: fix VT-d dma_mapping_error
 97d9800: IA64: fix swiotlb alloc_coherent for non DMA_64BIT_MASK devices

thanks!

	Ingo
