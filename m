From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 11 Jul 2007 01:31:38 +0000
Subject: Re: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <469432FA.70206@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <468CA2D6.40204@jp.fujitsu.com>
In-Reply-To: <468CA2D6.40204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>  >>>  	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
>  >>> +	;;
>  >>>  (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
> 
> The .acq only causes ordering w.r.t. data accesses.  The read from ar.itc
> isn't a data access, so potentially it could still float before the
> ld4.acq.  Consuming the value loaded into r28 presumably has to
> ensure that the load completes though.

Hmm, then will this problem not happen if timesource was not ar.itc?
If source is mmio, the read from the address is a data access, isn't it?

> I'm guessing here ... I haven't cross-checked with the architects.

I'll be grad if we can get a comment from Intel's architects.

> Does moving the "and r28 = ~1,r28" up into this slot hurt latency
> for a single call to gettimeofday()?  Presumably it will if
> xtime_lock.sequence is not in the cache.
> 
> -Tony

It will, I guess.
Anyway, we should make sure that the load of xtime_lock.sequence have
complete before reading ar.itc.

Thanks,
H.Seto

