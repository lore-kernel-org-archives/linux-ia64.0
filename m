From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 14:52:40 +0000
Subject: Re: sched_clock - cont'd
Message-Id: <16576.36024.383196.931650@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40C08A29.A46DF067@nospam.org>
In-Reply-To: <40C08A29.A46DF067@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 04 Jun 2004 16:41:45 +0200, Zoltan Menyhart <Zoltan.Menyhart_=
AT_bull.net@nospam.org> said:

  Zoltan> Oops: timer tick before it's due
  Zoltan> (itc=9859824596,itm=985985c2ef) Oops: timer tick before it's
  Zoltan> due (itc=9859f75936,itm=9859f9ac37) Oops: timer tick before
  Zoltan> it's due (itc=985a6c6c40,itm=985a6d957f) CPU 3: synchronized
  Zoltan> ITC with CPU 0 (last diff -3 cycles, maxerr 494 cycles)

  Zoltan> Once it is over, everything seems to be correct. E.g. I can
  Zoltan> stress the system by compiling the kernel with "make -j100".
  Zoltan> It's a 2.6.5 kernel.  I'm sure the new "sched_clock" code is
  Zoltan> O.K. I guess this modification has brought to light a hidden
  Zoltan> bug in the initial CPU synchronization or timing set up
  Zoltan> code.  Have you ever seen a similar problem ?

No.  sched_clock() has nothing to do with the timer-tick or
time-of-day, so the problem must be something else.

	--david
