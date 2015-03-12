From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 12 Mar 2015 13:44:07 +0000
Subject: Re: [PATCH v6 09/30] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <55019827.2060803@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com> <1425868467-9667-10-git-send-email-wangyijing@huawei.com> <20150312035202.GL10949@google.com>
In-Reply-To: <20150312035202.GL10949@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> +	host = kzalloc(sizeof(*host), GFP_KERNEL);
>> +	if (!host)
>> +		return NULL;
>> +
>> +	host->busnum = bus;
>> +	host->domain = domain;
>> +	/* If support CONFIG_PCI_DOMAINS_GENERIC, use
>> +	 * pci_host_assign_domain_nr() to assign domain
>> +	 * number instead PCI_DOMAIN(db).
>> +	 */
> 
> Follow the normal Linux comment style:
> 
> 	host->domain = domain;
> 
> 	/*
> 	 * If we support ...
> 	 */

OK.

> 
>> +	pci_host_assign_domain_nr(host);
>> +
...
>>  
>> +struct pci_host_bridge *pci_create_host_bridge(
>> +		struct device *parent, u32 dombus, struct list_head *resources);
>> +void pci_free_host_bridge(struct pci_host_bridge *host);
> 
> A later patch adds another declaration and a blank line here.  If you want
> the blank line, add it here, when you're adding the first declarations in
> this section.

OK.

> 
>>  #endif /* DRIVERS_PCI_H */
>> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
>> index 3d6befd..27ec612 100644
>> --- a/drivers/pci/probe.c
>> +++ b/drivers/pci/probe.c
>> @@ -503,31 +503,6 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
>>  	return b;
>>  }
...
>>  struct pci_host_bridge {
>>  	u16	domain;
>> +	u16 busnum;
> 
> Why do we need this?  host_bridge->bus->number and
> host_bridge->bus->busn_res.start both already contain the same information,
> and I hate to add a third place.  I know pci_create_host_bridge() doesn't
> have a struct pci_bus at the point where you initialize busnum, but it does
> have the resource list, which contains the bus number range.

Hmm, I will try to remove it, I put it here because when call pci_create_root_bus(),
I could only pass the pci_host_bridge_ops, don't need to provide the bus number,
pci_scan_root_bus() may lack the bus number resource at that time.
But I think fix it is not a hard job, I will rework it, thanks.


> 
>>  	struct device dev;
>>  	struct pci_bus *bus;		/* root bus */
>>  	struct list_head windows;	/* resource_entry */
>> -- 
>> 1.7.1
>>
> 
> .
> 


-- 
Thanks!
Yijing

