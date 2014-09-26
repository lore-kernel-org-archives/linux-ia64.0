From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 26 Sep 2014 02:12:00 +0000
Subject: Re: [PATCH v2 12/22] MIPS/Octeon/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <5424CB70.9020800@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com> <1411614872-4009-13-git-send-email-wangyijing@huawei.com> <20140925073435.GJ12423@ulmo>
In-Reply-To: <20140925073435.GJ12423@ulmo>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On 2014/9/25 15:34, Thierry Reding wrote:
> On Thu, Sep 25, 2014 at 11:14:22AM +0800, Yijing Wang wrote:
> [...]
>> diff --git a/arch/mips/pci/msi-octeon.c b/arch/mips/pci/msi-octeon.c
> [...]
>> @@ -132,12 +132,12 @@ msi_irq_allocated:
>>  	/* Make sure the search for available interrupts didn't fail */
>>  	if (irq >= 64) {
>>  		if (request_private_bits) {
>> -			pr_err("arch_setup_msi_irq: Unable to find %d free interrupts, trying just one",
>> +			pr_err("octeon_setup_msi_irq: Unable to find %d free interrupts, trying just one",
>>  			       1 << request_private_bits);
> 
> Perhaps while at it make this (and other similar changes in this patch):
> 
> 	pr_err("%s(): Unable to ...", __func__, ...);

Will update it, thanks!

> 
> So that it becomes more resilient against this kind of rename?
> 
>>  			request_private_bits = 0;
>>  			goto try_only_one;
>>  		} else
>> -			panic("arch_setup_msi_irq: Unable to find a free MSI interrupt");
>> +			panic("octeon_setup_msi_irq: Unable to find a free MSI interrupt");
> 
>> @@ -210,14 +210,13 @@ int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
>>  
>>  	return 0;
>>  }
>> -
> 
> This...

OK

> 
>> @@ -240,7 +239,7 @@ void arch_teardown_msi_irq(unsigned int irq)
>>  	 */
>>  	number_irqs = 0;
>>  	while ((irq0 + number_irqs < 64) &&
>> -	       (msi_multiple_irq_bitmask[index]
>> +		(msi_multiple_irq_bitmask[index]
> 
> ... and this seem like unrelated whitespace changes.

OK

> 
>>  		& (1ull << (irq0 + number_irqs))))
>>  		number_irqs++;
>>  	number_irqs++;
>> @@ -249,8 +248,8 @@ void arch_teardown_msi_irq(unsigned int irq)
>>  	/* Shift the mask to the correct bit location */
>>  	bitmask <<= irq0;
>>  	if ((msi_free_irq_bitmask[index] & bitmask) != bitmask)
>> -		panic("arch_teardown_msi_irq: Attempted to teardown MSI "
>> -		      "interrupt (%d) not in use", irq);
>> +		panic("octeon_teardown_msi_irq: Attempted to teardown MSI "
>> +			"interrupt (%d) not in use", irq);
> 
> And the second line here also needlessly changes the indentation.

OK
> 
> Thierry
> 


-- 
Thanks!
Yijing

