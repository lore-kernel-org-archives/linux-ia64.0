From: Amit Gud <gud@eth.net>
Date: Wed, 30 Mar 2005 06:53:44 +0000
Subject: Re: [PATCH 3/91] get rid of pci_find_{device,subsys} arch/ia64
Message-Id: <424A4E34.2060402@eth.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050329122242.GA26755@infradead.org>
In-Reply-To: <20050329122242.GA26755@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg KH wrote:
> On Tue, Mar 29, 2005 at 05:50:09PM +0530, Amit Gud wrote:
> 
>>Replace pci_find_{device,subsys} with pci_get_{device,subsys}.
>>
>>
>>
>>Signed-off-by: Amit Gud <gud@eth.net>
>>
>>---
>>diff -upr orig-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c work-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c
>>--- orig-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c	2005-03-15 21:00:10.000000000 +0530
>>+++ work-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c	2005-03-24 15:29:23.539955472 +0530
>>@@ -365,8 +365,9 @@ static int __init sn_pci_init(void)
>> 	 */
>> 
>> 	while ((pci_dev >>-		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
>>+		pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
>> 		sn_pci_fixup_slot(pci_dev);
>>+		pci_dev_put(dev);
>> 	}
> 
> 
> Argh, no, this is wrong.  And I think you did this in every one of the
> patches you sent out, so please send a retraction for every one of them
> too, I don't feel like doing it...
> 
> You should not do a pci_dev_put() in a loop like this.  Please go read
> the documentation for the pci_get_device() function, it explains how to
> use it...

Here admittedly, the variable is wrong (should be pci_dev and not dev). But
I don't see why pci_dev_put() should not be used in a loop. If I know it right, pci_get_device()
finds a particular device starting from the last argument and increments the reference count and pci_dev_put just decrements it
(which if becomes zero *pci_dev->dev->kobj is kfree()d, but the orginal struct pci_dev is still there (not-NULL), so
pci_get_device can start finding the device (starting from pci_dev), from where it had left off last time).
pci_find_device() is a non-safe way of finding a device, where it finds a particluar device but doesn't bother
incrementing the reference count.

So if we are to replace pci_find_device with pci_get_device, how should we go about in this particular case, which
apparently is the case with many other places where pci_find_device is used. The way I did seemed logical to me:
find the device - accept it - work with it - jerk it off.
Am I missing out something very obvious?


AG
--
May the source be with you.
