From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 28 Jan 2020 03:18:03 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <214c0d53-eb34-9b0c-2e4e-1aa005146331@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1580174873-18117-1-git-send-email-anshuman.khandual@arm.com>
 <14882A91-17DE-4ABD-ABF2-08E7CCEDF660@lca.pw>
In-Reply-To: <14882A91-17DE-4ABD-ABF2-08E7CCEDF660@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Qian Cai <cai@lca.pw>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 01/28/2020 07:41 AM, Qian Cai wrote:
>=20
>=20
>> On Jan 27, 2020, at 8:28 PM, Anshuman Khandual <Anshuman.Khandual@arm.co=
m> wrote:
>>
>> This adds tests which will validate architecture page table helpers and
>> other accessors in their compliance with expected generic MM semantics.
>> This will help various architectures in validating changes to existing
>> page table helpers or addition of new ones.
>>
>> This test covers basic page table entry transformations including but not
>> limited to old, young, dirty, clean, write, write protect etc at various
>> level along with populating intermediate entries with next page table pa=
ge
>> and validating them.
>>
>> Test page table pages are allocated from system memory with required size
>> and alignments. The mapped pfns at page table levels are derived from a
>> real pfn representing a valid kernel text symbol. This test gets called
>> right after page_alloc_init_late().
>>
>> This gets build and run when CONFIG_DEBUG_VM_PGTABLE is selected along w=
ith
>> CONFIG_VM_DEBUG. Architectures willing to subscribe this test also need =
to
>> select CONFIG_ARCH_HAS_DEBUG_VM_PGTABLE which for now is limited to x86 =
and
>> arm64. Going forward, other architectures too can enable this after fixi=
ng
>> build or runtime problems (if any) with their page table helpers.

Hello Qian,

>=20
> What=E2=80=99s the value of this block of new code? It only supports x86 =
and arm64
> which are supposed to be good now.

We have been over the usefulness of this code many times before as the patc=
h is
already in it's V12. Currently it is enabled on arm64, x86 (except PAE), ar=
c and
ppc32. There are build time or runtime problems with other archs which prev=
ent
enablement of this test (for the moment) but then the goal is to integrate =
all
of them going forward. The test not only validates platform's adherence to =
the
expected semantics from generic MM but also helps in keeping it that way du=
ring
code changes in future as well.

> Did those tests ever find any regression or this is almost only useful fo=
r new

The test has already found problems with s390 page table helpers.

> architectures which only happened once in a few years?

Again, not only it validates what exist today but its also a tool to make
sure that all platforms continue adhere to a common agreed upon semantics
as reflected through the tests here.

> The worry if not many people will use this config and code those that muc=
h in

Debug features or tests in the kernel are used when required. These are nev=
er or
should not be enabled by default. AFAICT this is true even for entire DEBUG=
_VM
packaged tests. Do you have any particular data or precedence to substantia=
te
the fact that this test will be used any less often than the other similar =
ones
in the tree ? I can only speak for arm64 platform but the very idea for this
test came from Catalin when we were trying to understand the semantics for =
THP
helpers while enabling THP migration without split. Apart from going over t=
he
commit messages from the past, there were no other way to figure out how any
particular page table helper is suppose to change given page table entry. T=
his
test tries to formalize those semantics.

> the future because it is inefficient to find bugs, it will simply be rott=
en
Could you be more specific here ? What parts of the test are inefficient ? I
am happy to improve upon the test. Do let me know you if you have suggestio=
ns.

> like a few other debugging options out there we have in the mainline that
will be a pain to remove later on.
>

Even though I am not agreeing to your assessment about the usefulness of the
test without any substantial data backing up the claims, the test case in
itself is very much compartmentalized, staying clear from generic MM and
debug_vm_pgtable() is only function executing the test which is getting
called from kernel_init_freeable() path.

- Anshuman
