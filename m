From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 13 Dec 2018 20:08:46 +0000
Subject: Re: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <20181213200846.GA21726@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, linux-ia64@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, Ilias Apalodimas <ilias.apalodimas@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, Keith Busch <keith.busch@intel.com>, Tony Luck <tony.luck@intel.com>, Robin Murphy <robin.murphy@arm.com>, Jonathan Derrick <jonathan.derrick@intel.com>, Tariq Toukan <tariqt@mellanox.com>

I've pulled v2 with the ia64 into dma-mapping for-next.  This should
give us a little more than a week in linux-next to sort out any
issues.
