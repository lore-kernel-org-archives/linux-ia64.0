From: Dave Chinner <david@fromorbit.com>
Date: Thu, 06 Oct 2016 21:47:51 +0000
Subject: Re: [RFC PATCH-tip v4 02/10] locking/rwsem: Stop active read lock ASAP
Message-Id: <20161006214751.GU27872@dastard>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
 <1471554672-38662-3-git-send-email-Waiman.Long@hpe.com>
 <20161006181718.GA14967@linux-80c1.suse>
In-Reply-To: <20161006181718.GA14967@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Waiman Long <Waiman.Long@hpe.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Thu, Oct 06, 2016 at 11:17:18AM -0700, Davidlohr Bueso wrote:
> On Thu, 18 Aug 2016, Waiman Long wrote:
> 
> >Currently, when down_read() fails, the active read locking isn't undone
> >until the rwsem_down_read_failed() function grabs the wait_lock. If the
> >wait_lock is contended, it may takes a while to get the lock. During
> >that period, writer lock stealing will be disabled because of the
> >active read lock.
> >
> >This patch will release the active read lock ASAP so that writer lock
> >stealing can happen sooner. The only downside is when the reader is
> >the first one in the wait queue as it has to issue another atomic
> >operation to update the count.
> >
> >On a 4-socket Haswell machine running on a 4.7-rc1 tip-based kernel,
> >the fio test with multithreaded randrw and randwrite tests on the
> >same file on a XFS partition on top of a NVDIMM with DAX were run,
> >the aggregated bandwidths before and after the patch were as follows:
> >
> > Test      BW before patch     BW after patch  % change
> > ----      ---------------     --------------  --------
> > randrw        1210 MB/s          1352 MB/s      +12%
> > randwrite     1622 MB/s          1710 MB/s      +5.4%
> 
> Yeah, this is really a bad workload to make decisions on locking
> heuristics imo - if I'm thinking of the same workload. Mainly because
> concurrent buffered io to the same file isn't very realistic and you
> end up pathologically pounding on i_rwsem (which used to be until
> recently i_mutex until Al's parallel lookup/readdir). Obviously write
> lock stealing wins in this case.

Except that it's DAX, and in 4.7-rc1 that used shared locking at the
XFS level and never took exclusive locks.

*However*, the DAX IO path locking in XFS  has changed in 4.9-rc1 to
match the buffered IO single writer POSIX semantics - the test is a
bad test based on the fact it exercised a path that is under heavy
development and so can't be used as a regression test across
multiple kernels.

If you want to stress concurrent access to a single file, please
use direct IO, not DAX or buffered IO.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
