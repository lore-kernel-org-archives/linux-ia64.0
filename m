From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 08 Apr 2015 08:32:27 +0000
Subject: Re: [PATCH v9 03/30] PCI: Save domain in pci_host_bridge
Message-Id: <5524E79B.5020304@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com> <1428053164-28277-5-git-send-email-wangyijing@huawei.com> <5524E248.9010509@free-electrons.com>
In-Reply-To: <5524E248.9010509@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-m68k@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org, dja@axtens.net, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Jiang Liu <jiang.liu@linux.intel.com>, linux-alpha@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

On 2015/4/8 16:09, Gregory CLEMENT wrote:
> Hi Yijing,
> 
> On 03/04/2015 11:25, Yijing Wang wrote:
>> Save domain in pci_host_bridge, so we could get domain
>> from pci_host_bridge, and at the end of series, we could
>> clean up the arch specific pci_domain_nr(). For arm,
>> we pass -1 as the domain number, we would update the
>> domain number in core by pci_bus_assign_domain_nr().
>>
> For the mvebu part I tested on Armada XP, Armada 375 and Armada 38x
> SoCs, and I didn't saw any regression. So you can add my:
> 
> Tested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Thanks a lot for your test!

Thanks!
Yijing.


>>
> 
> 


-- 
Thanks!
Yijing

