From: Patrick Gefre <pfg@sgi.com>
Date: Thu, 05 Feb 2004 17:11:09 +0000
Subject: Re: PCI question
Message-Id: <4022792D.2070309@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
In-Reply-To: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg KH wrote:

>On Tue, Feb 03, 2004 at 04:27:09PM -0600, Patrick Gefre wrote:
>  
>
>>The usage of pci_dev.sysdata is a bit confusing to me. I had initially
>>thought that this was available for any system specific use,  but then
>>in pcibios_fixup_device_resources() it is specifically cast as a
>>struct pci_controller *:
>>
>>#define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
>>
>>void __init
>>pcibios_fixup_device_resources (struct pci_dev *dev, struct pci_bus *bus)
>>    
>>
>
>What kernel are you looking at?  I don't see either of the above in the
>2.6.2 kernel tree.
>
>thanks,
>
>greg k-h
>  
>
In my bitkeeper tree : (bk parent: http://linux.bkbits.net/linux-2.5)

include/asm-ia64/pci.h:
#define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)

arch/ia64/pci/pci.c:
void __init
pcibios_fixup_device_resources (struct pci_dev *dev, struct pci_bus *bus)

Is there some ia64 patch I'm missing that removes this ?

-- Pat


