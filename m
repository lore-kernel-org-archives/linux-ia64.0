From: Grant Grundler <iod00d@hp.com>
Date: Tue, 05 Oct 2004 19:10:08 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <20041005191008.GG18567@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C647@scsmsx401.amr.corp.intel.com> <200410050843.44265.jbarnes@engr.sgi.com> <20041005162201.GC18567@cup.hp.com> <20041005174558.GZ16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041005174558.GZ16153@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Pat Gefre <pfg@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Oct 05, 2004 at 06:45:58PM +0100, Matthew Wilcox wrote:
> On Tue, Oct 05, 2004 at 09:22:01AM -0700, Grant Grundler wrote:
> > pci_root_ops should be static. It's only intended for ACPI.
> 
> What I had intended when I wrote this code was that platforms that didn't
> want to use the generic SAL code (and why not?  It doesn't seem like it
> should be the hardest thing in the world to move your hacks into SAL)
> was that people should override
> 
>   struct pci_raw_ops *raw_pci_ops = &pci_sal_ops;

ah ok.

> by just assigning raw_pci_ops in their own code.  I haven't looked at
> the SGI code yet, but this is how arch/i386/pci/direct.c (for example)
> works.
> 
> > Maybe rename pci_root_ops to "acpi_pci_ops" would make that clearer.
> 
> No.  Don't rename it to anything ACPI specific.  It isn't.

I understand raw_pci_ops is not ACPI specific.
But pci_root_ops is only used by pci_acpi_scan_root().

grundler@gsyprf3:/usr/src/linux-2.6.8.1$ fgrep pci_acpi_scan_root include/*/*
include/acpi/acpi_drivers.h:struct pci_bus *pci_acpi_scan_root(struct acpi_device *device, int domain, int bus);

and

./drivers/acpi/pci_root.c:      root->bus = pci_acpi_scan_root(device, root->id.segment, root->id.bus);

The rename still seems appropriate to me.

thanks,
grant
