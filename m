From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 14 Jul 2004 02:06:13 +0000
Subject: RE: Next Revison of timer patches with split into nanosecond,
Message-Id: <Pine.LNX.4.58.0407131901490.8669@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 13 Jul 2004, Chen, Kenneth W wrote:

> > +	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
> > +	tnat.nz p6,p0 = r32               // guard against NaT args
> > +(p6)    br.cond.spnt.few .fail_einval
>
> This adds stall cycles because of RAW dependency with p6.  Nat arg isn't
> a common case and shouldn't stall speed path. This br can be collapsed
> with the one that checks r33 nat.

I thought conditional branches do not stall? I can move that further down.
sure.


> > +	ld4 r2 = [r2]
> > +	movl r31 = xtime_lock
> > +	tnat.nz p6,p0 = r33
> > +	movl r30 = time_interpolator
>
> Too many movl, consider using @gprel?

Ok. Will look into that.


> > +	ld4 r20 = [r31]		//  xtime_lock.sequence
> > +	mf
>
> convert to ld4.acq??

Doesnt that run a risk because some of the timer values may be already in
the cache?

> > +	ld8 r24 = [r24]		// time_interpolator_last_counter
> > +(p6)	mov r2 = ar.itc		// CPU_TIMER
> > +(p9)	br.spnt.many fsys_fallback_syscall
> > +(p7)	ld8 r2 = [r29]		// readq
> > +(p8)	ld4 r2 = [r29]		// readw
> > +	and r20 = ~1,r20		// Make sequence even to force retry if odd
>
> Need .pred.rel.mutex p6,p7,p8 to keep assembler quiet.

Thanks.


> > + 	ld8 r21 = [r21]		// xtime.tv_sec
> > +	ld8 r22 = [r22]		// xtime_tv_nsec
>
> Probably not going to help much, but it should be scheduled way above,
> right after seqread to hide some part of memory latency.

I thought the itanium would coalesce these accesses since they are most
likely in the same cache line.

> > +ENTRY(fsys_clock_gettime)
>
> Implementation looked the same as fsys_gettimeofday except the last
> div 1000 part.  Any thing can be done to merge the two functions?

The parameters of both functions are different. The code piece in the
middle is basically gettimeofday (nsec versions). This could become a
subroutine.
