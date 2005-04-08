From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Apr 2005 19:05:06 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random
Message-Id: <16982.54754.320970.600789@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm quite sure I wrote ia64_fls() long before there was the generic
fls() so probably the bug was introduced when that happened.  Changing
ia64_fls() would be wrong, since the behavior of that function is
correct (in "as intended").  I'll take a look at fixing this, since I
was apparently the one who introduced the "broken" fls() and since we
may want to use a GCC builtin anyhow.  Also, the use of the
floating-point unit, while optimal from an architectural point of
view, may not be optimal from a microarchitecture point since all
McKinley-derived cores have relatively high latency for moving data
from the integer register file to the fp register file (and vice
versa).  High time to take another look.

	--david

>>>>> On Fri, 8 Apr 2005 10:33:24 -0700, Andrew Morton <akpm@osdl.org> said:

  Andrew> I agree that ia64's fls() is broken.

  Andrew> So the random driver is presently busted on ia64?


  Andrew> Matt Mackall <mpm@selenic.com> wrote:
  >>  Realized you're not on the cc list. This one's surprising.
  >> 
  >> ----- Forwarded message from Matt Mackall <mpm@selenic.com> -----
  >> 
  >> Date: Fri, 8 Apr 2005 09:27:46 -0700 From: Matt Mackall
  >> <mpm@selenic.com> To: Simon Derr <Simon.Derr@bull.net> Cc: Yura
  >> Pakhuchiy <pakhuchiy@iptel.by>, Patrice Martinez
  >> <patrice.martinez@ext.bull.net>, linux-kernel@vger.kernel.org
  >> Subject: Re: buggy ia64_fls() ? (was Re: /dev/random problem on
  >> 2.6.12-rc1)
  >> 
  >> On Fri, Apr 08, 2005 at 02:12:04PM +0200, Simon Derr wrote: > I
  >> enabled the debug messages in random.c and I think I found the
  >> problem > lying in the IA64 version of fls().
  >> 
  >> Good catch.
  >> 
  >> > It turns out that the generic and IA64 versions of fls()
  >> disagree:
  >> > 
  >> > (output from a small test program)
  >> > 
  >> > x ia64_fls(x) generic_fls(x)
  >> > 
  >> > i=-1, t=0, ia64: -65535 et generic:0 > i=0, t=1, ia64: 0 et
  >> generic:1 > i=1, t=2, ia64: 1 et generic:2 > i=2, t=4, ia64: 2 et
  >> generic:3 > i=3, t=8, ia64: 3 et generic:4
  >> 
  >> Well PPC at least sez:
  >> 
  >> /* * fls: find last (most-significant) bit set.  * Note fls(0)   >> 0, fls(1) = 1, fls(0x80000000) = 32.  */
  >> 
  >> And that agrees with the generic code (used by x86). So I think
  >> IA64 is probably wrong here indeed. It's amazing that the other
  >> users of fls don't blow up spectacularly.
  >> 
  >> > I tried to fix it with an ia64 version that would give the same
  >> result as > the generic version, but the kernel did not boot, I
  >> guess some functions > rely on the ""broken"" ia64_fls()
  >> behaviour.
  >> > 
  >> > So I just changed fls() to use generic_fls() instead of
  >> ia64_fls().
  >> 
  >> If the "fixed" version didn't boot, how did the "alternate fixed"
  >> version boot?
  >> 
  >> -- 
  >> Mathematics is the supreme nostalgia of our time.
  >> 
  >> ----- End forwarded message -----
  >> 
  >> -- 
  >> Mathematics is the supreme nostalgia of our time.
  Andrew> - To unsubscribe from this list: send the line "unsubscribe
  Andrew> linux-ia64" in the body of a message to
  Andrew> majordomo@vger.kernel.org More majordomo info at
  Andrew> http://vger.kernel.org/majordomo-info.html
