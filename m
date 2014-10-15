From: David Miller <davem@davemloft.net>
Date: Wed, 15 Oct 2014 02:36:41 +0000
Subject: Re: [PATCH v3 25/27] Sparc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <20141014.223641.1750858832286185881.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com>
	<1413342435-7876-26-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1413342435-7876-26-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wangyijing@huawei.com
Cc: bhelgaas@google.com, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, huxinwei@huawei.com, wuyun.wu@huawei.com, linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, arnd@arndb.de, tglx@linutronix.de, konrad.wilk@oracle.com, xen-devel@lists.xenproject.org, joro@8bytes.org, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sebott@linux.vnet.ibm.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org, cmetcalf@tilera.com, ralf@linux-mips.org, l.stach@pengutronix.de, david.vrabel@citrix.com, sergei.shtylyov@cogentembedded.com, mpe@ellerman.id.au, thierry.reding@gmail.com, thomas.petazzoni@free-electrons.com, liviu@dudau.co.uk

From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 15 Oct 2014 11:07:13 +0800

> Use MSI chip framework instead of arch MSI functions to configure
> MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Acked-by: David S. Miller <davem@davemloft.net>
