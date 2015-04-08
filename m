From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 08 Apr 2015 08:14:11 +0000
Subject: Re: [PATCH v9 07/30] PCI: Add default bus resource in pci_host_bridge
Message-Id: <5524E353.8070703@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com> <1428053164-28277-9-git-send-email-wangyijing@huawei.com> <20150407222541.GK10892@google.com>
In-Reply-To: <20150407222541.GK10892@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>> index 1542df8..f189dfb 100644
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -404,6 +404,8 @@ struct pci_host_bridge {
>>  	int domain;
>>  	struct device dev;
>>  	struct pci_bus *bus;		/* root bus */
>> +	/* we use default bus resource if no bus resource provided */
>> +	struct resource busn_res;
> 
> I don't understand the need for another busn_res here.  The host bridge bus
> range should be identical to the root bus range.  Having two copies will
> confuse things.
> 
> And apparently this host->busn_res is only filled in if the arch doesn't
> provide a busn resource?
> 
> To check for conflicts between host bridges, can you iterate through the
> existing ones and check the range of their root buses?

Checking root buses is not enough, there is time gap between pci_host_bridge creation and
pci root bus creation.
E.g. A and B do pci scan sync in two cpus, A first check the buses resource, and find free
bus resource, then it go to create pci_host_bridge and scan root bus, at the same time, B
also check the buses resource, because A has not created root bus, B also think there are
free buses, this is a problem.

I agree you that having two copies is not a good idea.

For pci bus resource, we have the following request path:
1. arch supplies the busn_res or PCI core add the default bus resource(in pci_scan_bus);
2. Call pci_bus_insert_busn_res() to insert the bus resource for root bus.
3. Call get_pci_domain_busn_res() to return the per-domain bus resource.
4. Request root bus resource under per-domain bus resource.

We have the per-domain structure pci_domain_busn_res to manage the bus resources in one domain,
so what about add a bitmap to manage the free bus resource ?
In pci_create_host_bridge(), first check whether the new pci_host_bridge bus resources required
is free, if yes, we set the bitmap to occupy the bus resource at once,  then create the host bridge
and add it to the global list.

struct pci_domain_busn_res {
	struct list_head list;
	struct resource res;
	int domain_nr;
	bitmap used;
};

Another problem, I found it's unnecessary to add bus resource to pci_host_bridge->windows.
Unlike the IO and MEM resource, we never use the pci_host_bridge bus resource again after
pci enumeration. I think we could clean it up, or in some cases, when arch supplies the
bus resource, we still have the two copies.

Thanks!
Yijing.

> 
>>  	struct list_head windows;	/* resource_entry */
>>  	void (*release_fn)(struct pci_host_bridge *);
>>  	void *release_data;
>> -- 
>> 1.7.1
>>
> 
> .
> 


-- 
Thanks!
Yijing

