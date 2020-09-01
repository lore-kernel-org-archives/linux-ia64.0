From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 01 Sep 2020 15:22:56 +0000
Subject: Re: [PATCH 07/28] 53c700: improve non-coherent DMA handling
Message-Id: <1598973776.4238.11.camel@HansenPartnership.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de>
         <20200819065555.1802761-8-hch@lst.de>
         <1598971960.4238.5.camel@HansenPartnership.com>
         <20200901150554.GN14765@casper.infradead.org>
In-Reply-To: <20200901150554.GN14765@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org, Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Tue, 2020-09-01 at 16:05 +0100, Matthew Wilcox wrote:
> On Tue, Sep 01, 2020 at 07:52:40AM -0700, James Bottomley wrote:
> > I think this looks mostly OK, except for one misnamed parameter
> > below. Unfortunately, the last non-coherent parisc was the 700
> > series and I no longer own a box, so I can't test that part of it
> > (I can fire up the C360 to test it on a coherent arch).
> 
> I have a 715/50 that probably hasn't been powered on in 15 years if
> you need something that old to test on (I believe the 725/100 uses
> the 7100LC and so is coherent).  I'll need to set up a cross-compiler 
> ...

I'm not going to say no to actual testing, but it's going to be a world
of pain getting something so old going.  I do have a box of older
systems I keep for architectural testing that I need to rummage around
in ... I just have a vague memory that my 715 actually caught fire a
decade ago and had to be disposed of.

James
