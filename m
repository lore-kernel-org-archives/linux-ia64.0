From: Roel Kluin <12o3l@tiscali.nl>
Date: Thu, 15 Nov 2007 22:32:39 +0000
Subject: Re: [PATCH with title] priority fix in acpi_map_lsapic()  arch/ia64/kernel/acpi.c
Message-Id: <473CC907.4040106@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
References: <473CC232.6020901@tiscali.nl>
In-Reply-To: <473CC232.6020901@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, len.brown@intel.com
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

As above should have been its title.

Roel Kluin wrote:
> I have sent this patch before to lkml, but it appears it wasn't picked up. Also
> I have to admit this isn't tested. This is a patch against linus' tree.
> 
> ACPI_MADT_ENABLED is defined 1    (include/acpi/actbl1.h 501)
> lapic_flags: an u32 of struct acpi_madt_local_sapic (include/acpi/actbl1.h 467)
> --
> '!' has a higher priority than '&', so as was
> this won't test the first bit, but rather evaluates to false for any non-zero
> lsapic->lapic_flags.
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> index 3d45d24..7d78d22 100644
> --- a/arch/ia64/kernel/acpi.c
> +++ b/arch/ia64/kernel/acpi.c
> @@ -858,7 +858,7 @@ int acpi_map_lsapic(acpi_handle handle, int *pcpu)
>  	lsapic = (struct acpi_madt_local_sapic *)obj->buffer.pointer;
>  
>  	if ((lsapic->header.type != ACPI_MADT_TYPE_LOCAL_SAPIC) ||
> -	    (!lsapic->lapic_flags & ACPI_MADT_ENABLED)) {
> +	    (!(lsapic->lapic_flags & ACPI_MADT_ENABLED))) {
>  		kfree(buffer.pointer);
>  		return -EINVAL;
>  	}
> 

