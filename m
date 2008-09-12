From: Jay Lan <jlan@sgi.com>
Date: Fri, 12 Sep 2008 13:57:21 +0000
Subject: Re: [PATCH]IA64: assign a distinguishable label to uncached memory
Message-Id: <48CA7541.2090101@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <48C9A2F8.3060308@sgi.com>	<20080912095548.54471a93@kepler.site>
	<20080912095858.445bba98@kepler.site>
In-Reply-To: <20080912095858.445bba98@kepler.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: kexec@lists.infradead.org, Jack Steiner <steiner@sgi.com>, linux-ia64@vger.kernel.org

Bernhard Walle wrote:
> * Bernhard Walle <bwalle@suse.de> [2008-09-12]: 
> 
>> Isn't that too much indent, i.e. shouldn't that be
> 
> Of course

Yep! Thanks for correction.

jay

> 
> --- a/arch/ia64/kernel/efi.c
> +++ b/arch/ia64/kernel/efi.c
> @@ -1232,9 +1232,10 @@ efi_initialize_iomem_resources(struct re
>                                 if (md->attribute & EFI_MEMORY_WP) {
>                                         name = "System ROM";
>                                         flags |= IORESOURCE_READONLY;
> -                               } else {
> +                               } else if (md->attribute = EFI_MEMORY_UC)
> +                                       name = "Uncached RAM";
> +                               else
>                                         name = "System RAM";
> -                               }
>                                 break;
>  
>                         case EFI_ACPI_MEMORY_NVS:
> 
> 
> My mailer decided to wrap the pasted text (which is my fault).
> 
> 
> Bernhard
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec

