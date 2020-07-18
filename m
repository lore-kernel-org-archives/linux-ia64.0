From: "Song Bao Hua (Barry Song)" <song.bao.hua@hisilicon.com>
Date: Sat, 18 Jul 2020 05:17:27 +0000
Subject: RE: [PATCH v2 5/6] ACPI: Remove side effect of partly creating a node in acpi_get_node
Message-Id: <B926444035E5E2439431908E3842AFD2593D5E@DGGEMI525-MBS.china.huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200717175959.899775-1-Jonathan.Cameron@huawei.com>
 <20200717175959.899775-6-Jonathan.Cameron@huawei.com>
In-Reply-To: <20200717175959.899775-6-Jonathan.Cameron@huawei.com>
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
> Subject: [PATCH v2 5/6] ACPI: Remove side effect of partly creating a node in
> acpi_get_node
> 
> acpi_get_node calls acpi_get_pxm to evaluate the _PXM AML method for
> entries found in DSDT/SSDT. ACPI 6.3 sec 6.2.14 states
> "_PXM evaluates to an integer that identifies a device as belonging to
>  a Proximity Domain defined in the System Resource Affinity Table (SRAT)."
> 
> Hence a _PXM method should not result in creation of a new NUMA node.
> Before this patch, _PXM could result in partial instantiation of
> NUMA node, missing elements such as zone lists.  A call to devm_kzalloc
> for example results in a null pointer dereference.
> 
> This patch therefore replaces the acpi_map_pxm_to_node with a call
> to pxm_to_node.
> 
> Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Reviewed-by: Barry Song <song.bao.hua@hisilicon.com>

> ---
>  drivers/acpi/numa/srat.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/acpi/numa/srat.c b/drivers/acpi/numa/srat.c
> index 8ef44ee0d76b..697a5c9e2eb5 100644
> --- a/drivers/acpi/numa/srat.c
> +++ b/drivers/acpi/numa/srat.c
> @@ -444,6 +444,6 @@ int acpi_get_node(acpi_handle handle)
> 
>  	pxm = acpi_get_pxm(handle);
> 
> -	return acpi_map_pxm_to_node(pxm);
> +	return pxm_to_node(pxm);
>  }
>  EXPORT_SYMBOL(acpi_get_node);
> --
> 2.19.1
