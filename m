From: Pat Gefre <pfg@sgi.com>
Date: Tue, 03 Feb 2004 22:35:26 +0000
Subject: PCI question
Message-Id: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



The usage of pci_dev.sysdata is a bit confusing to me. I had initially
thought that this was available for any system specific use,  but then
in pcibios_fixup_device_resources() it is specifically cast as a struct
pci_controller *:

#define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)

void __init
pcibios_fixup_device_resources (struct pci_dev *dev, struct pci_bus *bus)
{
   struct pci_controller *controller = PCI_CONTROLLER(dev);

In this funtion  the pci_controller elements 'window[]' and 'windows'
are also used.  This implies to me that these fields must be maintained
in any system specific structure ? i.e.

struct my_sysdata_struct {
   struct pci_controller dummy;
   /* my stuff would go here */
   struct my_real_sysdata_stuff;
};

Yet I don't see where anyone else is doing the above. Am I missing
something obvious ??

Thanks,
-- Pat

