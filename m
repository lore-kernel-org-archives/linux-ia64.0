From: "David S. Miller" <davem@redhat.com>
Date: Sun, 15 Aug 2004 23:58:27 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <20040815165827.0c0c8844.davem@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
	<20040815130919.44769735.davem@redhat.com>
	<Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 15 Aug 2004 15:58:27 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sun, 15 Aug 2004, David S. Miller wrote:
> 
> >
> > Is the read lock in the VMA semaphore enough to let you do
> > the pgd/pmd walking without the page_table_lock?
> > I think it is, but just checking.
> 
> That would be great.... May I change the page_table lock to
> be a read write spinlock instead?

No, I means "is the read long _ON_ the VMA semaphore".
The VMA semaphore is a read/write semaphore, and we grab
it for reading in the code path you're modifying.

Please don't change page_table_lock to a rwlock, it's
only needed for write accesses.
