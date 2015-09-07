From: Sudeep Holla <sudeep.holla@arm.com>
Date: Mon, 07 Sep 2015 15:32:05 +0000
Subject: Re: [PATCH v2 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the macro
Message-Id: <55EDADF5.5060008@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org> <1440022048-6285-2-git-send-email-al.stone@linaro.org>
In-Reply-To: <1440022048-6285-2-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <al.stone@linaro.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "patches@linaro.org" <patches@linaro.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>

Hi Al,

On 19/08/15 23:07, Al Stone wrote:

I finally got a chance to try this series on Juno. Well it exposed a 
firmware bug in MADT table :)

[..]

>                  acpi_tbl_entry_handler handler,
> @@ -245,6 +484,8 @@ acpi_parse_entries(char *id, unsigned long table_size,
>                 table_end) {
>                  if (entry->type = entry_id
>                      && (!max_entries || count < max_entries)) {
> +                       if (bad_madt_entry(table_header, entry))
> +                               return -EINVAL;

Not sure if we can have the above check here unconditionally.
Currently I can see there are 2 other users of acpi_parse_entries i.e.
PCC and NUMA. So may be it can be made conditional or return success for
non-MADT tables from bad_madt_entry ?

Other than that, you can add for ARM64 specific parts:
Reviewed-and-tested-by: Sudeep Holla <sudeep.holla@arm.com>

Regards,
Sudeep
