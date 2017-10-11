From: Dave Chinner <david@fromorbit.com>
Date: Wed, 11 Oct 2017 20:45:57 +0000
Subject: Re: [PATCH v6 00/11] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <20171011204557.GJ15067@dastard>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
 <20171011184840.3uomgj3hxxzernfd@hirez.programming.kicks-ass.net>
In-Reply-To: <20171011184840.3uomgj3hxxzernfd@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>

On Wed, Oct 11, 2017 at 08:48:40PM +0200, Peter Zijlstra wrote:
> On Wed, Oct 11, 2017 at 02:01:51PM -0400, Waiman Long wrote:
> >   # of Patches		   Reader 		  Writer
> >     Applied		Locking Rate		Locking Rate
> >   ------------		------------		------------
> > 	0	5,155/    5,155/    5,155    5,154/248,852/346,281
> > 	7	5,696/    5,697/    5,698  113,500/215,826/320,872
> > 	8	4,827/    5,047/    5,215    4,826/176,797/284,069
> > 	9     211,276/  509,712/1,134,007    4,894/221,839/246,818
> >        11     884,513/1,043,989/1,252,533    9,604/ 11,105/ 25,225
> > 
> > It can be seen that rwsem changes from writer-preferring to
> > reader-preferring.
> 
> A bit radically so, you almost starve the writers there.

Which is a bit of a problem for us, because we often use the write
locks as an IO barrier for operations like truncate, fallocate, etc.
i.e. we want it to immediately block readers.

That's going to be a bit of a problem if, for example, we have so
many AIO-based direct IO writers on a file we can't get fallocate to
run in a timely fashion to preallocate the space the writers are
soon going to write into.

Not to mention the AIO-DIO append case where we have multiple
concurrent writers at EOF, and so every so often one of the many IOs
needs to take the write lock extending EOF safely. Blocking that for
10ms waiting for a hand-off is going to make all the people who care
about deterministic IO latency go nuts....

So from my perspective on the IO side, I'd much prefer a write bias.
Indeed, if we go back to the Irix XFS code, all these locks we
defined as "MR_BARRIER" locks, which meant the XFS rwsems were
specifically intended to have writer bias.

I think we can live with a fair r/w bias, but swinging from a
50:1 write bias to a 100:1 read bias is going change behaviour
dramatically, and in many cases it won't be an improvement...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
