From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 03 Mar 2015 09:31:44 +0000
Subject: Re: [PATCH v4 22/30] PCI/Parisc: Use pci_scan_root_bus() for simplicity
Message-Id: <54F57F80.6050205@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com> <1424938344-4017-23-git-send-email-wangyijing@huawei.com> <20150303032412.GK11978@google.com>
In-Reply-To: <20150303032412.GK11978@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing0307@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, linux-parisc@vger.kernel.org

On 2015/3/3 11:24, Bjorn Helgaas wrote:
> On Thu, Feb 26, 2015 at 04:12:16PM +0800, Yijing Wang wrote:
>> From: Yijing Wang <wangyijing0307@gmail.com>
> 
> When you write subject lines, I think it's friendly to run
> "git log --oneline" on the file you're changing, and make yours
> match the previous ones.
> 
>   $ git log --oneline drivers/parisc/dino.c
>   3f05536d226d PCI/Parisc: Use pci_scan_root_bus() for simplicity
>   3335f75a8877 parisc: dino: fix %d confusingly prefixed with 0x in format string
>   3fad9b8d597f drivers/parisc: Use printf extension %pR for struct resource
>   0fe763c570ad Drivers: misc: remove __dev* attributes.
>   0b79ca2a800d parisc/PCI: Use list_for_each_entry() for bus->devices traversal
>   30aa80da43a5 parisc/PCI: register busn_res for root buses
>   ...
> 
> Yours doesn't match any of them, but "parisc/PCI" seems the best match.

OK, I will refresh the title, sorry.

> 
>> Now pci_bus_add_devices() has been ripped out
>> from pci_scan_root_bus(), we could use pci_scan_root_bus()
>> instead of pci_create_root_bus() + pci_scan_child_bus()
>> for simplicity. We could also remove the pci bus
>> resource(dino_current_bus,255) and pci_bus_update_busn_res_end(),
>> because pci_scan_root_bus() would do the same thing.
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> CC: "James E.J. Bottomley" <jejb@parisc-linux.org>
>> CC: linux-parisc@vger.kernel.org
>> ---
>>  drivers/parisc/dino.c    |   11 ++---------
>>  drivers/parisc/lba_pci.c |    7 ++-----
>>  2 files changed, 4 insertions(+), 14 deletions(-)
>>
>> diff --git a/drivers/parisc/dino.c b/drivers/parisc/dino.c
>> index a0580af..e5ee339 100644
>> --- a/drivers/parisc/dino.c
>> +++ b/drivers/parisc/dino.c
>> @@ -977,15 +977,11 @@ static int __init dino_probe(struct parisc_device *dev)
>>  	if (dino_dev->hba.gmmio_space.flags)
>>  		pci_add_resource(&resources, &dino_dev->hba.gmmio_space);
>>  
>> -	dino_dev->hba.bus_num.start = dino_current_bus;
>> -	dino_dev->hba.bus_num.end = 255;
>> -	dino_dev->hba.bus_num.flags = IORESOURCE_BUS;
>> -	pci_add_resource(&resources, &dino_dev->hba.bus_num);
> 
> I know pci_scan_root_bus() does default to bus 0-255, but I don't really
> like that behavior, and I think it's a bug for drivers like this to rely on
> that.  The PCI core has no way to discover the actual bus number range, and
> the only reason it supplies a default is because it was inconvenient to
> change all the callers.  The host bridge driver is the only code that has
> any chance of discovering and/or configuring the correct range.
> 
> So I think it's more correct to leave the existing code here, even though
> this code is is likely incorrect.  At least then if we trip over an issue
> with the bus range being incorrect, it will be clear that the fix should
> be in dino.c rather than the PCI core.

OK, I would keep this code here, thanks!

> 
> .
> 


-- 
Thanks!
Yijing

