From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 03 Mar 2015 01:12:23 +0000
Subject: Re: [PATCH v4 01/30] PCI: Rip out pci_bus_add_devices() from pci_scan_bus()
Message-Id: <54F50A77.7040703@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com> <1424938344-4017-2-git-send-email-wangyijing@huawei.com> <20150302234147.GA11978@google.com>
In-Reply-To: <20150302234147.GA11978@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, sparclinux@vger.kernel.org

>>  	pbm->pci_bus = pci_scan_bus(pbm->pci_first_busno, &pcic_ops, pbm);
>> +	if (pbm->pci_bus)
>> +		pci_bus_add_devices(pbm->pci_bus);
>>  #if 0 /* deadwood transplanted from sparc64 */
>>  	pci_fill_in_pbm_cookies(pbm->pci_bus, pbm, pbm->prom_node);
>>  	pci_record_assignments(pbm, pbm->pci_bus);
> 
> This is correct, but it should look like this instead:
> 
>     if (!pbm->pci_bus)
>       return;
>   #if 0 /* deadwood ... */
>   ...
>   #endif
>     pci_bus_add_devices(pbm->pci_bus);
>   }
> 
> That way the mainline code is the normal path, and pci_bus_add_devices() is
> in the correct place even if the "deadwood" code is resurrected.
> 

Yes, you are right, thanks!

> 
>> diff --git a/arch/unicore32/kernel/pci.c b/arch/unicore32/kernel/pci.c
>> index 374a055..3d82024 100644
>> --- a/arch/unicore32/kernel/pci.c
>> +++ b/arch/unicore32/kernel/pci.c
>> @@ -266,17 +266,12 @@ static int __init pci_common_init(void)
>>  	pci_fixup_irqs(pci_common_swizzle, pci_puv3_map_irq);
>>  
>>  	if (!pci_has_flag(PCI_PROBE_ONLY)) {
>> -		/*
>> -		 * Size the bridge windows.
>> -		 */
>> +		/* Size the bridge windows. */
>>  		pci_bus_size_bridges(puv3_bus);
>> -
>> -		/*
>> -		 * Assign resources.
>> -		 */
>> +		/* Assign resources. */
>>  		pci_bus_assign_resources(puv3_bus);
>>  	}
>> -
>> +	pci_bus_add_devices(puv3_bus);
>>  	return 0;
>>  }
>>  subsys_initcall(pci_common_init);
>> diff --git a/drivers/pci/hotplug/ibmphp_core.c b/drivers/pci/hotplug/ibmphp_core.c
>> index 96c5c72..86e3bfd 100644
>> --- a/drivers/pci/hotplug/ibmphp_core.c
>> +++ b/drivers/pci/hotplug/ibmphp_core.c
>> @@ -738,7 +738,7 @@ static void ibm_unconfigure_device(struct pci_func *func)
>>   */
>>  static u8 bus_structure_fixup(u8 busno)
>>  {
>> -	struct pci_bus *bus;
>> +	struct pci_bus *bus, *b;
>>  	struct pci_dev *dev;
>>  	u16 l;
>>  
>> @@ -765,7 +765,9 @@ static u8 bus_structure_fixup(u8 busno)
>>  					(l != 0x0000) && (l != 0xffff)) {
>>  			debug("%s - Inside bus_structure_fixup()\n",
>>  							__func__);
>> -			pci_scan_bus(busno, ibmphp_pci_bus->ops, NULL);
>> +			b = pci_scan_bus(busno, ibmphp_pci_bus->ops, NULL);
>> +			if (b)
>> +				pci_bus_add_devices(b);
> 
> Use this:
> 
>     if (!b)
>       continue;
>     pci_bus_add_devices(b);
> 
> for the same reason as above.


Will update, thanks!

Thanks!
Yijing.

> 
>>  			break;
>>  		}
>>  	}
>> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
>> index 8d2f400..88604f2 100644
>> --- a/drivers/pci/probe.c
>> +++ b/drivers/pci/probe.c
>> @@ -2123,7 +2123,6 @@ struct pci_bus *pci_scan_bus(int bus, struct pci_ops *ops,
>>  	b = pci_create_root_bus(NULL, bus, ops, sysdata, &resources);
>>  	if (b) {
>>  		pci_scan_child_bus(b);
>> -		pci_bus_add_devices(b);
>>  	} else {
>>  		pci_free_resource_list(&resources);
>>  	}
>> -- 
>> 1.7.1
>>
> 
> .
> 


-- 
Thanks!
Yijing

