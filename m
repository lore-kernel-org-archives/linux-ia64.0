From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 14 Mar 2006 19:33:53 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603141933.k2EJXrg05935@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Tuesday, March 14, 2006 2:13 AM
> Yet in my sequence:
> 
> (p6)    cmpxchg8.acq.nta r26 = [r17],r25,ar.ccv
> (p6)    itc.d r25
>          ;;
> (p6)    srlz.d
> 
> the execution of "cmpxchg" (that is not a quick & simple instruction)
> partially overlaps that of "itc" (this latter has got an acquire
> semantics, it does not depend on the completion of the former).

This is indeed a very fine work of art in micro-optimization.  Thank you
for pointing this out. I think this is going to save us a lot of cycles.


> If it is the page walker that inserts the new translation, then it has
> to observe the purge requirements, too:
> E.g. in case of page size of 64 K, up to 16 L1 DTLB entries may be
> purged and all the L1D cache lines brought in via these translations
> need to be invalidated.

There is no need to worry about performance in the slow path.  Slow path
is meant to take whatever effort needed to fix up a detected race condition.
So let it be a couple of cycles longer.


> I'd expect (sure, not knowing exectly how the HW works :-)) up to:
> 
> 	  16	max. number of L1 DTLB entries used for a page
> 	* 32	L1D cache is indexed as 0...31
> 	----
> 	 512
> 
> cycles only for purging and invalidating the old suff.

The hardware is a lot smarter than what you think :-)  come on, we are
talking about Itanium processor here. I plea you to give some faith to
the hardware designers please.

- Ken

