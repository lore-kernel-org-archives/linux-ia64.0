From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 12 Mar 2015 12:23:26 +0000
Subject: Re: [PATCH v6 08/30] PCI: Introduce pci_host_assign_domain_nr() to assign domain
Message-Id: <5501853E.7050009@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com> <1425868467-9667-9-git-send-email-wangyijing@huawei.com> <20150312013918.GC10949@google.com>
In-Reply-To: <20150312013918.GC10949@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>> index 8b3d245..2b1b998 100644
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -1327,11 +1327,15 @@ static inline int pci_domain_nr(struct pci_bus *bus)
>>  	return bus->domain_nr;
>>  }
>>  void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent);
>> +void pci_host_assign_domain_nr(struct pci_host_bridge *host);
> 
> I do not think this needs to be in include/linux/pci.h.  It's called only
> from drivers/pci/host-bridge.c, so at most, it needs to be in
> drivers/pci/pci.h.
> 
> Better still would be if the definition could be moved from
> drivers/pci/pci.c to drivers/pci/host-bridge.c so we wouldn't need anything
> in a header file at all.

This is a good idea, thanks.

> 
>>  #else
>>  static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
>>  					struct device *parent)
>>  {
>>  }
>> +static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
>> +{
>> +}
>>  #endif
>>  
>>  /* some architectures require additional setup to direct VGA traffic */
>> -- 
>> 1.7.1
>>
> 
> .
> 


-- 
Thanks!
Yijing

