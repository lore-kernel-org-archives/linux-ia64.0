From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 30 Jan 2020 13:44:18 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <d1668930-d9cf-0490-a100-d1c49b49b19f@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1580174873-18117-1-git-send-email-anshuman.khandual@arm.com>
 <14882A91-17DE-4ABD-ABF2-08E7CCEDF660@lca.pw>
 <214c0d53-eb34-9b0c-2e4e-1aa005146331@arm.com>
 <016A776F-EFD9-4D2B-A3A9-788008617D95@lca.pw>
 <20200129232044.2d133d98@thinkpad> <20200130072741.GA23707@linux.ibm.com>
In-Reply-To: <20200130072741.GA23707@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Qian Cai <cai@lca.pw>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 01/30/2020 12:57 PM, Mike Rapoport wrote:
> On Wed, Jan 29, 2020 at 11:20:44PM +0100, Gerald Schaefer wrote:
>> On Mon, 27 Jan 2020 22:33:08 -0500
>>
>> For example, who would have thought that pXd_bad() is supposed to
>> report large entries as bad? It's not really documented anywhere,
> 
> A bit off-topic,
> 
> @Anshuman, maybe you could start a Documentation/ patch that describes at
> least some of the pXd_whaterver()?
> Or that would be too much to ask? ;-)

No, it would not be :) I have been documenting the expected semantics for
the helpers in the test itself. The idea is to collate them all (have been
working on some additional tests but waiting for this one to get merged
first) here and once most of the test gets settled, will move semantics
documentation from here into Documentation/ directory in a proper format.

/*
 * Basic operations
 *
 * mkold(entry)			= An old and not a young entry
 * mkyoung(entry)		= A young and not an old entry
 * mkdirty(entry)		= A dirty and not a clean entry
 * mkclean(entry)		= A clean and not a dirty entry
 * mkwrite(entry)		= A write and not a write protected entry
 * wrprotect(entry)		= A write protected and not a write entry
 * pxx_bad(entry)		= A mapped and non-table entry
 * pxx_same(entry1, entry2)	= Both entries hold the exact same value
 */ 



> 
>> so we just checked them for sanity like normal entries, which
>> apparently worked fine so far, but for how long?
> 
