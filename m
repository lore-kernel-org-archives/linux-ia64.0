From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 14 Jul 2004 00:46:57 +0000
Subject: RE: Next Revison of timer patches with split into nanosecond, time_interpolator and debug patch
Message-Id: <200407140044.i6E0i8Y04656@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Tuesday, July 13, 2004 11:47 AM
>
> This version has
>  1. Patch split into three pieces:
>     A) the nanosecond patch. Probably controversial. Provides gettimeofday
>        using nsec resolution and patches posix-timers so that they
>        actually return nanosecond resolution.
>     B) The time interpolator patches to implement generic routines to
>        use any available counter for a time interpolator and provide IA64
>        fastcall support.
>     C) Patch to add debugging features. This now includes counters for
>        the various behaviors of the asm routines. Fallback, retries
>        and error conditions.
>
>  2. Style changes and conformance to calling conventions
>  3. Further minor fixes.
>
...

> +	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
> +	tnat.nz p6,p0 = r32               // guard against NaT args
> +(p6)    br.cond.spnt.few .fail_einval

This adds stall cycles because of RAW dependency with p6.  Nat arg isn't
a common case and shouldn't stall speed path. This br can be collapsed
with the one that checks r33 nat.


> +	ld4 r2 = [r2]
> +	movl r31 = xtime_lock
> +	tnat.nz p6,p0 = r33
> +	movl r30 = time_interpolator

Too many movl, consider using @gprel?


> +	ld4 r20 = [r31]		//  xtime_lock.sequence
> +	mf

convert to ld4.acq??


> +	ld8 r24 = [r24]		// time_interpolator_last_counter
> +(p6)	mov r2 = ar.itc		// CPU_TIMER
> +(p9)	br.spnt.many fsys_fallback_syscall
> +(p7)	ld8 r2 = [r29]		// readq
> +(p8)	ld4 r2 = [r29]		// readw
> +	and r20 = ~1,r20		// Make sequence even to force retry if odd

Need .pred.rel.mutex p6,p7,p8 to keep assembler quiet.


> + 	ld8 r21 = [r21]		// xtime.tv_sec
> +	ld8 r22 = [r22]		// xtime_tv_nsec

Probably not going to help much, but it should be scheduled way above,
right after seqread to hide some part of memory latency.


> +ENTRY(fsys_clock_gettime)

Implementation looked the same as fsys_gettimeofday except the last
div 1000 part.  Any thing can be done to merge the two functions?


