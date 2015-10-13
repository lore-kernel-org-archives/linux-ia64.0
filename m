From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 13 Oct 2015 09:48:27 +0000
Subject: Re: [v7,58/60] PCI: Introduce resource_disabled()
Message-Id: <20151013094827.666D5140FDF@ozlabs.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1444340359-8011-59-git-send-email-yinghai@kernel.org>
In-Reply-To: <1444340359-8011-59-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, David Miller <davem@davemloft.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, TJ <linux@iam.tj>, Yijing Wang <wangyijing@huawei.com>, Khalid Aziz <khalid.aziz@oracle.com>
Cc: linux-s390@vger.kernel.org, linux-am33-list@redhat.com, linux-ia64@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-sh@vger.kernel.org, linux-pci@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>

On Thu, 2015-08-10 at 21:39:17 UTC, Yinghai Lu wrote:
> Current is using !flags, and we are going to use
> IORESOURCE_DISABLED instead of clearing resource flags.
> 
> Let's convert all !flags to helper function resource_disabled().
> resource_disabled will check !flags and IORESOURCE_DISABLED both.
> 
> diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
> index 8853667..a830e0c 100644
> --- a/arch/powerpc/kernel/pci-common.c
> +++ b/arch/powerpc/kernel/pci-common.c
> @@ -810,7 +810,7 @@ static void pcibios_fixup_resources(struct pci_dev *dev)
>  	for (i = 0; i < DEVICE_COUNT_RESOURCE; i++) {
>  		struct resource *res = dev->resource + i;
>  		struct pci_bus_region reg;
> -		if (!res->flags)
> +		if (resource_disabled(res))
>  			continue;
>  
>  		/* If we're going to re-assign everything, we mark all resources
> @@ -919,7 +919,7 @@ static void pcibios_fixup_bridge(struct pci_bus *bus)
>  	struct pci_dev *dev = bus->self;
>  
>  	pci_bus_for_each_resource(bus, res, i) {
> -		if (!res || !res->flags)
> +		if (!res || resource_disabled(res))
>  			continue;
>  		if (i >= 3 && bus->self->transparent)
>  			continue;
> @@ -1160,7 +1160,8 @@ static void pcibios_allocate_bus_resources(struct pci_bus *bus)
>  		 pci_domain_nr(bus), bus->number);
>  
>  	pci_bus_for_each_resource(bus, res, i) {
> -		if (!res || !res->flags || res->start > res->end || res->parent)
> +		if (!res || resource_disabled(res) ||
> +		    res->start > res->end || res->parent)
>  			continue;
>  
>  		/* If the resource was left unset at this point, we clear it */
> @@ -1255,7 +1256,8 @@ static void __init pcibios_allocate_resources(int pass)
>  			r = &dev->resource[idx];
>  			if (r->parent)		/* Already allocated */
>  				continue;
> -			if (!r->flags || (r->flags & IORESOURCE_UNSET))
> +			if (resource_disabled(r) ||
> +			    (r->flags & IORESOURCE_UNSET))
>  				continue;	/* Not assigned at all */
>  			/* We only allocate ROMs on pass 1 just in case they
>  			 * have been screwed up by firmware
> @@ -1393,7 +1395,7 @@ void pcibios_claim_one_bus(struct pci_bus *bus)
>  		for (i = 0; i < PCI_NUM_RESOURCES; i++) {
>  			struct resource *r = &dev->resource[i];
>  
> -			if (r->parent || !r->start || !r->flags)
> +			if (r->parent || !r->start || resource_disabled(r))
>  				continue;
>  
>  			pr_debug("PCI: Claiming %s: Resource %d: %pR\n",
> @@ -1474,7 +1476,7 @@ static void pcibios_setup_phb_resources(struct pci_controller *hose,
>  	/* Hookup PHB IO resource */
>  	res = &hose->io_resource;
>  
> -	if (!res->flags) {
> +	if (resource_disabled(res)) {
>  		pr_info("PCI: I/O resource not set for host"
>  		       " bridge %s (domain %d)\n",
>  		       hose->dn->full_name, hose->global_number);
> @@ -1489,7 +1491,7 @@ static void pcibios_setup_phb_resources(struct pci_controller *hose,
>  	/* Hookup PHB Memory resources */
>  	for (i = 0; i < 3; ++i) {
>  		res = &hose->mem_resources[i];
> -		if (!res->flags) {
> +		if (resource_disabled(res)) {
>  			if (i = 0)
>  				printk(KERN_ERR "PCI: Memory resource 0 not set for "
>  				       "host bridge %s (domain %d)\n",
> diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
> index 414fd1a..81484c1 100644
> --- a/arch/powerpc/platforms/powernv/pci-ioda.c
> +++ b/arch/powerpc/platforms/powernv/pci-ioda.c
> @@ -874,7 +874,7 @@ static int pnv_pci_vf_resource_shift(struct pci_dev *dev, int offset)
>  	num_vfs = pdn->num_vfs;
>  	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>  		res = &dev->resource[i + PCI_IOV_RESOURCES];
> -		if (!res->flags || !res->parent)
> +		if (resource_disabled(res) || !res->parent)
>  			continue;
>  
>  		if (!pnv_pci_is_mem_pref_64(res->flags))
> @@ -905,7 +905,7 @@ static int pnv_pci_vf_resource_shift(struct pci_dev *dev, int offset)
>  	 */
>  	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>  		res = &dev->resource[i + PCI_IOV_RESOURCES];
> -		if (!res->flags || !res->parent)
> +		if (resource_disabled(res) || !res->parent)
>  			continue;
>  
>  		if (!pnv_pci_is_mem_pref_64(res->flags))
> @@ -1188,7 +1188,7 @@ static int pnv_pci_vf_assign_m64(struct pci_dev *pdev, u16 num_vfs)
>  
>  	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>  		res = &pdev->resource[i + PCI_IOV_RESOURCES];
> -		if (!res->flags || !res->parent)
> +		if (resource_disabled(res) || !res->parent)
>  			continue;
>  
>  		if (!pnv_pci_is_mem_pref_64(res->flags))
> @@ -2757,7 +2757,7 @@ static void pnv_pci_ioda_fixup_iov_resources(struct pci_dev *pdev)
>  
>  	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>  		res = &pdev->resource[i + PCI_IOV_RESOURCES];
> -		if (!res->flags || res->parent)
> +		if (resource_disabled(res) || res->parent)
>  			continue;
>  		if (!pnv_pci_is_mem_pref_64(res->flags)) {
>  			dev_warn(&pdev->dev, " non M64 VF BAR%d: %pR\n",
> @@ -2779,7 +2779,7 @@ static void pnv_pci_ioda_fixup_iov_resources(struct pci_dev *pdev)
>  
>  	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>  		res = &pdev->resource[i + PCI_IOV_RESOURCES];
> -		if (!res->flags || res->parent)
> +		if (resource_disabled(res) || res->parent)
>  			continue;
>  		if (!pnv_pci_is_mem_pref_64(res->flags)) {
>  			dev_warn(&pdev->dev, "Skipping expanding VF BAR%d: %pR\n",
> @@ -2820,7 +2820,7 @@ static void pnv_ioda_setup_pe_seg(struct pci_controller *hose,
>  	BUG_ON(!(pe->flags & (PNV_IODA_PE_BUS | PNV_IODA_PE_BUS_ALL)));
>  
>  	pci_bus_for_each_resource(pe->pbus, res, i) {
> -		if (!res || !res->flags ||
> +		if (!res || resource_disabled(res) ||
>  		    res->start > res->end)
>  			continue;

Those conversions all look correct to me.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)


cheers
