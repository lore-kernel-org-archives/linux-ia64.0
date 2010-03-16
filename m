From: Becky Bruce <beckyb@kernel.crashing.org>
Date: Tue, 16 Mar 2010 19:28:09 +0000
Subject: Re: [PATCH v4 05/11] swiotlb: add swiotlb_set_default_size()
Message-Id: <C200C089-E6B9-4836-A7B5-3233EB2CE5FB@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1268421166-4791-6-git-send-email-albert_herranz@yahoo.es> <20100316104440Y.fujita.tomonori@lab.ntt.co.jp> <4B9F1E11.80201@yahoo.es> <20100316190805Z.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100316190805Z.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: albert_herranz@yahoo.es, benh@kernel.crashing.org, linux-usb@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org


On Mar 16, 2010, at 5:08 AM, FUJITA Tomonori wrote:

> On Tue, 16 Mar 2010 06:58:41 +0100
> Albert Herranz <albert_herranz@yahoo.es> wrote:
>
>> FUJITA Tomonori wrote:
>>> On Fri, 12 Mar 2010 20:12:40 +0100
>>> Albert Herranz <albert_herranz@yahoo.es> wrote:
>>>
>>>> The current SWIOTLB code uses a default of 64MB for the IO TLB  
>>>> area.
>>>> This size can be influenced using a kernel command line parameter  
>>>> "swiotlb".
>>>> Unfortunately, the parsing of the kernel command line is done  
>>>> _after_ the
>>>> swiotlb is initialized on some architectures.
>>>>
>>>> This patch adds a new function swiotlb_set_default_size() which  
>>>> can be used
>>>> before swiotlb_init() to indicate the desired IO TLB area size in  
>>>> bytes.
>>>>
>>>> This will be used later to implement a smaller IO TLB on the  
>>>> Nintendo Wii
>>>> video game console which just comes with 24MB + 64MB of RAM.
>>>>
>>>> CC: linuxppc-dev@lists.ozlabs.org
>>>> CC: linux-kernel@vger.kernel.org
>>>> CC: x86@kernel.org
>>>> CC: linux-ia64@vger.kernel.org
>>>> Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
>>>> ---
>>>> include/linux/swiotlb.h |    2 ++
>>>> lib/swiotlb.c           |   20 ++++++++++++++++++++
>>>> 2 files changed, 22 insertions(+), 0 deletions(-)
>>>
>>> Please fix the powerpc swiotlb initialization instead.
>>>
>>> Calling swiotlb_init() before parsing kernel parameters sounds
>>> wrong. Any reasons why you can't fix it?
>>>
>>
>> I think that this would be better asked by a PowerPC maintainer. Ben?
>>
>> If this is really a problem the swiotlb late init may be a solution  
>> too in this particular case.
>
> Hmm, why swiotlb_late_init_with_default_size()?
>
> Why can't you initialize swiotlb in mem_init() like this (only compile
> tested)? Any time before freeing bootmem works for swiotlb.

This is an oops in the original patchset -  I think it should be fine  
to move the swiotlb_init later as Fujita suggests, at least for 32-bit  
powerpc.  I just booted this on mpc8641 and everything seems OK.

-Becky

>
>
> diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/ 
> setup_32.c
> index b152de3..8f58986 100644
> --- a/arch/powerpc/kernel/setup_32.c
> +++ b/arch/powerpc/kernel/setup_32.c
> @@ -39,7 +39,6 @@
> #include <asm/serial.h>
> #include <asm/udbg.h>
> #include <asm/mmu_context.h>
> -#include <asm/swiotlb.h>
>
> #include "setup.h"
>
> @@ -343,11 +342,6 @@ void __init setup_arch(char **cmdline_p)
> 		ppc_md.setup_arch();
> 	if ( ppc_md.progress ) ppc_md.progress("arch: exit", 0x3eab);
>
> -#ifdef CONFIG_SWIOTLB
> -	if (ppc_swiotlb_enable)
> -		swiotlb_init(1);
> -#endif
> -
> 	paging_init();
>
> 	/* Initialize the MMU context management stuff */
> diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/ 
> setup_64.c
> index 6354739..9143891 100644
> --- a/arch/powerpc/kernel/setup_64.c
> +++ b/arch/powerpc/kernel/setup_64.c
> @@ -61,7 +61,6 @@
> #include <asm/xmon.h>
> #include <asm/udbg.h>
> #include <asm/kexec.h>
> -#include <asm/swiotlb.h>
> #include <asm/mmu_context.h>
>
> #include "setup.h"
> @@ -541,11 +540,6 @@ void __init setup_arch(char **cmdline_p)
> 	if (ppc_md.setup_arch)
> 		ppc_md.setup_arch();
>
> -#ifdef CONFIG_SWIOTLB
> -	if (ppc_swiotlb_enable)
> -		swiotlb_init(1);
> -#endif
> -
> 	paging_init();
>
> 	/* Initialize the MMU context management stuff */
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 311224c..448f972 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -48,6 +48,7 @@
> #include <asm/sparsemem.h>
> #include <asm/vdso.h>
> #include <asm/fixmap.h>
> +#include <asm/swiotlb.h>
>
> #include "mmu_decl.h"
>
> @@ -320,6 +321,11 @@ void __init mem_init(void)
> 	struct page *page;
> 	unsigned long reservedpages = 0, codesize, initsize, datasize,  
> bsssize;
>
> +#ifdef CONFIG_SWIOTLB
> +	if (ppc_swiotlb_enable)
> +		swiotlb_init(1);
> +#endif
> +
> 	num_physpages = lmb.memory.size >> PAGE_SHIFT;
> 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux- 
> kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

