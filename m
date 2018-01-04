From: Christoph Hellwig <hch@lst.de>
Date: Thu, 04 Jan 2018 08:45:33 +0000
Subject: Re: [PATCH 17/67] microblaze: rename dma_direct to dma_microblaze
Message-Id: <20180104084533.GA3135@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de> <20171229081911.2802-18-hch@lst.de> <CAGRGNgW1qwLcCAvU2Jc=3_7b-0Bu016to3cQUgVsc+ca0No_6g@mail.gmail.com>
In-Reply-To: <CAGRGNgW1qwLcCAvU2Jc=3_7b-0Bu016to3cQUgVsc+ca0No_6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Calaby <julian.calaby@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, "Mailing List, Arm" <linux-arm-kernel@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.or>

On Fri, Dec 29, 2017 at 09:11:56PM +1100, Julian Calaby wrote:
> Hi Christoph,
> 
> On Fri, Dec 29, 2017 at 7:18 PM, Christoph Hellwig <hch@lst.de> wrote:
> > This frees the dma_direct_* namespace for a generic implementation.
> 
> Don't you mean "dma_nommu" not "dma_microblaze" in the subject line?

Yes, thanks.
