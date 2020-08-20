From: Tomasz Figa <tfiga@chromium.org>
Date: Thu, 20 Aug 2020 17:33:48 +0000
Subject: Re: [PATCH 05/28] media/v4l2: remove V4L2-FLAG-MEMORY-NON-CONSISTENT
Message-Id: <CAAFQd5D=NzgjosB51-O_cH27a8V6CPgCfaPSfHHz7nKJPbazgg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de> <20200819065555.1802761-6-hch@lst.de>
 <CAAFQd5COLxjydDYrfx47ht8tj-aNPiaVnC+WyQA7nvpW4gs=ww@mail.gmail.com>
 <20200819135454.GA17098@lst.de> <CAAFQd5BuXP7t3d-Rwft85j=KTyXq7y4s24mQxLr=VoY9krEGZw@mail.gmail.com>
 <20200820044347.GA4533@lst.de> <20200820052004.GA5305@lst.de>
 <CAAFQd5CFiA2WBaaPQ9ezvMjYZfNw37c42UEy9Pk7kJyCi1mLzQ@mail.gmail.com> <20200820165407.GD12693@lst.de>
In-Reply-To: <20200820165407.GD12693@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: alsa-devel@alsa-project.org, linux-ia64@vger.kernel.org, Linux Doc Mailing List <linux-doc@vger.kernel.org>, nouveau@lists.freedesktop.org, linux-nvme@lists.infradead.org, linux-mips@vger.kernel.org, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, linux-mm@kvack.org, linux-samsung-soc <linux-samsung-soc@vger.kernel.org>, Joonyoung Shim <jy0922.shim@samsung.com>, linux-scsi@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Matt Porter <mporter@kernel.crashing.org>, Linux Media Mailing List <linux-media@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <linux-arm-kernel@lists.infradead.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, Seung-Woo Kim <sw0312.kim@samsung.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <iommu@lists.linux-foundation.org>

On Thu, Aug 20, 2020 at 6:54 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Thu, Aug 20, 2020 at 12:05:29PM +0200, Tomasz Figa wrote:
> > The UAPI and V4L2/videobuf2 changes are in good shape and the only
> > wrong part is the use of DMA API, which was based on an earlier email
> > guidance anyway, and a change to the synchronization part . I find
> > conclusions like the above insulting for people who put many hours
> > into designing and implementing the related functionality, given the
> > complexity of the videobuf2 framework and how ill-defined the DMA API
> > was, and would feel better if such could be avoided in future
> > communication.
>
> It wasn't meant to be too insulting, but I found this out when trying
> to figure out how to just disable it.  But it also ends up using
> the actual dma attr flags for it's own consistency checks, so just
> not setting the flag did not turn out to work that easily.
>

Yes, sadly the videobuf2 ended up becoming quite counterintuitive
after growing for the long years and that is reflected in the design
of this feature as well. I think we need to do something about it.

> But in general it helps to add a few more people to the Cc list for
> such things that do stranger things.  Especially if you think you did
> it based on the advice of those people.

Indeed, we should have CCed you and other DMA folks. Sergey who worked
on this series is quite new to these areas of the kernel (although not
to the kernel itself) and it's my fault for not explicitly letting him
know to do that.

Best regards,
Tomasz
