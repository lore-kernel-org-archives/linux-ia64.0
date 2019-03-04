From: Steven Price <steven.price@arm.com>
Date: Mon, 04 Mar 2019 13:16:47 +0000
Subject: Re: [PATCH v3 08/34] ia64: mm: Add p?d_large() definitions
Message-Id: <15100043-26e4-2ee1-28fe-101e12f74926@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-9-steven.price@arm.com>
 <20190301215728.nk7466zohdlgelcb@kshutemo-mobl1>
In-Reply-To: <20190301215728.nk7466zohdlgelcb@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, "Liang, Kan" <kan.liang@linux.intel.com>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, James Morse <james.morse@arm.com>

On 01/03/2019 21:57, Kirill A. Shutemov wrote:
> On Wed, Feb 27, 2019 at 05:05:42PM +0000, Steven Price wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_large() functions/macros.
>>
>> For ia64 leaf entries are always at the lowest level, so implement
>> stubs returning 0.
> 
> Are you sure about this? I see pte_mkhuge defined for ia64 and Kconfig
> contains hugetlb references.
> 

I'm not completely familiar with ia64, but my understanding is that it
doesn't have the situation where a page table walk ends early - there is
always the full depth of entries. The p?d_huge() functions always return 0.

However my understanding is that it does support huge TLB entries, so
when populating the TLB a region larger than a standard page can be mapped.

I'd definitely welcome review by someone more familiar with ia64 to
check my assumptions.

Thanks,

Steve
