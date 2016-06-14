From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 14 Jun 2016 18:24:23 +0000
Subject: Re: [RFC PATCH-tip 6/6] xfs: Enable reader optimistic spinning for DAX inodes
Message-Id: <20160614182423.GA6330@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
 <1465927959-39719-7-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465927959-39719-7-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <Waiman.Long@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, xfs@oss.sgi.com, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Tue, Jun 14, 2016 at 02:12:39PM -0400, Waiman Long wrote:
> This patch enables reader optimistic spinning for inodes that are
> under a DAX-based mount point.
> 
> On a 4-socket Haswell machine running on a 4.7-rc1 tip-based kernel,
> the fio test with multithreaded randrw and randwrite tests on the
> same file on a XFS partition on top of a NVDIMM with DAX were run,
> the aggregated bandwidths before and after the patch were as follows:

And why is this specific to DAX?  Many I/O operations already never
got out to disk, and ilock is mostly held for operations that have
nothing to do with disk I/O.
