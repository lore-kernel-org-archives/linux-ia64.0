From: Grant Grundler <iod00d@hp.com>
Date: Tue, 04 May 2004 17:51:37 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <20040504175137.GH1701@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 10:27:21AM -0700, Jesse Barnes wrote:
> On Tuesday, May 4, 2004 10:14 am, Grant Grundler wrote:
> > Why not use the existing resource map?
> > The PCI bus data structures are hierarchial and resources are well
> > defined in that. Seems like the linked list of I/O ranges could (1)
> > get very long and (2) just replicates what's already there.
> 
> You mean just use request_region at pci_mmap_page_range time instead?

No - directly walk the either the PCI bus/device tree or walk
the ioport space resource tree and lookup the owner.

> That 
> would prevent multiple processes from accessing the same region, but we'd 
> still want to know the PID of the process that had that range reserved (the 
> gfx guys really want to get a signal when an I/O error occurs so they can 
> recover in userspace; other userspace drivers probably want the same).  

hrm...ic. And the process doesn't need to "mmap" the region/file for
IO Port space like it would for MMIO accesses. :^(

Isn't working with the vendor to NOT do this sort of crap also an option?
At least a few vendors offer EFI drivers for video cards...
(ie avoid the problem of x86 BIOS in the first place)

Linux really needs a driver/card that can provide HW acceleration
without first having BIOS initializing it. parisc-linux port
(and probably a few others) could use such a driver/card too.


> Another problem is that legacy I/O space isn't listed in any of the PCI 
> resource maps (at least as far as I know), so there would be no way to track 
> that region, which is the one that I'm *really* interested in. :)

Well, if code is randomly poking around without registering with
request_region, then your proposal is as good as any.

> Yeah, it could be tied in with that interface.

cool.

thanks,
grant
