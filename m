From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 18 May 2005 11:42:56 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428B2A40.4010103@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rolf Eike Beer wrote:

> 
> 
> 
>>+	if (rc = PCI_SLOT_ALREADY_UP) {
>>+		dev_dbg(slot->pci_bus->self, "is already active\n");
>>+		return -EPERM;
>>+	}
> 
> 
> IIRC most other drivers handle this case as success. Greg, your opinion?
> 

Other drivers handle this by returning 1.  I changed the return value to 1.

> 
> 
>>+		dev_dbg(slot->pci_bus->self, "Slot %s already inactive\n");
>>+		return -ENODEV;
>>+	}
> 
> 
> Again this might better be a success.
> 

Other drivers handle this by returning 1.  I changed the return value to 1.

>>+	num_funcs = pci_scan_slot(slot->pci_bus, PCI_DEVFN(slot->device_num+1,
> 
> 
> Add spaces before and after '+'. I don't feel good with this "+1" at all, this 
> is some kind of strange.
> 

Aside from being used in the above calculation, the slot->device_num is also a 
bitmask.  The 0th bit corresponds to the first device that is active/inactive on 
a slot.

In the calculation above, the slot we're scanning is PCI_DEVFN(1,0) -- the first 
device in the slot.

I could flip things around and use slot->device_num to a one-based calculation, 
but that leads to more "device_num - 1" statements than "device_num" statements 
in the code.

P.
