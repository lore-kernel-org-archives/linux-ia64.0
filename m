From: Mike Rapoport <rppt@linux.ibm.com>
Date: Tue, 24 Sep 2019 12:31:47 +0000
Subject: Re: [PATCH V3 0/2] mm/debug: Add tests for architecture exported page table helpers
Message-Id: <20190924123146.GC5202@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1568961203-18660-1-git-send-email-anshuman.khandual@arm.com>
 <20190924115101.p6y7vpbtgmj5qjku@box>
In-Reply-To: <20190924115101.p6y7vpbtgmj5qjku@box>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue, Sep 24, 2019 at 02:51:01PM +0300, Kirill A. Shutemov wrote:
> On Fri, Sep 20, 2019 at 12:03:21PM +0530, Anshuman Khandual wrote:
> > This series adds a test validation for architecture exported page table
> > helpers. Patch in the series adds basic transformation tests at various
> > levels of the page table. Before that it exports gigantic page allocation
> > function from HugeTLB.
> > 
> > This test was originally suggested by Catalin during arm64 THP migration
> > RFC discussion earlier. Going forward it can include more specific tests
> > with respect to various generic MM functions like THP, HugeTLB etc and
> > platform specific tests.
> > 
> > https://lore.kernel.org/linux-mm/20190628102003.GA56463@arrakis.emea.arm.com/
> > 
> > Testing:
> > 
> > Successfully build and boot tested on both arm64 and x86 platforms without
> > any test failing. Only build tested on some other platforms. Build failed
> > on some platforms (known) in pud_clear_tests() as there were no available
> > __pgd() definitions.
> > 
> > - ARM32
> > - IA64
> 
> Hm. Grep shows __pgd() definitions for both of them. Is it for specific
> config?
 
For ARM32 it's defined only for 3-lelel page tables, i.e with LPAE on.
For IA64 it's defined for !STRICT_MM_TYPECHECKS which is even not a config
option, but a define in arch/ia64/include/asm/page.h
 
> -- 
>  Kirill A. Shutemov

-- 
Sincerely yours,
Mike.
