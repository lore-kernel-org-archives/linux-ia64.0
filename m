From: David Daney <ddaney@caviumnetworks.com>
Date: Thu, 12 May 2016 00:06:13 +0000
Subject: Re: [PATCH v6 13/14] arm64, acpi, numa: NUMA support based on SRAT and SLIT
Message-Id: <5733C8F5.6090206@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com> <1461780436-27182-14-git-send-email-ddaney.cavm@gmail.com> <20160511103929.GC3051@e104818-lin.cambridge.arm.com>
In-Reply-To: <20160511103929.GC3051@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: David Daney <ddaney.cavm@gmail.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, Robert Richter <rrichter@cavium.com>, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>, Jon

On 05/11/2016 03:39 AM, Catalin Marinas wrote:
> On Wed, Apr 27, 2016 at 11:07:15AM -0700, David Daney wrote:
>> +static int __init get_mpidr_in_madt(int acpi_id, u64 *mpidr)
>> +{
>> +	unsigned long madt_end, entry;
>> +	struct acpi_table_madt *madt;
>> +	acpi_size tbl_size;
>> +
>> +	if (ACPI_FAILURE(acpi_get_table_with_size(ACPI_SIG_MADT, 0,
>> +			(struct acpi_table_header **)&madt, &tbl_size)))
>> +		return -ENODEV;
>> +
>> +	entry = (unsigned long)madt;
>> +	madt_end = entry + madt->header.length;
>> +
>> +	/* Parse all entries looking for a match. */
>> +	entry += sizeof(struct acpi_table_madt);
>> +	while (entry + sizeof(struct acpi_subtable_header) < madt_end) {
>> +		struct acpi_subtable_header *header >> +			(struct acpi_subtable_header *)entry;
>> +
>> +		if (header->type = ACPI_MADT_TYPE_GENERIC_INTERRUPT) {
>> +			struct acpi_madt_generic_interrupt *gicc >> +				container_of(header,
>> +				struct acpi_madt_generic_interrupt, header);
>> +
>> +			if ((gicc->flags & ACPI_MADT_ENABLED) &&
>> +			    (gicc->uid = acpi_id)) {
>> +				*mpidr = gicc->arm_mpidr;
>> +				early_acpi_os_unmap_memory(madt, tbl_size);
>> +				return 0;
>> +			}
>> +		}
>> +		entry += header->length;
>> +	}
>> +
>> +	early_acpi_os_unmap_memory(madt, tbl_size);
>> +	return -ENODEV;
>> +}
>> +
>> +/* Callback for Proximity Domain -> ACPI processor UID mapping */
>> +void __init acpi_numa_gicc_affinity_init(struct acpi_srat_gicc_affinity *pa)
>> +{
>> +	int pxm, node;
>> +	u64 mpidr;
>> +
>> +	if (srat_disabled())
>> +		return;
>> +
>> +	if (pa->header.length < sizeof(struct acpi_srat_gicc_affinity)) {
>> +		pr_err("SRAT: Invalid SRAT header length: %d\n",
>> +			pa->header.length);
>> +		bad_srat();
>> +		return;
>> +	}
>> +
>> +	if (!(pa->flags & ACPI_SRAT_GICC_ENABLED))
>> +		return;
>> +
>> +	if (cpus_in_srat >= NR_CPUS) {
>> +		pr_warn_once("SRAT: cpu_to_node_map[%d] is too small, may not be able to use all cpus\n",
>> +			     NR_CPUS);
>> +		return;
>> +	}
>> +
>> +	pxm = pa->proximity_domain;
>> +	node = acpi_map_pxm_to_node(pxm);
>> +
>> +	if (node = NUMA_NO_NODE || node >= MAX_NUMNODES) {
>> +		pr_err("SRAT: Too many proximity domains %d\n", pxm);
>> +		bad_srat();
>> +		return;
>> +	}
>> +
>> +	if (get_mpidr_in_madt(pa->acpi_processor_uid, &mpidr)) {
>> +		pr_err("SRAT: PXM %d with ACPI ID %d has no valid MPIDR in MADT\n",
>> +			pxm, pa->acpi_processor_uid);
>> +		bad_srat();
>> +		return;
>> +	}
>
> I wonder whether you could replace the get_mpidr_in_madt() function with
> something like acpi_get_phys_id(). It looks like get_mpidr_in_madt()
> duplicates functionality already available elsewhere.
>

I just tried that, and it doesn't work.

The problem is that this code is being run very early in the boot, and 
kmalloc cannot be used.  acpi_get_phys_id() and its ilk can only be used 
once we have working kmalloc.  We need to extract the NUMA information 
early like this precisely because it is needed to initializing the slab 
system

Notice that we are using early_acpi_os_unmap_memory() et al. in 
get_mpidr_in_madt() explicitly for this reason.

In summary: I don't think we need another revision of this patch, it is 
like this for a good reason.

David Daney

