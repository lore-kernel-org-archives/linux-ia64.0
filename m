From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 08 Sep 2004 19:45:22 +0000
Subject: Re: Timer patch V8
Message-Id: <1094672722.3129.24.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   I see this made it upstream.  Unfortunately w/ CONFIG_HPET=y, I now
get this:

  CC      drivers/char/hpet.o
drivers/char/hpet.c:669: error: `MC' undeclared here (not in a function)
drivers/char/hpet.c:669: error: initializer element is not constant
drivers/char/hpet.c:669: error: (near initialization for `hpet_interpolator.addr')
drivers/char/hpet.c: In function `hpet_init':
drivers/char/hpet.c:956: error: `hpet_cycles_per_sec' undeclared (first use in this function)
drivers/char/hpet.c:956: error: (Each undeclared identifier is reported only once
drivers/char/hpet.c:956: error: for each function it appears in.)
drivers/char/hpet.c:960: error: `hpet_nsecs_per_cycle' undeclared (first use in this function)
make[2]: *** [drivers/char/hpet.o] Error 1

I assume hpet_cycles_per_sec and hpet_nsecs_per_cycle just need to be
declared again, but I couldn't figure out what MC is supposed to be.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

