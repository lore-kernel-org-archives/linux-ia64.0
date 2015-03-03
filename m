From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 03 Mar 2015 08:08:29 +0000
Subject: Re: [PATCH v4 12/30] PCI: Introduce pci_host_bridge_ops to support host specific operations
Message-Id: <54F56BFD.2060008@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com> <1424938344-4017-13-git-send-email-wangyijing@huawei.com> <20150303025020.GF11978@google.com>
In-Reply-To: <20150303025020.GF11978@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> +	if (host->ops && host->ops->phb_prepare) {
>> +		error = host->ops->phb_prepare(host);
>> +		if(error) {
> 
> Whitespace error.

Will fix.

> 
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -400,6 +400,13 @@ static inline int pci_channel_offline(struct pci_dev *pdev)
>>  	return (pdev->error_state != pci_channel_io_normal);
>>  }
>>  
>> +struct pci_host_bridge;
>> +struct pci_host_bridge_ops {
>> +	void (*phb_set_root_bus_speed)(struct pci_host_bridge *host);
>> +	int (*phb_prepare)(struct pci_host_bridge *host);
>> +	void (*phb_of_scan_bus)(struct pci_host_bridge *);
> 
> These function pointers don't need a "phb_" prefix.

Will update them.

> 
> .
> 


-- 
Thanks!
Yijing

