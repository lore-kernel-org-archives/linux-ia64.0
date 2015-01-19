From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 19 Jan 2015 03:17:47 +0000
Subject: Re: [PATCH 23/28] PCI/designware: Use pci_scan_root_bus() for simplicity
Message-Id: <54BC775B.5020400@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <1421372666-12288-24-git-send-email-wangyijing@huawei.com> <54BA9052.9080904@cogentembedded.com>
In-Reply-To: <54BA9052.9080904@cogentembedded.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-m68k@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, linux-arm-kernel@lists.infradead.org

On 2015/1/18 0:39, Sergei Shtylyov wrote:
> Hello.
> 
> On 1/16/2015 4:44 AM, Yijing Wang wrote:
> 
>> Use pci_scan_root_bus() instead of pci_create_root_bus() +
>> pci_scan_child_bus() for simplicity.
> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> ---
>>   drivers/pci/host/pcie-designware.c |    4 +---
>>   1 files changed, 1 insertions(+), 3 deletions(-)
> 
>> diff --git a/drivers/pci/host/pcie-designware.c b/drivers/pci/host/pcie-designware.c
>> index eef3111..d37fe27 100644
>> --- a/drivers/pci/host/pcie-designware.c
>> +++ b/drivers/pci/host/pcie-designware.c
>> @@ -725,13 +725,11 @@ static struct pci_bus *dw_pcie_scan_bus(int nr, struct pci_sys_data *sys)
>>       struct pcie_port *pp = sys_to_pcie(sys);
>>
>>       pp->root_bus_nr = sys->busnr;
>> -    bus = pci_create_root_bus(pp->dev, sys->busnr,
>> +    bus = pci_scan_root_bus(pp->dev, sys->busnr,
>>                     &dw_pcie_ops, sys, &sys->resources);
> 
>    Please realign this line, so that it still starts under 'pp'.

ok.

> 
> WBR, Sergei
> 
> 
> .
> 


-- 
Thanks!
Yijing

