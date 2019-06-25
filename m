From: Christoph Hellwig <hch@lst.de>
Date: Tue, 25 Jun 2019 06:50:03 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <20190625065003.GA29883@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 25, 2019 at 08:46:57AM +0200, John Paul Adrian Glaubitz wrote:
> I can reproduce the crash when trying to load the module for the USB controllers,
> for example. Loading the kernel module for the SATA controllers provokes the
> backtrace as well.
> 
> I have skimmed through the code a bit , but I'm not sure whether I understand
> the code in kernel/dma/direct.c correctly, so my suggestion would be to just
> set GFP_DMA32 in __dma_direct_alloc_pages() unconditionally for a test. Would
> that be enough for a test?

Yes.
