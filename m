From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 12 Mar 2015 13:14:45 +0000
Subject: Re: [PATCH v6 12/30] PCI: Introduce pci_host_bridge_ops to support host specific operations
Message-Id: <55019145.2060504@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com> <1425868467-9667-13-git-send-email-wangyijing@huawei.com> <20150312032341.GE10949@google.com>
In-Reply-To: <20150312032341.GE10949@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>>  void pci_free_host_bridge(struct pci_host_bridge *host);
>>  #endif /* DRIVERS_PCI_H */
>> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
>> index c8e074d..59d9be3 100644
>> --- a/drivers/pci/probe.c
>> +++ b/drivers/pci/probe.c
>> @@ -1889,6 +1889,8 @@ static struct pci_bus *__pci_create_root_bus(
>>  
>>  	bridge->bus = b;
>>  	b->bridge = get_device(&bridge->dev);
>> +	if (bridge->ops && bridge->ops->set_root_bus_speed)
>> +		bridge->ops->set_root_bus_speed(bridge);
> 
> Before this patch, can you do this:
> 
>   - Rename the powerpc pcibios_root_bridge_prepare() to
>     pcibios_set_root_bus_speed() and add a call to it here
> 
>   - Move the pcibios_root_bridge_prepare() call to pci_create_host_bridge()
> 
> Then this patch will make a lot more sense because it will look like this,
> with the host bridge ops call right next to the matching pcibios call:
> 
>   +	if (host->ops && host->ops->prepare) {
>   +		error = host->ops->prepare(host);
>   +		...
>   +	}
> 	pcibios_root_bridge_prepare(...);
> 
>   +	if (bridge->ops && bridge->ops->set_root_bus_speed)
>   +		bridge->ops->set_root_bus_speed(bridge);
> 	pcibios_set_root_bus_speed(...);

OK, will update.

> 
>>  	error = pcibios_root_bridge_prepare(bridge);
>>  	if (error)
>>  		goto err_out;
>> @@ -1954,7 +1956,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, u32 db,
>>  {
>>  	struct pci_host_bridge *host;
>>  
>> -	host = pci_create_host_bridge(parent, db, resources, sysdata);
>> +	host = pci_create_host_bridge(parent, db, resources, sysdata, NULL);
>>  	if (!host)
>>  		return NULL;
>>  
>> @@ -2051,10 +2053,13 @@ static struct pci_bus *__pci_scan_root_bus(
>>  		pci_bus_insert_busn_res(b, b->number, 255);
>>  	}
>>  
>> -	max = pci_scan_child_bus(b);
>> -
>> -	if (!found)
>> -		pci_bus_update_busn_res_end(b, max);
>> +	if (host->ops && host->ops->scan_bus) {
>> +		host->ops->scan_bus(host);
>> +	} else {
>> +		max = pci_scan_child_bus(b);
>> +		if (!found)
>> +			pci_bus_update_busn_res_end(b, max);
>> +	}
> 
> I think host->ops->scan_bus() should have the same prototype as
> pci_scan_child_bus(), and it should return max, and you should do the same
> busn update as when you call pci_scan_child_bus().  So the code would look
> like this:
> 
>     if (host->ops && host->ops->scan_bus)
> 	max = host->ops->scan_bus(b);
>     else
> 	max = pci_scan_child_bus(b);
> 
>     if (!found)
> 	pci_bus_update_busn_res_end(b, max);
> 

OK, I will try to change the of scan_bus(), and make it return the max bus number like pci_scan_child_bus().

>>  
>>  	return b;
>>  }
>> @@ -2064,7 +2069,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, u32 db,
>>  {
>>  	struct pci_host_bridge *host;
>>  
>> -	host = pci_create_host_bridge(parent, db, resources, sysdata);
>> +	host = pci_create_host_bridge(parent, db, resources, sysdata, NULL);
>>  	if (!host)
>>  		return NULL;
>>  
>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>> index b621f5b..e9922b1 100644
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -400,6 +400,13 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
>>  	return (pdev->error_state != pci_channel_io_normal);
>>  }
>>  
>> +struct pci_host_bridge;
>> +struct pci_host_bridge_ops {
>> +	void (*set_root_bus_speed)(struct pci_host_bridge *host);
>> +	int (*prepare)(struct pci_host_bridge *host);
>> +	void (*scan_bus)(struct pci_host_bridge *);
> 
> Needs an argument name to match the style of the other ops.

Sorry, I missed it, will add it, thanks.


> 
>> +};
>> +
>>  struct pci_host_bridge {
>>  	u16	domain;
>>  	u16 busnum;
>> @@ -407,6 +414,7 @@ struct pci_host_bridge {
>>  	struct pci_bus *bus;		/* root bus */
>>  	struct list_head windows;	/* resource_entry */
>>  	struct list_head list;
>> +	struct pci_host_bridge_ops *ops;
>>  	void (*release_fn)(struct pci_host_bridge *);
>>  	void *release_data;
>>  };
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

