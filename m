From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 08 Feb 2002 06:11:28 +0000
Subject: [Linux-ia64] Re: O(1) MQ scheduler J9 patch for IA64
Message-Id: <marc-linux-ia64-105590698806025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Erich> I had to add a function smp_call_function_nowait which sends
  Erich> an IPI and returns immediately in order to get rid of a
  Erich> IA64-specific race condition when the mmu_context wraps
  Erich> around. Now it makes a very stable and fast impression,
  Erich> interactive work is even possible while doing a "hackbench
  Erich> 55" and ping flooding the machine... Tested on 2 CPU BigSur,
  Erich> 4 CPU LION, 16 CPU AzusA.

Hmmh, I'm a bit worried that this is a fragile solution.  It would
break if there ever was a scenario where a task migrated from one CPU
to another while the target CPU has interrupts disabled.  I do not
think this can happen with Ingo's current scheduler but I'd prefer a
more robust solution.

A somewhat cheesy solution might be to have a per-CPU flag that
indicates whether a CPU should flush its TLB before switching to the
next task.  We could check for this in activate_mm().  Do you want to
try this?

	--david

