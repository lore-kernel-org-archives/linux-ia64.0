From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 04 Jun 2004 22:25:56 +0000
Subject: RE: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized ITC
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F016474FF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Only problem is that we can get high precision, but unless we can also
>get access to the NTP daemon's parameters, we don't know the accuracy
>of the result.
>
>Dunno about your systems, but mine drift around the real time by a
>couple of *milliseconds* so nanosecond accuracy in gettimeofday()
>won't buy much.

It depends what you are trying to do.  If you want to time how long
a short event takes ... then asking for the time of day before and
after and subtracting is the obvious solution.  If the event only
takes 5 micro-seconds, a one micro-second granularity in gettimeofday()
will give a +/- 20% error.  Even if the absolute time you see in the
two calls is off from UTC by a couple of milli-seconds, the rate of
drift is presumably small enough for the subtraction to make sense.

-Tony
