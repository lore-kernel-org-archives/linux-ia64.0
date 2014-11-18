From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 18 Nov 2014 12:41:33 +0000
Subject: Re: [RFC PATCH 07/16] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <546B3E7D.4030800@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1936415.emTbbPeHqx@wuerfel> <546B3124.7070206@huawei.com> <2911754.xsk2IUfQFO@wuerfel>
In-Reply-To: <2911754.xsk2IUfQFO@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linuxppc-dev@lists.ozlabs.org, Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, Suravee.Suthikulpanit@amd.com, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org

>>>> We need, some platforms pass NULL pointer as host bridge parent.
>>>
>>> But those don't have to use the new pci_create_host_bridge() function,
>>> right?
>>
>> As I mentioned in another reply, I hope all pci host drivers could use
>> pci_create_host_bridge(), keep different PCI scan interfaces in PCI core
>> make things become complex.
> 
> Doing this for all platforms that have PCI support would be a lot of
> work though, I think it's better to focus on having a the best interface
> for the majority of users.

Yes.

> 
> 	Arnd
> 
> .
> 


-- 
Thanks!
Yijing

