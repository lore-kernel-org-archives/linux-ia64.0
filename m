From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 16:51:32 +0000
Subject: Re: sched_clock - cont'd
Message-Id: <16576.43156.627974.180637@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40C08A29.A46DF067@nospam.org>
In-Reply-To: <40C08A29.A46DF067@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 04 Jun 2004 16:41:45 +0200, Zoltan Menyhart <Zoltan.Menyhart_=
AT_bull.net@nospam.org> said:

  Zoltan> David, Since I applied your patch, I re-booted my Tiger-4
  Zoltan> about 10 times and I got twice the following Oops:

  Zoltan> CPU 3: base freq=199.453MHz, ITC ratio=13/2, ITC
  Zoltan> freq=1296.444MHz+/--1ppm Calibrating delay loop... 1943.56
  Zoltan> BogoMIPS Oops: timer tick before it's due
  Zoltan> (itc=97c85f8eed,itm=97c87b85d7) Oops: timer tick before it's
  Zoltan> due (itc=97c8d4a7c7,itm=97c8dc1d93) Oops: timer tick before
  Zoltan> it's due (itc=97c949bc39,itm=97c95006db)

  Zoltan> Once it is over, everything seems to be correct. E.g. I can
  Zoltan> stress the system by compiling the kernel with "make -j100".
  Zoltan> It's a 2.6.5 kernel.

I forgot to mention: make sure you have Bjorn's patch in your
tree:

Stable cset id: davidm@tiger.hpl.hp.com|ChangeSet|20040513223146|25847

ChangeSet@1.1608.9.11, 2004-05-13 15:31:46-07:00, davidm@tiger.hpl.hp.com
  ia64: fix spurious "timer tick before it's due" problem

  Patch Bjorn Helgaas: Fix the "timer tick before it's due" complaint
  from timer_interrupt().  The problem was that smp_callin() turned
  on the periodic timer tick before syncing the ITC with the BP.

This went in _after_ 2.6.6 so it's likely that this will fix your
problem (I never saw the issue on a 4-way, though).

	--david
