From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Jun 2002 16:13:45 +0000
Subject: Re: [Linux-ia64] [RFC] Multithreaded core dump for 2.5.10-ia64 kernel.
Message-Id: <marc-linux-ia64-105590701905647@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905644@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905644@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 5 Jun 2002 14:33:12 -0700, "Gross, Mark" <mark.gross@intel.com> said:

  Mark> I'm new to the stack unwinding thing WRT ia64 and would love
  Mark> to get some feed back on my tweaks to process.c that collect
  Mark> the register state data for the thread processes in the
  Mark> crashing thread group.

It looks fine to me.  One suggestion, however: it might be a good idea
to add a BUG_ON(task != current) statement to the dump_task_regs() and
dump_task_fpu() routines.  This will stop folks from accidentally
trying to use unw_init_from_blocked_task() for the currently running
task.

	--david

