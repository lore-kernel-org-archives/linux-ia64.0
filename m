From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 24 Sep 2003 18:29:18 +0000
Subject: Re: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106442817901476@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442430128845@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442430128845@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Sep 2003 12:17:41 -0600, Khalid Aziz <khalid_aziz@hp.com> said:

  Khalid> So it would seem. What would then explain clock going
  Khalid> backwards? Here is what I see when the test fails:

  Khalid> tpget37128357,995121000, tpset37128358,0

  Khalid> where tpget is what was returned by gettimeofday() and tpset
  Khalid> is what was set by settimeofday(). Clock seems to have moved
  Khalid> back by 4.879 msec.

Not sure off-hand and I haven't looked at the 2.4 code-base in a
while, but aren't we double-compensating in do_settimeofday()?  There,
we have:

		tv->tv_usec -= gettimeoffset();
		tv->tv_usec -= (jiffies - wall_jiffies) * (1000000 / HZ);

Perhaps the second line just needs to go?

	--david
