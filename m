From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 20 Nov 2014 02:00:41 +0000
Subject: Re: [RFC PATCH 07/16] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <546D4B49.6020408@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1416219710-26088-8-git-send-email-wangyijing@huawei.com> <2507218.mHliopJb05@wuerfel> <546B041A.4060403@huawei.com> <20141118144819.GK12037@e106497-lin.cambridge.arm.com> <546BFF74.4030101@huawei.com> <20141119162914.GB9162@bart.dudau.co.uk>
In-Reply-To: <20141119162914.GB9162@bart.dudau.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Liviu Dudau <liviu@dudau.co.uk>
Cc: Liviu Dudau <Liviu.Dudau@arm.com>, Arnd Bergmann <arnd@arndb.de>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Bjorn Helgaas <bhelgaas@google.com>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "huxinwei@huawei.com" <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

>>> Something like this:
>>>
>>> struct pci_controller {
>>> 	struct pci_host_bridge bridge;
>>> 	/* private host bridge data here */
>>> 	.....
>>> };
>>>
>>> #define PCI_CONTROLLER(bus)	({
>>> 	struct pci_host_bridge *hb = to_pci_host_bridge(bus->bridge); \
>>> 	container_of(hb, struct pci_controller, bridge); })
>>>
>>>
>>> Then we can retrieve the host bridge structure from everywhere we have a device.
>>
>> Hi Liviu, it looks good to me, because this change will involve lots platforms,
>> I would think more about it. Thanks for your suggestion very much! :)
> 
> Given that I also look at this area maybe we should join forces and divide the problem?

That's better, we could cooperate to do this. :)

> 
> Best regards,
> Liviu
> 
>>
>>
>> Thanks!
>> Yijing.
>>
>>>
>>> Best regards,
>>> Liviu
>>>
>>>>
>>>>>
>>>>>> +	host = kzalloc(sizeof(*host), GFP_KERNEL);
>>>>>> +	if (!host)
>>>>>> +		return NULL;
>>>>>
>>>>> devm_kzalloc maybe?
>>>>
>>>> I don't know much detail about devm_kzalloc(), but we have no pci host driver
>>>> here, and I found no devm_kzalloc() uses in core PCI code before.
>>>>
>>>>>
>>>>>> +	if (!resources) {
>>>>>> +		/* Use default IO/MEM/BUS resources*/
>>>>>> +		pci_add_resource(&host->windows, &ioport_resource);
>>>>>> +		pci_add_resource(&host->windows, &iomem_resource);
>>>>>> +		pci_add_resource(&host->windows, &busn_resource);
>>>>>> +	} else {
>>>>>> +		list_for_each_entry_safe(window, n, resources, list)
>>>>>> +			list_move_tail(&window->list, &host->windows);
>>>>>> +	}
>>>>>
>>>>> I think we should assume that the correct resources are passed. You
>>>>> could add a wrapper around this function to convert old platforms
>>>>> though.
>>>>
>>>> OK, I will move these code out of pci_create_host_bridge, and add a wrapper
>>>> to setup the default resources.
>>>>
>>>>>
>>>>>> +EXPORT_SYMBOL(pci_create_host_bridge);
>>>>>
>>>>> EXPORT_SYMBOL_GPL() maybe?
>>>>
>>>> OK, will update it.
>>>>
>>>>>
>>>>>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>>>>>> index 8b11b38..daa7f40 100644
>>>>>> --- a/include/linux/pci.h
>>>>>> +++ b/include/linux/pci.h
>>>>>> @@ -402,7 +402,12 @@ struct pci_host_bridge_window {
>>>>>>  struct pci_host_bridge {
>>>>>>  	struct device dev;
>>>>>>  	struct pci_bus *bus;		/* root bus */
>>>>>> +	struct list_head list;
>>>>>>  	struct list_head windows;	/* pci_host_bridge_windows */
>>>>>> +	int busnum;
>>>>>
>>>>> The busnum should already be implied through the bus resource.
>>>>
>>>> Yes, I will consider remove it and introduce a helper function to get the root bus number, thanks!
>>>>
>>>> Thanks!
>>>> Yijing.
>>>>
>>>>>
>>>>> 	Arnd
>>>>>
>>>>> .
>>>>>
>>>>
>>>>
>>>> -- 
>>>> Thanks!
>>>> Yijing
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>
>>
>>
>> -- 
>> Thanks!
>> Yijing
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
> 


-- 
Thanks!
Yijing

