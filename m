From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 19 Jun 2003 22:31:37 +0000
Subject: Re: [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105606334623527@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105606334623525@msgid-missing>
In-Reply-To: <marc-linux-ia64-105606334623525@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Forgot to mention that this also addresses the problem with MAXORDER.

On Thu, Jun 19, 2003 at 03:28:29PM -0700, Jesse Barnes wrote:
> Here's another one.  It still has the bootmem allocator change, but I'll
> push that seperately on lkml, I think it makes sense.  This version is a
> bit different from the last:
> 
>   o added back in the #ifndef CONFIG_DISCONTIGMEM in memory.c and mm.h
>     for max_mapnr and mem_map
>   o added an ugly hack in asm-ia64/page.h to use different vars since
>     max_mapnr and mem_map aren't available in the discontig case
>   o added back some more CONFIG_VIRTUAL_MEM_MAP #ifdefs
> 
> Turning off CONFIG_VIRTUAL_MEM_MAP still doesn't work--need to fix
> mm/init.c to accomodate that case.
> 
> Any other comments?
> 
> Thanks,
> Jesse
