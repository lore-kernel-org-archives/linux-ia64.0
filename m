From: Keith Owens <kaos@sgi.com>
Date: Tue, 22 Mar 2005 03:04:55 +0000
Subject: Re: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <10666.1111460695@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12404.1111129477@kao2.melbourne.sgi.com>
In-Reply-To: <12404.1111129477@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Mar 2005 23:17:29 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 18 Mar 2005 18:04:37 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> memcpy_mck.S::__copy_user breaks in the prefetch code under these
>  Keith> conditions :-
>
>  Keith> * src is unaligned and
>  Keith> * dst is near the end of a page and
>  Keith> * the page after dst is unmapped.
>
>  Keith> The loop count in r21 is 1 value too high.  A length of 0x100 gives
>  Keith> ar.lc = r21 = 2.  .unaligned_src incorrectly copies r21 into ar.lc,
>  Keith> when it should copy cnt, so the lfetch lines are executed 3 times, not
>  Keith> 2.  That takes dst_pre_mem past the end of the page and into an
>  Keith> unallocated area, oops.
>
>That's a good thing to fix (it's definitely a performance bug).  However,
>lfetch.fault should be safe to use even on unmapped memory.  See this
>code in ia64_do_page_fault():
>
> /*
>  * This fault was due to a speculative load or lfetch.fault, set the "ed"
>  * bit in the psr to ensure forward progress.  (Target register will get a
>  * NaT for ld.s, lfetch will be canceled.)
>  */
>
>I don't see off-hand why this wouldn't work as intended.

It's got me puzzled as well.  On my test system, single stepping the
offending instruction _WILL_ cause a fault, but letting it run normally
does not cause an error.  A normal run (without single step) definitely
uses lfetch with an invalid address, however ia64_fault() is not
invoked, not even for isr.na.

I am trying to get some time on the big system to reproduce the problem
and see why lfetch is faulting there.  Is there any chance that a
concurrent interrupt (the failing system does a lot of I/O) can lose
the lfetch status?

