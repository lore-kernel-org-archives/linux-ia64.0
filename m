From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 13 Mar 2015 03:19:12 +0000
Subject: Re: [PATCH v6 06/30] PCI: Combine PCI domain and bus number in u32 arg
Message-Id: <55025730.40504@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com> <1425868467-9667-7-git-send-email-wangyijing@huawei.com> <20150312012946.GA10949@google.com> <55018330.5050002@huawei.com> <20150312194927.GC7346@google.com>
In-Reply-To: <20150312194927.GC7346@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> struct pci_scan_info {
>> 	int bus;
>> 	struct device *parent;
>> 	struct pci_ops *ops;
>> 	void *sysdata;
>> 	struct list_head *resource;
>> 	int domain;
>> 	struct pci_host_bridge_ops;
>> }
>>
>> Do you like this one or keep it like now ?
>>
>> pci_scan_root_bus(struct device *parent, int domain, int bus,
>> 		struct pci_ops *ops, void *sysdata, struct list_head *resources, struct pci_host_bridge_ops *ops)
> 
> I don't think reducing the number of arguments is a good argument for
> squashing some of them together.
> 
> I don't really want to add a structure like that because it adds management
> complexity for all the callers because it contains per-bridge things (bus,
> parent, domain, resource, sysdata).  Things like struct pci_ops and struct
> pci_host_bridge_ops are much simpler because drivers can statically
> allocate a single copy and use it for multiple devices.
> 
> I think it might make sense to put the struct pci_ops pointer inside struct
> pci_host_bridge_ops.  That would get rid of one of the arguments.
> 
> You might also be able to get rid of the "bus" argument, since the caller
> should be passing an IORESOURCE_BUS resource in the resource list, and
> "bus" should be the same as res->start.

I think this make sense, I will try to find a better solution.

Thanks!
Yijing.

> 
> Bjorn
> 
> .
> 


-- 
Thanks!
Yijing

