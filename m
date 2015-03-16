From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 16 Mar 2015 01:28:16 +0000
Subject: Re: [PATCH v6 10/30] PCI: Introduce pci_host_bridge_list to manage host bridges
Message-Id: <550631B0.2030709@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com> <1425868467-9667-11-git-send-email-wangyijing@huawei.com> <20150312025537.GD10949@google.com> <55018E90.9030301@huawei.com> <20150312195651.GD7346@google.com> <55025955.3020000@huawei.com> <CAErSpo5RgADWDPDvA-sg+MhmayPgTCfQqN1j0hYorAzZ=8_-qg@mail.gmail.com>
In-Reply-To: <CAErSpo5RgADWDPDvA-sg+MhmayPgTCfQqN1j0hYorAzZ=8_-qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

>> Currently, if platform does not know the end bus number (not provide the bus resource),
>> we will update the max bus number returned by pci_scan_child_bus() to the bus resource end,
>> and I think this is reasonable. I consider to introduce a flag to identify the bus resource
>> which end bus number is undefined, then we could force all pci_scan_root_bus()  etc. callers
>> to provide the bus resource, and we could process the bus resource end according the bus resource flag.
>> Also then we could reduce the bus argument which is the same as busn_res->start.
>> I would try to provide draft patch, then we could discuss it more clearly.
> 
> Without having seen a patch, my inclination is to avoid a flag because
> flags change the behavior of the code you call, which makes that code
> harder to follow.  Maybe we could require these platforms to
> explicitly update the ending bus number after scanning the bus.

OK, agree, thanks for your suggestion :)

> 
> Bjorn
> 
> .
> 


-- 
Thanks!
Yijing

