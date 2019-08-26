From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 26 Aug 2019 02:41:36 +0000
Subject: Re: [RFC V2 0/1] mm/debug: Add tests for architecture exported page table helpers
Message-Id: <652ae041-2033-1cf8-e559-6dcf85dd2fdd@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
 <20190809101632.GM5482@bombadil.infradead.org>
 <20190809114450.GF48423@lakrids.cambridge.arm.com>
In-Reply-To: <20190809114450.GF48423@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Rutland <mark.rutland@arm.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 08/09/2019 05:14 PM, Mark Rutland wrote:
> On Fri, Aug 09, 2019 at 03:16:33AM -0700, Matthew Wilcox wrote:
>> On Fri, Aug 09, 2019 at 01:03:17PM +0530, Anshuman Khandual wrote:
>>> Should alloc_gigantic_page() be made available as an interface for general
>>> use in the kernel. The test module here uses very similar implementation from
>>> HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
>>> needs to be exported through a header.
>>
>> Why are you allocating memory at all instead of just using some
>> known-to-exist PFNs like I suggested?
> 
> IIUC the issue is that there aren't necessarily known-to-exist PFNs that
> are sufficiently aligned -- they may not even exist.
> 
> For example, with 64K pages, a PMD covers 512M. The kernel image is
> (generally) smaller than 512M, and will be mapped at page granularity.
> In that case, any PMD entry for a kernel symbol address will point to
> the PTE level table, and that will only necessarily be page-aligned, as
> any P?D level table is only necessarily page-aligned.

Right.

> 
> In the same configuration, you could have less than 512M of total
> memory, and none of this memory is necessarily aligned to 512M. So
> beyond the PTE level, I don't think you can guarantee a known-to-exist
> valid PFN.
Right a PMD aligned valid PFN might not even exist. This proposed patch
which attempts to allocate memory chunk with required alignment will just
fail indicating that such a valid PFN does not exist and hence will skip
any relevant tests. At present this is done for PUD aligned allocation
failure but we can similarly skip PMD relevant tests as well if PMD
aligned memory chunk is not allocated.

> 
> I also believe that synthetic PFNs could fail pfn_valid(), so that might
> cause us pain too...

Agreed. So do we have an agreement that it is better to use allocated
memory with required alignment for the tests than known-to-exist PFNs ?

- Anshuman
