From: Robert Richter <rrichter@marvell.com>
Date: Wed, 20 Mar 2019 14:48:34 +0000
Subject: Re: [PATCH] efi: Unify dmi setup code over architectures arm/arm64, io64 and x86
Message-Id: <20190320144828.a7iui7v5cwt45myr@rric.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190320130502.16667-1-rrichter@marvell.com>
 <20190320131607.vgst3r7ynha55ikw@rric.localdomain>
In-Reply-To: <20190320131607.vgst3r7ynha55ikw@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Jean Delvare <jdelvare@suse.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Marcin Benka <mbenka@marvell.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>

On 20.03.19 13:16:13, Robert Richter wrote:

> diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
> index 4a0dfe4ab829..c250b767030e 100644
> --- a/drivers/firmware/efi/arm-runtime.c
> +++ b/drivers/firmware/efi/arm-runtime.c
> @@ -162,14 +162,10 @@ void efi_virtmap_unload(void)
>  static int __init arm_dmi_init(void)
>  {
>  	/*
> -	 * On arm64/ARM, DMI depends on UEFI, and dmi_scan_machine() needs to
> +	 * On arm64/ARM, DMI depends on UEFI, and dmi_setup() needs to
>  	 * be called early because dmi_id_init(), which is an arch_initcall
>  	 * itself, depends on dmi_scan_machine() having been called already.
>  	 */
> -	dmi_scan_machine();
> -	dmi_memdev_walk();
> -	if (dmi_available)
> -		dmi_set_dump_stack_arch_desc();

This went wrong in the last stage of a comment rework. A dmi_setup()
should be here. Will resubmit. Sorry.

-Robert

>  	return 0;
>  }
