From: Grant Grundler <iod00d@hp.com>
Date: Tue, 26 Oct 2004 18:37:16 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <20041026183716.GK2728@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 26, 2004 at 11:19:20AM -0700, Jesse Barnes wrote:
> Yep.  And it has to sync both consistent and non-consistent memory (flush 
> might be a better term since coherence isn't really the issue).

coherence is the issue. data is coherent until it reaches
whatever domain the chipset defines to be coherent.
Normally that means the data has to reach some path common to
CPU (cache) and memory controller.

> > Jesse, you keep mixing up PCI-X Relaxed Ordering with readX() interface
> > and the two are NOT (directly) related.
> > The device driver can enable PCI-X Relaxed Ordering hints in general.
> > But the IO device controls "RO" hint use on individual bus transactions 
> > it masters.
> 
> I don't believe you.  The spec makes it look like the I/O address *coming
> from the CPU* has to contain a bit to indicate relaxed ordering.

I agree that's true for outbound DMA but not inbound DMA.
Whoever masters the transaction gets to set the attribute.
For outbound (to device), CPU/Chipset get to decide.

I quote from section 11.1 "Relaxed Write Ordering" of
"PCI-X Addendum to the PCI Local Bus Specification, Revision 1.0a,
July 24, 2000":
    ...Thus, individual write transactions to that buffer area can be
    allowed to complete out of order as long as the status write pushes all
    previous writes ahead of it. An I/O device can easily accomplish this by
    setting the Relaxed Ordering attribute for all payload write transactions
    but always generating a separate transaction for the status write(s) with
    the Relaxed Ordering attribute not set.

The above description makes it pretty clear the device is setting the
attribute.

I'm not worried about ordering on outbound (aka DMA reads vs MMIO
writes) since I know parisc violates that rule and it works fine
for the IO devices that are common used there. Some HP IA64 platforms
also violate the outbound order (DMA reads can bypass MMIO writes).

> But as I've said 
> before, we won't know until we see chipsets that support all aspects of this 
> feature.

Agreed. We might never enable it. But in any case,  I'll assert again
PCI-X RO is orthogonal to the read_relaxed() discussion.

grant
