From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Date: Thu, 14 Oct 2004 14:27:04 +0000
Subject: Re: [PATCH] Introduce PCI <-> CPU address conversion [1/2]
Message-Id: <20041014182704.A13971@jurassic.park.msu.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk>; from matthew@wil.cx on Thu, Oct 14, 2004 at 01:47:37PM +0100
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Oct 14, 2004 at 01:47:37PM +0100, Matthew Wilcox wrote:
> Some machines have a different address space on the PCI bus from the
> CPU's bus.  This is currently fixed up in pcibios_fixup_bus().  However,
> this is not called for hotplug devices.  Calling pcibios_fixup_bus() when
> a device is hotplugged onto a bus is also wrong as it would attempt to
> fixup devices that have already been fixed up with potentially horrific
> consequences.

This logic makes sense only if you have sort of firmware which
properly initializes the hotplug devices, so I think that the fixup
should belong in that particular hotplug driver (or architecture).
In general case the newly inserted device will have 0s in the BARs,
so there is no point for bus to CPU conversion. You have to use
pci_assign_resource() which does know about different address
spaces.

> This patch teaches the generic PCI layer that there may be different
> address spaces, and converts from bus views to cpu views when reading
> from BARs.  Some drivers (eg sym2, acpiphp) need to go back the other
> way, so it also introduces the inverse operation.

This one already exists - pcibios_resource_to_bus().

Ivan.
