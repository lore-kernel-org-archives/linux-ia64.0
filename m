From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Jul 2004 01:16:21 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <16629.56037.120532.779793@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
	<1089835776.1388.216.camel@cog.beaverton.ibm.com>
	<Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
	<1089839740.1388.230.camel@cog.beaverton.ibm.com>
	<Pine.LNX.4.58.0407141703360.17055@schroedinger.engr.sgi.com>
	<1089852486.1388.256.camel@cog.beaverton.ibm.com>
In-Reply-To: <1089852486.1388.256.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: john stultz <johnstul@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, george anzinger <george@mvista.com>, lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

>>>>> On Wed, 14 Jul 2004 17:48:06 -0700, john stultz <johnstul@us.ibm.com> said:

  John> Although you still have the issue w/ NTP adjustments being
  John> ignored, but last time I looked at the time_interpolator code,
  John> it seemed it was being ignored there too, so at least your not
  John> doing worse then the ia64 do_gettimeofday(). [If I'm doing the
  John> time_interpolator code a great injustice with the above,
  John> someone please correct me]

The existing time-interpolator code for ia64 never lets time go
backwards (in the absence of a settimeofday(), of course).  There is
no need to special-case NTP.

With Christoph's changes, NTP is an issue again, however.

	--david
