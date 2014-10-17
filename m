From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 17 Oct 2014 07:42:06 +0000
Subject: Re: [PATCH v3 21/27] Powerpc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <5440C84E.6050408@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>	 <1413342435-7876-22-git-send-email-wangyijing@huawei.com> <1413530600.21650.5.camel@concordia>
In-Reply-To: <1413530600.21650.5.camel@concordia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>

On 2014/10/17 15:23, Michael Ellerman wrote:
> On Wed, 2014-10-15 at 11:07 +0800, Yijing Wang wrote:
>> Use MSI chip framework instead of arch MSI functions to configure
>> MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> ---
>> Hi Michael,
>>    I dropped the Acked-by , because this version has a
>> lot changes compared to last. So, I guess you may want to check it again.
> 
> OK thanks.
> 
> Still looks OK and boots on one of my test systems that uses MSI.

Good!

> 
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> (for powerpc)

Thanks very much!

Thanks!
Yijing.

> 
> 
> cheers
> 
> 
> 
> .
> 


-- 
Thanks!
Yijing

