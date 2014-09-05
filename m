From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 05 Sep 2014 10:47:48 +0000
Subject: Re: [PATCH v1 15/21] Powerpc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <540994D4.6040500@cogentembedded.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com> <1409911806-10519-16-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1409911806-10519-16-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>

Hello.

On 9/5/2014 2:10 PM, Yijing Wang wrote:

> Use MSI chip framework instead of arch MSI functions to configure
> MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.

> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>   arch/powerpc/kernel/msi.c |   14 ++++++++++++--
>   1 files changed, 12 insertions(+), 2 deletions(-)

> diff --git a/arch/powerpc/kernel/msi.c b/arch/powerpc/kernel/msi.c
> index 71bd161..01781a4 100644
> --- a/arch/powerpc/kernel/msi.c
> +++ b/arch/powerpc/kernel/msi.c
[...]
> @@ -27,7 +27,17 @@ int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
>   	return ppc_md.setup_msi_irqs(dev, nvec, type);
>   }
>
> -void arch_teardown_msi_irqs(struct pci_dev *dev)
> +static void ppc_teardown_msi_irqs(struct pci_dev *dev)

    Shouldn't this function take IRQ # instead?

>   {
>   	ppc_md.teardown_msi_irqs(dev);
>   }
> +
> +static struct msi_chip ppc_msi_chip = {
> +	.setup_irqs = ppc_setup_msi_irqs,
> +	.teardown_irqs = ppc_teardown_msi_irqs,
> +};
> +
> +struct msi_chip *arch_find_msi_chip(struct pci_dev *dev)
> +{
> +	return &ppc_msi_chip;
> +}

WBR, Sergei

