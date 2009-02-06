From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 06 Feb 2009 16:01:00 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <20090206160100.GS18368@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com> <3f9a31f40902060053x18dacf58u40c739ab89f13860@mail.gmail.com> <20090206180957.6294.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090206145556.GH18368@elte.hu> <1233934141.3209.20.camel@localhost.localdomain> <20090206153315.GD13758@n2100.arm.linux.org.uk> <20090206154539.GP18368@elte.hu> <20090206154917.GE13758@n2100.arm.linux.org.uk>
In-Reply-To: <20090206154917.GE13758@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jaswinder Singh Rajput <jaswinderlinux@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>


* Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> On Fri, Feb 06, 2009 at 04:45:39PM +0100, Ingo Molnar wrote:
> > 
> > * Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> > 
> > > On Fri, Feb 06, 2009 at 08:59:01PM +0530, Jaswinder Singh Rajput wrote:
> > > > Jaswinder Singh Rajput (2):
> > > >       Neither asm/types.h nor linux/types.h is required for arch/ia64/include/asm/fpu.h
> > > >       make linux/types.h as assembly safe
> > > 
> > > I continue to disagree with the need for the second patch.
> > 
> > But have not replied to my mail about that so far.
> 
> Sigh.  No I didn't - because I also got a reply from Jaswinder and
> covered all points in _that_ reply.
> 
> Would you like me to re-send my reply so that you can appear in the To:
> header?
> 
> Stop making this discussion stupidly obtuse.

I am not making anything stupidly obtuse, your reply to Jaswinder was in a 
different (but related) portion of the thread, that i have not read yet at 
that point. I have read it now and have replied.

	Ingo
