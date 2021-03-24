From: Ard Biesheuvel <ardb@kernel.org>
Date: Wed, 24 Mar 2021 12:33:40 +0000
Subject: Re: [PATCH] ia64: fix EFI_DEBUG build
Message-Id: <CAMj1kXEmuVWR=TAmzXHnvKxbtSn1-Zkhr-0rOWV0BB1OGyx_TQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210322221441.3555003-1-slyfox@gentoo.org> <CAMj1kXF5ufbDPLhBboYav0bU3C1tnn1ZrDesPGGnni=+1N8hjw@mail.gmail.com>
 <YFosKXrTwfqBRLjf@sf>
In-Reply-To: <YFosKXrTwfqBRLjf@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, 23 Mar 2021 at 18:58, Sergei Trofimovich <slyfox@gentoo.org> wrote:
>
> On Tue, Mar 23, 2021 at 09:35:13AM +0100, Ard Biesheuvel wrote:
> > On Mon, 22 Mar 2021 at 23:16, Sergei Trofimovich <slyfox@gentoo.org> wrote:
> > >
> > > When enabled local debugging via `#define EFI_DEBUG 1` noticed
> > > build failure:
> > >
> > >     ia64/kernel/efi.c:564:8: error: 'i' undeclared (first use in this function)
> > >       564 |   for (i = 0, p = efi_map_start; p < efi_map_end;
> > >           |        ^
> > >
> > > CC: Ard Biesheuvel <ardb@kernel.org>
> > > CC: linux-efi@vger.kernel.org
> > > CC: linux-ia64@vger.kernel.org
> > > Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
> >
> > What are the other changes for?
>
> The rest are fixes for format string mismatch in %lx / unsigned long long.
> Should I resend with updated comment or split it to another commit?
>
> They all are hiding under EFI_DEBUG and are not visible by default.
>

OK, but please describe the purpose of *all* changes in the commit log.

Also, the breakage seems to be caused by

commit 14fb4209094355928d5a742e35afabdf7b404c17
Author: Ard Biesheuvel <ardb@kernel.org>
Date:   Mon Jan 20 10:49:11 2020 +0100

    efi: Merge EFI system table revision and vendor checks

so you can include a line in the signoff area saying

Fixes: 14fb42090943559 ("efi: Merge EFI system table revision and
vendor checks")


> > > ---
> > >  arch/ia64/kernel/efi.c | 11 ++++++-----
> > >  1 file changed, 6 insertions(+), 5 deletions(-)
> > >
> > > diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
> > > index c5fe21de46a8..31149e41f9be 100644
> > > --- a/arch/ia64/kernel/efi.c
> > > +++ b/arch/ia64/kernel/efi.c
> > > @@ -415,10 +415,10 @@ efi_get_pal_addr (void)
> > >                 mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
> > >
> > >                 printk(KERN_INFO "CPU %d: mapping PAL code "
> > > -                       "[0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
> > > -                       smp_processor_id(), md->phys_addr,
> > > -                       md->phys_addr + efi_md_size(md),
> > > -                       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
> > > +                       "[0x%llx-0x%llx) into [0x%llx-0x%llx)\n",
> > > +                       smp_processor_id(), md->phys_addr,
> > > +                       md->phys_addr + efi_md_size(md),
> > > +                       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
> > >  #endif
> > >                 return __va(md->phys_addr);
> > >         }
> > > @@ -560,6 +560,7 @@ efi_init (void)
> > >         {
> > >                 efi_memory_desc_t *md;
> > >                 void *p;
> > > +               unsigned int i;
> > >
> > >                 for (i = 0, p = efi_map_start; p < efi_map_end;
> > >                      ++i, p += efi_desc_size)
> > > @@ -586,7 +587,7 @@ efi_init (void)
> > >                         }
> > >
> > >                         printk("mem%02d: %s "
> > > -                              "range=[0x%016lx-0x%016lx) (%4lu%s)\n",
> > > +                              "range=[0x%016llx-0x%016llx) (%4lu%s)\n",
> > >                                i, efi_md_typeattr_format(buf, sizeof(buf), md),
> > >                                md->phys_addr,
> > >                                md->phys_addr + efi_md_size(md), size, unit);
> > > --
> > > 2.31.0
> > >
>
> --
>
>   Sergei
