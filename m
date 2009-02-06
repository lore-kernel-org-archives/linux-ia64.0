From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Fri, 06 Feb 2009 15:41:01 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <1233934141.3209.20.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <3f9a31f40902060053x18dacf58u40c739ab89f13860@mail.gmail.com>
	 <20090206180957.6294.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206145556.GH18368@elte.hu>
In-Reply-To: <20090206145556.GH18368@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jaswinder Singh Rajput <jaswinderlinux@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

On Fri, 2009-02-06 at 15:55 +0100, Ingo Molnar wrote:
> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > > Index: b/arch/ia64/include/asm/fpu.h
> > > > =================================> > > > --- a/arch/ia64/include/asm/fpu.h
> > > > +++ b/arch/ia64/include/asm/fpu.h
> > > > @@ -6,7 +6,7 @@
> > > >  *     David Mosberger-Tang <davidm@hpl.hp.com>
> > > >  */
> > > >
> > > > -#include <linux/types.h>
> > > > +#include <asm/types.h>
> > > >
> > > 
> > > No , we do not even need asm/types.h
> > > 
> > > Subject: [PATCH] Neither asm/types.h nor linux/types.h is not required
> > > for arch/ia64/include/asm/fpu.h
> > > 
> > > Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> > 
> > ok. I confirmed.
> > 	Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Thanks.
> 
> Jaswinder, mind adding these tags to the commit and sending a pull request 
> with all fixes?

The following changes since commit 0b86a4e34d885e734a4c4e46293376f3f1c639eb:
  Ingo Molnar (1):
        Merge branch 'core/header-fixes' of git://git.kernel.org/.../jaswinder/linux-2.6-tip into core/header-fixes

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tip.git core/header-fixes

Jaswinder Singh Rajput (2):
      Neither asm/types.h nor linux/types.h is required for arch/ia64/include/asm/fpu.h
      make linux/types.h as assembly safe

 arch/ia64/include/asm/fpu.h |    2 --
 include/linux/types.h       |    3 ++-
 2 files changed, 2 insertions(+), 3 deletions(-)

Complete diff:
diff --git a/arch/ia64/include/asm/fpu.h b/arch/ia64/include/asm/fpu.h
index b6395ad..0c26157 100644
--- a/arch/ia64/include/asm/fpu.h
+++ b/arch/ia64/include/asm/fpu.h
@@ -6,8 +6,6 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-#include <linux/types.h>
-
 /* floating point status register: */
 #define FPSR_TRAP_VD	(1 << 0)	/* invalid op trap disabled */
 #define FPSR_TRAP_DD	(1 << 1)	/* denormal trap disabled */
diff --git a/include/linux/types.h b/include/linux/types.h
index 712ca53..c30973a 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_TYPES_H
 #define _LINUX_TYPES_H
 
+#ifndef __ASSEMBLY__
 #ifdef	__KERNEL__
 
 #define DECLARE_BITMAP(name,bits) \
@@ -212,5 +213,5 @@ struct ustat {
 };
 
 #endif	/* __KERNEL__ */
-
+#endif /*  __ASSEMBLY__ */
 #endif /* _LINUX_TYPES_H */


