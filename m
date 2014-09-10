From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 10 Sep 2014 12:36:14 +0000
Subject: Re: [Xen-devel] [PATCH v1 04/21] x86/xen/MSI: Eliminate arch_msix_mask_irq() and arch_msi_mask_irq()
Message-Id: <541045BE.9050804@citrix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409911806-10519-1-git-send-email-wangyijing@huawei.com> <1409911806-10519-5-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1409911806-10519-5-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, Bharat.Bhushan@freescale.com, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, x86@kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, xen-devel@lists.xenproject.org, arnab.basu@freescale.com, Arnd Bergmann <arnd@arndb.de>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Xinwei Hu <huxinwei@huawei.com>, Tony Luck <tony.luck@intel.com>, Ralf Baechle <ralf@linux-mips.org>, iommu@lists.linux-foundation.org, Wuyun <wuyun.wu@huawei.com>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 05/09/14 11:09, Yijing Wang wrote:
> Commit 0e4ccb150 added two __weak arch functions arch_msix_mask_irq()
> and arch_msi_mask_irq() to fix a bug found when running xen in x86.
> Introduced these two funcntions make MSI code complex. And mask/unmask
> is the irq actions related to interrupt controller, should not use
> weak arch functions to override mask/unmask interfaces. This patch
> reverted commit 0e4ccb150 and export struct irq_chip msi_chip, modify
> msi_chip->irq_mask/irq_unmask() in xen init functions to fix this
> bug for simplicity. Also this is preparation for using struct
> msi_chip instead of weak arch MSI functions in all platforms.

Acked-by: David Vrabel <david.vrabel@citrix.com>

But I wonder if it would be better the Xen subsystem to provide its own
struct irq_chip instead of adjusting the fields in the generic x86 one.

David
