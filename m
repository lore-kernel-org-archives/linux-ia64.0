From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 13 Oct 2000 16:26:41 +0000
Subject: Re: [Linux-ia64] clock stops on test9
Message-Id: <marc-linux-ia64-105590678205568@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205567@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205567@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 13 Oct 2000 11:55:10 +0200, Einar Saltnes <eisa@scali.no> said:

  Einar> However, there are some problems with the system clock. The
  Einar> BIOS clock seems to run OK, but in linux the clock seems to
  Einar> stop after some random time. When using "date", time stands
  Einar> still after some random time! This gives me some trouble
  Einar> using other utilities e.g. ping and even shutdown.  This
  Einar> shows only on the dual B1-stepping box and not the UP
  Einar> A2-stepping box. It can run OK for a few minutes or for some
  Einar> hours.  Anyone got a clue?

Doesn't sound familiar.  It's very unlikely to be a hardware problem
because the kernel's timer tick runs off the CPU cycle counter.  Where
did you get the test9 kernel from and what version of the toolchain
was used to compile it?

  Einar> Which configuration settings should I use regarding the
  Einar> A-stepping / A1-stepping / B-stepping / B1-stepping settings
  Einar> in menuconfig for my two Itanium boxes (see below)?  What
  Einar> about the settings if I change back to Dual A3-stepping /
  Einar> BIOS 50 ?  (So far I have been looking at H.J.Lu's settings
  Einar> which was posted on Sep 08)

For A2, turn on the A-step workarounds and nothing else.
For B1, turn on the B-step workarounds and nothing else.

  Einar> BTW, when talking about BigSurs and Lions how can I tell them
  Einar> apart? It would be nice to know when something on this list
  Einar> applies to my Itanium boxes.

That's real easy: if it's rackmounted, it's a Lion, if it's in a
deskside case, it's a Big Sur.

	--david

