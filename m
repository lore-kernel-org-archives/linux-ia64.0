From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 15 Oct 2004 00:36:33 +0000
Subject: Re: [PATCH] Introduce PCI <-> CPU address conversion [1/2]
Message-Id: <20041015003633.GX16153@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk> <20041014125348.GA9633@infradead.org> <20041014135323.GO16153@parcelfarce.linux.theplanet.co.uk> <20041014180005.GA11954@infradead.org> <20041014180748.GS16153@parcelfarce.linux.theplanet.co.uk> <416EFFBE.7B8F702@sgi.com>
In-Reply-To: <416EFFBE.7B8F702@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Colin Ngam <cngam@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Christoph Hellwig <hch@infradead.org>, Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Oct 14, 2004 at 05:37:51PM -0500, Colin Ngam wrote:
> On SGI's Altix system, the sysdata for the device is very much different than
> the sysdata for the bus.

That's fascinating, because ia64 is one of the architectures that relies
on sysdata being the same in both the bus and the device:

#define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)

In various places, we have
        struct pci_controller *controller = PCI_CONTROLLER(dev);
and
        if (PCI_CONTROLLER(bus)->iommu)

So what the hell does Altix do?  Which sysdata can be used to get to the
pci_controller?  This seems like a horrible mistake to me.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
