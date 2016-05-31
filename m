From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Tue, 31 May 2016 13:05:13 +0000
Subject: Re: [PATCH v7 13/15] ACPI / processor: Add acpi_map_madt_entry().
Message-Id: <574D8C09.3030608@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
 <1464129345-18985-14-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1464129345-18985-14-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

On 2016/5/25 6:35, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
>
> Follow-on arm64 ACPI/NUMA patches need to map MADT entries very early
> (before kmalloc is usable).
>
> Add acpi_map_madt_entry() which, indirectly, uses
> early_memremap()/early_memunmap() to access the table and parse out
> the mpidr.  The existing implementation of map_madt_entry() is
> modified to take a pointer to the MADT as a parameter and the callers
> adjusted.
>
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>   drivers/acpi/processor_core.c | 26 ++++++++++++++++++++++----
>   include/acpi/processor.h      |  1 +
>   2 files changed, 23 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
> index 33a38d6..9125d7d 100644
> --- a/drivers/acpi/processor_core.c
> +++ b/drivers/acpi/processor_core.c
> @@ -108,13 +108,12 @@ static int map_gicc_mpidr(struct acpi_subtable_header *entry,
>   	return -EINVAL;
>   }
>
> -static phys_cpuid_t map_madt_entry(int type, u32 acpi_id)
> +static phys_cpuid_t map_madt_entry(struct acpi_table_madt *madt,
> +				   int type, u32 acpi_id)
>   {
>   	unsigned long madt_end, entry;
>   	phys_cpuid_t phys_id = PHYS_CPUID_INVALID;	/* CPU hardware ID */
> -	struct acpi_table_madt *madt;
>
> -	madt = get_madt_table();
>   	if (!madt)
>   		return phys_id;
>
> @@ -145,6 +144,25 @@ static phys_cpuid_t map_madt_entry(int type, u32 acpi_id)
>   	return phys_id;
>   }
>
> +phys_cpuid_t __init acpi_map_madt_entry(u32 acpi_id)
> +{
> +	struct acpi_table_madt *madt = NULL;
> +	acpi_size tbl_size;
> +	phys_cpuid_t rv;
> +
> +	acpi_get_table_with_size(ACPI_SIG_MADT, 0,
> +				 (struct acpi_table_header **)&madt,
> +				 &tbl_size);
> +	if (!madt)
> +		return PHYS_CPUID_INVALID;
> +
> +	rv = map_madt_entry(madt, 1, acpi_id);

Just nit-pick, pass 1 here means we need to define an acpi processor
device object in DSDT (see function map_gicc_mpidr(),
device_declaration), it would be fine for x2apic and gic mode,
but not for lapic mode, since the function name is acpi_map_madt_entry
which is general for all architecture, it will confuse people I think.

How about rename acpi_map_madt_entry() to acpi_map_madt_gicc_entry()?
It's only used for AMR64 to get mpidrs from GICC entries using acpi_id,
other than that, it's good to me.

Thanks
Hanjun
