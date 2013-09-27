From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 27 Sep 2013 16:04:06 +0000
Subject: Re: [PATCH] checkpatch: Make the memory barrier test noisier
Message-Id: <20130927160406.GY9093@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130927060213.GA6673@gmail.com>
 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
 <1380289495.17366.91.camel@joe-AO722>
 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
 <1380291257.17366.103.camel@joe-AO722>
 <20130927142605.GC15690@laptop.programming.kicks-ass.net>
 <1380292495.17366.106.camel@joe-AO722>
 <20130927145007.GD15690@laptop.programming.kicks-ass.net>
 <20130927151749.GA2149@linux.vnet.ibm.com>
 <20130927153434.GG15690@laptop.programming.kicks-ass.net>
In-Reply-To: <20130927153434.GG15690@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Joe Perches <joe@perches.com>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org

On Fri, Sep 27, 2013 at 05:34:34PM +0200, Peter Zijlstra wrote:
> On Fri, Sep 27, 2013 at 08:17:50AM -0700, Paul E. McKenney wrote:
> > > Barriers are fundamentally about order; and order only makes sense if
> > > there's more than 1 party to the game.
> > 
> > Oddly enough, there is one exception that proves the rule...  On Itanium,
> > suppose we have the following code, with x initially equal to zero:
> > 
> > CPU 1: ACCESS_ONCE(x) = 1;
> > 
> > CPU 2: r1 = ACCESS_ONCE(x); r2 = ACCESS_ONCE(x);
> > 
> > Itanium architects have told me that it really is possible for CPU 2 to
> > see r1=1 and r2=0.  Placing a memory barrier between CPU 2's pair of
> > fetches prevents this, but without any other memory barrier to pair with.
> 
> Oh man.. its really past time to sink that itanic already.
> 
> I suppose it allows the cpu to reorder the reads in its pipeline and the
> memory barrier disallows this. Curious.. does our memory-barriers.txt
> file mention this 'fun' fact?

Probably not.  I was recently reminded of it by some people on the C++
standards committee.  I had first heard of it about 5 years ago, but
hadn't heard definitively until quite recently.

I defer to the Itanium maintainers to actually make the required changes,
should they choose to do so.  I suppose that one way to handle it in the
Linux kernel would be to make ACCESS_ONCE() be architecture specific,
with Itanium placing a memory barrier either before or after --- either
would work.  But since Itanium seems to run Linux reliably, I am guessing
that the probability of misordering is quite low.  But again, the ball
is firmly in the Itanium maintainers' courts, and I have added them on CC.

							Thanx, Paul

