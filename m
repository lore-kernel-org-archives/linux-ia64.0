From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 08 Apr 2015 08:30:39 +0000
Subject: Re: [PATCH v9 23/30] PCI/mvebu: Use pci_common_init_dev() to simplify code
Message-Id: <5524E72F.1050500@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com> <1428053164-28277-25-git-send-email-wangyijing@huawei.com> <5524E1F9.6030700@free-electrons.com>
In-Reply-To: <5524E1F9.6030700@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-m68k@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org, dja@axtens.net, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Jiang Liu <jiang.liu@linux.intel.com>, linux-alpha@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

> 2 months ago, Thomas Petazzoni was concerned about the removal of
> mvebu_pcie_scan_bus(). So I dig the archives of the discussion
> surrounding the pcie-mvebu drive. I found that the main purpose
> of using this function was to allow to pass "struct device *" pointer.
> 
> Thanks to the introduction of pci_common_init_dev it was not needed
> anymore. Actually we should have done this change when this function
> had been introduced. So for the point of view of the code it's fine.
> Then I tested your full series on Armada XP, Armada 375 and Armada 38x
> SoCs, and I didn't saw any regression. So you can add my:
> 
> Reviewed-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Tested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Great, thanks very much!

Thanks!
Yijing.


> 
> 
> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>> CC: Jason Cooper <jason@lakedaemon.net>
>> ---
>>  drivers/pci/host/pci-mvebu.c |   18 +-----------------
>>  1 files changed, 1 insertions(+), 17 deletions(-)
>>
>> diff --git a/drivers/pci/host/pci-mvebu.c b/drivers/pci/host/pci-mvebu.c
>> index 0cfc494..d5a2b70 100644
>> --- a/drivers/pci/host/pci-mvebu.c
>> +++ b/drivers/pci/host/pci-mvebu.c
>> @@ -750,21 +750,6 @@ static int mvebu_pcie_setup(int nr, struct pci_sys_data *sys)
>>  	return 1;
>>  }
>>  
>> -static struct pci_bus *mvebu_pcie_scan_bus(int nr, struct pci_sys_data *sys)
>> -{
>> -	struct mvebu_pcie *pcie = sys_to_pcie(sys);
>> -	struct pci_bus *bus;
>> -
>> -	bus = pci_create_root_bus(&pcie->pdev->dev, -1, sys->busnr,
>> -				  &mvebu_pcie_ops, sys, &sys->resources);
>> -	if (!bus)
>> -		return NULL;
>> -
>> -	pci_scan_child_bus(bus);
>> -
>> -	return bus;
>> -}
>> -
>>  static resource_size_t mvebu_pcie_align_resource(struct pci_dev *dev,
>>  						 const struct resource *res,
>>  						 resource_size_t start,
>> @@ -808,12 +793,11 @@ static void mvebu_pcie_enable(struct mvebu_pcie *pcie)
>>  	hw.nr_controllers = 1;
>>  	hw.private_data   = (void **)&pcie;
>>  	hw.setup          = mvebu_pcie_setup;
>> -	hw.scan           = mvebu_pcie_scan_bus;
>>  	hw.map_irq        = of_irq_parse_and_map_pci;
>>  	hw.ops            = &mvebu_pcie_ops;
>>  	hw.align_resource = mvebu_pcie_align_resource;
>>  
>> -	pci_common_init(&hw);
>> +	pci_common_init_dev(&pcie->pdev->dev, &hw);
>>  }
>>  
>>  /*
>>
> 
> 


-- 
Thanks!
Yijing

