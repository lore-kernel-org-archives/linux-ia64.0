From: Andrew Morton <akpm@osdl.org>
Date: Fri, 08 Apr 2005 17:33:24 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random
Message-Id: <20050408103324.6c5231df.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I agree that ia64's fls() is broken.

So the random driver is presently busted on ia64?


Matt Mackall <mpm@selenic.com> wrote:
>
> Realized you're not on the cc list. This one's surprising.
> 
> ----- Forwarded message from Matt Mackall <mpm@selenic.com> -----
> 
> Date: Fri, 8 Apr 2005 09:27:46 -0700
> From: Matt Mackall <mpm@selenic.com>
> To: Simon Derr <Simon.Derr@bull.net>
> Cc: Yura Pakhuchiy <pakhuchiy@iptel.by>,
> 	Patrice Martinez <patrice.martinez@ext.bull.net>,
> 	linux-kernel@vger.kernel.org
> Subject: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)
> 
> On Fri, Apr 08, 2005 at 02:12:04PM +0200, Simon Derr wrote:
> > I enabled the debug messages in random.c and I think I found the problem 
> > lying in the IA64 version of fls().
> 
> Good catch.
>  
> > It turns out that the generic and IA64 versions of fls() disagree:
> > 
> > (output from a small test program)
> > 
> >      x   ia64_fls(x)      generic_fls(x)
> > 
> > i=-1, t=0, ia64: -65535 et generic:0
> > i=0, t=1, ia64: 0 et generic:1
> > i=1, t=2, ia64: 1 et generic:2
> > i=2, t=4, ia64: 2 et generic:3
> > i=3, t=8, ia64: 3 et generic:4
> 
> Well PPC at least sez:
> 
> /*
>  * fls: find last (most-significant) bit set.
>  * Note fls(0) = 0, fls(1) = 1, fls(0x80000000) = 32.
>  */
> 
> And that agrees with the generic code (used by x86). So I think IA64
> is probably wrong here indeed. It's amazing that the other users of
> fls don't blow up spectacularly.
> 
> > I tried to fix it with an ia64 version that would give the same result as 
> > the generic version, but the kernel did not boot, I guess some functions 
> > rely on the ""broken"" ia64_fls() behaviour.
> > 
> > So I just changed fls() to use generic_fls() instead of ia64_fls().
> 
> If the "fixed" version didn't boot, how did the "alternate fixed"
> version boot?
> 
> -- 
> Mathematics is the supreme nostalgia of our time.
> 
> ----- End forwarded message -----
> 
> -- 
> Mathematics is the supreme nostalgia of our time.
