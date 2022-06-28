From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 28 Jun 2022 03:24:24 +0000
Subject: Re: [PATCH V5 04/26] sparc/mm: Move protection_map[] inside the platform
Message-Id: <f26804cf-e342-5826-8f01-4b087a7baa63@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220627045833.1590055-1-anshuman.khandual@arm.com>
 <20220627045833.1590055-5-anshuman.khandual@arm.com>
 <YrnlkLbyYSbI0EQw@ravnborg.org>
In-Reply-To: <YrnlkLbyYSbI0EQw@ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: linux-mm@kvack.org, hch@infradead.org, christophe.leroy@csgroup.eu, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>



On 6/27/22 22:44, Sam Ravnborg wrote:
> Hi Anshuman,
> 
> On Mon, Jun 27, 2022 at 10:28:11AM +0530, Anshuman Khandual wrote:
>> This moves protection_map[] inside the platform and while here, also enable
>> ARCH_HAS_VM_GET_PAGE_PROT on 32 bit platforms via DECLARE_VM_GET_PAGE_PROT.
>>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: sparclinux@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>  arch/sparc/Kconfig                  |  2 +-
>>  arch/sparc/include/asm/pgtable_32.h | 19 -------------------
>>  arch/sparc/include/asm/pgtable_64.h | 19 -------------------
>>  arch/sparc/mm/init_32.c             | 20 ++++++++++++++++++++
>>  arch/sparc/mm/init_64.c             |  3 +++
>>  5 files changed, 24 insertions(+), 39 deletions(-)
>>
>> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
>> index ba449c47effd..09f868613a4d 100644
>> --- a/arch/sparc/Kconfig
>> +++ b/arch/sparc/Kconfig
>> @@ -13,6 +13,7 @@ config 64BIT
>>  config SPARC
>>  	bool
>>  	default y
>> +	select ARCH_HAS_VM_GET_PAGE_PROT
>>  	select ARCH_MIGHT_HAVE_PC_PARPORT if SPARC64 && PCI
>>  	select ARCH_MIGHT_HAVE_PC_SERIO
>>  	select DMA_OPS
>> @@ -84,7 +85,6 @@ config SPARC64
>>  	select PERF_USE_VMALLOC
>>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
>>  	select HAVE_C_RECORDMCOUNT
>> -	select ARCH_HAS_VM_GET_PAGE_PROT
>>  	select HAVE_ARCH_AUDITSYSCALL
>>  	select ARCH_SUPPORTS_ATOMIC_RMW
>>  	select ARCH_SUPPORTS_DEBUG_PAGEALLOC
>> diff --git a/arch/sparc/include/asm/pgtable_32.h b/arch/sparc/include/asm/pgtable_32.h
>> index 4866625da314..8ff549004fac 100644
>> --- a/arch/sparc/include/asm/pgtable_32.h
>> +++ b/arch/sparc/include/asm/pgtable_32.h
>> @@ -64,25 +64,6 @@ void paging_init(void);
>>  
>>  extern unsigned long ptr_in_current_pgd;
>>  
>> -/*         xwr */
>> -#define __P000  PAGE_NONE
>> -#define __P001  PAGE_READONLY
>> -#define __P010  PAGE_COPY
>> -#define __P011  PAGE_COPY
>> -#define __P100  PAGE_READONLY
>> -#define __P101  PAGE_READONLY
>> -#define __P110  PAGE_COPY
>> -#define __P111  PAGE_COPY
>> -
>> -#define __S000	PAGE_NONE
>> -#define __S001	PAGE_READONLY
>> -#define __S010	PAGE_SHARED
>> -#define __S011	PAGE_SHARED
>> -#define __S100	PAGE_READONLY
>> -#define __S101	PAGE_READONLY
>> -#define __S110	PAGE_SHARED
>> -#define __S111	PAGE_SHARED
>> -
>>  /* First physical page can be anywhere, the following is needed so that
>>   * va-->pa and vice versa conversions work properly without performance
>>   * hit for all __pa()/__va() operations.
>> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
>> index 4679e45c8348..a779418ceba9 100644
>> --- a/arch/sparc/include/asm/pgtable_64.h
>> +++ b/arch/sparc/include/asm/pgtable_64.h
>> @@ -187,25 +187,6 @@ bool kern_addr_valid(unsigned long addr);
>>  #define _PAGE_SZHUGE_4U	_PAGE_SZ4MB_4U
>>  #define _PAGE_SZHUGE_4V	_PAGE_SZ4MB_4V
>>  
>> -/* These are actually filled in at boot time by sun4{u,v}_pgprot_init() */
>> -#define __P000	__pgprot(0)
>> -#define __P001	__pgprot(0)
>> -#define __P010	__pgprot(0)
>> -#define __P011	__pgprot(0)
>> -#define __P100	__pgprot(0)
>> -#define __P101	__pgprot(0)
>> -#define __P110	__pgprot(0)
>> -#define __P111	__pgprot(0)
>> -
>> -#define __S000	__pgprot(0)
>> -#define __S001	__pgprot(0)
>> -#define __S010	__pgprot(0)
>> -#define __S011	__pgprot(0)
>> -#define __S100	__pgprot(0)
>> -#define __S101	__pgprot(0)
>> -#define __S110	__pgprot(0)
>> -#define __S111	__pgprot(0)
>> -
>>  #ifndef __ASSEMBLY__
>>  
>>  pte_t mk_pte_io(unsigned long, pgprot_t, int, unsigned long);
>> diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
>> index 1e9f577f084d..8693e4e28b86 100644
>> --- a/arch/sparc/mm/init_32.c
>> +++ b/arch/sparc/mm/init_32.c
>> @@ -302,3 +302,23 @@ void sparc_flush_page_to_ram(struct page *page)
>>  		__flush_page_to_ram(vaddr);
>>  }
>>  EXPORT_SYMBOL(sparc_flush_page_to_ram);
>> +
>> +static pgprot_t protection_map[16] __ro_after_init = {
> This can be const - like done for powerpc and others.
> sparc32 and sparc64 uses each their own - and I do not see sparc32 do
> any modifications to protection_map.

Indeed protection_map[] arrays are independent both for sparc32 and spacr64.
sparc32 platform never changes the protection_map[] array during boot. Sure,
will make it into a const instead. Thanks for pointing this out.

> 
> With this change:
> Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
> 
