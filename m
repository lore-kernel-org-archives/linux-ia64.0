From: Al Stone <ahs3@fc.hp.com>
Date: Mon, 23 Aug 2004 18:25:51 +0000
Subject: Re: [PATCH] OProfile ia64 performance counter support
Message-Id: <1093285551.12540.13.camel@fcboson.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040821195206.GA10240@compsoc.man.ac.uk>
	 <20040821140016.33900da7.akpm@osdl.org>
In-Reply-To: <20040821140016.33900da7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: John Levon <levon@movementarian.org>, oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@osdl.org

I'll admit to being a bit behind (sigh) in keeping
the userspace oprofile builds up-to-date, but Debian
packages (i386 and ia64) and source tarballs are at:

  http://free.linux.hp.com/~ahs3/oprofile

The latest I have there is 0.7.1.  I hope to post 0.8
(or better) userspace tool builds in the next week or two.

Of course, CVS at SourceForge always has the latest
source (http://oprofile.sf.net).

On Sat, 2004-08-21 at 15:00, Andrew Morton wrote:
> John Levon <levon@movementarian.org> wrote:
> >
> > This patch provides support for IA64 hardware performance counters via
> >  the perfmon interface.
> 
> OK - I'll plop this in -mm but I'd ask Tony to do the final merge as and
> when it suits the ia64 team.
> 
> What's the story on userspace support for oprofile-on-ia64?
> 
> 
> -------------------------------------------------------
> SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
> 100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
> Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
> http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
> _______________________________________________
> oprofile-list mailing list
> oprofile-list@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/oprofile-list
-- 
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Linux & Open Source Lab                       Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------

