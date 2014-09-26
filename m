From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 26 Sep 2014 03:12:30 +0000
Subject: Re: [PATCH v2 04/22] x86/xen/MSI: Eliminate arch_msix_mask_irq() and arch_msi_mask_irq()
Message-Id: <5424D99E.2000900@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com> <1411614872-4009-5-git-send-email-wangyijing@huawei.com> <20140925143346.GF20089@laptop.dumpdata.com>
In-Reply-To: <20140925143346.GF20089@laptop.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On 2014/9/25 22:33, Konrad Rzeszutek Wilk wrote:
> On Thu, Sep 25, 2014 at 11:14:14AM +0800, Yijing Wang wrote:
>> Commit 0e4ccb150 added two __weak arch functions arch_msix_mask_irq()
>> and arch_msi_mask_irq() to fix a bug found when running xen in x86.
>> Introduced these two funcntions make MSI code complex. And mask/unmask
> 
> "These two functions made the MSI code more complex."

OK, will update, thanks.

>> is the irq actions related to interrupt controller, should not use
>> weak arch functions to override mask/unmask interfaces. This patch
> 
> I am bit baffled of what you are saying.

Sorry for my poor English. The meaning is that I think override irq_chip
mask/unmask irq is better than introduced weak functions.

>> reverted commit 0e4ccb150 and export struct irq_chip msi_chip, modify
>> msi_chip->irq_mask/irq_unmask() in xen init functions to fix this
>> bug for simplicity. Also this is preparation for using struct
>> msi_chip instead of weak arch MSI functions in all platforms.
>> Keep default_msi_mask_irq() and default_msix_mask_irq() in
>> linux/msi.h to make s390 MSI code compile happy, they wiil be removed
> 
> s/wiil/will.

Will update, thanks.

> 
>> in the later patch.
>>
>> Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> 
> I don't even remember testing it - I guess I did the earlier version.

Yes, I added your tested-by because in last version, you help to test the whole series in xen.
And I didn't change something in xen part patches in this new version.

> 
> So a couple of questions since I've totally forgotten about this:
> 
>> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
>> index 50f67a3..5f8f3af 100644
>> --- a/drivers/pci/msi.c
>> +++ b/drivers/pci/msi.c
...
>>  static void msi_set_mask_bit(struct irq_data *data, u32 flag)
>> @@ -852,7 +842,7 @@ void pci_msi_shutdown(struct pci_dev *dev)
>>  	/* Return the device with MSI unmasked as initial states */
>>  	mask = msi_mask(desc->msi_attrib.multi_cap);
>>  	/* Keep cached state to be restored */
>> -	arch_msi_mask_irq(desc, mask, ~mask);
>> +	__msi_mask_irq(desc, mask, ~mask);
> 
> If I am reading this right, it will call the old 'default_msi_mask_irq'
> which is exactly what we don't want to do under Xen. We want to call
> the NOP code.

Good catch. I missed this one, it will also be called in xen.
I need to rework this patch.

>>  
>>  	/* Restore dev->irq to its default pin-assertion irq */
>>  	dev->irq = desc->msi_attrib.default_irq;
>> @@ -950,7 +940,7 @@ void pci_msix_shutdown(struct pci_dev *dev)
>>  	/* Return the device with MSI-X masked as initial states */
>>  	list_for_each_entry(entry, &dev->msi_list, list) {
>>  		/* Keep cached states to be restored */
>> -		arch_msix_mask_irq(entry, 1);
>> +		__msix_mask_irq(entry, 1);
> 
> Ditto here.
> 
> Looking more at this code I have to retract my Reviewed-by and Tested-by
> on the whole series.

OK, because this patch still need some enhancement.

> 
> Is it possible to get a git tree for this please?

I will provide a git tree as soon as possible.

Thanks!
Yijing.

> 
>>  	}
>>  
>>  	msix_clear_and_set_ctrl(dev, PCI_MSIX_FLAGS_ENABLE, 0);
>> diff --git a/include/linux/msi.h b/include/linux/msi.h
>> index 45ef8cb..cc46a62 100644
>> --- a/include/linux/msi.h
>> +++ b/include/linux/msi.h
>> @@ -19,6 +19,8 @@ void read_msi_msg(struct msi_desc *entry, struct msi_msg *msg);
>>  void get_cached_msi_msg(struct msi_desc *entry, struct msi_msg *msg);
>>  void __write_msi_msg(struct msi_desc *entry, struct msi_msg *msg);
>>  void write_msi_msg(unsigned int irq, struct msi_msg *msg);
>> +u32 __msix_mask_irq(struct msi_desc *desc, u32 flag);
>> +u32 __msi_mask_irq(struct msi_desc *desc, u32 mask, u32 flag);
>>  
>>  struct msi_desc {
>>  	struct {
>> @@ -59,8 +61,8 @@ void arch_restore_msi_irqs(struct pci_dev *dev);
>>  
>>  void default_teardown_msi_irqs(struct pci_dev *dev);
>>  void default_restore_msi_irqs(struct pci_dev *dev);
>> -u32 default_msi_mask_irq(struct msi_desc *desc, u32 mask, u32 flag);
>> -u32 default_msix_mask_irq(struct msi_desc *desc, u32 flag);
>> +#define default_msi_mask_irq	__msi_mask_irq
>> +#define default_msix_mask_irq	__msix_mask_irq
>>  
>>  struct msi_chip {
>>  	struct module *owner;
>> -- 
>> 1.7.1
>>
> 
> .
> 


-- 
Thanks!
Yijing

