From: James Bottomley <James.Bottomley@steeleye.com>
Date: Sun, 18 May 2003 21:26:22 +0000
Subject: Re: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
Message-Id: <marc-linux-ia64-105590723705940@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2003-05-18 at 15:17, Grant Grundler wrote:
> On Sun, May 18, 2003 at 12:49:49PM -0500, James Bottomley wrote:
> > In that case, the platform returns zero to "this much" being less than
> > the full 64 bits implying there's no mask the platform and driver can
> > agree on.
> 
> My point was it's better if the driver always check the return
> value regardless of which interface is ultimately agreed upon.
> (in reference to whether "no one cares a flying fish".)
> 
> If one accepts that requirement, the only improvement in Arjen's proposal
> is the platform DMA support can guess what might be better and make that
> the "effective" mask.  The driver still needs to check the effective mask.
> I happen to agree with davem : redefining this interface in 2.5 for
> a trivial improvement doesn't seem reasonable at this point.

Yes and no.  A full bit u64 mask should never fail, so the *majority* of
drivers will just set the full mask and see what they get back, not
expecting a zero.  Any driver setting less than the full mask would have
to check the return.  That would be better for most drivers (also, the
if 64 bit mask else if 32 bit mask else error would be removed).

I agree its not a 2.5 must have.  However, it is easy enough to thread
into the dma_ interface (and that has currently few enough implementing
platforms and driver users to make such a change small and fairly easy).

Also, knowing the effective mask (and it would have to be set properly
on return) would be extremely useful for drivers that have weird width
modes (like aic with 64 vs 39 vs 32 bit addressing in the
descriptors)...it would allow me to eliminate the memory size checks in
those drivers.

James



