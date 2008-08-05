From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Aug 2008 14:59:48 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308329447@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
 <1217926585.3589.113.camel@twins>
In-Reply-To: <1217926585.3589.113.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Nishanth Aravamudan <nacc@us.ibm.com>
Cc: "mingo@elte.hu" <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bill Gatliff <bgat@billgatliff.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>

+u64 sched_clock_cpu(int cpu)
+{
+       if (unlikely(!sched_clock_running))
+               return 0;
+
+       return sched_clock();
+}

This looks like it will solve the issue on the boot cpu.  It
leaves a potential hole as we bring up other cpus if[1] there
are any printk() calls before they get to cpu_init() to
initialize ar.kr3.  This code path is all under arch/ia64
though ... so if we shoot ourselves in the foot, it will be
our own fault.

-Tony

[1] Currently there is just one Dprintk() call in this path
at the start of start_secondary() ... I could put it inside
#ifndef CONFIG_PRINTK_TIME so as not to surprise anyone that
enabled it.
