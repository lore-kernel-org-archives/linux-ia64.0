From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Apr 2003 21:41:52 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705439@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Apr 2003 16:35:56 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Hi, On systems with a drifting ITC, such as the SGI SN2, the
  Jes> current implementation of timer_interrupt() and gettimeoffset()
  Jes> wont work as they rely heavily on ar.itc.

  Jes> On SN2 this has been solved by using the synchronized RTC in
  Jes> the system, which results a different implementation of the two
  Jes> above mentioned functions.

  Jes> To get around this I suggest we change gettimeoffset() and
  Jes> timer_intererupt() to be machvec's.

I suspect we're better off in the long term making gettimeoffset() a
function pointer.  I can certainly imagine platforms where multiple
interpolation sources are available and depending on parameters (e.g.,
long-term stability or overhead), one might want to choose one or
another.

The motivation for changing timer_interrupt() seems suspect to me.
The timer interupt is generated PER CPU, so there is no drift issue at
all (in fact, we intentionally _skew_ things at boot time to reduce
the likelihood of getting all timer interrupts at the same time).

	--david

