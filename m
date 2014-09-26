From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 26 Sep 2014 01:58:54 +0000
Subject: Re: [PATCH v2 01/22] PCI/MSI: Clean up struct msi_chip argument
Message-Id: <5424C85E.4090006@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com> <1411614872-4009-2-git-send-email-wangyijing@huawei.com> <20140925071536.GG12423@ulmo>
In-Reply-To: <20140925071536.GG12423@ulmo>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On 2014/9/25 15:15, Thierry Reding wrote:
> On Thu, Sep 25, 2014 at 11:14:11AM +0800, Yijing Wang wrote:
>> Msi_chip functions setup_irq/teardown_irq rarely use msi_chip
>> argument.
> 
> That's not true. Out of the four drivers that you modify two use the
> parameter. And the two that don't probably should be using it too.
> 
> 50% is not "rarely". =)
> 
>>           We can look up msi_chip pointer by the device pointer
>> or irq number, so clean up msi_chip argument.
> 
> I don't like this particular change. The idea was to keep the API object
> oriented so that drivers wouldn't have to know where to get the MSI chip
> from. It also makes it more resilient against code reorganizations since
> the core code is the only place that needs to know where to get the chip
> from.

Hm, ok, Thomas also don't like this change, I will drop this one, thanks.

Thanks!
Yijing.

> 
> Thierry
> 


-- 
Thanks!
Yijing

