From: Matt Fleming <matt@console-pimps.org>
Date: Mon, 05 Aug 2013 12:15:40 +0000
Subject: Re: [PATCH v2 2/5] efi: provide a generic efi_config_init()
Message-Id: <20130805121540.GP2515@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
 <1375462582-16423-3-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375462582-16423-3-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, patches@linaro.org

On Fri, 02 Aug, at 05:56:19PM, Leif Lindholm wrote:
> Common to (U)EFI support on all platforms is the global "efi" data
> structure, and the code that parses the System Table to locate
> addresses to populate that structure with.
> 
> This patch adds both of these to the global EFI driver code.
> 
> Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
> ---
>  drivers/firmware/efi/efi.c |  106 ++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/efi.h        |    7 +++
>  2 files changed, 113 insertions(+)

[...]

> +static __init int match_config_table(efi_guid_t *guid,
> +				     unsigned long table,
> +				     efi_config_table_type_t *table_types)
> +{
> +	u8 str[38];

Shouldn't this be 37? You get 36 bytes for your GUID, plus a trailing
NUL? Either way, this should be a #define. The closest thing we have in
include/linux/efi.h is EFI_VARIABLE_GUID_LEN. Perhaps we need a
EFI_GUID_LEN that includes the trailing NUL?

> +	int i;
> +
> +	if (table_types) {
> +		efi_guid_unparse(guid, str);
> +
> +		for (i = 0; efi_guidcmp(table_types[i].guid, NULL_GUID); i++) {
> +			efi_guid_unparse(&table_types[i].guid, str);
> +
> +			if (!efi_guidcmp(*guid, table_types[i].guid)) {
> +				*(table_types[i].ptr) = table;
> +				pr_cont(" %s=0x%lx ",
> +					table_types[i].name, table);
> +				return 1;
> +			}
> +		}
> +	}
> +
> +	return 0;
> +}

One thing I just noticed that's worth pointing out is that 'pr_fmt'
isn't defined in drivers/firmware/efi/efi.c. Before your patch series
you get,

[    0.000000] efi:  SMBIOS=0xbae41a98  ACPI=0xbac6f000  ACPI 2.0=0xbac6f000  MPS=0xfca90 

and after,

[    0.000000]  SMBIOS=0xbae41a98  ACPI=0xbac6f000  ACPI 2.0=0xbac6f000 MPS=0xfca90 

which isn't the end of the world, but it does mean that the error
messages are now much less informative, e.g.

> +	config_tables = early_memremap(efi.systab->tables,
> +				       efi.systab->nr_tables * sz);
> +	if (config_tables = NULL) {
> +		pr_err("could not map configuration table!\n");
> +		return -ENOMEM;
> +	}

Which goes from,

  efi: could not map configuration table!

to become,

  could not map configuration table!

-- 
Matt Fleming, Intel Open Source Technology Center
