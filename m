From: Robin Holt <holt@sgi.com>
Date: Sun, 18 Sep 2005 23:06:25 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050918230625.GA19862@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 16, 2005 at 06:08:45PM -0700, David Mosberger-Tang wrote:
> On 9/16/05, Robin Holt <holt@sgi.com> wrote:
> 
> > Can you site one instance where it is more helpful to know that _ANY_
> > lock in the system is hitting ia64_spinlock_contention as opposed to
> > the function which has the spin_lock() code?  I can recall times when
> > network traffic was contending on locks and causing my application to
> > appear to have a contended lock.  With this change, at least we know
> > the degradation is do to something external.
> 
> Not sure if I can help siting it, but I can cite one recent example: I
> was looking at a profile of a test which wasn't supposed to have any
> contention.  Yet, ia64_spinlock_contention unexpectedly showed up
> fairly high in the profile.  Turns out it was due to some left-over
> debug code.  Of course, I was using q-syscollect so it was easy to see
> who was calling the spinlock contention routine a lot...

That would be a case where you are contending on one lock and you would
be given the function that was contending.  What I was concerned with
is where two or more locks are contended and ia64_spinlock_contention
artificially appears at the top.

Robin
