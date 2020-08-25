From: Christoph Hellwig <hch@lst.de>
Date: Tue, 25 Aug 2020 13:26:12 +0000
Subject: Re: a saner API for allocating DMA addressable pages
Message-Id: <20200825132612.GA22318@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <CGME20200819065610eucas1p2fde88e81917071b1888e7cc01ba0f298@eucas1p2.samsung.com> <20200819065555.1802761-1-hch@lst.de> <8fa1ce36-c783-1a02-6890-211eb504a33b@samsung.com>
In-Reply-To: <8fa1ce36-c783-1a02-6890-211eb504a33b@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Christoph Hellwig <hch@lst.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org, Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Tue, Aug 25, 2020 at 01:30:41PM +0200, Marek Szyprowski wrote:
> I really wonder what is the difference between this new API and 
> alloc_pages(GFP_DMA, n). Is this API really needed? I thought that this 
> is legacy thing to be removed one day...

The difference is that the pages returned are guranteed to be addressable
by the devie.  This is a very important difference that matters for
a lot of use cases.
