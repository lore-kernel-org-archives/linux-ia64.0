From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 06:58:06 +0000
Subject: Re: possible time_interpolator bug?
Message-Id: <16435.3326.193311.110598@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077086574.985.56.camel@cog.beaverton.ibm.com>
In-Reply-To: <1077086574.985.56.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Feb 2004 22:42:54 -0800, john stultz <johnstul@us.ibm.com> said:

  John> So each second, we call "_update(NSEC_PER_SEC)", however for
  John> each tick we call update_wall_time_one_tick() which calls
  John> "_update(delta_nsec)".

  John> Thus in a period of one second, we call _update() HZ times w/
  John> ~NSEC_PER_SEC/HZ as an argument, then at the second overflow
  John> we call it again w/ NSEC_PER_SEC.

  John> It seems that calling _update() on the second overflow is
  John> unnecessary.

Not just unnecessary, but wrong!

  John> It would be noted that time inconsistencies are not seen using
  John> the ITC interpolator, however the ITC interpolator has an
  John> empty _update function.

Yes.

  John> Am I just missing something here?

I don't think so.  Good bug hunting.  Some time ago SGI reported some
jumpiness but I never got a definite answer whether the problem had
been solved.

You may want to run this by someone who actually understands the code
in timer.c but I'm pretty sure you're right.

Thanks,

	--david
