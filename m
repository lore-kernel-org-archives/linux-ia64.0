From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 28 Jan 2020 07:15:41 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <ba5a836a-b594-f846-1734-71dcd5d089e6@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <115c187b-73ce-30b2-0694-999db1f2183b@c-s.fr>
 <F90DA0AA-4D27-4346-8D8D-D9A7871E2C07@lca.pw>
In-Reply-To: <F90DA0AA-4D27-4346-8D8D-D9A7871E2C07@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Qian Cai <cai@lca.pw>, Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 01/28/2020 12:06 PM, Qian Cai wrote:
>=20
>=20
>> On Jan 28, 2020, at 1:17 AM, Christophe Leroy <christophe.leroy@c-s.fr> =
wrote:
>>
>> It is 'default y' so there is no much risk that it is forgotten, at leas=
t all test suites run with 'allyes_defconfig' will trigger the test, so I t=
hink it is really a good feature.
>=20
> This thing depends on DEBUG_VM which I don=E2=80=99t see it is selected b=
y any defconfig. Am I missing anything?
>=20

'allyesconfig' makes 'DEBUG_VM =3D y' which in turn will enable 'DEBUG_VM_P=
GTABLE =3D y'
on platforms that subscribe ARCH_HAS_DEBUG_VM_PGTABLE.
