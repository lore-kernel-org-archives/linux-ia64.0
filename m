From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 09 Mar 2005 23:06:27 +0000
Subject: Re: Page Fault Scalability patch V19 [1/4]: pte_cmpxchg and
Message-Id: <Pine.LNX.4.58.0503091503140.30604@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309201324.29721.28956.sendpatchset@schroedinger.engr.sgi.com>
 <20050309201329.29721.1860.sendpatchset@schroedinger.engr.sgi.com>
 <m1y8cwv2yl.fsf@muc.de>
In-Reply-To: <m1y8cwv2yl.fsf@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 10 Mar 2005, Andi Kleen wrote:

> Christoph Lameter <clameter@sgi.com> writes:
> >
> > Atomic operations may be enabled in the kernel configuration on
> > i386, ia64 and x86_64 if a suitable CPU is configured in SMP mode.
> > Generic atomic definitions for ptep_xchg and ptep_cmpxchg
> > have been provided based on the existing xchg() and cmpxchg() functions
> > that already work atomically on many platforms. It is very
>
> I'm curious - do you have any micro benchmarks on i386 or x86-64 systems
> about the difference between spin_lock(ptl) access; spin_unlock(ptl);
> and cmpxchg ?

There is a benchmark for UP on
http://oss.sgi.com/projects/page_fault_performance.

> cmpxchg can be quite slow, with bad luck it could be slower than
> the spinlocks.

Spinlocks also require atomic operations like a lock decb on i386 in order
to acquire the locks. And the page_table_lock is acquired two
times in the page fault handler. In order for this to be faster

2*spinlock acquisition and release would have to be faster than a cmpxchg.

> A P4 would be good to benchmark this because it seems to be the worst
> case.

The numbers on the webpage are for an AMD64. But I can try
to get some testing done on a P4 too.
