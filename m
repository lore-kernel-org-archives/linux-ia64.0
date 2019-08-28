From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Wed, 28 Aug 2019 09:34:54 +0000
Subject: Re: [RFC V2 0/1] mm/debug: Add tests for architecture exported page table helpers
Message-Id: <504f891e-7346-7328-74b0-7df3acc230e8@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
 <20190809101632.GM5482@bombadil.infradead.org>
 <a5aab7ff-f7fd-9cc1-6e37-e4185eee65ac@arm.com>
 <20190809135202.GN5482@bombadil.infradead.org>
 <7a88f6bb-e8c7-3ac7-2f92-1de752a01f33@arm.com>
 <20190826131308.GA15933@bombadil.infradead.org>
In-Reply-To: <20190826131308.GA15933@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 08/26/2019 06:43 PM, Matthew Wilcox wrote:
> On Mon, Aug 26, 2019 at 08:07:13AM +0530, Anshuman Khandual wrote:
>> On 08/09/2019 07:22 PM, Matthew Wilcox wrote:
>>> On Fri, Aug 09, 2019 at 04:05:07PM +0530, Anshuman Khandual wrote:
>>>> On 08/09/2019 03:46 PM, Matthew Wilcox wrote:
>>>>> On Fri, Aug 09, 2019 at 01:03:17PM +0530, Anshuman Khandual wrote:
>>>>>> Should alloc_gigantic_page() be made available as an interface for general
>>>>>> use in the kernel. The test module here uses very similar implementation from
>>>>>> HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
>>>>>> needs to be exported through a header.
>>>>>
>>>>> Why are you allocating memory at all instead of just using some
>>>>> known-to-exist PFNs like I suggested?
>>>>
>>>> We needed PFN to be PUD aligned for pfn_pud() and PMD aligned for mk_pmd().
>>>> Now walking the kernel page table for a known symbol like kernel_init()
>>>
>>> I didn't say to walk the kernel page table.  I said to call virt_to_pfn()
>>> for a known symbol like kernel_init().
>>>
>>>> as you had suggested earlier we might encounter page table page entries at PMD
>>>> and PUD which might not be PMD or PUD aligned respectively. It seemed to me
>>>> that alignment requirement is applicable only for mk_pmd() and pfn_pud()
>>>> which create large mappings at those levels but that requirement does not
>>>> exist for page table pages pointing to next level. Is not that correct ? Or
>>>> I am missing something here ?
>>>
>>> Just clear the bottom bits off the PFN until you get a PMD or PUD aligned
>>> PFN.  It's really not hard.
>>
>> As Mark pointed out earlier that might end up being just a synthetic PFN
>> which might not even exist on a given system.
> 
> And why would that matter?
> 

To start with the test uses struct page with mk_pte() and mk_pmd() while
pfn gets used in pfn_pud() during pXX_basic_tests(). So we will not be able
to derive a valid struct page from a synthetic pfn. Also if synthetic pfn is
going to be used anyway then why derive it from a real kernel symbol like
kernel_init(). Could not one be just made up with right alignment ?

Currently the test allocates 'mm_struct' and other page table pages from real
memory then why should it use synthetic pfn while creating actual page table
entries ? Couple of benefits going with synthetic pfn will be..

- It simplifies the test a bit removing PUD_SIZE allocation helpers
- It might enable the test to be run on systems without adequate memory

In the current proposal the allocation happens during boot making it much more
likely to succeed than not and when it fails, respective tests will be skipped.

I am just wondering if being able to run complete set of tests on smaller
systems with less memory weighs lot more in favor of going with synthetic
pfn instead.
