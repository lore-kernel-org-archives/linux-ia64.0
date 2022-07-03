From: "Michael Kelley (LINUX)" <mikelley@microsoft.com>
Date: Sun, 03 Jul 2022 14:57:03 +0000
Subject: RE: [PATCH v3 7/8] genirq: Return a const cpumask from irq_data_get_affinity_mask
Message-Id: <PH0PR21MB302584D4FE115FB39070B1E3D7BF9@PH0PR21MB3025.namprd21.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220701200056.46555-1-samuel@sholland.org>
 <20220701200056.46555-8-samuel@sholland.org>
In-Reply-To: <20220701200056.46555-8-samuel@sholland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Samuel Holland <samuel@sholland.org>, Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, Bartosz Golaszewski <brgl@bgdev.pl>, Bjorn Helgaas <bhelgaas@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Broadcom internal kernel review list <bcm-kernel-feedback-list@broadcom.com>, Chris Zankel <chris@zankel.net>, Colin Ian King <colin.king@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dexuan Cui <decui@microsoft.com>, Florian Fainelli <f.fainelli@gmail.com>, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Haiyang Zhang <haiyangz@microsoft.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Jan Beulich <jbeulich@suse.com>, Joerg Roedel <joro@8bytes.org>, Juergen Gross <jgross@suse.com>, Julia Lawall <Julia.Lawall@inria.fr>, KY Srinivasan <kys@microsoft.com>, Kees Cook <keescook@chromium.org>, =?iso-8859-2?Q?Krzysztof_Wilczy=F1ski?= <kw@linux.com>, Linus Walleij <linus.walleij@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <Mark.Rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Maximilian Heyne <mheyne@amazon.de>, Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Rikard Falkeborn <rikard.falkeborn@gmail.com>, Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Sven Schnelle <svens@stackframe.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Wei Liu <wei.liu@kernel.org>, Wei Xu <xuwei5@hisilicon.com>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "iommu@lists.linux.dev" <iommu@lists.linux.dev>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-hyperv@vger.kernel.org" <linux-hyperv@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "x86@kernel.org" <x86@kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>

From: Samuel Holland <samuel@sholland.org> Sent: Friday, July 1, 2022 1:01 PM
> 
> Now that the irq_data_update_affinity helper exists, enforce its use
> by returning a a const cpumask from irq_data_get_affinity_mask.

Nit: duplicate word "a"

> 
> Since the previous commit already updated places that needed to call
> irq_data_update_affinity, this commit updates the remaining code that
> either did not modify the cpumask or immediately passed the modified
> mask to irq_set_affinity.
> 
> Signed-off-by: Samuel Holland <samuel@sholland.org>
> ---
> 
> Changes in v3:
>  - New patch to make the returned cpumasks const
> 
>  arch/mips/cavium-octeon/octeon-irq.c |  4 ++--
>  arch/sh/kernel/irq.c                 |  7 ++++---
>  arch/x86/hyperv/irqdomain.c          |  2 +-
>  arch/xtensa/kernel/irq.c             |  7 ++++---
>  drivers/iommu/hyperv-iommu.c         |  2 +-
>  drivers/pci/controller/pci-hyperv.c  | 10 +++++-----
>  include/linux/irq.h                  | 12 +++++++-----
>  kernel/irq/chip.c                    |  8 +++++---
>  kernel/irq/debugfs.c                 |  2 +-
>  kernel/irq/ipi.c                     | 16 +++++++++-------
>  10 files changed, 39 insertions(+), 31 deletions(-)
> 

[snip]

> diff --git a/arch/x86/hyperv/irqdomain.c b/arch/x86/hyperv/irqdomain.c
> index 7e0f6bedc248..42c70d28ef27 100644
> --- a/arch/x86/hyperv/irqdomain.c
> +++ b/arch/x86/hyperv/irqdomain.c
> @@ -192,7 +192,7 @@ static void hv_irq_compose_msi_msg(struct irq_data *data,
> struct msi_msg *msg)
>  	struct pci_dev *dev;
>  	struct hv_interrupt_entry out_entry, *stored_entry;
>  	struct irq_cfg *cfg = irqd_cfg(data);
> -	cpumask_t *affinity;
> +	const cpumask_t *affinity;
>  	int cpu;
>  	u64 status;
> 

[snip]

> diff --git a/drivers/iommu/hyperv-iommu.c b/drivers/iommu/hyperv-iommu.c
> index e285a220c913..51bd66a45a11 100644
> --- a/drivers/iommu/hyperv-iommu.c
> +++ b/drivers/iommu/hyperv-iommu.c
> @@ -194,7 +194,7 @@ hyperv_root_ir_compose_msi_msg(struct irq_data *irq_data,
> struct msi_msg *msg)
>  	u32 vector;
>  	struct irq_cfg *cfg;
>  	int ioapic_id;
> -	struct cpumask *affinity;
> +	const struct cpumask *affinity;
>  	int cpu;
>  	struct hv_interrupt_entry entry;
>  	struct hyperv_root_ir_data *data = irq_data->chip_data;
> diff --git a/drivers/pci/controller/pci-hyperv.c b/drivers/pci/controller/pci-hyperv.c
> index db814f7b93ba..aebada45569b 100644
> --- a/drivers/pci/controller/pci-hyperv.c
> +++ b/drivers/pci/controller/pci-hyperv.c
> @@ -642,7 +642,7 @@ static void hv_arch_irq_unmask(struct irq_data *data)
>  	struct hv_retarget_device_interrupt *params;
>  	struct tran_int_desc *int_desc;
>  	struct hv_pcibus_device *hbus;
> -	struct cpumask *dest;
> +	const struct cpumask *dest;
>  	cpumask_var_t tmp;
>  	struct pci_bus *pbus;
>  	struct pci_dev *pdev;
> @@ -1613,7 +1613,7 @@ static void hv_pci_compose_compl(void *context, struct
> pci_response *resp,
>  }
> 
>  static u32 hv_compose_msi_req_v1(
> -	struct pci_create_interrupt *int_pkt, struct cpumask *affinity,
> +	struct pci_create_interrupt *int_pkt, const struct cpumask *affinity,
>  	u32 slot, u8 vector, u8 vector_count)
>  {
>  	int_pkt->message_type.type = PCI_CREATE_INTERRUPT_MESSAGE;
> @@ -1641,7 +1641,7 @@ static int hv_compose_msi_req_get_cpu(struct cpumask
> *affinity)
>  }
> 
>  static u32 hv_compose_msi_req_v2(
> -	struct pci_create_interrupt2 *int_pkt, struct cpumask *affinity,
> +	struct pci_create_interrupt2 *int_pkt, const struct cpumask *affinity,
>  	u32 slot, u8 vector, u8 vector_count)
>  {
>  	int cpu;
> @@ -1660,7 +1660,7 @@ static u32 hv_compose_msi_req_v2(
>  }
> 
>  static u32 hv_compose_msi_req_v3(
> -	struct pci_create_interrupt3 *int_pkt, struct cpumask *affinity,
> +	struct pci_create_interrupt3 *int_pkt, const struct cpumask *affinity,
>  	u32 slot, u32 vector, u8 vector_count)
>  {
>  	int cpu;
> @@ -1697,7 +1697,7 @@ static void hv_compose_msi_msg(struct irq_data *data,
> struct msi_msg *msg)
>  	struct hv_pci_dev *hpdev;
>  	struct pci_bus *pbus;
>  	struct pci_dev *pdev;
> -	struct cpumask *dest;
> +	const struct cpumask *dest;
>  	struct compose_comp_ctxt comp;
>  	struct tran_int_desc *int_desc;
>  	struct msi_desc *msi_desc;

For these files with Hyper-V related changes:
arch/x86/hyperv/irqdomain.c
drivers/iommu/hyperv-iommu.c
drivers/pci/controller/pci-hyperv.c

Reviewed-by: Michael Kelley <mikelley@microsoft.com>
