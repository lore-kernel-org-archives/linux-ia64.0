From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Fri, 06 Feb 2009 15:52:30 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <1233935328.3209.30.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <3f9a31f40902060053x18dacf58u40c739ab89f13860@mail.gmail.com>
	 <20090206180957.6294.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206145556.GH18368@elte.hu>
	 <1233934141.3209.20.camel@localhost.localdomain>
	 <20090206153315.GD13758@n2100.arm.linux.org.uk>
In-Reply-To: <20090206153315.GD13758@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jaswinder Singh Rajput <jaswinderlinux@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

On Fri, 2009-02-06 at 15:33 +0000, Russell King - ARM Linux wrote:
> On Fri, Feb 06, 2009 at 08:59:01PM +0530, Jaswinder Singh Rajput wrote:
> > On Fri, 2009-02-06 at 15:55 +0100, Ingo Molnar wrote:
> > > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > > > Index: b/arch/ia64/include/asm/fpu.h
> > > > > > =================================> > > > > > --- a/arch/ia64/include/asm/fpu.h
> > > > > > +++ b/arch/ia64/include/asm/fpu.h
> > > > > > @@ -6,7 +6,7 @@
> > > > > >  *     David Mosberger-Tang <davidm@hpl.hp.com>
> > > > > >  */
> > > > > >
> > > > > > -#include <linux/types.h>
> > > > > > +#include <asm/types.h>
> > > > > >
> > > > > 
> > > > > No , we do not even need asm/types.h
> > > > > 
> > > > > Subject: [PATCH] Neither asm/types.h nor linux/types.h is not required
> > > > > for arch/ia64/include/asm/fpu.h
> > > > > 
> > > > > Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> > > > 
> > > > ok. I confirmed.
> > > > 	Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > 
> > > Thanks.
> > > 
> > > Jaswinder, mind adding these tags to the commit and sending a pull request 
> > > with all fixes?
> > 
> > The following changes since commit 0b86a4e34d885e734a4c4e46293376f3f1c639eb:
> >   Ingo Molnar (1):
> >         Merge branch 'core/header-fixes' of git://git.kernel.org/.../jaswinder/linux-2.6-tip into core/header-fixes
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tip.git core/header-fixes
> > 
> > Jaswinder Singh Rajput (2):
> >       Neither asm/types.h nor linux/types.h is required for arch/ia64/include/asm/fpu.h
> >       make linux/types.h as assembly safe
> 
> I continue to disagree with the need for the second patch.

Like Ingo suggested:

On Fri, 2009-02-06 at 15:58 +0100, Ingo Molnar wrote:
>  Well types.h easily gets included in other files though, which might be 
> partially suited for assembly - and have !__ASSEMBLY__ portions that rely on 
> a types.h include.
> 
> So making this file an invariant in .S files does not sound like a bad idea 
> to me. Is there any downside?
> 

We cannot see any downside of this patch.

But we can see upside of this patch is:
1. No need to protect linux/types.h with #ifndef __ASSEMBLY__ in many
files
2. So we trying to replace multiple #ifndef __ASSEMBLY__ with one.

Thanks,

--
JSR


