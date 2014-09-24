From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 24 Sep 2014 03:52:08 +0000
Subject: Re: [PATCH v1 00/21] Use MSI chip to configure MSI/MSI-X in all platforms
Message-Id: <54223FE8.4070101@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com> <20140923210936.GC27117@google.com>
In-Reply-To: <20140923210936.GC27117@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

On 2014/9/24 5:09, Bjorn Helgaas wrote:
> On Fri, Sep 05, 2014 at 06:09:45PM +0800, Yijing Wang wrote:
>> This series is based Bjorn's pci-next branch + Alexander Gordeev's two patches
>> "Remove arch_msi_check_device()" link: https://lkml.org/lkml/2014/7/12/41
>>
>> Currently, there are a lot of weak arch functions in MSI code.
>> Thierry Reding Introduced MSI chip framework to configure MSI/MSI-X in arm.
>> This series use MSI chip framework to refactor MSI code across all platforms
>> to eliminate weak arch functions. It has been tested fine in x86(with or without
>> irq remap).
> 
> I see you plan some updates, so I'll look for a v2 posting after v3.17 releases.
> It will be great to get rid of some of those weak functions!

Thanks, I will send out the new version soon.

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

