From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Tue, 28 Jan 2014 14:46:21 +0000
Subject: Re: [PATCH 0/5] ia64 ski emulator patches
Message-Id: <21223.49853.281661.425847@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com>
	<21218.28095.779306.523187@gargle.gargle.HOWL>
	<alpine.LRH.2.02.1401240937020.28468@file01.intranet.prod.int.rdu2.redhat.com>
	<21219.63903.326798.277717@gargle.gargle.HOWL>
	<alpine.LRH.2.02.1401251536550.27200@file01.intranet.prod.int.rdu2.redhat.com>
	<21220.10175.311714.796806@gargle.gargle.HOWL>
In-Reply-To: <21220.10175.311714.796806@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mikael Pettersson <mikpelinux@gmail.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Mikael Pettersson writes:
 > Mikulas Patocka writes:
 >  > 
 >  > 
 >  > On Sat, 25 Jan 2014, Mikael Pettersson wrote:
 >  > 
 >  > > My ski patches are in <http://user.it.uu.se/~mikpe/linux/patches/ia64/ski-1.3.2/>
 >  > > for now.  I'll post the kernel patches to linux-ia64 @ vger in a few minutes.
 >  > > 
 >  > > /Mikael
 >  > 
 >  > Thanks for the patches.
 >  > 
 >  > Isn't this subject to races? - could it lock up if the signal happens just 
 >  > before the pause syscall?
 >  > 
 >  > +    case SSC_HALT_LIGHT:
 >  > +      /* Sleep until SIGIO or SIGALRM is received; this relies on
 >  > +        keyboard/ethernet input being detected via SIGIO, and the
 >  > +        ITC now being emulated via setitimer() and SIGALRM.  */
 >  > +      pause ();
 >  > +      break;
 >  > +
 > 
 > Thanks for the review. You're right, the pause mustn't happen if
 > itc_itimer_fired = 1.  Let me ponder this for a while...

Ok, I've fixed this in two different ways: one patch which uses pselect,
and one patch which uses plain select + the self-pipe trick.  Both work
in limited testing, but the pselect one is much nicer and appears to have
a little less host CPU overhead, so that's the one I'm stress-testing now.

Both patches have been uploaded to the same place as before.

/Mikael
