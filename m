From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Date: Wed, 29 Jan 2020 22:20:44 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <20200129232044.2d133d98@thinkpad>
List-Id: <linux-ia64.vger.kernel.org>
References: <1580174873-18117-1-git-send-email-anshuman.khandual@arm.com>
 <14882A91-17DE-4ABD-ABF2-08E7CCEDF660@lca.pw>
 <214c0d53-eb34-9b0c-2e4e-1aa005146331@arm.com>
 <016A776F-EFD9-4D2B-A3A9-788008617D95@lca.pw>
In-Reply-To: <016A776F-EFD9-4D2B-A3A9-788008617D95@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qian Cai <cai@lca.pw>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Mon, 27 Jan 2020 22:33:08 -0500
Qian Cai <cai@lca.pw> wrote:

> > 
> >> Did those tests ever find any regression or this is almost only useful for new
> > 
> > The test has already found problems with s390 page table helpers.
> 
> Hmm, that is pretty weak where s390 is not even official supported with this version.
> 

I first had to get the three patches upstream, each fixing non-conform
behavior on s390, and each issue was found by this extremely useful test:

2416cefc504b s390/mm: add mm_pxd_folded() checks to pxd_free()
2d1fc1eb9b54 s390/mm: simplify page table helpers for large entries
1c27a4bc817b s390/mm: make pmd/pud_bad() report large entries as bad

I did not see any direct effect of this misbehavior yet, but I am
very happy that this could be found and fixed in order to prevent
future issues. And this is exactly the value of this test, to make
sure that all architectures have a common understanding of how
the various page table helpers are supposed to work.

For example, who would have thought that pXd_bad() is supposed to
report large entries as bad? It's not really documented anywhere,
so we just checked them for sanity like normal entries, which
apparently worked fine so far, but for how long?
