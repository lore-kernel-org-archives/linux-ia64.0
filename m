From: Grant Grundler <iod00d@hp.com>
Date: Wed, 06 Oct 2004 20:48:32 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <20041006204832.GB26459@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com> <41644301.9EC028B3@sgi.com> <20041006195424.GF25773@cup.hp.com> <200410061327.28572.jbarnes@engr.sgi.com>
In-Reply-To: <200410061327.28572.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Grant Grundler <iod00d@hp.com>, Colin Ngam <cngam@sgi.com>, Patrick Gefre <pfg@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Oct 06, 2004 at 01:27:28PM -0700, Jesse Barnes wrote:
> Though now what's there seems awfully redundant, wouldn't you say?

Yes - but we are using code which *requires* the arch define raw_pci_ops.
See drivers/acpi/osl.c:acpi_os_initialize()

#ifdef CONFIG_ACPI_PCI
	if (!raw_pci_ops) {
		printk(KERN_ERR PREFIX "Access to PCI configuration space unavailable\n");
		return AE_NULL_ENTRY;
	}
#endif


> Just 
> allowing direct access to pci_root_ops is a much simpler approach and gets 
> rid of a bunch of extra, unneeded code (i.e. closer to Pat's original 
> version).

Agreed. I'm not real clear on why drivers/acpi didn't do that.
But apperently ACPI supports many methods to PCI or PCI-Like (can you
guess I'm not clear on this?) config space. raw_pci_ops supports
multiple methods in i386. ia64 only happens to use one so far.
It seems right for SN2 to use this mechanism if it needs a different
method.

Willy tried to explain this to me yesterday and I thought I understood
most of it...apperently that was a transient moment of clarity. :^/

...
> > Can you quote the bit of the patch which implements "if the bus does not
> > exist" check?
> > I can't find it.
> 
> In the current code it's:
> 
>  for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
>   if (pci_bus_to_vertex(i))
>    pci_scan_bus(i, &sn_pci_ops, controller);
>
> which causes the next loop to only fixup existing busses. But I don't see it 
> in the new code.

Ok. I'm glad it's not just me 'cuz I'm having a bad day.

thanks,
grant
