From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 06 Feb 2009 17:41:48 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <20090206174148.GB19148@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com> <3f9a31f40902060053x18dacf58u40c739ab89f13860@mail.gmail.com> <20090206180957.6294.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090206145556.GH18368@elte.hu> <1233934141.3209.20.camel@localhost.localdomain> <20090206153315.GD13758@n2100.arm.linux.org.uk> <1233935328.3209.30.camel@localhost.localdomain> <20090206155512.GF13758@n2100.arm.linux.org.uk> <20090206173249.GC11299@uranus.ravnborg.org>
In-Reply-To: <20090206173249.GC11299@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Jaswinder Singh Rajput <jaswinder@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jaswinder Singh Rajput <jaswinderlinux@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>


* Sam Ravnborg <sam@ravnborg.org> wrote:

> On Fri, Feb 06, 2009 at 03:55:12PM +0000, Russell King - ARM Linux wrote:
> > On Fri, Feb 06, 2009 at 09:18:48PM +0530, Jaswinder Singh Rajput wrote:
> > > On Fri, 2009-02-06 at 15:33 +0000, Russell King - ARM Linux wrote:
> > > > On Fri, Feb 06, 2009 at 08:59:01PM +0530, Jaswinder Singh Rajput wrote:
> > > > > Jaswinder Singh Rajput (2):
> > > > >       Neither asm/types.h nor linux/types.h is required for arch/ia64/include/asm/fpu.h
> > > > >       make linux/types.h as assembly safe
> > > > 
> > > > I continue to disagree with the need for the second patch.
> > > 
> > > Like Ingo suggested:
> > > 
> > > On Fri, 2009-02-06 at 15:58 +0100, Ingo Molnar wrote:
> > > >  Well types.h easily gets included in other files though, which might be 
> > > > partially suited for assembly - and have !__ASSEMBLY__ portions that rely on 
> > > > a types.h include.
> > > > 
> > > > So making this file an invariant in .S files does not sound like a bad idea 
> > > > to me. Is there any downside?
> > > > 
> > > 
> > > We cannot see any downside of this patch.
> > > 
> > > But we can see upside of this patch is:
> > > 1. No need to protect linux/types.h with #ifndef __ASSEMBLY__ in many
> > > files
> > > 2. So we trying to replace multiple #ifndef __ASSEMBLY__ with one.
> > 
> > The point is:
> > 
> > 1. If the parent include needs to include linux/types.h to get at C
> >    types _and_ the include file needs to also be included by assembly
> >    code, it itself needs to have #ifndef __ASSEMBLY__ to protect those
> >    uses from the assembly code.
> > 
> >    In that case, the linux/types.h include should be contained within
> >    the #ifndef __ASSEMBLY__ .. #endif block along with all C only
> >    parts of the header file.
> > 
> > 2. if it doesn't need C types from linux/types.h, then that header has
> >    no business including linux/types.h, and the include should be
> >    eliminated to save the already dirbolically slow compiler from
> >    having to read and parse that file, and more importantly allowing
> >    it to eliminate linux/types.h from the build dependencies.
> > 
> > Yes, you can wrap linux/types.h with that ifndef, and yes it will fix
> > any problems, but I view it as a hack rather than fixing the real problem
> > which is lazyness by code writers to get their include dependencies right.
> 
> You guys are getting this wrong.
> The patch from Jaswinder needs to be fixed so we unconditionally
> include <asm/types.h> from linux/types.h.

Yeah, that's true.

> And then ll users can safely include linux/types.h and when we one
> day realize we can move some stuff used in .S files from
> asm/types.h to linux/types.h then we are all safe and no breakage.

Yeah.

	Ingo
