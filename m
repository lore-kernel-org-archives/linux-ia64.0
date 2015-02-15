From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 15 Feb 2015 01:11:14 +0000
Subject: Re: [PATCH v2 00/30] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <54DFF232.3090001@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com> <20150214194552.GA3932@e102568-lin.cambridge.arm.com>
In-Reply-To: <20150214194552.GA3932@e102568-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marc Zyngier <Marc.Zyngier@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-m68k@vger.kernel.org" <linux-m68k@vger.kernel.org>, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> Also we could eliminate all arch specific pci_domain_nr() after applied this series.
>>
>> I tested this series on x86 (with or without ACPI).
>> Comments and tests are warmly welcome!
> 
> Can you push a public branch out rebased against mainline for us to pull
> and test please ?

OK, I will rebase it and push it to my github repo today, and send out the git URL, thanks!

Thanks!
Yijing.

> 
> Thanks !
> Lorenzo
> 
> 
> .
> 


-- 
Thanks!
Yijing

