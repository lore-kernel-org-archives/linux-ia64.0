From: Grant Grundler <iod00d@hp.com>
Date: Thu, 15 Jan 2004 22:16:40 +0000
Subject: Re: [PATCH] readX_relaxed interface
Message-Id: <20040115221640.GA11283@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040115204913.GA8172@sgi.com>
In-Reply-To: <20040115204913.GA8172@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeremy@sgi.com

On Thu, Jan 15, 2004 at 12:49:13PM -0800, Jesse Barnes wrote:
> Based on the PIO ordering disucssion, I've come up with the following
> patch.  It has the potential to help any platform that has seperate PIO
> and DMA channels, and allows them to be reorderd wrt each other.

This is only significant for DMA writes (inbound) vs. PIO Read returns.
The ZX1 platforms have reordering enabled for outbound DMA (vs PIO
writes) since last summer.

Outside the context of PCI-X Relaxed Ordering, this violates PCI
ordering rules. Any patches to drivers *using* the new readb()
variants in effect work around this violation. I"m ok with that - just
want it to be clear.

PCI-X support will need a different interface
(eg pcix_enable_relaxed_ordering()) to support
it's form of "Relaxed Ordering".

> Some
> SGI MIPS platforms, as well as the SGI Altix (aka sn2) platform behave
> this way, and will thus benefit from this patch.
> 
> It adds a new PIO read routine for PIOs that don't have to be ordered
> wrt DMA on the system.
> 
> If it looks ok, I'll add in macros for the other arches and send it out
> for inclusion.

It looks ok to me.

thanks,
grant
