From: Jeremy Higdon <jeremy@sgi.com>
Date: Fri, 16 Jan 2004 03:19:14 +0000
Subject: Re: [PATCH] readX_relaxed interface
Message-Id: <20040116031914.GE374259@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040115204913.GA8172@sgi.com> <20040115221640.GA11283@cup.hp.com>
In-Reply-To: <20040115221640.GA11283@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Jan 15, 2004 at 02:16:40PM -0800, Grant Grundler wrote:
> On Thu, Jan 15, 2004 at 12:49:13PM -0800, Jesse Barnes wrote:
> > Based on the PIO ordering disucssion, I've come up with the following
> > patch.  It has the potential to help any platform that has seperate PIO
> > and DMA channels, and allows them to be reorderd wrt each other.
> 
> This is only significant for DMA writes (inbound) vs. PIO Read returns.

Correct.

> The ZX1 platforms have reordering enabled for outbound DMA (vs PIO
> writes) since last summer.

The SGI NUMA platforms do this also.  This is always safe, at least
in real life systems, I think (though someone will now undoubtedly
come up with an example where it isn't), as long as CPU updates to
memory made by the CPU prior to issuing the PIO are coherent by the
time the device sees the PIO.  If not, then you need some sort of
cache writeback, which is already provided for in APIs.

> Outside the context of PCI-X Relaxed Ordering, this violates PCI
> ordering rules. Any patches to drivers *using* the new readb()
> variants in effect work around this violation. I"m ok with that - just
> want it to be clear.

I would put it a different way.  We are currently conforming to
PCI ordering rules using a relatively expensive sw/hw workaround
in the SN versions of readX().
These readX_relaxed() variants allow us to speed up drivers in
cases where DMA write and PIO read ordering is unnecessary or
taken care of some other way (maybe a previous readX call).

So with this patch, we're providing a fast PIO read that violates
PCI ordering rules, to be used only when the ordering rules are
unnecessary.

Btw, in certain situations, this can cut what would be a 50us or
longer PIO read down to about 1us, which is why we're pushing this.

> PCI-X support will need a different interface
> (eg pcix_enable_relaxed_ordering()) to support
> it's form of "Relaxed Ordering".

Right.


Thanks for the reviews.

jeremy
