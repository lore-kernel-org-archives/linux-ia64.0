From: Robin Holt <holt@sgi.com>
Date: Tue, 16 Mar 2004 15:24:55 +0000
Subject: Re: pgd_free, pmd_free, and pte_free trapping memory.
Message-Id: <20040316152455.GC3311@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040316112424.GA20203@lnx-holt>
In-Reply-To: <20040316112424.GA20203@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 16, 2004 at 02:48:20PM +0000, Christoph Hellwig wrote:
> On Tue, Mar 16, 2004 at 05:24:24AM -0600, Robin Holt wrote:
> > Looking through the code, we have identified the source of the problem.
> > The fork is occuring on one cpu where the pgd, pmd, and pte allocations
> > get pages of memory local to that cpu.  The worker thread is then
> > migrated to a different cpu where it exits.  The pages are then placed
> > on the cpu which is very distant from where the memory is located.
> > 
> > I looked at the i386 code which appears to have been very similar to the
> > ia64 at one point in time, but no longer.  They appear to have completely
> > eliminated the quicklists.  Is this the right direction for ia64?
> > 
> > Since, when the pgd, pmd, and pte are ready to be freed, they are
> > zeroed out again, I understand the benefit to keeping the entry around
> > to save the time for zeroing out the page again.  Why not have a single
> > quicklist where all three are placed.  How would node locality best play
> > into placing items on the lists?  Should we have one quicklist on
> > each cpu that a cpu returns node local pages and then a node quicklist
> > where we place pages that are not node local using cmpxchg?
> 
> Tjis quicklist thing is a workaround for not having per-cpu pages in
> Linux <= 2.4.  Your patch is a workaround for a workaround and gets a little
> ugly.  I'd say just rip the quicklists out like x86 and benchmark it.

I have a kernel with these ripped out.  I have run one simple Aim7 run
on a 32P system.  The performance fell in the noise range of a normal
Aim7 run.  Is this a good test to run?  Should I focus on any specific
benchmark, or run a suite?

> 
> That's less code and thus less complexity which is always good.  Now if
> the pre-zeroing actually makes a difference we might have to keep small
> pre-zeroed list around, but I doubt this is really good idea (or even
> nessecary)

The page zeroing costs 4uSec per page (I believe that is the number).
With a typical fork taking approx 40 pages, that should be felt during
an Aim7 run.  It looks like caches are masking some of that out.
