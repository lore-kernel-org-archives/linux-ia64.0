From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Mar 2015 07:30:44 +0000
Subject: Re: [PATCH v6 04/30] xen/PCI: Don't use deprecated function pci_scan_bus_parented()
Message-Id: <5513B5A4.1070209@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com> <1425868467-9667-5-git-send-email-wangyijing@huawei.com> <20150311223211.GB1082@google.com> <55017CA5.2010502@huawei.com> <20150312193505.GB7346@google.com> <55024D35.6050509@huawei.com> <CAErSpo4T7f9PNVMLrQbCvW2a=HnRauQR2eBz6H69B7Q2=ELNWw@mail.gmail.com> <20150313140132.GH5378@l.oracle.com> <CAErSpo69ytCxBK5AD79Nz05wy=GwzcOGV7WkiKFxpLDH4wtJXw@mail.gmail.com> <20150325192331.GG25884@l.oracle.com>
In-Reply-To: <20150325192331.GG25884@l.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>

>>> Is there an git tree with this so I can just try it out?
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git
>> pci/enumeration-yw6 has similar code (it exports the single
> 
> I presume now it is bjorn/pci/enumeration-yw8 ? Going to test this out
> this week.

Hi Konrad, I fixed two issues found by Tomasz and Daniel for the current v8 version.
I posted out the latest v9 in my github tree. Could you pull this series from my
github tree ?
The URL is: https://github.com/YijingWang/linux-pci.git enumer9

Thanks!
Yijing.

>> busn_resource and makes xen use it).  That should be functionally
>> identical to what v4.0-rc1 does.
>>
>> Yijing hasn't posted the static busn_res proposal above yet, so I
>> don't have a branch with that in it.
>>
>> Bjorn
> 
> .
> 


-- 
Thanks!
Yijing

