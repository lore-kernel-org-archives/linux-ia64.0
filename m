From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Date: Mon, 10 Dec 2018 16:48:25 +0000
Subject: Re: [PATCH] mm/zsmalloc.c: Fix zsmalloc 32-bit PAE support
Message-Id: <32747ea1-7437-8055-a4f5-9f22378e57ae@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181210142105.6750-1-rafael.tinoco@linaro.org>
 <20181210151506.phyjkfcg3skogtyh@kshutemo-mobl1>
In-Reply-To: <20181210151506.phyjkfcg3skogtyh@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Ram Pai <linuxram@us.ibm.com>, linux-mips@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid.aziz@oracle.com>, Paul Mackerras <paulus@samba.org>, "H . Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Hogan <jhogan@kernel.org>, Anthony Yznaga <anthony.yznaga@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Fenghua Yu <fenghua.yu@intel.com>, Joerg Roedel <jroedel@suse.de>, Rafael David Tinoco <rafael.tinoco@linaro.org>, Juergen Gross <jgross@suse.com>, Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>, Nicholas Piggin <npiggin@gmail.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Jiri Kosina <jkosina@suse.cz>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Minchan Kim <minchan@kernel.org>, Paul Burton <paul.burton@mips.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, "David S . Miller" <davem@davemloft.net>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 12/10/18 1:15 PM, Kirill A. Shutemov wrote:
> On Mon, Dec 10, 2018 at 12:21:05PM -0200, Rafael David Tinoco wrote:
>> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
>> index 84bd9bdc1987..d808cfde3d19 100644
>> --- a/arch/x86/include/asm/pgtable_64_types.h
>> +++ b/arch/x86/include/asm/pgtable_64_types.h
>> @@ -64,8 +64,6 @@ extern unsigned int ptrs_per_p4d;
>>  #define P4D_SIZE		(_AC(1, UL) << P4D_SHIFT)
>>  #define P4D_MASK		(~(P4D_SIZE - 1))
>>  
>> -#define MAX_POSSIBLE_PHYSMEM_BITS	52
>> -
>>  #else /* CONFIG_X86_5LEVEL */
>>  
>>  /*
>> @@ -154,4 +152,6 @@ extern unsigned int ptrs_per_p4d;
>>  
>>  #define PGD_KERNEL_START	((PAGE_SIZE / 2) / sizeof(pgd_t))
>>  
>> +#define MAX_POSSIBLE_PHYSMEM_BITS (pgtable_l5_enabled() ? 52 : 46)
>> +
> 
> ...
> 
>>  #endif /* _ASM_X86_PGTABLE_64_DEFS_H */
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index 0787d33b80d8..132c20b6fd4f 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
> 
> ...
> 
>> @@ -116,6 +100,25 @@
>>   */
>>  #define OBJ_ALLOCATED_TAG 1
>>  #define OBJ_TAG_BITS 1
>> +
>> +/*
>> + * MAX_POSSIBLE_PHYSMEM_BITS should be defined by all archs using zsmalloc:
>> + * Trying to guess it from MAX_PHYSMEM_BITS, or considering it BITS_PER_LONG,
>> + * proved to be wrong by not considering PAE capabilities, or using SPARSEMEM
>> + * only headers, leading to bad object encoding due to object index overflow.
>> + */
>> +#ifndef MAX_POSSIBLE_PHYSMEM_BITS
>> + #define MAX_POSSIBLE_PHYSMEM_BITS BITS_PER_LONG
>> + #error "MAX_POSSIBLE_PHYSMEM_BITS HAS to be defined by arch using zsmalloc";
>> +#else
>> + #ifndef CONFIG_64BIT
>> +  #if (MAX_POSSIBLE_PHYSMEM_BITS >= (BITS_PER_LONG + PAGE_SHIFT - OBJ_TAG_BITS))
>> +   #error "MAX_POSSIBLE_PHYSMEM_BITS is wrong for this arch";
>> +  #endif
>> + #endif
>> +#endif
>> +
>> +#define _PFN_BITS (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)
>>  #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
>>  #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
> 
> Have you tested it with CONFIG_X86_5LEVEL=y?
> 
> ASAICS, the patch makes OBJ_INDEX_BITS and what depends from it dynamic --
> it depends what paging mode we are booting in. ZS_SIZE_CLASSES depends
> indirectly on OBJ_INDEX_BITS and I don't see how struct zs_pool definition
> can compile with dynamic ZS_SIZE_CLASSES.
> 
> Hm?
> 

You're right, terribly sorry. This was a last time change.

mm/zsmalloc.c:256:21: error: variably modified ‘size_class’ at file scope

I'll revisit the patch. Any other comments are welcome.

Thank you
