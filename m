From: Jack Steiner <steiner@sgi.com>
Date: Wed, 17 Mar 2004 16:20:16 +0000
Subject: Re: pgd_free, pmd_free, and pte_free trapping memory.
Message-Id: <20040317162016.GB32491@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040316112424.GA20203@lnx-holt>
In-Reply-To: <20040316112424.GA20203@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > 
> >   Robin> The page zeroing costs 4uSec per page (I believe that is the
> >   Robin> number).  With a typical fork taking approx 40 pages, that
> >   Robin> should be felt during an Aim7 run.  It looks like caches are
> >   Robin> masking some of that out.
> > 
> > Try UP.  Also, what if the page-size is 64KB?  In any case, 4usec is a
> > lot.
> 
> I got the 4uSec from Jack Steiner.  I don't know if he tested it with
> 64KB pages.  I will check.

I see the following times for the kernel "clearpage" routine. I run this
code in user space but I use the kernel assembly code for clearing pages.
AFAICT, the timing should be identical to running it in the kernel.

The test harness ensures that the timing is done with warm TLBs & cold 
cache (data not in cpu caches):

	 3.1 usec 16K node local memory
	 6.1 usec 16K remote memory

	12.5 usec 64K node local memory
	24.5 usec 64K remote memory

I ran this on Itanium 2 1300MHz cpus. However, processor core speed does
not significantly affect timings since most time is spent waiting for 
off chip memory access.

Also, timing will obviously vary across different platforms.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


