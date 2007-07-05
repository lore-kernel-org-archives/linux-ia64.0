From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 05 Jul 2007 08:57:47 +0000
Subject: Re: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <468CB28B.2070300@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <468CA2D6.40204@jp.fujitsu.com>
In-Reply-To: <468CA2D6.40204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab wrote:
> Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> writes:
>> <PATCH>
>>> Index: linux-2.6.21/arch/ia64/kernel/fsys.S
>>> =================================>>> --- linux-2.6.21.orig/arch/ia64/kernel/fsys.S
>>> +++ linux-2.6.21/arch/ia64/kernel/fsys.S
>>> @@ -247,6 +247,9 @@
>>>  .time_redo:
>>>  	.pred.rel.mutex p8,p9,p10
>>>  	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
>>> +	;;
>>> +	and r28 = ~1,r28	// Make sequence even to force retry if odd
>>> +	;;
>>>  (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
>>>  	add r22 = IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
>>>  (p9)	ld8 r2 = [r30]		// readq(ti->address). Could also have latency issues..
>>> @@ -284,7 +287,6 @@
>>>  (p15)	ld8 r17 = [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
>>>  (p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
>>>  	// simulate tbit.nz.or p7,p0 = r28,0
>>> -	and r28 = ~1,r28	// Make sequence even to force retry if odd
>>>  	getf.sig r2 = f8
>>>  	mf
>>>  	add r8 = r8,r18		// Add time interpolator offset
>> </PATCH>
> 
> How can the register lose its contents?  The only thing that can make a
> difference is the stop bit.

I tried

 >>>  	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
 >>> +	;;
 >>>  (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!

but nothing changes (leap continues).


Thanks,
H.Seto
