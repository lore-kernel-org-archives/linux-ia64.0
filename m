From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 06 Feb 2009 13:42:53 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <20090206134253.GA9919@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1233385816.17794.16.camel@localhost.localdomain> <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

On Fri, Feb 06, 2009 at 05:19:00PM +0900, KOSAKI Motohiro wrote:
> > diff --git a/arch/ia64/include/asm/fpu.h b/arch/ia64/include/asm/fpu.h
> > index 3859558..b6395ad 100644
> > --- a/arch/ia64/include/asm/fpu.h
> > +++ b/arch/ia64/include/asm/fpu.h
> > @@ -6,7 +6,7 @@
> >   *	David Mosberger-Tang <davidm@hpl.hp.com>
> >   */
> >  
> > -#include <asm/types.h>
> > +#include <linux/types.h>
> 
> this change break ia64 build perfectly.
> this patch seems don't tested at all.
> 
> Ingo, I hope you ask patch author how to test posted patch ;-)

Patch author test the patch by adding it to a git tree that hits -next.
And this catched ths bug - so -next served its purpose.

	Sam
