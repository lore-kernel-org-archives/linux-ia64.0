From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 10:55:47 +0000
Subject: Re: [PATCH 1/2] ia64 clocksource
Message-Id: <469CA033.6080506@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070714002509.GJ2317@localhost>
In-Reply-To: <20070714002509.GJ2317@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bob Picco wrote:
> @@ -214,61 +209,56 @@ ENTRY(fsys_gettimeofday)
  :
>  	movl r27 = xtime
  :
>  .time_redo:
> -	.pred.rel.mutex p8,p9,p10
> -	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
> +	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must be first in struct
  :
>  	ld8 r8 = [r27],-IA64_TIMESPEC_TV_NSEC_OFFSET	// xtime.tv_nsec
  :
> -	ld4 r10 = [r29]		// xtime_lock.sequence
> +	ld4 r10 = [r20]		// gtod_lock.sequence, old xtime_lock.sequence
  :
>  	cmp4.ne.or p7,p0 = r28,r10
> -(p7)	br.cond.dpnt.few .time_redo	// sequence number changed ?
> +(p7)	br.cond.dpnt.few .time_redo	// sequence number changed, outer loop2

This patch removes locking xtime_lock but the code still reads xtime.

Since gtod_lock.sequence will not tell us whether xtime is updated
(or going to be updated) while in this window, the result may be wrong...


>  	// r29 = address of seqlock
  :
> -	movl r20 = time_interpolator
> +	movl r20 = fsyscall_gtod_data // load fsyscall gettimeofday data address
>  	;;
> -	ld8 r20 = [r20]		// get pointer to time_interpolator structure
> -	movl r29 = xtime_lock
> -	ld4 r2 = [r2]		// process work pending flags
> +	add r29 = IA64_ITC_JITTER_OFFSET,r20

It seems that the comment doesn't match to current usage.


Thanks,
H.Seto
