From: "Song Bao Hua (Barry Song)" <song.bao.hua@hisilicon.com>
Date: Sat, 18 Jul 2020 05:14:46 +0000
Subject: RE: [PATCH v2 2/6] ACPI: Do not create new NUMA domains from ACPI static tables that are not SRAT
Message-Id: <B926444035E5E2439431908E3842AFD2593D4E@DGGEMI525-MBS.china.huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200717175959.899775-1-Jonathan.Cameron@huawei.com>
 <20200717175959.899775-3-Jonathan.Cameron@huawei.com>
In-Reply-To: <20200717175959.899775-3-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Cameron <jonathan.cameron@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <bhelgaas@google.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "martin@geanix.com" <martin@geanix.com>, Ingo Molnar <mingo@redhat.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Linuxarm <linuxarm@huawei.com>, Dan Williams <dan.j.williams@intel.com>



> -----Original Message-----
> From: Jonathan Cameron
> Sent: Saturday, July 18, 2020 6:00 AM
> To: linux-mm@kvack.org; linux-acpi@vger.kernel.org;
> linux-arm-kernel@lists.infradead.org; x86@kernel.org
> Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>; Bjorn Helgaas
> <bhelgaas@google.com>; linux-pci@vger.kernel.org; martin@geanix.com; Ingo
> Molnar <mingo@redhat.com>; linux-ia64@vger.kernel.org; Tony Luck
> <tony.luck@intel.com>; Fenghua Yu <fenghua.yu@intel.com>; Thomas
> Gleixner <tglx@linutronix.de>; Linuxarm <linuxarm@huawei.com>; Dan
> Williams <dan.j.williams@intel.com>; Song Bao Hua (Barry Song)
> <song.bao.hua@hisilicon.com>; Jonathan Cameron
> <jonathan.cameron@huawei.com>
> Subject: [PATCH v2 2/6] ACPI: Do not create new NUMA domains from ACPI
> static tables that are not SRAT
> 
> Several ACPI static tables contain references to proximity domains.
> ACPI 6.3 has clarified that only entries in SRAT may define a new domain
> (sec 5.2.16).
> 
> Those tables described in the ACPI spec have additional clarifying text.
> 
> NFIT: Table 5-132,
> 
> "Integer that represents the proximity domain to which the memory belongs.
>  This number must match with corresponding entry in the SRAT table."
> 
> HMAT: Table 5-145,
> 
> "... This number must match with the corresponding entry in the SRAT
>  table's processor affinity structure ... if the initiator is a processor,
>  or the Generic Initiator Affinity Structure if the initiator is a generic
>  initiator".
> 
> IORT and DMAR are defined by external specifications.
> 
> Intel Virtualization Technology for Directed I/O Rev 3.1 does not make any
> explicit statements, but the general SRAT statement above will still apply.
> https://software.intel.com/sites/default/files/managed/c5/15/vt-directed-io-s
> pec.pdf
> 
> IO Remapping Table, Platform Design Document rev D, also makes not explicit
> statement, but refers to ACPI SRAT table for more information and again the
> generic SRAT statement above applies.
> https://developer.arm.com/documentation/den0049/d/
> 
> In conclusion, any proximity domain specified in these tables, should be a
> reference to a proximity domain also found in SRAT, and they should not be
> able
> to instantiate a new domain.  Hence we switch to pxm_to_node() which will
> only
> return existing nodes.
> 
> Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Much better than v1 which was using a bool parameter "false" to stop acpi_map_pxm_to_node()
from creating node.

And pxm_to_node() has been used by some other places as an API which is
serving the transition from pxm to node.

Reviewed-by: Barry Song <song.bao.hua@hisilicon.com>

> ---
>  drivers/acpi/arm64/iort.c  | 2 +-
>  drivers/acpi/nfit/core.c   | 3 +--
>  drivers/acpi/numa/hmat.c   | 2 +-
>  drivers/iommu/intel/dmar.c | 2 +-
>  4 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/acpi/arm64/iort.c b/drivers/acpi/arm64/iort.c
> index 28a6b387e80e..eb0f158612c8 100644
> --- a/drivers/acpi/arm64/iort.c
> +++ b/drivers/acpi/arm64/iort.c
> @@ -1293,7 +1293,7 @@ static int  __init
> arm_smmu_v3_set_proximity(struct device *dev,
> 
>  	smmu = (struct acpi_iort_smmu_v3 *)node->node_data;
>  	if (smmu->flags & ACPI_IORT_SMMU_V3_PXM_VALID) {
> -		int dev_node = acpi_map_pxm_to_node(smmu->pxm);
> +		int dev_node = pxm_to_node(smmu->pxm);
> 
>  		if (dev_node != NUMA_NO_NODE && !node_online(dev_node))
>  			return -EINVAL;
> diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
> index 7c138a4edc03..d933a4636d00 100644
> --- a/drivers/acpi/nfit/core.c
> +++ b/drivers/acpi/nfit/core.c
> @@ -2947,8 +2947,7 @@ static int acpi_nfit_register_region(struct
> acpi_nfit_desc *acpi_desc,
>  	if (spa->flags & ACPI_NFIT_PROXIMITY_VALID) {
>  		ndr_desc->numa_node = acpi_map_pxm_to_online_node(
>  						spa->proximity_domain);
> -		ndr_desc->target_node = acpi_map_pxm_to_node(
> -				spa->proximity_domain);
> +		ndr_desc->target_node = pxm_to_node(spa->proximity_domain);
>  	} else {
>  		ndr_desc->numa_node = NUMA_NO_NODE;
>  		ndr_desc->target_node = NUMA_NO_NODE;
> diff --git a/drivers/acpi/numa/hmat.c b/drivers/acpi/numa/hmat.c
> index 2c32cfb72370..cf6df2df26cd 100644
> --- a/drivers/acpi/numa/hmat.c
> +++ b/drivers/acpi/numa/hmat.c
> @@ -666,7 +666,7 @@ static void hmat_register_target_device(struct
> memory_target *target,
> 
>  	pdev->dev.numa_node > acpi_map_pxm_to_online_node(target->memory_pxm);
>  	info = (struct memregion_info) {
> -		.target_node = acpi_map_pxm_to_node(target->memory_pxm),
> +		.target_node = pxm_to_node(target->memory_pxm),
>  	};
>  	rc = platform_device_add_data(pdev, &info, sizeof(info));
>  	if (rc < 0) {
> diff --git a/drivers/iommu/intel/dmar.c b/drivers/iommu/intel/dmar.c
> index 683b812c5c47..b1acdaead059 100644
> --- a/drivers/iommu/intel/dmar.c
> +++ b/drivers/iommu/intel/dmar.c
> @@ -473,7 +473,7 @@ static int dmar_parse_one_rhsa(struct
> acpi_dmar_header *header, void *arg)
>  	rhsa = (struct acpi_dmar_rhsa *)header;
>  	for_each_drhd_unit(drhd) {
>  		if (drhd->reg_base_addr = rhsa->base_address) {
> -			int node = acpi_map_pxm_to_node(rhsa->proximity_domain);
> +			int node = pxm_to_node(rhsa->proximity_domain);
> 
>  			if (!node_online(node))
>  				node = NUMA_NO_NODE;
> --
> 2.19.1

Thanks
Barry
