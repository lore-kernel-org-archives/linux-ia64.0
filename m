From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 22:52:25 +0000
Subject: Re: sched_clock
Message-Id: <16576.64809.757551.150988@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B4868F.B649611C@nospam.org>
In-Reply-To: <40B4868F.B649611C@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 04 Jun 2004 13:11:26 +0200, Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org> said:

  Zoltan> David Mosberger wrote:
  >>  Yes, you're right, there is an intermediate-result overflow
  >> problem in sched_clock() that I missed.  How does the attached
  >> patch work for you?

  Zoltan> Thank you, it is O.K.

Thanks for checking it out.

  Zoltan> On the other hand, we might have similar problems in
  Zoltan> fsys.S. Some comments like the one below makes me worry a
  Zoltan> bit:

  Zoltan> 	// if now < last_tick, set p7 = 1, p8 = 0

  Zoltan> I cannot really say that I fully understand what is in
  Zoltan> fsys.S, but should not "now" always be after no matter what
  Zoltan> time stamp, last tick ?

No, the "<" there is done with 64-bit modular arithmetic so this code
is fine (it's the equivalent of the time_before() macro).

The ia64-specific code is very careful to work correctly even when the
ITC wraps around.  sched_clock() is a (platform-independent) exception
and it is OK because, in the worst case, an overflow will lead to a
scheduling hiccup.  Basically, the scheduler will simply "think" that
a task slept for NS_MAX_SLEEP_AVG when it may have slept much less
(there may be some other minor hiccups, but that should be pretty much
it, AFAICT).

	--david
