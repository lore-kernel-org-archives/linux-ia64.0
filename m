From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 26 Sep 2014 02:13:21 +0000
Subject: Re: [PATCH v2 14/22] MIPS/Xlp/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <5424CBC1.8080702@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com> <1411614872-4009-15-git-send-email-wangyijing@huawei.com> <20140925073608.GK12423@ulmo>
In-Reply-To: <20140925073608.GK12423@ulmo>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On 2014/9/25 15:36, Thierry Reding wrote:
> On Thu, Sep 25, 2014 at 11:14:24AM +0800, Yijing Wang wrote:
>> Use MSI chip framework instead of arch MSI functions to configure
>> MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.
> 
> Nit: s/irq/IRQ/ in the above.
> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> ---
>>  arch/mips/pci/msi-xlp.c |   14 ++++++++++++--
>>  1 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/mips/pci/msi-xlp.c b/arch/mips/pci/msi-xlp.c
>> index e469dc7..6b791ef 100644
>> --- a/arch/mips/pci/msi-xlp.c
>> +++ b/arch/mips/pci/msi-xlp.c
>> @@ -245,7 +245,7 @@ static struct irq_chip xlp_msix_chip = {
>>  	.irq_unmask	= unmask_msi_irq,
>>  };
>>  
>> -void arch_teardown_msi_irq(unsigned int irq)
>> +void xlp_teardown_msi_irq(unsigned int irq)
> 
> Should this not be static now as well?

Yes, Will update.

> 
> Thierry
> 


-- 
Thanks!
Yijing

