From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Mar 2003 00:43:28 +0000
Subject: Re: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705281@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705273@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705273@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Mar 2003 15:55:02 -0800, Rich Altmaier <richa@engr.sgi.com> said:

  Rich> Jes, regarding your query on real life ITC drifts, I have this
  Rich> input.  Typical crystals used for the CPU clock today have an
  Rich> accuracy of 250ppm.  That is 250 parts per million.  Which
  Rich> means for each million ticks, it may actually be 250 realtime
  Rich> units too fast or too slow.  So in one second's worth of 1GHz
  Rich> ticks, it may be wrong versus realtime by 250 microseconds.
  Rich> (not to belabor the point, but then a 1 millisecond error
  Rich> accumulates each 4 seconds).

Good point.

  Rich> In case you ask "how can this be, my digital watch is better
  Rich> than that".  Your watch is better designed, plus it has more
  Rich> temperature stability on your arm.  Plus nobody is willing to
  Rich> buy expensive crystals for the computer...

Well, most watches don't run at 1GHz either! ;-)

	--david

