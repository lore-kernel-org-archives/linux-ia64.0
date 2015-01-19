From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 19 Jan 2015 03:17:02 +0000
Subject: Re: [PATCH 18/28] PCI/sparc: Use pci_scan_root_bridge() for simplicity
Message-Id: <54BC772E.6020103@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <1421372666-12288-19-git-send-email-wangyijing@huawei.com> <2658988.B0VmbMPdJ9@wuerfel>
In-Reply-To: <2658988.B0VmbMPdJ9@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Cc: Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <jiang.liu@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-m68k@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, "David S. Miller" <davem@davemloft.net>

On 2015/1/16 18:01, Arnd Bergmann wrote:
> On Friday 16 January 2015 09:44:16 Yijing Wang wrote:
>> +static void pci_host_bridge_probe_mode(
>> +               struct pci_host_bridge *host)
>> +{
>> +       host->of_scan = true;
>> +}
>>
> 
> I probably missed something here, but where does host->of_scan
> get used?
> 

It is used in __pci_scan_root_bus() to detect whether of scan bus is needed in patch 11.


@@ -2051,10 +2053,17 @@ static struct pci_bus *__pci_scan_root_bus(
 		pci_bus_insert_busn_res(b, host->busnum, 255);
 	}

-	max = pci_scan_child_bus(b);
+	if (host->ops && host->ops->phb_probe_mode)
+		host->ops->phb_probe_mode(host);

-	if (!found)
-		pci_bus_update_busn_res_end(b, max);
+	if (host->of_scan) {
+		if (host->ops &&host->ops->phb_of_scan_bus)
+			host->ops->phb_of_scan_bus(host);
+	} else {
+		max = pci_scan_child_bus(b);
+		if (!found)
+			pci_bus_update_busn_res_end(b, max);
+	}

 	return b;

Thanks!
Yijing.


> 	Arnd
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
> .
> 


-- 
Thanks!
Yijing

