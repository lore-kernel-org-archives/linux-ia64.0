From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Jun 2004 17:33:39 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16574.3955.332701.713217@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 May 2004 12:05:57 -0700, Christoph Lameter <clameter@sgi.com> said:

  Christoph> The Altix systems never use ITC to determine the time so
  Christoph> this check and the cmpxchg is not necessary.

I see the problem: the basic problem seems to come from the fact that
the non-ITC-interpolation code didn't quite come out the way I
anticipated: I expected even this code to use/need last_nsec_offset
just like the ITC-based code, but it ended up not doing that.  I
_think_ that's OK and, if so, we should probably push all the
last_nsec_offset back down into the interpolator-specific code.
However, this is tricky code so I want to mull it some more to make
sure I'm not missing a subtle race.

  Christoph> Also the fast system call handler for sys_gettimeofday()
  Christoph> can only improve scalability if the ITC is the basis for
  Christoph> gettimeofday which is also never the case on Altix SN2
  Christoph> systems.

Does this really make a substantial difference?  My guess is no and,
if so, I'd rather not add any more #ifdefs.

	--david
