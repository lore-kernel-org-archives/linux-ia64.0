From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 16 Aug 2004 00:11:53 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
 <20040815130919.44769735.davem@redhat.com> <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
 <20040815165827.0c0c8844.davem@redhat.com>
In-Reply-To: <20040815165827.0c0c8844.davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@redhat.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


On Sun, 15 Aug 2004, David S. Miller wrote:
> > On Sun, 15 Aug 2004, David S. Miller wrote:
> > > Is the read lock in the VMA semaphore enough to let you do
> > > the pgd/pmd walking without the page_table_lock?
> > > I think it is, but just checking.
> >
> > That would be great.... May I change the page_table lock to
> > be a read write spinlock instead?
>
> No, I means "is the read long _ON_ the VMA semaphore".
> The VMA semaphore is a read/write semaphore, and we grab
> it for reading in the code path you're modifying.
>
> Please don't change page_table_lock to a rwlock, it's
> only needed for write accesses.

pgd/pmd walking should be possible always even without the vma semaphore
since the CPU can potentially walk the chain at anytime.

The modification of the pte is not without issue since there are other
code paths that may modify pte's and rely on the page_table_lock to
exclude others from modifying ptes. One known problem is the swap
code which sets the page to the pte_not_present condition to insure that
nothing else touches the page while it is figuring out where to put it. A
page fault during that time (skipping the checking of the
page_table_lock) will cause the fastpath to be taken which will then
assign new memory to it.

We need to have some kind of system how finer granularity locks could be
realized.

One possibility is to abuse the rw spinlock to not only allow exclusive
access to the page tables(as done right now with the spinlock) but also
allow shared access with pte locking after a read lock.

Is there any other way to realize this?


