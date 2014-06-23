From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Mon, 23 Jun 2014 13:54:46 +0000
Subject: Re: [PATCH v6 1/9] efi: Use early_mem*() instead of early_io*()
Message-Id: <20140623135446.GG28489@olila.local.net-space.pl>
List-Id: <linux-ia64.vger.kernel.org>
References: <1403299768-9955-1-git-send-email-daniel.kiper@oracle.com>
 <1403299768-9955-2-git-send-email-daniel.kiper@oracle.com>
 <53A7F104020000780001C4BE@mail.emea.novell.com>
In-Reply-To: <53A7F104020000780001C4BE@mail.emea.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@suse.com>
Cc: andrew.cooper3@citrix.com, david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, matt.fleming@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, konrad.wilk@oracle.com, eshelton@pobox.com, mingo@redhat.com, mjg59@srcf.ucam.org, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org

I am CC'ing IA-64 guys.

On Mon, Jun 23, 2014 at 08:19:00AM +0100, Jan Beulich wrote:
> >>> On 20.06.14 at 23:29, <daniel.kiper@oracle.com> wrote:
> > --- a/drivers/firmware/efi/efi.c
> > +++ b/drivers/firmware/efi/efi.c
> > @@ -298,7 +298,7 @@ int __init efi_config_init(efi_config_table_type_t *arch_tables)
> >  			if (table64 >> 32) {
> >  				pr_cont("\n");
> >  				pr_err("Table located above 4GB, disabling EFI.\n");
> > -				early_iounmap(config_tables,
> > +				early_memunmap(config_tables,
> >  					       efi.systab->nr_tables * sz);
> >  				return -EINVAL;
> >  			}
> > @@ -314,7 +314,7 @@ int __init efi_config_init(efi_config_table_type_t *arch_tables)
> >  		tablep += sz;
> >  	}
> >  	pr_cont("\n");
> > -	early_iounmap(config_tables, efi.systab->nr_tables * sz);
> > +	early_memunmap(config_tables, efi.systab->nr_tables * sz);
> >
> >  	set_bit(EFI_CONFIG_TABLES, &efi.flags);
> >
>
> If these two changes are really deemed necessary (there's the
> implied assumption currently in place that early_iounmap() can
> undo early_memremap() mappings), then ia64 will need a
> definition added for early_memunmap() or its build will break.

I know that early_memunmap() = early_iounmap() in general. However,
I think that it is less confusing if use relevant functions in pairs
(i.e. early_memremap() with early_memunmap(), ...) than mix them up.

We have following choices here:
  - leave early_iounmap() as is in drivers/firmware/efi/efi.c
    (arch/x86/platform/efi/efi.c:early_iounmap() -> early_memunmap()
    changes should be left as is),
  - include asm/early_ioremap.h in arch/ia64/include/asm/io.h
    (as I can see the same think is done for x86 and arm64).

I prefer second solution but I do not insist.

Daniel
