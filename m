From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Fri, 04 Jun 2004 14:41:45 +0000
Subject: Re: sched_clock - cont'd
Message-Id: <40C08A29.A46DF067@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David,

Since I applied your patch, I re-booted my Tiger-4 about 10 times
and I got twice the following Oops:

CPU 3: base freq=199.453MHz, ITC ratio=13/2, ITC freq=1296.444MHz+/--1ppm
Calibrating delay loop... 1943.56 BogoMIPS
Oops: timer tick before it's due (itc=97c85f8eed,itm=97c87b85d7)
Oops: timer tick before it's due (itc=97c8d4a7c7,itm=97c8dc1d93)
Oops: timer tick before it's due (itc=97c949bc39,itm=97c95006db)

... some 100 of similar lines ...

Oops: timer tick before it's due (itc=9859824596,itm=985985c2ef)
Oops: timer tick before it's due (itc=9859f75936,itm=9859f9ac37)
Oops: timer tick before it's due (itc=985a6c6c40,itm=985a6d957f)
CPU 3: synchronized ITC with CPU 0 (last diff -3 cycles, maxerr 494 cycles)

Once it is over, everything seems to be correct. E.g. I can stress
the system by compiling the kernel with "make -j100".
It's a 2.6.5 kernel.
I'm sure the new "sched_clock" code is O.K. I guess this modification
has brought to light a hidden bug in the initial CPU synchronization
or timing set up code.
Have you ever seen a similar problem ?

The 4 CPUs in the box are the same, like CPU #3:
processor  : 3
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 1
revision   : 5
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 1296.444994
itc MHz    : 1296.444994
BogoMIPS   : 1941.96

Thanks,

Zolt=E1n
