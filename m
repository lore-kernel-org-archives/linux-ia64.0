From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Wed, 26 May 2004 11:59:11 +0000
Subject: sched_clock
Message-Id: <40B4868F.B649611C@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Time can go backward.
At least for the IA64 implementation where "sched_clock()" overflows.
Example:

sched_clock[MFI]	    mov.m r3=3Dar.itc

// r3: 0x0000002d19db39e7

sched_clock+0xc		    addl r10=3D-2096336,r1;;
sched_clock+0x10[MFI]       setf.sig f9=3Dr3
sched_clock+0x20[MMI]       ld8 r9=3D[r10];;
sched_clock+0x26            adds r8$,r9;;
sched_clock+0x30[MMI]       ld8 r2=3D[r8];;

// r2: 0x0000000050383e5f   -- itc MHz: 797.809000

sched_clock+0x36            setf.sig f6=3Dr2;;
sched_clock+0x46            xmpy.l f8=F9,f6;;
sched_clock+0x50[MMI]       getf.sig r2=F8;;

// r2: 0x21fd270c8ae86eb9   -- has overflown

sched_clock+0x5c            extr.u r8=3Dr2,30,34

// r8: 0x0000000087f49c32   -- *Previously* I got 3fe001a68

Funny results can be obtained in "schedule()". E.g.:

	unsigned long run_time;
	now =3D sched_clock();
        run_time =3D now - prev->timestamp;

I do think it is a good programming solution to abuse the fact that
the variables are unsigned, and should "sched_clock()" overflow, we would
be saved by the "else" branch.

        if (likely(now - prev->timestamp < NS_MAX_SLEEP_AVG))
                run_time =3D now - prev->timestamp;
        else
                run_time =3D NS_MAX_SLEEP_AVG;

BTW is completely unfair if a task (even if it has run for just a fraction
of microsec.) is given "NS_MAX_SLEEP_AVG" just because "sched_clock()" has
overflown.

I do not think this comment below could be right (neither what it states nor
how it is used) because the ITC is a running counter, it is not restated
every time when a task is scheduled or time-stamp-ed.

/*
 * This shift should be large enough to be able to represent 1000000000/itc=
_freq with good
 * accuracy while being small enough to fit 10*1000000000<<IA64_NSEC_PER_CY=
C_SHIFT in 64 bits
 * (this will give enough slack to represent 10 seconds worth of time as a =
scaled number).
 */

I do not really see why we multiply the value read out from the ITC by
"local_cpu_data->nsec_per_cyc" in "sched_clock()".

Why do not we simply count nanoseconds as the scheduler wants us ?
We should convert carefully the ITC ticks into nanoseconds, doing something=
 like:

unsigned long long sched_clock (void)
{
	return ia64_get_itc() * local_cpu_data->mult / local_cpu_data->div;
}

By "carefully" I mean avoiding overflows.

Time stamps should form an ever increasing "chain of time".

Thanks.


Zolt=E1n Menyh=E1rt
