From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Jul 2004 21:14:09 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <16629.41505.190823.945993@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
	<1089835776.1388.216.camel@cog.beaverton.ibm.com>
	<Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407141323530.15874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: john stultz <johnstul@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

>>>>> On Wed, 14 Jul 2004 13:28:39 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> Right. I had it named getnstimeofday before but the
  Christoph> feeling was that the patch should not introduce a new
  Christoph> name. Any approach that would allow progress on the issue
  Christoph> would be fine with me.

Just to avoid further confusion: I wasn't objecting to the name, I was
suggesting that do_gettimeofday() should instead use timespec.

  Christoph> do_gettimeofday is used all over the linux kernel for a
  Christoph> variety of purposes and lots of code depends on the
  Christoph> presence of a timeval struct.

Which is true...

	--david
