From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Mar 2004 08:14:51 +0000
Subject: Re: 2.6 unwind problem in kernel/sched.c
Message-Id: <16464.8187.46194.970020@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3398.1078793456@kao2.melbourne.sgi.com>
In-Reply-To: <3398.1078793456@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 09 Mar 2004 11:50:56 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> 2.6.4-rc2, gcc 3.2.3, binutils 2.14.90.0.4.  kernel/sched.c
  Keith> does schedule() -> context_switch() -> switch_to() followed
  Keith> by finish_task_switch().  finish_task_switch() calls
  Keith> finish_arch_switch() which enables interrupts.  If there is
  Keith> an interrupt pending, that interrupt runs at schedule+0x1090
  Keith> (ssm).

  Keith> At this point we are running on the new stack but cr_iip
  Keith> points into schedule() so the unwinder uses schedule's unwind
  Keith> data (b0, ar.pfs in r60, r61).  r60 and r61 are loaded from
  Keith> bsp on the new stack, they are completely wrong and the
  Keith> unwind is useless.

I must be missing something. After switch_to() you're fully switched
to the new task so I don't see why an interrupt during
finish_arch_switch() would mess up the backtrace.  Since CR.IIP points
to schedule() and since the interrupt handler will return to that
instruction after its done, the state at that instruction better be
valid.

	--david
