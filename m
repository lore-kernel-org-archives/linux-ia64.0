From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 18 Nov 2014 00:55:17 +0000
Subject: Re: [RFC PATCH 14/16] arm/PCI: Introduce pci_get_domain_nr()
Message-Id: <546A98F5.8080506@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1416219710-26088-15-git-send-email-wangyijing@huawei.com> <20141117120839.GA22241@e102568-lin.cambridge.arm.com>
In-Reply-To: <20141117120839.GA22241@e102568-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "huxinwei@huawei.com" <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>

>>  
>> -	bus->domain_nr = domain;
>> +void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
>> +{
>> +	bus->domain_nr = pci_get_domain_nr(parent);
>>  }
>>  #endif
> 
> This code is superseded by the last patches I sent to move the domain
> assignment to PCI core code.
> 
> http://lists.infradead.org/pipermail/linux-arm-kernel/2014-November/301220.html

OK, I will update it based the latest one.

> 
> Lorenzo
> 
> 
> .
> 


-- 
Thanks!
Yijing

