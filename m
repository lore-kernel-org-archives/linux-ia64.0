From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 19 Jan 2015 10:53:28 +0000
Subject: Re: [PATCH 18/28] PCI/sparc: Use pci_scan_root_bridge() for simplicity
Message-Id: <54BCE228.2020907@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <2658988.B0VmbMPdJ9@wuerfel> <54BC772E.6020103@huawei.com> <7748275.Tf0dzsPZdA@wuerfel>
In-Reply-To: <7748275.Tf0dzsPZdA@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Cc: Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-m68k@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>

On 2015/1/19 16:44, Arnd Bergmann wrote:
> On Monday 19 January 2015 11:17:02 Yijing Wang wrote:
>> On 2015/1/16 18:01, Arnd Bergmann wrote:
>>> On Friday 16 January 2015 09:44:16 Yijing Wang wrote:
>>>> +static void pci_host_bridge_probe_mode(
>>>> +               struct pci_host_bridge *host)
>>>> +{
>>>> +       host->of_scan = true;
>>>> +}
>>>>
>>>
>>> I probably missed something here, but where does host->of_scan
>>> get used?
>>>
>>
>> It is used in __pci_scan_root_bus() to detect whether of scan bus is needed in patch 11.
> 
> Ok, I see it now.
> 
>> @@ -2051,10 +2053,17 @@ static struct pci_bus *__pci_scan_root_bus(
>>  		pci_bus_insert_busn_res(b, host->busnum, 255);
>>  	}
>>
>> -	max = pci_scan_child_bus(b);
>> +	if (host->ops && host->ops->phb_probe_mode)
>> +		host->ops->phb_probe_mode(host);
>>
>> -	if (!found)
>> -		pci_bus_update_busn_res_end(b, max);
>> +	if (host->of_scan) {
>> +		if (host->ops &&host->ops->phb_of_scan_bus)
>> +			host->ops->phb_of_scan_bus(host);
>> +	} else {
>> +		max = pci_scan_child_bus(b);
>> +		if (!found)
>> +			pci_bus_update_busn_res_end(b, max);
>> +	}
>>
> 
> I think we can simplify this based on the knowledge that this code
> will remain powerpc specific. How about removing the phb_probe_mode()
> callback and replacing it with just a phb_scan_bus() callback that
> will always get set on sparc, and do this on powerpc:
> 
> +static void pci_host_bridge_of_scan_bus(struct pci_host_bridge *host)
> +{
> +       int mode = PCI_PROBE_NORMAL;
> +       struct pci_bus *bus = host->bus;
> +       struct pci_controller *hose = dev_get_drvdata(&host->dev);
> +
> +       /* Get probe mode and perform scan */
> +       if (hose->dn && ppc_md.pci_probe_mode)
> +               mode = ppc_md.pci_probe_mode(bus);
> +
> +       pr_debug("    probe mode: %d\n", mode);
> +       if (mode = PCI_PROBE_DEVTREE) {
> +               of_scan_bus(host->dn, bus);
> +		return max; // XXX need to get this from somewhere
> +	}
> +	return pci_scan_child_bus(b);
> +}
> 
> Would that work?

This looks good to me, it is more simple.

Thanks!
Yijing.


> 	Arnd
> 
> .
> 


-- 
Thanks!
Yijing

