From: Christoph Hellwig <hch@lst.de>
Date: Wed, 19 Aug 2020 13:54:55 +0000
Subject: Re: [PATCH 05/28] media/v4l2: remove V4L2-FLAG-MEMORY-NON-CONSISTENT
Message-Id: <20200819135454.GA17098@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de> <20200819065555.1802761-6-hch@lst.de> <CAAFQd5COLxjydDYrfx47ht8tj-aNPiaVnC+WyQA7nvpW4gs=ww@mail.gmail.com>
In-Reply-To: <CAAFQd5COLxjydDYrfx47ht8tj-aNPiaVnC+WyQA7nvpW4gs=ww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tomasz Figa <tfiga@chromium.org>
Cc: Christoph Hellwig <hch@lst.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <iommu@lists.linux-foundation.org>, Tom Lendacky <thomas.lendacky@amd.com>, alsa-devel@alsa-project.org, linux-samsung-soc <linux-samsung-soc@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-scsi@vger.kernel.org, linux-parisc@vger.kernel.org, Linux Doc Mailing List <linux-doc@vger.kernel.org>, nouveau@lists.freedesktop.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvme@lists.infradead.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <linux-arm-kernel@lists.infradead.org>, Linux Media Mailing List <linux-media@vger.kernel.org>

On Wed, Aug 19, 2020 at 01:16:51PM +0200, Tomasz Figa wrote:
> Hi Christoph,
> 
> On Wed, Aug 19, 2020 at 8:56 AM Christoph Hellwig <hch@lst.de> wrote:
> >
> > The V4L2-FLAG-MEMORY-NON-CONSISTENT flag is entirely unused,
> 
> Could you explain what makes you think it's unused? It's a feature of
> the UAPI generally supported by the videobuf2 framework and relied on
> by Chromium OS to get any kind of reasonable performance when
> accessing V4L2 buffers in the userspace.

Because it doesn't do anything except on PARISC and non-coherent MIPS,
so by definition it isn't used by any of these media drivers.
