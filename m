From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 27 Sep 2004 23:17:21 +0000
Subject: Re: [PATCH] clean up contig/discontig/virt_mem_map macros
Message-Id: <200409271617.21285.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409272233.i8RMXAV32176@unix-os.sc.intel.com>
In-Reply-To: <200409272233.i8RMXAV32176@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, September 27, 2004 3:33 pm, Tony Luck wrote:
> I got this patch from Zou Nan hai to resolve the problem that
> Andrew Morton has been having booting his ia64 system.  The code
> is quite a bit cleaner as he has reduced the number of different
> definitions of pfn_valid/page_to_pfn/pfn_to_page, and left the
> only remaining ones next to each other in page.h ... so this
> should be easier to maintain going forward.
>
> It has been tested on a variety of systems:
>
>  1G Tiger \  Tested by Zou Nan hai, I assume DIG=y, NUMA=n
>  8G Tiger /  but I don't know for sure.
>  4G Tiger with generic_defconfig
>  4G Tiger with DIG kernel, NUMA, DISCONTIG and VIRTUAL_MEM_MAP on
>  4G Tiger with DIG kernel, NUMA/DISCONTIG off; VIRTUAL_MEM_MAP on
>  HP zx2000 with zx1_defconfig
>
> Can someone please check it on sn2 (sn2_defconfig compiles, but I haven't
> booted it) ... and any other systems or configurations that don't match
> any of the above.  I'd like to stop carrying the BPB that Andrew gave
> me.

Boots on a small machine and the code looks identical, so I'm pretty sure it's 
fine.

Thanks,
Jesse
