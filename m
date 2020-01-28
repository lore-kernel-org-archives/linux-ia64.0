From: Qian Cai <cai@lca.pw>
Date: Tue, 28 Jan 2020 19:07:10 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <69091BA4-18C4-4425-A5E2-31FBE4654AF9@lca.pw>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200128174709.GK655507@arrakis.emea.arm.com>
In-Reply-To: <20200128174709.GK655507@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Anshuman Khandual <Anshuman.Khandual@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Dan Williams <dan.j.williams@intel.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



> On Jan 28, 2020, at 12:47 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> 
> The primary goal here is not finding regressions but having clearly
> defined semantics of the page table accessors across architectures. x86
> and arm64 are a good starting point and other architectures will be
> enabled as they are aligned to the same semantics.

This still does not answer the fundamental question. If this test is simply inefficient to find bugs, who wants to spend time to use it regularly?  If this is just one off test that may get running once in a few years (when introducing a new arch), how does it justify the ongoing cost to maintain it?

I do agree there could be a need to clearly define this thing but that belongs to documentation rather than testing purpose. It is confusing to mix this with other config options which have somewhat a different purpose, it will then be a waste of time for people who mistakenly enable this for regular automatic testing and never found any bug from it.
