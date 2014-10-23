From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 23 Oct 2014 01:17:19 +0000
Subject: Re: [PATCH v3 24/27] IA64/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <5448571F.6030105@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com> <1413342435-7876-25-git-send-email-wangyijing@huawei.com> <20141022235345.GE4795@google.com>
In-Reply-To: <20141022235345.GE4795@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>

On 2014/10/23 7:53, Bjorn Helgaas wrote:
> On Wed, Oct 15, 2014 at 11:07:12AM +0800, Yijing Wang wrote:
>> Use MSI chip framework instead of arch MSI functions to configure
>> MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.
> 
> This needs slightly more detail.  You're using the MSI chip framework
> "instead of arch MSI functions".  Well, there are still arch-specific
> functions, i.e., arch_ia64_setup_msi_irq() and
> arch_ia64_teardown_msi_irq().
> 
> We used to have arch_setup_msi_irq() which had a weak default
> implementation, and a strong arch-specific implementation here, and you're
> replacing that model with the new "msi-ops" model.  I don't know how you
> want to write that, but it's not that you're getting rid of the
> arch-specific code; you're keeping arch-specific code but structuring it
> differently.

Hm, I will rename the msi-ops functions.

> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> ---
>>  arch/ia64/include/asm/pci.h |   10 ++++++++++
>>  arch/ia64/kernel/msi_ia64.c |   14 ++++++++++----
>>  arch/ia64/pci/pci.c         |    1 +
>>  3 files changed, 21 insertions(+), 4 deletions(-)
>>
>> diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
>> index 52af5ed..907dcba 100644
>> --- a/arch/ia64/include/asm/pci.h
>> +++ b/arch/ia64/include/asm/pci.h
>> @@ -94,6 +94,7 @@ struct pci_controller {
>>  	int segment;
>>  	int node;		/* nearest node with memory or NUMA_NO_NODE for global allocation */
>>  
>> +	struct msi_chip *msi_chip;
>>  	void *platform_data;
>>  };
>>  
>> @@ -101,6 +102,15 @@ struct pci_controller {
>>  #define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
>>  #define pci_domain_nr(busdev)    (PCI_CONTROLLER(busdev)->segment)
>>  
>> +extern struct msi_chip chip;
> 
> Please make this name more descriptive.  "chip" is way too generic for a
> global name.

OK, what about rename it to ia64_msi_chip, and rename the original static irq_chip ia64_msi_chip to
static irq_chip msi_chip like in x86.

> 
>> +static inline struct msi_chip *pci_msi_chip(struct pci_bus *bus)
>> +{
>> +	struct pci_controller *ctrl = bus->sysdata;
>> +
>> +	return ctrl->msi_chip;
>> +}
>> +
>>  extern struct pci_ops pci_root_ops;
>>  
>>  static inline int pci_proc_domain(struct pci_bus *bus)
>> diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
>> index 8c3730c..401fc98 100644
>> --- a/arch/ia64/kernel/msi_ia64.c
>> +++ b/arch/ia64/kernel/msi_ia64.c
>> @@ -112,15 +112,16 @@ static struct irq_chip ia64_msi_chip = {
>>  };
>>  
>>  
>> -int arch_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
>> +static int arch_ia64_setup_msi_irq(struct msi_chip *chip,
>> +		struct pci_dev *dev, struct msi_desc *desc)
>>  {
>>  	if (platform_setup_msi_irq)
>> -		return platform_setup_msi_irq(pdev, desc);
>> +		return platform_setup_msi_irq(dev, desc);
>>  
>> -	return ia64_setup_msi_irq(pdev, desc);
>> +	return ia64_setup_msi_irq(dev, desc);
> 
> Please don't make gratuitous changes ("pdev" -> "dev") at the same time,
> especially since the rest of the file still uses "pdev".

OK.

> 
>>  }
>>  
>> -void arch_teardown_msi_irq(unsigned int irq)
>> +static void arch_ia64_teardown_msi_irq(struct msi_chip *chip, unsigned int irq)
>>  {
>>  	if (platform_teardown_msi_irq)
>>  		return platform_teardown_msi_irq(irq);
>> @@ -128,6 +129,11 @@ void arch_teardown_msi_irq(unsigned int irq)
>>  	return ia64_teardown_msi_irq(irq);
>>  }
>>  
>> +struct msi_chip chip = {
>> +	.setup_irq = arch_ia64_setup_msi_irq,
>> +	.teardown_irq = arch_ia64_teardown_msi_irq,
>> +};
>> +
>>  #ifdef CONFIG_INTEL_IOMMU
>>  #ifdef CONFIG_SMP
>>  static int dmar_msi_set_affinity(struct irq_data *data,
>> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
>> index 291a582..299b67d 100644
>> --- a/arch/ia64/pci/pci.c
>> +++ b/arch/ia64/pci/pci.c
>> @@ -437,6 +437,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
>>  
>>  	controller->companion = device;
>>  	controller->node = acpi_get_node(device->handle);
>> +	controller->msi_chip = &chip;
>>  
>>  	info = kzalloc(sizeof(*info), GFP_KERNEL);
>>  	if (!info) {
>> -- 
>> 1.7.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> 
> .
> 


-- 
Thanks!
Yijing

