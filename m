From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 14 Mar 2006 10:12:31 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <4416970F.902@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

> Hmm, I think another alternative is to rip out all the itc insertion
> code and let the hardware page walker do the "dirty" job.  Because it
> is known and architected to be atomic-read-and-insert and is also
> known to honor ptc.g while atomic-read-and-insert is in-flight (i.e.,
> won't insert tlb entry).

Form the "semantical point of view", I can agree with you.

Yet in my sequence:

(p6)    cmpxchg8.acq.nta r26 = [r17],r25,ar.ccv
(p6)    itc.d r25
         ;;
(p6)    srlz.d

the execution of "cmpxchg" (that is not a quick & simple instruction)
partially overlaps that of "itc" (this latter has got an acquire
semantics, it does not depend on the completion of the former).

If it is the page walker that inserts the new translation, then it has
to observe the purge requirements, too:
E.g. in case of page size of 64 K, up to 16 L1 DTLB entries may be
purged and all the L1D cache lines brought in via these translations
need to be invalidated.
It does take time.

> I don't have any numbers ...  Though I've measured 5 cycles hpw insert
> latency. It ought be faster than srlz.d.

How did you measure it?

I'd expect (sure, not knowing exectly how the HW works :-)) up to:

	  16	max. number of L1 DTLB entries used for a page
	* 32	L1D cache is indexed as 0...31
	----
	 512

cycles only for purging and invalidating the old suff.

I think the CPU refuses the external purge request while the hardware
page walker is busy with this clean up activity
(retry response on the system bus).

In my sequence, it is "srlz.d" that stalls the exec. pipeline during
this clean up activity.

> It occurs on me that you can do even more: you don't even need the
> 2nd load, move itc opportunistically before cmpxchg, then use data
> returned from cmpxchg and compare it to the first read.

You will have to have a slightly more complicated sequence:

(p6)    itc.d r25
         ;;                                // "itc" must be the last in the group
(p6)    srlz.d                            // This is what I think is necessary
(p6)    cmpxchg8.acq r26=[r17],r25,ar.ccv

You avoid an L2 cache access by eliminating "ld" and you do not
take advantage of the partially overlapping "cmpxchg" and "itc".

Regards,

Zoltan
