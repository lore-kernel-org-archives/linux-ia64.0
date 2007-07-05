From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 05 Jul 2007 07:50:46 +0000
Subject: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <468CA2D6.40204@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi all,

I have run a test of gettimeofday() with "nojitter" option
to make sure whether time fluctuating is really there or not.

> $ dmesg | grep ITC
> Jitter checking for ITC timers disabled
> CPU 0: base freq 0.000MHz, ITC ratio=15/2, ITC freq=1500.000MHz
> CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 568 cycles)
> CPU 1: base freq 0.000MHz, ITC ratio=15/2, ITC freq=1500.000MHz
> CPU 2: synchronized ITC with CPU 0 (last diff 5 cycles, maxerr 2087 cycle=
s)
> CPU 2: base freq 0.000MHz, ITC ratio=15/2, ITC freq=1500.000MHz
> CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 2098 cycle=
s)
> CPU 3: base freq 0.000MHz, ITC ratio=15/2, ITC freq=1500.000MHz

CPUs on this server are poorly synchronized.
It seems that someone located between FSBs is lazy.

There were no problem until number of running threads are less than 3.

> $ ./a.out
> Oops, time goes backword!
>  old: 1181506369.260876
>  new: 1181224894.285294
> diff:     281474.975582
>    3: 1181224894.284165
>    2: 1181224894.284165
>    1: 1181506369.260876
>    0: 1181224894.285294

Wow.
My test said "backward" since it got smaller value than previous one.
But in fact it didn't go to past but just returned from future.
280000sec is about 3days...

To investigate this phenomenon, I made up a debug patch:

<PATCH>
> Index: linux-2.6.21/arch/ia64/kernel/fsys.S
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.21.orig/arch/ia64/kernel/fsys.S
> +++ linux-2.6.21/arch/ia64/kernel/fsys.S
> @@ -244,6 +244,12 @@
>         cmp.ne p13,p0 =3D r2,r0   // need jitter compensation?
>         extr r21 =3D r21,16,8     // shift factor
>         ;;
> +       // DEBUG
> +       //  if nojitter then r3, r30, r23, and r25 are free
> +       //   p8 =3D 1
> +       //   p9 =3D 0 & p10 =3D 0 : r30
> +       //   p13 =3D 0          : r23, r25, r3
> +       // DEBUG
>  .time_redo:
>         .pred.rel.mutex p8,p9,p10
>         ld4.acq r28 =3D [r29]     // xtime_lock.sequence. Must come first=
 for lock
> ing purposes
> @@ -253,6 +259,10 @@
>  (p10)  ld4 r2 =3D [r30]          // readw(ti->address)
>  (p13)  add r23 =3D IA64_TIME_INTERPOLATOR_LAST_CYCLE_OFFSET,r20
>         ;;                      // could be removed by moving the last ad=
d upward
> +       // DEBUG
> +       //  get itc again
> +       mov r3 =3D ar.itc
> +       // DEBUG
>         ld8 r26 =3D [r22]         // time_interpolator->last_counter
>  (p13)  ld8 r25 =3D [r23]         // time interpolator->last_cycle
>         add r24 =3D IA64_TIME_INTERPOLATOR_OFFSET_OFFSET,r20
> @@ -273,6 +283,10 @@
>         ;;
>         and r10 =3D r10,r14       // Apply mask
>         ;;
> +       // DEBUG
> +       //  now r14 is free. get itc again
> +       mov r14 =3D ar.itc
> +       // DEBUG
>         setf.sig f8 =3D r10
>         nop.i 123
>         ;;
> @@ -283,20 +297,37 @@
>         ;;
>  (p15)  ld8 r17 =3D [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
>  (p7)   cmp.ne p7,p0 =3D r25,r3   // if cmpxchg not successful redo
> +// DEBUG
> +// to keep r2 (=3Dcurrent_clock), use r25 instead
>         // simulate tbit.nz.or p7,p0 =3D r28,0
>         and r28 =3D ~1,r28        // Make sequence even to force retry if=
 odd
> -       getf.sig r2 =3D f8
> +//     getf.sig r2 =3D f8
> +       getf.sig r25 =3D f8
>         mf
>         add r8 =3D r8,r18         // Add time interpolator offset
>         ;;
>         ld4 r10 =3D [r29]         // xtime_lock.sequence
>  (p15)  add r8 =3D r8, r17        // Add monotonic.nsecs to nsecs
> -       shr.u r2 =3D r2,r21
> +//     shr.u r2 =3D r2,r21
> +       shr.u r25 =3D r25,r21
>         ;;              // overloaded 3 bundles!
>         // End critical section.
> -       add r8 =3D r8,r2          // Add xtime.nsecs
> +//     add r8 =3D r8,r2          // Add xtime.nsecs
> +       add r8 =3D r8,r25         // Add xtime.nsecs
>         cmp4.ne.or p7,p0 =3D r28,r10
>  (p7)   br.cond.dpnt.few .time_redo     // sequence number changed ?
> +// DEBUG
> +       // DEBUG
> +       //  bug if r8 is too large
> +       movl r30 =3D 1000000000000        // 100sec
> +       ;;
> +       cmp.ge p6,p0 =3D r8,r30
> +       ;;
> +(p6)   mov r30 =3D ar.itc        // get itc again if NG
> +       ;;
> +(p6)   ld8 r3 =3D [r0]           // BUG!
> +       ;;
> +       // DEBUG
>         // Now r8=3Dtv->tv_nsec and r9=3Dtv->tv_sec
>         mov r10 =3D r0
>         movl r2 =3D 1000000000
</PATCH>

and got a stack trace from applied kernel:

<TRACE>
> a.out[5126]: NaT consumption 17179869216 [1]
> Modules linked in: sunrpc binfmt_misc dm_mirror dm_mod thermal processor =
fan con
> tainer button sr_mod sg e100 mii usb_storage ehci_hcd ohci_hcd
>=20
> Pid: 5126, CPU 3, comm:                a.out
> psr : 00001010085a6010 ifs : 8000000000000008 ip  : [<a00000010000f830>] =
   Not
> tainted
> ip is at fsys_gettimeofday+0x1f0/0x320
> unat: 0000000000000000 pfs : c000000000000008 rsc : 000000000000000f
> rnat: 0000000000000000 bsps: 600007ffffe24048 pr  : 0000000000564141
> ldrs: 0000000000800000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : 4000000000000ed0 b6  : 2000000000167520 b7  : a00000010000f640
> f6  : 000000000000000000000 f7  : 1003e000000000000aaaa
> f8  : 1003efffffffffa4e05b2 f9  : 000000000000000000000
> f10 : 000000000000000000000 f11 : 000000000000000000000
> r1  : 2000000000260238 r2  : 0000001672312e22 r3  : 0000001672312e28
> r8  : 000100000bebbe9a r9  : 00000000468cd7b3 r10 : 0000000000007d5a
> r11 : c00000000000038f r12 : 60000fffffe1f6e0 r13 : 200000000004f270
> r14 : 0000001672314111 r15 : 000000000000043f r16 : e00000011b1f8000
> r17 : 000000000000003f r18 : 000000000000024c r19 : 0000000000000118
> r20 : a0000001009413f8 r21 : 0000000000000010 r22 : a000000100941418
> r23 : 60000fffffe1f708 r24 : a000000100941410 r25 : 0000fffffffffa4e
> r26 : 00000016723136ad r27 : a000000100ae5210 r28 : 0000000000007d5a
> r29 : a0000001008f9680 r30 : 000000167231430d r31 : 60000fffffe1f710
>=20
> Call Trace:
>  [<a0000001000139a0>] show_stack+0x40/0xa0
>                                 sp=E00000011b1ffa20 bsp=E00000011b1f8d38
>  [<a000000100014600>] show_regs+0x840/0x880
>                                 sp=E00000011b1ffbf0 bsp=E00000011b1f8ce0
>  [<a000000100036940>] die+0x1c0/0x2c0
>                                 sp=E00000011b1ffbf0 bsp=E00000011b1f8c98
>  [<a000000100036a90>] die_if_kernel+0x50/0x80
>                                 sp=E00000011b1ffc10 bsp=E00000011b1f8c68
>  [<a000000100037ca0>] ia64_fault+0x11e0/0x1300
>                                 sp=E00000011b1ffc10 bsp=E00000011b1f8c10
>  [<a00000010000bdc0>] ia64_leave_kernel+0x0/0x280
>                                 sp=E00000011b1ffe30 bsp=E00000011b1f8c10
>  [<a00000010000f830>] fsys_gettimeofday+0x1f0/0x320
>                                 sp=E00000011b200000 bsp=E00000011b1f8bc8
</TRACE>

Let's think.

r2  : 0000001672312e22  is current_clock, fetched from ar.itc at first.
r26 : 00000016723136ad  is last_counter, stored by CPU0 at last tick.

It is clear that leaping time is caused by getting larger last_counter
than current_clock.

r8  : 000100000bebbe9a  is calculated offset.

Negative offset was treated as unsigned.

r3  : 0000001672312e28  is clock value just after fetching counters
r14 : 0000001672314111  is clock before xmpy.l
r30 : 000000167231430d  is clock at exit on bug

Clocks between r3 to r14 are about 4800. Who was there? Interrupt?
The value of last_counter is a clock between r3 to r14.
So it can be assumed that there were timer interrupts.
A timer interrupt on CPU0 updates last_counter while it takes xtime_lock.

r28 : 0000000000007d5a  is xtime_lock.sequence at entrance (dropped bit0)
r10 : 0000000000007d5a  is xtime_lock.sequence at exit

However this couple of xtime_lock.sequence value claims there were no
writer took xtime_lock during this operation.

...What is wrong?

I suspected the value of r28.
So I just relocate "consuming" of r28 to early stage.

<PATCH>
> Index: linux-2.6.21/arch/ia64/kernel/fsys.S
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.21.orig/arch/ia64/kernel/fsys.S
> +++ linux-2.6.21/arch/ia64/kernel/fsys.S
> @@ -247,6 +247,9 @@
>  .time_redo:
>  	.pred.rel.mutex p8,p9,p10
>  	ld4.acq r28 =3D [r29]	// xtime_lock.sequence. Must come first for locki=
ng purposes
> +	;;
> +	and r28 =3D ~1,r28	// Make sequence even to force retry if odd
> +	;;
>  (p8)	mov r2 =3D ar.itc		// CPU_TIMER. 36 clocks latency!!!
>  	add r22 =3D IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
>  (p9)	ld8 r2 =3D [r30]		// readq(ti->address). Could also have latency is=
sues..
> @@ -284,7 +287,6 @@
>  (p15)	ld8 r17 =3D [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
>  (p7)	cmp.ne p7,p0 =3D r25,r3	// if cmpxchg not successful redo
>  	// simulate tbit.nz.or p7,p0 =3D r28,0
> -	and r28 =3D ~1,r28	// Make sequence even to force retry if odd
>  	getf.sig r2 =3D f8
>  	mf
>  	add r8 =3D r8,r18		// Add time interpolator offset
</PATCH>

What a surprise! This patch solves the problem!

Therefore now my concern is what does "acq" of ld4.acq provides.
According to ASDM, it says "Acquire data accesses guarantee that
they are made visible prior to all subsequent data accesses."

I'm not sure but since the problem is solved by above patch,
it seems that value loaded to r28 on CPU3 was not xtime_lock.sequence
before timer interrupt on CPU0 but one after the interrupt.

Is this software/coding bug?
Or is this a hardware/firmware's bug which don't follow requirement of
"Acquire data access"?

If this is coding bug, there would be another solution that adding
comparison of last_counter and current_clock. But clearly relocation
is cheaper way.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----
 arch/ia64/kernel/fsys.S |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6.21/arch/ia64/kernel/fsys.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.21.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.21/arch/ia64/kernel/fsys.S
@@ -247,6 +247,9 @@
 .time_redo:
 	.pred.rel.mutex p8,p9,p10
 	ld4.acq r28 =3D [r29]	// xtime_lock.sequence. Must come first for locking=
 purposes
+	;;
+	and r28 =3D ~1,r28	// Make sequence even to force retry if odd
+	;;
 (p8)	mov r2 =3D ar.itc		// CPU_TIMER. 36 clocks latency!!!
 	add r22 =3D IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
 (p9)	ld8 r2 =3D [r30]		// readq(ti->address). Could also have latency issu=
es..
@@ -284,7 +287,6 @@
 (p15)	ld8 r17 =3D [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
 (p7)	cmp.ne p7,p0 =3D r25,r3	// if cmpxchg not successful redo
 	// simulate tbit.nz.or p7,p0 =3D r28,0
-	and r28 =3D ~1,r28	// Make sequence even to force retry if odd
 	getf.sig r2 =3D f8
 	mf
 	add r8 =3D r8,r18		// Add time interpolator offset




