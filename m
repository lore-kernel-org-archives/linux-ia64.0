From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 16 Mar 2004 15:34:01 +0000
Subject: Re: pgd_free, pmd_free, and pte_free trapping memory.
Message-Id: <20040316153401.A1335@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040316112424.GA20203@lnx-holt>
In-Reply-To: <20040316112424.GA20203@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 16, 2004 at 09:24:55AM -0600, Robin Holt wrote:
> I have a kernel with these ripped out.  I have run one simple Aim7 run
> on a 32P system.  The performance fell in the noise range of a normal
> Aim7 run.  Is this a good test to run?  Should I focus on any specific
> benchmark, or run a suite?

I'm not actually sure.  You could ask Ingo Molnar who implemented both
the per-cpu pages and ripped out the x86 quicklists if I remember correctly.

Ingo, any idea on how to benchmark that kind of thing best?

> > That's less code and thus less complexity which is always good.  Now if
> > the pre-zeroing actually makes a difference we might have to keep small
> > pre-zeroed list around, but I doubt this is really good idea (or even
> > nessecary)
> 
> The page zeroing costs 4uSec per page (I believe that is the number).
> With a typical fork taking approx 40 pages, that should be felt during
> an Aim7 run.  It looks like caches are masking some of that out.

OTOH you have more pages avalilable, the real per-cpu pages have a better
cache locality than the quicklists, the kernel has a smaller icache footprint,
etc..
