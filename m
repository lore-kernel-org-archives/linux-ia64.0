From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Jul 2004 03:57:56 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <16630.196.880937.911232@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
	<1089835776.1388.216.camel@cog.beaverton.ibm.com>
	<Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
	<1089839740.1388.230.camel@cog.beaverton.ibm.com>
	<Pine.LNX.4.58.0407141703360.17055@schroedinger.engr.sgi.com>
	<1089852486.1388.256.camel@cog.beaverton.ibm.com>
	<16629.56037.120532.779793@napali.hpl.hp.com>
	<1089855319.1388.295.camel@cog.beaverton.ibm.com>
In-Reply-To: <1089855319.1388.295.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: john stultz <johnstul@us.ibm.com>
Cc: David Mosberger <davidm@hpl.hp.com>, Christoph Lameter <clameter@sgi.com>, george anzinger <george@mvista.com>, lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

>>>>> On Wed, 14 Jul 2004 18:35:20 -0700, john stultz <johnstul@us.ibm.com> said:

  john> On Wed, 2004-07-14 at 18:16, David Mosberger wrote:
  >> >>>>> On Wed, 14 Jul 2004 17:48:06 -0700, john stultz
  >> <johnstul@us.ibm.com> said:

  >>  The existing time-interpolator code for ia64 never lets time go
  >> backwards (in the absence of a settimeofday(), of course).  There
  >> is no need to special-case NTP.

  John> I guess I don't understand then, from my looking over it I
  John> didn't see where the time_interpolator_get_offset() is scaled
  John> back when NTP is slewing the clock.

Are you looking at Christoph's code?  My explanation applies to the
old interpolation-code...

	--david
