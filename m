From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 06 Feb 2009 14:55:56 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <20090206145556.GH18368@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com> <3f9a31f40902060053x18dacf58u40c739ab89f13860@mail.gmail.com> <20090206180957.6294.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20090206180957.6294.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>, Jaswinder Singh Rajput <jaswinder@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > Index: b/arch/ia64/include/asm/fpu.h
> > > =================================> > > --- a/arch/ia64/include/asm/fpu.h
> > > +++ b/arch/ia64/include/asm/fpu.h
> > > @@ -6,7 +6,7 @@
> > >  *     David Mosberger-Tang <davidm@hpl.hp.com>
> > >  */
> > >
> > > -#include <linux/types.h>
> > > +#include <asm/types.h>
> > >
> > 
> > No , we do not even need asm/types.h
> > 
> > Subject: [PATCH] Neither asm/types.h nor linux/types.h is not required
> > for arch/ia64/include/asm/fpu.h
> > 
> > Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> 
> ok. I confirmed.
> 	Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks.

Jaswinder, mind adding these tags to the commit and sending a pull request 
with all fixes?

	Ingo
