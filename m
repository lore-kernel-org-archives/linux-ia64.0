From: Grant Grundler <iod00d@hp.com>
Date: Tue, 26 Oct 2004 17:55:52 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <20041026175552.GD2728@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 26, 2004 at 09:23:24AM -0700, Jesse Barnes wrote:
> I'm pretty sure this is the case.

Me too. (Re perf sensitive devices NOT using IO Port address space)

> In fact when I last discussed this with 
> Linus he indicated that an ioread shouldn't guarantee DMA completion either, 
> which would mean we could reuse the read_relaxed stuff to implement it.

How can a device driver guarantee all in-flight DMA has completed
before unmapping control data?
(ie buffers allocated with pci_alloc_consistent()).

PCI ordering rules dictate MMIO read flush in-flight inbound DMA.
I'm just looking for a replacement if there is going to be
a difference in semantics between readl() and io_readl().

thanks,
grant
