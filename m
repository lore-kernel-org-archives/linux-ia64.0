From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Nov 2003 06:01:18 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106930814009175@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 20:09:15 -0800, "John Hawkes" <hawkes@sgi.com> said:

  John> I'd like to hear an argument about why sched_clock() needs
  John> sub-microsecond accuracy, instead of just using jiffies, when
  John> one use of sched_clock() is to compare a delta time against
  John> cache_decay_ticks, which is a "jiffies"-granularity value, and
  John> the other use is to determine the relative
  John> computebound-vs-interactive characteristics of the process.

It's probably best to discuss this on lkml.  I didn't follow all the
recent scheduler developments but AFAIK, this is largely driven by
trying to fix some scheduling corners.  I think the "persistent
starvation" bug that Stephane found gets fixed by it, for example.
Also, supposedly it helps interactivity.

	--david
