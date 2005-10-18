From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 18 Oct 2005 18:33:06 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <200510181233.06825.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 18 October 2005 11:06 am, Luck, Tony wrote:
> >> > I don't want to move pcdp.h under asm-ia64.  EFI (and, I hope,
> >> > PCDP) is coming to x86 soon.  There's nothing ia64-specific
> >> > in pcdp.h or pcdp.c, so I think it would be a mistake to
> >> > move it to an arch-specific directory.
> >> 
> >> Ok, thanks Bjorn.  I was under the impression that stuff under dig64.org
> >> was ia64 specific ...
> >> 
> >> Would moving it to include/linux be an option?
> >
> >I sort of hate to put it in include/linux, too, but I guess
> >it's already a dumping ground for all sorts of miscellaneous
> >stuff, so one more wouldn't make it much worse.
> >
> >And I can't think of any better options.
> 
> The comments at the head of pcdp.h certainly make it look
> very ia64 specific.  Are there any newer EFI documents that
> it could point to instead of the dig64.org URLs?

The point of the PCDP is to tell the OS what console firmware
was using, so you don't need "console=" arguments.  It's
defined to be very easy to parse, so the OS can use it before
ACPI or PCI device enumeration.

So other than the URL that contains "dig64", there's nothing
ia64-specific.  Matt Tolentino (Intel) was hoping that the
PCDP or something similar would eventually be supported on
x86 as well.  But that world still has its blinders on and
assumes all the world is VGA, and seems to think that if you
want something other than VGA, by George, you ought to *have*
to use "console=".

> Linus is just as fond of EFI as he is of ACPI (i.e. not at all),
> so I don't think he'll be too happy with include/linux/pcdp.h
> If it really is the only place for this to move, then this discussion
> needs to happen on linux-kernel, not on linux-ia64.
> 
> Since PCDP is closely linked to ACPI, would include/acpi/pcdp.h
> be at all plausible?

PCDP is not linked with ACPI at all, except that it happens to
use an address structure that matches the ACPI "generic address".
We should probably just duplicate that structure definition and
kill the linux/acpi.h include.

> Or, merge the contents into include/linux/efi.h?

This would be a possibility.  But other than the fact that we
get the address of the PCDP from EFI, there's no EFI dependency
either.

The only problem with the current location is that SGI firmware
doesn't have quite enough device enumeration support for their
VGA devices, so they have to depend on the PCDP as a crutch.  So
maybe we should just leave pcdp.h alone and make SGI duplicate
what they need.
