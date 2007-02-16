From: Richard Knutsson <ricknu-0@student.ltu.se>
Date: Fri, 16 Feb 2007 15:02:33 +0000
Subject: Re: [KJ] [PATCH] is_power_of_2 in ia64mm
Message-Id: <45D5C789.1090607@student.ltu.se>
List-Id: <linux-ia64.vger.kernel.org>
References: <1171627435.6127.0.camel@wriver-t81fb058.linuxcoe>
In-Reply-To: <1171627435.6127.0.camel@wriver-t81fb058.linuxcoe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vignesh Babu BM <vignesh.babu@wipro.com>
Cc: Kernel Janitors List <kernel-janitors@lists.osdl.org>, linux-mm@kvack.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Vignesh Babu BM wrote:
> Replacing (n & (n-1)) in the context of power of 2 checks
> with is_power_of_2
>
>
> diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
> index 0c7e94e..0ccc70e 100644
> --- a/arch/ia64/mm/hugetlbpage.c
> +++ b/arch/ia64/mm/hugetlbpage.c
> @@ -16,6 +16,7 @@
>  #include <linux/smp_lock.h>
>  #include <linux/slab.h>
>  #include <linux/sysctl.h>
> +#include <linux/log2.h>
>  #include <asm/mman.h>
>  #include <asm/pgalloc.h>
>  #include <asm/tlb.h>
> @@ -175,7 +176,7 @@ static int __init hugetlb_setup_sz(char *str)
>  		tr_pages = 0x15557000UL;
>  
>  	size = memparse(str, &str);
> -	if (*str || (size & (size-1)) || !(tr_pages & size) ||
> +	if (*str || !is_power_of_2(size) || !(tr_pages & size) ||
>  		size <= PAGE_SIZE ||
>  		size >= (1UL << PAGE_SHIFT << MAX_ORDER)) {
>  		printk(KERN_WARNING "Invalid huge page size specified\n");
>
>   
As we talked about before; is this really correct? !is_power_of_2(0) = 
true while (0 & (0-1)) = 0.

Richard Knutsson

