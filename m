From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Fri, 13 Sep 2019 08:51:35 +0000
Subject: Re: [PATCH] mm/pgtable/debug: Fix test validating architecture page table helpers
Message-Id: <20190913085135.rfr3zrabghi2qo2t@box>
List-Id: <linux-ia64.vger.kernel.org>
References: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
 <527dd29d-45fa-4d83-1899-6cbf268dd749@arm.com>
 <e2b42446-7f91-83f1-ac12-08dff75c4d35@c-s.fr>
 <cb226b56-ff20-3136-7ffb-890657e56870@c-s.fr>
 <bdf7f152-d093-1691-4e96-77da7eb9e20a@arm.com>
In-Reply-To: <bdf7f152-d093-1691-4e96-77da7eb9e20a@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Fri, Sep 13, 2019 at 02:12:45PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 09/13/2019 12:41 PM, Christophe Leroy wrote:
> >=20
> >=20
> > Le 13/09/2019 =E0 09:03, Christophe Leroy a =E9crit=A0:
> >>
> >>
> >> Le 13/09/2019 =E0 08:58, Anshuman Khandual a =E9crit=A0:
> >>> On 09/13/2019 11:53 AM, Christophe Leroy wrote:
> >>>> Fix build failure on powerpc.
> >>>>
> >>>> Fix preemption imbalance.
> >>>>
> >>>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> >>>> ---
> >>>> =A0 mm/arch_pgtable_test.c | 3 +++
> >>>> =A0 1 file changed, 3 insertions(+)
> >>>>
> >>>> diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
> >>>> index 8b4a92756ad8..f2b3c9ec35fa 100644
> >>>> --- a/mm/arch_pgtable_test.c
> >>>> +++ b/mm/arch_pgtable_test.c
> >>>> @@ -24,6 +24,7 @@
> >>>> =A0 #include <linux/swap.h>
> >>>> =A0 #include <linux/swapops.h>
> >>>> =A0 #include <linux/sched/mm.h>
> >>>> +#include <linux/highmem.h>
> >>>
> >>> This is okay.
> >>>
> >>>> =A0 #include <asm/pgalloc.h>
> >>>> =A0 #include <asm/pgtable.h>
> >>>> @@ -400,6 +401,8 @@ static int __init arch_pgtable_tests_init(void)
> >>>> =A0=A0=A0=A0=A0 p4d_clear_tests(p4dp);
> >>>> =A0=A0=A0=A0=A0 pgd_clear_tests(mm, pgdp);
> >>>> +=A0=A0=A0 pte_unmap(ptep);
> >>>> +
> >>>
> >>> Now the preemption imbalance via pte_alloc_map() path i.e
> >>>
> >>> pte_alloc_map() -> pte_offset_map() -> kmap_atomic()
> >>>
> >>> Is not this very much powerpc 32 specific or this will be applicable
> >>> for all platform which uses kmap_XXX() to map high memory ?
> >>>
> >>
> >> See https://elixir.bootlin.com/linux/v5.3-rc8/source/include/linux/hig=
hmem.h#L91
> >>
> >> I think it applies at least to all arches using the generic implementa=
tion.
> >>
> >> Applies also to arm:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/arm/mm/highmem.c=
#L52
> >>
> >> Applies also to mips:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/mips/mm/highmem.=
c#L47
> >>
> >> Same on sparc:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/sparc/mm/highmem=
.c#L52
> >>
> >> Same on x86:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/x86/mm/highmem_3=
2.c#L34
> >>
> >> I have not checked others, but I guess it is like that for all.
> >>
> >=20
> >=20
> > Seems like I answered too quickly. All kmap_atomic() do preempt_disable=
(), but not all pte_alloc_map() call kmap_atomic().
> >=20
> > However, for instance ARM does:
> >=20
> > https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/arm/include/asm/p=
gtable.h#L200
> >=20
> > And X86 as well:
> >=20
> > https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/x86/include/asm/p=
gtable_32.h#L51
> >=20
> > Microblaze also:
> >=20
> > https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/microblaze/includ=
e/asm/pgtable.h#L495
>=20
> All the above platforms checks out to be using k[un]map_atomic(). I am wo=
ndering whether
> any of the intermediate levels will have similar problems on any these 32=
 bit platforms
> or any other platforms which might be using generic k[un]map_atomic().

No. Kernel only allocates pte page table from highmem. All other page
tables are always visible in kernel address space.

--=20
 Kirill A. Shutemov
