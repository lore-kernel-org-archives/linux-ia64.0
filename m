From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 00:54:04 +0000
Subject: Re: [PATCH v2 00/30] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <54EE6EAC.9070607@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com> <20150225230925.GQ6220@google.com>
In-Reply-To: <20150225230925.GQ6220@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On 2015/2/26 7:09, Bjorn Helgaas wrote:
> On Wed, Jan 21, 2015 at 08:29:55AM +0800, Yijing Wang wrote:
>> v1->v2:
>> 	Split pci_host_bridge_list into a new patch, remove .phb_probe_mode
>> 	and rework powerpc .phb_of_scan_bus() for simpilicty suggested by
>> 	Arnd. Refresh some patch description log, and add a new patch to fix
>> 	build warning in ia64.
>>
>> This series is based on Bjorn's pci-next branch.
> 
> Hi Yijing,
> 
> Would you mind rebasing this to v4.0-rc1?  It doesn't apply quite cleanly
> any more.

OK, I will resend the series based on the v4.0-rc1.

Thanks!
Yijing.

> 
> Thanks,
>   Bjorn
> 
> .
> 


-- 
Thanks!
Yijing

