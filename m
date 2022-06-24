From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Fri, 24 Jun 2022 05:32:33 +0000
Subject: Re: [PATCH V4 00/26] mm/mmap: Drop __SXXX/__PXXX macros from across platforms
Message-Id: <33bdac1e-207a-192b-bf43-818abfa49fe1@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624044339.1533882-1-anshuman.khandual@arm.com>
 <YrVHvv0spuMsC1In@infradead.org>
In-Reply-To: <YrVHvv0spuMsC1In@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, christophe.leroy@csgroup.eu, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org



On 6/24/22 10:42, Christoph Hellwig wrote:
> On Fri, Jun 24, 2022 at 10:13:13AM +0530, Anshuman Khandual wrote:
>> vm_get_page_prot(), in order for it to be reused on platforms that do not
>> require custom implementation. Finally, ARCH_HAS_VM_GET_PAGE_PROT can just
>> be dropped, as all platforms now define and export vm_get_page_prot(), via
>> looking up a private and static protection_map[] array. protection_map[]
>> data type is the following for all platforms without deviation (except the
>> powerpc one which is shared between 32 and 64 bit platforms), keeping it
>> unchanged for now.
>>
>> static pgprot_t protection_map[16] __ro_after_init
> 
> On most architectures this should be const now, only very few ever
> modify it.

Will make it a 'static const pgprot_t protection_map[16] __ro_after_init'
on platforms that do not change the protection_map[] even during boot.
