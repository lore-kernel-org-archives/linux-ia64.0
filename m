From: Jack Steiner <steiner@sgi.com>
Date: Tue, 24 Feb 2004 04:05:59 +0000
Subject: Re: HUGEPAGE SIZE a boottime option
Message-Id: <20040224040558.GA15484@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 08:26:32AM -0800, Chen, Kenneth W wrote:
> sorry, missed this important hunk:
>  # else
>  #  error Unsupported IA-64 HugeTLB Page Size!
>  # endif
> +#define HPAGE_SHIFT hpage_shift
> 
> Here is a work-in-progress patch that includes more comments we have.


Looks reasonable to me....


> 
> (1) hugepagesz parameter should have min/max checked.  Doesn't make
> sense to config huge page size smaller than PAGE_SIZE, or config huge
> page size larger than what page allocator allows (MAX_ORDER).
> 
> (2) We can avoid patching vhpt handler and still allow dynamic sizing.
> 
> (3) we remain unhappy with penalty hit on reload_context().  Region
> register 4 now has a dependency on loading variable hpage_shift, which
> could have worst case two/three hundred cycles.  This variable is next
> to ia64_ctx (which is heavily used), but there is no guarantee that
> they sits in the same cache line.  I've tried prefetch() with
> gcc-3.2.3, but it generates code that everyone can laugh at it.
> 
> (4) If we have gone this far, it probably won't take that much more
> to make it runtime configurable!
> 
> 
> - Ken
> 
> 
> -----Original Message-----
> From: Jack Steiner [mailto:steiner@sgi.com]
> Sent: Sunday, February 22, 2004 3:08 PM
> To: Chen, Kenneth W
> Cc: linux-ia64@vger.kernel.org
> Subject: Re: HUGEPAGE SIZE a boottime option
> 
> 
> On Thu, Feb 19, 2004 at 08:00:04PM -0800, Chen, Kenneth W wrote:
> > It is not functionally complete though.  alloc_fresh_huge_page(),
> > hugetlb_free_pgtables(), and update_and_free_page has #define
> > constant that indirectly from HPAGE_SHIFT.
> > 
> > You might checked already, text replication works in this case?
> > 
> 
> (I posted this earlier. However, our mail server has been messed up & I dont think
> the mail got thru. Excuse the duplicate if the other mail ever makes it....)
> 
> 
> The patch passes preliminary testing.
> 
> I dont see any issues with #define constants indirectly using HPAGE_SHIFT. HPAGE_SHIFT
> is now defined as:
>         #define HPAGE_SHIFT hpage_shift
> and
>         extern int hpage_shift;         
>         int hpage_shift=HPAGE_SHIFT_DEFAULT;
> 
> 
> Indirect references should work ok.
> 
> 
> > -----Original Message-----
> > From: linux-ia64-owner@vger.kernel.org
> > [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Jack Steiner
> > Sent: Thursday, February 19, 2004 5:08 PM
> > To: linux-ia64@vger.kernel.org
> > Subject: HUGEPAGE SIZE a boottime option
> > 
> > 
> > Here is a preliminary version of a patch that makes the size of
> > HUGEPAGES a boottime option. Only ia64-specific files are changed (except
> > for the Documentation file).
> > 
> > We have a number of customers using large pages. Unfortunately, 
> > the "optimum" size of a large page is application & configuration
> > dependent. Rather that having each customer recompile to specify their
> > own HUGEPAGESIZE, this patch make the size a boottime option.
> > 
> > 
> > Does this patch look reasonable? If so, I will incorporate feedback,
> > finish testing it, update it to 2.6.3 & resubmit.

Content-Description: htlb_size.patch
> [-- octet_filter file type: "'diff' output text" --]
> 
> [-- Statistics (lines words chars):  106 377 3429 /tmp/htlb_size.patch --]
> 
> diff -Nur linux-2.6.3/arch/ia64/kernel/ivt.S linux-2.6.3.htlb/arch/ia64/kernel/ivt.S
> --- linux-2.6.3/arch/ia64/kernel/ivt.S	2004-02-17 19:57:16.000000000 -0800
> +++ linux-2.6.3.htlb/arch/ia64/kernel/ivt.S	2004-02-22 23:13:34.000000000 -0800
> @@ -118,10 +118,11 @@
>  #ifdef CONFIG_HUGETLB_PAGE
>  	extr.u r26=r25,2,6
>  	;;
> -	cmp.eq p8,p0=HPAGE_SHIFT,r26
> +	cmp.ne p8,p0=r18,r26
> +	sub r27=r26,r18
>  	;;
>  (p8)	dep r25=r18,r25,2,6
> -(p8)	shr r22=r22,HPAGE_SHIFT-PAGE_SHIFT
> +(p8)	shr r22=r22,r27
>  #endif
>  	;;
>  	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
> diff -Nur linux-2.6.3/arch/ia64/mm/hugetlbpage.c linux-2.6.3.htlb/arch/ia64/mm/hugetlbpage.c
> --- linux-2.6.3/arch/ia64/mm/hugetlbpage.c	2004-02-17 19:58:01.000000000 -0800
> +++ linux-2.6.3.htlb/arch/ia64/mm/hugetlbpage.c	2004-02-22 22:58:58.000000000 -0800
> @@ -23,6 +23,7 @@
>  static long	htlbpagemem;
>  int		htlbpage_max;
>  static long	htlbzone_pages;
> +unsigned int	hpage_shift=HPAGE_SHIFT_DEFAULT;
>  
>  static struct list_head hugepage_freelists[MAX_NUMNODES];
>  static spinlock_t htlbpage_lock = SPIN_LOCK_UNLOCKED;
> @@ -520,6 +521,30 @@
>  }
>  __setup("hugepages=", hugetlb_setup);
>  
> +static int __init hugetlb_setup_sz(char *str)
> +{
> +	u64 tr_pages;
> +	unsigned long long size;
> +
> +	if (ia64_pal_vm_page_size(&tr_pages, NULL) != 0)
> +		/*
> +		 * shouldn't happen, but just in case.
> +		 */
> +		tr_pages = 0x15557000UL;
> +
> +	size = memparse(str, &str);
> +	if (*str || (size & (size-1)) || !(tr_pages & size) ||
> +		size <= PAGE_SIZE ||
> +		size >= (1UL << PAGE_SHIFT << MAX_ORDER)) {
> +		printk(KERN_WARNING "Invalid huge page size specified\n");
> +		return 1;
> +	}
> +
> +	hpage_shift = __ffs(size);
> +	return 1;
> +}
> +__setup("hugepagesz=", hugetlb_setup_sz);
> +
>  static int __init hugetlb_init(void)
>  {
>  	int i;
> diff -Nur linux-2.6.3/include/asm-ia64/page.h linux-2.6.3.htlb/include/asm-ia64/page.h
> --- linux-2.6.3/include/asm-ia64/page.h	2004-02-17 19:57:16.000000000 -0800
> +++ linux-2.6.3.htlb/include/asm-ia64/page.h	2004-02-22 17:26:18.000000000 -0800
> @@ -37,26 +37,26 @@
>  #define RGN_MAP_LIMIT	((1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)	/* per region addr limit */
>  
>  #ifdef CONFIG_HUGETLB_PAGE
> -
>  # if defined(CONFIG_HUGETLB_PAGE_SIZE_4GB)
> -#  define HPAGE_SHIFT	32
> +#  define HPAGE_SHIFT_DEFAULT	32
>  # elif defined(CONFIG_HUGETLB_PAGE_SIZE_1GB)
> -#  define HPAGE_SHIFT	30
> +#  define HPAGE_SHIFT_DEFAULT	30
>  # elif defined(CONFIG_HUGETLB_PAGE_SIZE_256MB)
> -#  define HPAGE_SHIFT	28
> +#  define HPAGE_SHIFT_DEFAULT	28
>  # elif defined(CONFIG_HUGETLB_PAGE_SIZE_64MB)
> -#  define HPAGE_SHIFT	26
> +#  define HPAGE_SHIFT_DEFAULT	26
>  # elif defined(CONFIG_HUGETLB_PAGE_SIZE_16MB)
> -#  define HPAGE_SHIFT	24
> +#  define HPAGE_SHIFT_DEFAULT	24
>  # elif defined(CONFIG_HUGETLB_PAGE_SIZE_4MB)
> -#  define HPAGE_SHIFT	22
> +#  define HPAGE_SHIFT_DEFAULT	22
>  # elif defined(CONFIG_HUGETLB_PAGE_SIZE_1MB)
> -#  define HPAGE_SHIFT	20
> +#  define HPAGE_SHIFT_DEFAULT	20
>  # elif defined(CONFIG_HUGETLB_PAGE_SIZE_256KB)
> -#  define HPAGE_SHIFT	18
> +#  define HPAGE_SHIFT_DEFAULT	18
>  # else
>  #  error Unsupported IA-64 HugeTLB Page Size!
>  # endif
> +#define HPAGE_SHIFT hpage_shift
>  
>  # define REGION_HPAGE	(4UL)	/* note: this is hardcoded in mmu_context.h:reload_context()!*/
>  # define REGION_SHIFT	61
> @@ -140,6 +140,7 @@
>  # define is_hugepage_only_range(addr, len)		\
>  	 (REGION_NUMBER(addr) = REGION_HPAGE &&	\
>  	  REGION_NUMBER((addr)+(len)) = REGION_HPAGE)
> +extern unsigned int hpage_shift;
>  #endif
>  
>  static __inline__ int


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


