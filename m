From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 10 Oct 2016 09:34:34 +0000
Subject: Re: [RFC PATCH-tip v4 02/10] locking/rwsem: Stop active read lock ASAP
Message-Id: <20161010093434.GA18024@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
 <1471554672-38662-3-git-send-email-Waiman.Long@hpe.com>
 <20161006181718.GA14967@linux-80c1.suse>
 <20161006214751.GU27872@dastard>
 <20161009151748.GA29102@infradead.org>
 <20161010060745.GA27872@dastard>
In-Reply-To: <20161010060745.GA27872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Davidlohr Bueso <dave@stgolabs.net>, Waiman Long <Waiman.Long@hpe.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Mon, Oct 10, 2016 at 05:07:45PM +1100, Dave Chinner wrote:
> > > *However*, the DAX IO path locking in XFS  has changed in 4.9-rc1 to
> > > match the buffered IO single writer POSIX semantics - the test is a
> > > bad test based on the fact it exercised a path that is under heavy
> > > development and so can't be used as a regression test across
> > > multiple kernels.
> > 
> > That being said - I wonder if we should allow the shared lock on DAX
> > files IFF the user is specifying O_DIRECT in the open mode..
> 
> It should do - if it doesn't then we screwed up the IO path
> selection logic in XFS and we'll need to fix it.

Depends on your defintion of "we".  The DAX code has always abused the
direct I/O path, and that abuse is ingrained in the VFS path in a way that
we can't easily undo it in XFS, e.g. take a look at io_is_direct and
iocb_flags in include/linux/fs.h, which ensure that DAX I/O will always
appear as IOCB_DIRECT to the fs.  It will take some time to untagle
this, but it's on my todo list once the last file system (ext4)
untangles the DAX and direct I/O path.
