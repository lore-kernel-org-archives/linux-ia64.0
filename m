From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Fri, 19 Mar 2004 09:56:00 +0000
Subject: Re: [2/3] Use insert_resource in pci_claim_resource
Message-Id: <20040319095600.A9678@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040318235024.GH25059@parcelfarce.linux.theplanet.co.uk> <20040318235217.GJ25059@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040318235217.GJ25059@parcelfarce.linux.theplanet.co.uk>; from willy@debian.org on Thu, Mar 18, 2004 at 11:52:17PM +0000
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@zip.com.au>, Greg KH <greg@kroah.com>, David Mosberger <davidm@hpl.hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Mar 18, 2004 at 11:52:17PM +0000, Matthew Wilcox wrote:
> On ia64, the parent resources are not necessarily PCI resources and
> so won't get found by pci_find_parent_resource.  Use the shiny new
> insert_resource() function instead, which I think we would have used
> here had it been available at the time.

I think we want to preserve the existing behaviour rather than change
it.  We really do want to request the device resource against its
immediate parent because that is the way PCI works - if a devices
resources don't fall within the parent bus resources, we want to
know about it.

May I suggest that ia64 sets the parent bus resources appropriately,
which should relieve this problem (iow, pci_root_bus->resource[0..3])?
If pci_find_parent_resource() is returning the wrong thing, its likely
that other users of this function will also be getting the wrong answer.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
