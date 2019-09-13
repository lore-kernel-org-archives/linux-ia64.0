From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Fri, 13 Sep 2019 09:13:05 +0000
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <20190913091305.rkds4f3fqv3yjhjy@box>
List-Id: <linux-ia64.vger.kernel.org>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <ab0ca38b-1e4f-b636-f8b4-007a15903984@c-s.fr>
 <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
In-Reply-To: <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Fri, Sep 13, 2019 at 02:32:04PM +0530, Anshuman Khandual wrote:
>=20
> On 09/12/2019 10:44 PM, Christophe Leroy wrote:
> >=20
> >=20
> > Le 12/09/2019 =E0 08:02, Anshuman Khandual a =E9crit=A0:
> >> This adds a test module which will validate architecture page table he=
lpers
> >> and accessors regarding compliance with generic MM semantics expectati=
ons.
> >> This will help various architectures in validating changes to the exis=
ting
> >> page table helpers or addition of new ones.
> >>
> >> Test page table and memory pages creating it's entries at various leve=
l are
> >> all allocated from system memory with required alignments. If memory p=
ages
> >> with required size and alignment could not be allocated, then all depe=
nding
> >> individual tests are skipped.
> >>
> >=20
> > [...]
> >=20
> >>
> >> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> >> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> >> ---
> >> =A0 arch/x86/include/asm/pgtable_64_types.h |=A0=A0 2 +
> >> =A0 mm/Kconfig.debug=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 |=A0 14 +
> >> =A0 mm/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=A0 1 +
> >> =A0 mm/arch_pgtable_test.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 | 429 ++++++++++++++++++++++++
> >> =A0 4 files changed, 446 insertions(+)
> >> =A0 create mode 100644 mm/arch_pgtable_test.c
> >>
> >> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/includ=
e/asm/pgtable_64_types.h
> >> index 52e5f5f2240d..b882792a3999 100644
> >> --- a/arch/x86/include/asm/pgtable_64_types.h
> >> +++ b/arch/x86/include/asm/pgtable_64_types.h
> >> @@ -40,6 +40,8 @@ static inline bool pgtable_l5_enabled(void)
> >> =A0 #define pgtable_l5_enabled() 0
> >> =A0 #endif /* CONFIG_X86_5LEVEL */
> >> =A0 +#define mm_p4d_folded(mm) (!pgtable_l5_enabled())
> >> +
> >=20
> > This is specific to x86, should go in a separate patch.
>=20
> Thought about it but its just a single line. Kirill suggested this in the
> previous version. There is a generic fallback definition but s390 has it's
> own. This change overrides the generic one for x86 probably as a fix or as
> an improvement. Kirill should be able to help classify it in which case it
> can be a separate patch.

I don't think it worth a separate patch.

--=20
 Kirill A. Shutemov
