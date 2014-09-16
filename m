From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 16 Sep 2014 02:08:43 +0000
Subject: Re: [PATCH v1 05/21] PCI/MSI: Introduce weak arch_find_msi_chip() to find MSI chip
Message-Id: <54179BAB.7030506@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com>	 <1409911806-10519-6-git-send-email-wangyijing@huawei.com> <1410792154.3314.7.camel@pengutronix.de>
In-Reply-To: <1410792154.3314.7.camel@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetca>

On 2014/9/15 22:42, Lucas Stach wrote:
> Am Freitag, den 05.09.2014, 18:09 +0800 schrieb Yijing Wang:
>> Introduce weak arch_find_msi_chip() to find the match msi_chip.
>> Currently, MSI chip associates pci bus to msi_chip. Because in
>> ARM platform, there may be more than one MSI controller in system.
>> Associate pci bus to msi_chip help pci device to find the match
>> msi_chip and setup MSI/MSI-X irq correctly. But in other platform,
>> like in x86. we only need one MSI chip, because all device use
>> the same MSI address/data and irq etc. So it's no need to associate
>> pci bus to MSI chip, just use a arch function, arch_find_msi_chip()
>> to return the MSI chip for simplicity. The default weak
>> arch_find_msi_chip() used in ARM platform, find the MSI chip
>> by pci bus.
>>
> Hm, while one weak function sounds much better than the plethora we have
> now, I wonder how much work it would be to associate the msi_chip with
> the pci bus on other arches the same way as done on ARM. This way we
> could kill this calling into arch specific functions which would make
> things a bit clearer to follow I think.

That's a heavy work to associate msi_chip with the pci_bus in all platforms,
And only in ARM platform, there are two or more different msi_chips which maybe
associate pci hostbridge or irq chip. In other platforms, only one MSI chip
exists at the same time. Another reason is I don't think associate the msi_chip
with pci bus is a good idea to make PCI device find its own msi_chip.
All PCI devices under the same PCI hostbridge should have the same msi_chip,
and now a property "msi-parent" is defined to help pci hostbridge to find its matched
msi_chip. I like to associate the msi_chip with a pci hostbridge. So we don't need to
add a lot of pcibios_add_bus() to do that.

I inspected all MSI chip drivers, and found there are two different relations between msi_chip and PCI hostbridge
1. MSI chip is a irq chip, like irq_armada_370_xp, PCI hostbridge platform device use "msi-parent" to find msi_chip by of_node.
2. MSI chip is integrated into PCI hostbridge, so msi_chip->dev is the PCI hostbridge platform device.

So long as we use PCI hostbridge platform device as the parent of PCI hostbridge, every PCI device under the hostbridge
can find the msi_chip by it.

All MSI chip drivers now except pci-mvebu have been passed the hostbridge platform dev as the parent.
pci_common_init_dev(pcie->dev, &hw);
			^
Pseudo code like:

struct msi_chip *pcibios_find_msi_chip(struct pci_dev *dev)
 {
       struct pci_bus *root;
       struct pci_host_bridge *bridge;
       struct msi_chip *chip;
       struct device_node *node, *msi_node;

       /* First we find msi_chip by the phb of_node */    <-------- MSI chip is a irq chip
       root = pci_find_root_bus(dev->bus);
       node = pcibios_get_phb_of_node(root);
       if (node) {
               msi_node = of_parse_phandle(n, "msi-parent", 0);
               of_node_put(node);
               if (msi_node)
                       return of_pci_find_msi_chip_by_node(msi_node);
       }


       /* Some msi_chip are integrated into pci hostbridge,
        * we find it by phb device pointer.
        */
       if (bridge && bridge->dev.parent) {		<-----------MSI chip is integrated into PCI hostbridge
               down_read(&pci_msi_chip_sem);
               list_for_each_entry(chip, &pci_msi_chip_list, list) {
                       if (chip->dev = bridge->dev.parent) {
                               up_read(pci_msi_chip_sem);
                               return chip;
                       }
                }
               up_read(&pci_msi_chip_sem);
        }


        return NULL;
 }

Thanks!
Yijing.


> 
> Regards,
> Lucas
> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> ---
>>  drivers/pci/msi.c |    7 ++++++-
>>  1 files changed, 6 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
>> index a77e7f7..539c11d 100644
>> --- a/drivers/pci/msi.c
>> +++ b/drivers/pci/msi.c
>> @@ -29,9 +29,14 @@ static int pci_msi_enable = 1;
>>  
>>  /* Arch hooks */
>>  
>> +struct msi_chip * __weak arch_find_msi_chip(struct pci_dev *dev)
>> +{
>> +	return dev->bus->msi;
>> +}
>> +
>>  int __weak arch_setup_msi_irq(struct pci_dev *dev, struct msi_desc *desc)
>>  {
>> -	struct msi_chip *chip = dev->bus->msi;
>> +	struct msi_chip *chip = arch_find_msi_chip(dev);
>>  	int err;
>>  
>>  	if (!chip || !chip->setup_irq)
> 


-- 
Thanks!
Yijing

