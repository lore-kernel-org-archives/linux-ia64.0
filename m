From: Robin Holt <holt@sgi.com>
Date: Wed, 17 Mar 2004 12:27:15 +0000
Subject: Re: pgd_free, pmd_free, and pte_free trapping memory.
Message-Id: <20040317122714.GD2119@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040316112424.GA20203@lnx-holt>
In-Reply-To: <20040316112424.GA20203@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 16, 2004 at 10:06:18PM -0800, David Mosberger wrote:
> >>>>> On Tue, 16 Mar 2004 09:24:55 -0600, Robin Holt <holt@sgi.com> said:
> 
>   Robin> I have a kernel with these ripped out.  I have run one simple
>   Robin> Aim7 run on a 32P system.  The performance fell in the noise
>   Robin> range of a normal Aim7 run.  Is this a good test to run?
>   Robin> Should I focus on any specific benchmark, or run a suite?
> 
> For this kind of test, I'd rather see a micro-benchmark to establish
> the worst-case effect.  Then we have an upper bound and can make a
> judgment as to whether or not that's a likely scenario.  And yes, this
> would mean that you'd probably want to measure it on a relative small
> system (certainly not NUMA, perhaps just UP).

I am currently looking into Christoph's suggestion of using a per
cpu page allocator.  Unfortunately, yesterday was a little busy and
I didn't get much of a chance to look into it.

> 
>   >>  That's less code and thus less complexity which is always good.
>   >> Now if the pre-zeroing actually makes a difference we might have
>   >> to keep small pre-zeroed list around, but I doubt this is really
>   >> good idea (or even nessecary)
> 
>   Robin> The page zeroing costs 4uSec per page (I believe that is the
>   Robin> number).  With a typical fork taking approx 40 pages, that
>   Robin> should be felt during an Aim7 run.  It looks like caches are
>   Robin> masking some of that out.
> 
> Try UP.  Also, what if the page-size is 64KB?  In any case, 4usec is a
> lot.

I got the 4uSec from Jack Steiner.  I don't know if he tested it with
64KB pages.  I will check.
