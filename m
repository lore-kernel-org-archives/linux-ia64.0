From: Grant Grundler <iod00d@hp.com>
Date: Tue, 05 Oct 2004 16:22:01 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <20041005162201.GC18567@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C647@scsmsx401.amr.corp.intel.com> <200410050843.44265.jbarnes@engr.sgi.com>
In-Reply-To: <200410050843.44265.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Pat Gefre <pfg@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Oct 05, 2004 at 08:43:44AM -0700, Jesse Barnes wrote:
... 
> >   arch/ia64/pci/pci.c
> 
> It looks like the only non-codingstyle change here is to make pci_root_ops 
> non-static (and btw, some of the CodingStyle fixups look wrong).  If it needs 
> to be non-static, it should be declared in a header file so we don't have to 
> extern it in sn_pci_fixup_bus.

pci_root_ops should be static. It's only intended for ACPI.
Maybe rename pci_root_ops to "acpi_pci_ops" would make that clearer.

If SN2 platform needs hacks, then define "sn2_acpi_pci_ops" someplace
in the SN2 specific source code. In this case, SN2 will also 
need to continue to NOT use pci_acpi_scan_root() and define it's
own discovery. When SN2 firmware can support pci_acpi_scan_root(),
then it would make sense to drop the SN2 specific PCI discovery and pci_ops.
And both can co-exist - SN2 code can check which version of firmware
is installed and invoke ia64 ACPI support if that is known to work.

If SN2 needs something defined in the ACPI spec but missing from ia64
ACPI support, add the missing bits to arch/ia64/pci/pci.c.
It just shouldn't interfere with current use.

hth,
grant
