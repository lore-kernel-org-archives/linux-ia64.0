From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Jun 2004 20:35:38 +0000
Subject: Re: [draft] gettimeofday scalability: Moving cmpxchg into itc_get_offset
Message-Id: <16592.44826.580584.328018@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406161200460.6118@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0406161200460.6118@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Jun 2004 12:15:09 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> Any feedback appreciated.

It sounds good to me, except that removing the fast-path
gettimeofday() is a serious regression, especially now that there a
distros that actually support the fast path.

My suggestion: focus on implementing a fast-path clock_gettime() (for
CLOCK_REALTIME, I think).  Once that's working, we can direct gettimeofday()
to clock_gettime() with an additional nsec -> usec conversion.

In regards to fast division: the answer depends.  If you're dividing
by a constant, you can can use a multiply (let GCC take care of
generating the assembly code, to be sure you get all the bits
correct).  If you're not dividing by a constant, the best algorithm
depends on the range of the arguments.

	--david
