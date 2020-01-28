From: Catalin Marinas <catalin.marinas@arm.com>
Date: Tue, 28 Jan 2020 17:47:09 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <20200128174709.GK655507@arrakis.emea.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1580174873-18117-1-git-send-email-anshuman.khandual@arm.com>
 <14882A91-17DE-4ABD-ABF2-08E7CCEDF660@lca.pw>
In-Reply-To: <14882A91-17DE-4ABD-ABF2-08E7CCEDF660@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Qian Cai <cai@lca.pw>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Anshuman Khandual <Anshuman.Khandual@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Dan Williams <dan.j.williams@intel.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Mon, Jan 27, 2020 at 09:11:53PM -0500, Qian Cai wrote:
> On Jan 27, 2020, at 8:28 PM, Anshuman Khandual <Anshuman.Khandual@arm.com=
> wrote:
> > This adds tests which will validate architecture page table helpers and
> > other accessors in their compliance with expected generic MM semantics.
> > This will help various architectures in validating changes to existing
> > page table helpers or addition of new ones.
[...]
> What=E2=80=99s the value of this block of new code? It only supports x86 =
and
> arm64 which are supposed to be good now. Did those tests ever find any
> regression or this is almost only useful for new architectures which
> only happened once in a few years?

The primary goal here is not finding regressions but having clearly
defined semantics of the page table accessors across architectures. x86
and arm64 are a good starting point and other architectures will be
enabled as they are aligned to the same semantics.

See for example this past discussion:

https://lore.kernel.org/linux-mm/20190628102003.GA56463@arrakis.emea.arm.co=
m/

These tests should act as the 'contract' between the generic mm code and
the architecture port. Without clear semantics, some bugs may be a lot
subtler than a boot failure.

FTR, I fully support this patch (and I should get around to review it
properly; thanks for the reminder ;)).

--=20
Catalin
