From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Jun 2004 21:29:06 +0000
Subject: Re: [draft] gettimeofday scalability: Moving cmpxchg into itc_get_offset
Message-Id: <16592.48034.936025.906433@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406161200460.6118@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0406161200460.6118@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Jun 2004 14:13:40 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> Can I change that API?

Yes, I think so.  ia64 is the only user of the API and when I created
the original API, I had to make some assumptions, some of which have
turned out to be wrong.

However, note that you cannot make normal function-calls from an
light-weight syscall handler (well, you _could_ but setting things up
to that point would cost extra time), so I think we'll have to
special-case the fast system-call path anyhow.  It would be nice
if we could limit it to two cases:

 - ITC-based interpolation.
 - global clock based interpolation.

I think it _may_ work, seeing that HPET, SN2 timer, and Cyclone all
seem to be reading the global clock with a single 8-byte MMIO load.

  Christoph> The particular problem is that one has a 64 bit number of
  Christoph> nsecs since some initial timeframe (possibly
  Christoph> get_counter()*freq+offset) that needs to be separated
  Christoph> into secs and nsecs. The divisor is 32bits (1000000000).

  Christoph> Typically this is

  Christoph> n / 1000000000 -> secs n % 1000000000 -> nsecs

  Christoph> I saw that you were able to simulate division by 1000
  Christoph> through multiplying by a constant. Is that code generated
  Christoph> by the compiler that you kept or did you develop that
  Christoph> yourself?

I think that code may have been written by Ian originally but yes, I
definitely always use the compiler to help me with
division-by-constants.  You have to be a little bit careful about that
to avoid losing significant bits and the compiler already has all the
logic to do that.  Thanks to the xmpy.hu instruction, it is always
possible to reduce integer-division-by constant to a multiply & shift
on ia64.

  Christoph> I could simply get to the .S file generated from timer.c
  Christoph> and start out with the code there.

I'd just write a dummy function which does the division only, so that
you don't get all the extra code aroun dit.

	--david
