From: john stultz <johnstul@us.ibm.com>
Date: Wed, 18 Feb 2004 06:42:54 +0000
Subject: possible time_interpolator bug?
Message-Id: <1077086574.985.56.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All,
	Using my ia64-cyclone patch I've been occasionally noticing time
inconsistencies near second overflows. Being as the whole purpose of the
patch is to avoid time inconsistencies, I've been wearing my forehead
raw trying to find the bug in my implementation of the cyclone time
interpolator. 

I believe I have found either a bug in the time_interpolator code, or a
bug in my understanding of how it is supposed to work. 

Looking in kernel/timer.c at update_wall_time_one_tick() and
update_wall_time().

First in update_wall_time():

static void update_wall_time(unsigned long ticks)
{
	do {
		ticks--;
		update_wall_time_one_tick();
	} while (ticks);

	if (xtime.tv_nsec >= 1000000000) {
	    xtime.tv_nsec -= 1000000000;
	    xtime.tv_sec++;
	    time_interpolator_update(NSEC_PER_SEC);
	    second_overflow();
	}
}

So each second, we call "_update(NSEC_PER_SEC)", however for each tick
we call update_wall_time_one_tick() which calls "_update(delta_nsec)". 

Thus in a period of one second, we call _update() HZ times w/
~NSEC_PER_SEC/HZ as an argument, then at the second overflow we call it
again w/ NSEC_PER_SEC. 

It seems that calling _update() on the second overflow is unnecessary.
And because in my implementation of update_cyclone(), we then clear the
offset_base variable, this causes time inconsistencies. 

It would be noted that time inconsistencies are not seen using the ITC
interpolator, however the ITC interpolator has an empty _update
function.

Am I just missing something here?

thanks
-john


