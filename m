From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 26 Mar 2014 12:56:23 +0000
Subject: Re: [PATCH v3 1/5] efi: Add efi_init_ops variable
Message-Id: <20140326125623.GA24856@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-2-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1395781076-12000-2-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Kiper <daniel.kiper@oracle.com>
Cc: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com, Tang Liang <liang.tang@oracle.com>

On Tue, 25 Mar, at 09:57:52PM, Daniel Kiper wrote:
> Add efi_init_ops variable which allows us to replace
> EFI init functions on Xen with its specific stuff.
> 
> This patch is based on Jan Beulich and Tang Liang work.
> 
> Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
> Signed-off-by: Tang Liang <liang.tang@oracle.com>
> ---
>  arch/ia64/kernel/efi.c      |   30 +++++++++++++++++++++---------
>  arch/x86/platform/efi/efi.c |   18 +++++++++++++-----
>  drivers/firmware/efi/efi.c  |   26 ++++++++++++++++++++++++++
>  include/linux/efi.h         |    8 ++++++++
>  4 files changed, 68 insertions(+), 14 deletions(-)

[...]

> @@ -1118,6 +1118,14 @@ u64 efi_mem_attributes(unsigned long phys_addr)
>  	return 0;
>  }
>  
> +struct efi_init_ops efi_init_ops = {
> +	.efi_init = efi_init_generic,
> +	.efi_reserve_boot_services = efi_reserve_boot_services_generic,
> +	.efi_enter_virtual_mode = efi_enter_virtual_mode_generic,
> +	.efi_mem_type = efi_mem_type_generic,
> +	.efi_mem_attributes = efi_mem_attributes_generic
> +};

Please don't create another struct of EFI function pointers.

After this we'll have 3 global efi structures defintions and 4 global
efi objects on x86,

  - struct efi_early [in the boot stub]
  - struct efi ['efi_phys' before/'efi' after SetVirtualAddressMap()]
  - struct efi_init_ops [for the benefit of xen]

I have a big problem with exposing .efi_reserve_boot_services as an API.

Also, the fact that in later patches you're copying chunks of the x86
virt_*() funtions suggests to me that this has been implemented at the
wrong layer, because it actively discourages sharing code between x86
and Xen.

-- 
Matt Fleming, Intel Open Source Technology Center
