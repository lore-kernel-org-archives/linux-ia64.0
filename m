From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 10 Jan 2005 17:52:05 +0000
Subject: Re: [PATCH] trivial build fix
Message-Id: <200501100952.05124.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105377434.6812.19.camel@tdi>
In-Reply-To: <1105377434.6812.19.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, January 10, 2005 9:17 am, Alex Williamson wrote:
>   Latest bk of ia64/kernel/topology.c needs linux/nodemask.h.
> asm-ia64/numa.h seems like a reasonable place for it.  Thanks,
>
>  Alex
>
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>
>
> === include/asm-ia64/numa.h 1.17 vs edited ==> --- 1.17/include/asm-ia64/numa.h 2005-01-07 22:44:03 -07:00
> +++ edited/include/asm-ia64/numa.h 2005-01-10 09:38:24 -07:00
> @@ -17,6 +17,7 @@
>
>  #include <linux/cache.h>
>  #include <linux/cpumask.h>
> +#include <linux/nodemask.h>
>  #include <linux/numa.h>
>  #include <linux/smp.h>
>  #include <linux/threads.h>

I think cw already sent a fix to akpm for this problem, though he put the 
#include into topology.c, which seems more correct unless numa.h itself needs 
it.

Jesse
