From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Jun 2004 22:13:26 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16582.14854.924570.718924@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Jun 2004 14:48:20 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:

  Christoph> Please show me how last_itc can *receive* a bogus
  Christoph> value. What you are saying cannot happen because last_itc
  Christoph> does not depend in any way on variables modified by the
  Christoph> timer interrupt. Last_itc is updated using a cmpxchg
  Christoph> which will deal with the problem of multiple CPUs
  Christoph> updating the value.

Ah, I see now what you mean.  Yes, tracking the maximum ITC rather
than a relative offsets is a nice trick that solves the problem of the
ITC-based getoffset not being "restartable".

What threw me off is that you continue to read jiffies and
wall_jiffies in the do/while-loop for the cmpxchg.  I don't see why
that's necessary/helpful.  If you get a tick, you'll throw away the
result of the routine anyhow so you might just as well move it out of
the loop.

So I think your patch does work.  I'd only ask that you replace the
explicit "check-for-earlier while allowing for wraparound" with a call
to the time_before() macro (or at least the equivalent open-code, if
you're nervous about using jiffies-related macros for non-jiffy
values).

Thanks,

	--david
