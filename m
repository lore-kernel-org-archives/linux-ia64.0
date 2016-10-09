From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 09 Oct 2016 15:17:48 +0000
Subject: Re: [RFC PATCH-tip v4 02/10] locking/rwsem: Stop active read lock ASAP
Message-Id: <20161009151748.GA29102@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
 <1471554672-38662-3-git-send-email-Waiman.Long@hpe.com>
 <20161006181718.GA14967@linux-80c1.suse>
 <20161006214751.GU27872@dastard>
In-Reply-To: <20161006214751.GU27872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Chinner <david@fromorbit.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, Waiman Long <Waiman.Long@hpe.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Fri, Oct 07, 2016 at 08:47:51AM +1100, Dave Chinner wrote:
> Except that it's DAX, and in 4.7-rc1 that used shared locking at the
> XFS level and never took exclusive locks.
> 
> *However*, the DAX IO path locking in XFS  has changed in 4.9-rc1 to
> match the buffered IO single writer POSIX semantics - the test is a
> bad test based on the fact it exercised a path that is under heavy
> development and so can't be used as a regression test across
> multiple kernels.

That being said - I wonder if we should allow the shared lock on DAX
files IFF the user is specifying O_DIRECT in the open mode..
