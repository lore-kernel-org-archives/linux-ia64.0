From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 03 Mar 2015 08:49:46 +0000
Subject: Re: [PATCH v4 20/30] PCI/sparc: Use pci_scan_root_bridge() for simplicity
Message-Id: <54F575AA.6050409@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com> <1424938344-4017-21-git-send-email-wangyijing@huawei.com> <20150303031059.GJ11978@google.com>
In-Reply-To: <20150303031059.GJ11978@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, sparclinux@vger.kernel.org

>> -	pci_of_scan_bus(pbm, node, bus);
>> -	pci_bus_add_devices(bus);
>> -	pci_bus_register_of_sysfs(bus);
>> +	pci_bus_add_devices(host->bus);
>> +	pci_bus_register_of_sysfs(host->bus);
>>  
>> -	pci_claim_bus_resources(bus);
>> +	pci_claim_bus_resources(host->bus);
> 
> Isn't this a case where pci_claim_bus_resources() should be done before
> pci_bus_add_devices()?  You didn't introduce this problem, but since you're
> fixing similar issues, seems like we should fix this one, too.  In a patch
> of its own, of course.

OK, will fix in a another patch.

> 
>>  
>> -	return bus;
>> +	return host->bus;
>>  }
>>  
>>  void pcibios_fixup_bus(struct pci_bus *pbus)
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

