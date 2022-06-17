From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 17 Jun 2022 15:26:31 +0000
Subject: Re: [PATCH 1/4] hugetlb: skip to end of PT page mapping when pte not present
Message-Id: <CAMuHMdU-qdNMqwtpm+PMixKoicYHPokAQqWAh-Vw-sjZz_z7xA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220616210518.125287-1-mike.kravetz@oracle.com>
 <20220616210518.125287-2-mike.kravetz@oracle.com> <YqyMhmAjrQ4C+EyA@xz-m1.local>
In-Reply-To: <YqyMhmAjrQ4C+EyA@xz-m1.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Peter,

On Fri, Jun 17, 2022 at 4:22 PM Peter Xu <peterx@redhat.com> wrote:
> On Thu, Jun 16, 2022 at 02:05:15PM -0700, Mike Kravetz wrote:
> > @@ -6877,6 +6896,39 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
> >       return (pte_t *)pmd;
> >  }
> >
> > +/*
> > + * Return a mask that can be used to update an address to the last huge
> > + * page in a page table page mapping size.  Used to skip non-present
> > + * page table entries when linearly scanning address ranges.  Architectures
> > + * with unique huge page to page table relationships can define their own
> > + * version of this routine.
> > + */
> > +unsigned long hugetlb_mask_last_page(struct hstate *h)
> > +{
> > +     unsigned long hp_size = huge_page_size(h);
> > +
> > +     switch (hp_size) {
> > +     case P4D_SIZE:
> > +             return PGDIR_SIZE - P4D_SIZE;
> > +     case PUD_SIZE:
> > +             return P4D_SIZE - PUD_SIZE;
> > +     case PMD_SIZE:
> > +             return PUD_SIZE - PMD_SIZE;
> > +     default:
>
> Should we add a WARN_ON_ONCE() if it should never trigger?

And with panic_on_warn, it'll panic only once ;-)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
