From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Thu, 31 Oct 2002 06:55:12 +0000
Subject: [Linux-ia64] RE: [Pcihpd-discuss] PCI hotplug broken on IA64
Message-Id: <marc-linux-ia64-105590709805307@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Wed, Oct 30, 2002 at 09:52:44PM -0800, Greg KH wrote:
> > On Wed, Oct 30, 2002 at 08:49:24PM -0800, Lee, Jung-Ik wrote:
> > > 
> > > > I don't think the current way of accessing PCI 
> configuration space
> > > > with temporary pci_dev and pci_bus is definitive answer but we
> > > > are depending on it now.
> > > > Could someone enlighten me?
> > > > Any ideas?
> > > 
> > > All pci config space access before pci_dev/pci_bus are built
> > > should be able to make direct call to
> > > pci_config_{read|write}(seg, bus, dev, func, offset, size, value).
> > 
> > Um, where are these functions exported?  I don't see them in the 2.4
> > tree :)
> 
> Ok, just to make myself clear, yes I know the functions are there, but
> no, they are not explicitly exported, or supported on all archs.
> 

Hotplug drivers in drivers/hotplug are for Intel architecture,
and the above APIs are available as global for both i386 and ia64.
Actually, acpi driver uses them for ACPI/PCI population before 
pci_dev is built for the hierarchy.

thanks,
J.I.



