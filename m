From: Russ Anderson <rja@sgi.com>
Date: Thu, 06 Jan 2005 20:50:12 +0000
Subject: Re: [patch] per cpu MCA/INIT fixes.
Message-Id: <200501062050.j06KoCL0218437@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> I just applied and pushed Jack's patch to the test-2.6.11 tree, Russ, can
> you fix up your patch to apply cleanly on top of Jack's.

Yup.
 
> >> +#ifdef CONFIG_SMP
> >> +#include <asm/mca.h>
> >> +#endif
> >
> >Just a nit, header files should always be safe to include 
> >unconditionally.  If they're not, the headers need fixing (barring out of tree 
> >stuff like kdb of course).
> 
> Agreed ... this looks really ugly ... surely we want to support MCA
> on uni-processors as well as SMP!  What's the issue that provoked
> adding the #ifdef here?

The only reason was that the changes are all in per_cpu_init() and
that routine is inside #ifdef CONFIG_SMP.

I built the patch with all configs in arch/ia64/configs, but now 
see that they all have CONFIG_SMP=y.  (sigh)

Given all the infrastructure setup done under #ifdef CONFIG_SMP, would
it work with uni-processor?  I'll start digging through the code...

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
