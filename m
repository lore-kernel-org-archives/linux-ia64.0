From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 08 Apr 2015 01:18:48 +0000
Subject: Re: [PATCH v9 06/30] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <552481F8.1090308@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com> <1428053164-28277-8-git-send-email-wangyijing@huawei.com> <20150407213839.GJ10892@google.com>
In-Reply-To: <20150407213839.GJ10892@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> +	/*
>> +	 * If support CONFIG_PCI_DOMAINS_GENERIC, use
>> +	 * pci_host_assign_domain_nr() to update domain
>> +	 * number.
>> +	 */
>> +	host->domain = domain;
>> +	pci_host_assign_domain_nr(host);
> 
> I think it's a bit confusing that there's another "host->domain ="
> assignment buried inside pci_host_assign_domain_nr(), so the first
> assignment is overwritten when CONFIG_PCI_DOMAINS_GENERIC is set.
> 
> Can you do something like this instead:
> 
>   int pci_host_assign_domain_nr(struct pci_host_bridge *host, int domain)
>   {
>   #ifdef CONFIG_PCI_DOMAINS_GENERIC
>     host->domain = pci_assign_domain_nr(host->dev.parent);
>   #else
>     host->domain = domain;
>   #endif
>   }
> 
> Then the alternatives (CONFIG_PCI_DOMAINS_GENERIC=y and
> CONFIG_PCI_DOMAINS_GENERIC being unset) are close together and right at the
> #ifdef CONFIG_PCI_DOMAINS_GENERIC, so no extra comments are needed.

OK, I would use #ifdef to update pci_host_assign_domain_nr(), and I would drop the
last patch [PATCH v9 30/30] PCI: Clean up CONFIG_PCI_DOMAINS_GENERIC.

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

