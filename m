From: Grant Likely <grant.likely@secretlab.ca>
Date: Wed, 27 Nov 2013 12:12:31 +0000
Subject: Re: [PATCH] firmware/dmi_scan: generalize for use by other archs
Message-Id: <20131127121231.968E6C404EC@trevor.secretlab.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <1385034003-32160-1-git-send-email-ard.biesheuvel@linaro.org> < CAKv+Gu9VbSLDOYnuGkuajSHmp2PMKE-hLS4X0Gu-KO=uhU9skg@mail.gmail.com>
In-Reply-To: <CAKv+Gu9VbSLDOYnuGkuajSHmp2PMKE-hLS4X0Gu-KO=uhU9skg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "x86@kernel.org" <x86@kernel.org>, linux-ia64@vger.kernel.org, "mingo@redhat.com" <mingo@redhat.com>, tony.luck@intel.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org
Cc: Leif Lindholm <leif.lindholm@linaro.org>, Al Stone <al.stone@linaro.org>, Yi Li <yi.li@linaro.org>

On Mon, 25 Nov 2013 13:07:23 +0100, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> Hello all,
> 
> Resending this patch to a slightly wider audience.
> 
> The point of this patch is reworking the dmi_scan code slightly so it
> can be reused on ARM and arm64.
> There are no functional changes for x86 or IA-64, just one open
> question, i.e., whether the non-EFI fallback probe should be performed
> on IA-64 in the first place.
> 
> If I could get acks for this patch please (if there are no
> objections), I will propose it to be merged through the ARM and/or
> arm64 trees as part of the complete series to enable SMBIOS.
>
> On 21 November 2013 12:40, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> > This patch makes a couple of changes to the SMBIOS/DMI scanning
> > code so it can be used on other archs (such as ARM and arm64):
> > (a) wrap the calls to ioremap()/iounmap(), this allows the use of a
> >     flavor of ioremap() more suitable for random unaligned access;
> > (b) allow the non-EFI fallback probe into hardcoded physical address
> >     0xF0000 to be disabled.
> >
> > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Looks good.

Reviewed-by: Grant Likely <grant.likely@linaro.org>

> > ---
> >
> > @Tony: does the fallback probe make any sense at all on IA-64? It was enabled
> > before, so I added the #define for IA-64 as well, but perhaps we could remove it
> > altogether?
> >
> >  arch/ia64/include/asm/dmi.h | 10 +++++++---
> >  arch/x86/include/asm/dmi.h  |  8 ++++++--
> >  drivers/firmware/dmi_scan.c | 20 +++++++++++---------
> >  3 files changed, 24 insertions(+), 14 deletions(-)
> >
> > diff --git a/arch/ia64/include/asm/dmi.h b/arch/ia64/include/asm/dmi.h
> > index 185d3d1..61e3b56 100644
> > --- a/arch/ia64/include/asm/dmi.h
> > +++ b/arch/ia64/include/asm/dmi.h
> > @@ -5,8 +5,12 @@
> >  #include <asm/io.h>
> >
> >  /* Use normal IO mappings for DMI */
> > -#define dmi_ioremap ioremap
> > -#define dmi_iounmap(x,l) iounmap(x)
> > -#define dmi_alloc(l) kzalloc(l, GFP_ATOMIC)
> > +#define dmi_early_remap                ioremap
> > +#define dmi_early_unmap(x,l)   iounmap(x)
> > +#define dmi_remap              ioremap
> > +#define dmi_unmap              iounmap
> > +#define dmi_alloc(l)           kzalloc(l, GFP_ATOMIC)
> > +
> > +#define DMI_SCAN_MACHINE_NON_EFI_FALLBACK      1
> >
> >  #endif
> > diff --git a/arch/x86/include/asm/dmi.h b/arch/x86/include/asm/dmi.h
> > index fd8f9e2..bb2b572 100644
> > --- a/arch/x86/include/asm/dmi.h
> > +++ b/arch/x86/include/asm/dmi.h
> > @@ -13,7 +13,11 @@ static __always_inline __init void *dmi_alloc(unsigned len)
> >  }
> >
> >  /* Use early IO mappings for DMI because it's initialized early */
> > -#define dmi_ioremap early_ioremap
> > -#define dmi_iounmap early_iounmap
> > +#define dmi_early_remap                early_ioremap
> > +#define dmi_early_unmap                early_iounmap
> > +#define dmi_remap              ioremap
> > +#define dmi_unmap              iounmap
> > +
> > +#define DMI_SCAN_MACHINE_NON_EFI_FALLBACK      1
> >
> >  #endif /* _ASM_X86_DMI_H */
> > diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
> > index fa0affb..2c7c793 100644
> > --- a/drivers/firmware/dmi_scan.c
> > +++ b/drivers/firmware/dmi_scan.c
> > @@ -108,7 +108,7 @@ static int __init dmi_walk_early(void (*decode)(const struct dmi_header *,
> >  {
> >         u8 *buf;
> >
> > -       buf = dmi_ioremap(dmi_base, dmi_len);
> > +       buf = dmi_early_remap(dmi_base, dmi_len);
> >         if (buf = NULL)
> >                 return -1;
> >
> > @@ -116,7 +116,7 @@ static int __init dmi_walk_early(void (*decode)(const struct dmi_header *,
> >
> >         add_device_randomness(buf, dmi_len);
> >
> > -       dmi_iounmap(buf, dmi_len);
> > +       dmi_early_unmap(buf, dmi_len);
> >         return 0;
> >  }
> >
> > @@ -483,18 +483,19 @@ void __init dmi_scan_machine(void)
> >                  * needed during early boot.  This also means we can
> >                  * iounmap the space when we're done with it.
> >                  */
> > -               p = dmi_ioremap(efi.smbios, 32);
> > +               p = dmi_early_remap(efi.smbios, 32);
> >                 if (p = NULL)
> >                         goto error;
> >                 memcpy_fromio(buf, p, 32);
> > -               dmi_iounmap(p, 32);
> > +               dmi_early_unmap(p, 32);
> >
> >                 if (!dmi_present(buf)) {
> >                         dmi_available = 1;
> >                         goto out;
> >                 }
> >         } else {
> > -               p = dmi_ioremap(0xF0000, 0x10000);
> > +#ifdef DMI_SCAN_MACHINE_NON_EFI_FALLBACK
> > +               p = dmi_early_remap(0xF0000, 0x10000);
> >                 if (p = NULL)
> >                         goto error;
> >
> > @@ -510,12 +511,13 @@ void __init dmi_scan_machine(void)
> >                         memcpy_fromio(buf + 16, q, 16);
> >                         if (!dmi_present(buf)) {
> >                                 dmi_available = 1;
> > -                               dmi_iounmap(p, 0x10000);
> > +                               dmi_early_unmap(p, 0x10000);
> >                                 goto out;
> >                         }
> >                         memcpy(buf, buf + 16, 16);
> >                 }
> > -               dmi_iounmap(p, 0x10000);
> > +               dmi_early_unmap(p, 0x10000);
> > +#endif
> >         }
> >   error:
> >         pr_info("DMI not present or invalid.\n");
> > @@ -787,13 +789,13 @@ int dmi_walk(void (*decode)(const struct dmi_header *, void *),
> >         if (!dmi_available)
> >                 return -1;
> >
> > -       buf = ioremap(dmi_base, dmi_len);
> > +       buf = dmi_remap(dmi_base, dmi_len);
> >         if (buf = NULL)
> >                 return -1;
> >
> >         dmi_table(buf, dmi_len, dmi_num, decode, private_data);
> >
> > -       iounmap(buf);
> > +       dmi_unmap(buf);
> >         return 0;
> >  }
> >  EXPORT_SYMBOL_GPL(dmi_walk);
> > --
> > 1.8.3.2
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

