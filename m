From: Colin Ngam <cngam@sgi.com>
Date: Sat, 17 May 2003 17:06:36 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705923@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:

> >>>>> "David" = David S Miller <davem@redhat.com> writes:
>
> David>    From: Jes Sorensen <jes@wildopensource.com> Date: 16 May
> David> 2003 17:02:36 -0400
>
> >    How does this patch look to you? It adds the generic code
> > for setting the mask, it will then be up to Colin to fix the
> > SGI SN2 specific code to honor it.
>
> >    I also added a patch to the tg3 driver to set the mask as it
> > seems to work just dandy with 64 bit consistent addresses.
>
> David> I'd hate to say this but we probably need a
> David> pci_consistent_dma_supported().
>
> Hi Dave,
>
> I thought about this one, but from the system's point of view, I don't
> see a difference between being able to do 64 bit DMA to consistent
> allocations and 64 bit DMA to dynamic allocations. I'd say this is a
> host adapter/driver problem for descriptor limitations as you pointed
> out.

If we define consistent DMA capability as a capability that is restricted and
controlled by the driver/adapter, yes, the system DMA capability, which is
what pci_dma_supported() returns, is all we need.  However, if we define
consistent DMA capability as a capability that the system/platform can
restrict, and it can be different than what pci_dma_supported(), then , yes
we will need pci_consistent_dma_supported().

I am rather bias towards treating this as a device driver/adapter restriction.
Unless,
it is also expected by this pci_alloc_consistent() interface to ensure that
actual
physical memory allocated is between 0-4G .. which on our platform is not
possible as we do not have such memory ranges.  I do not understand this to
be the case.  The requirement for a 32bits DMA handle to perform SAC has
nothing to to with the actual location of the Physical memory,  when this DMA
Handle is presented to the IO Chipset for either a DMA read or a DMA write on
the PCI Bus.

I am bias but both ways will work, with pci_consistent_dma_supported() providing

an option for platforms(not driver/adapter) that do restrict consistent DMA
capability.  Is this a valid system/platform restriction?  If so, we will need
pci_consistent_dma_supported().  Otherwise, no, we do not need this new
interface.

Thanks.

colin



>
>
> I am not strongly biased on this one, it just seems redundant to me.
> I'll be happy to add it to the patch if you prefer that.
>
> David> But this can wait and your patch is fine, EXCEPT the missing
> David> documentation update :-)
>
> I have an updated patch nearly ready, including fancy documentation
> updates and Jeremy's fix to tg3.c. I will post this to linux-kernel
> shortly.
>
> Cheers,
> Jes


