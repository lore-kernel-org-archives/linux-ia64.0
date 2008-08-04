From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 22:41:51 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3083291B2@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
	<20080804.150249.71509974.davem@davemloft.net>
	<57C9024A16AD2D4C97DC78E552063EA308329139@orsmsx505.amr.corp.intel.com>
 <20080804.151448.190011603.davem@davemloft.net>
 <57C9024A16AD2D4C97DC78E552063EA308329161@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA308329161@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, David Miller <davem@davemloft.net>
Cc: "nacc@us.ibm.com" <nacc@us.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> I'm looking at that ... but it is a bit more complex.  We only have
> a "__per_cpu" block in the kernel on uni-processor systems. For
> larger systems we dynamically allocate, and we have two different
> mechanisms to that (one for SMP and one for NUMA).

Humm.  Perhaps I can always build in __per_cpu and use it for
cpu 0.  And then fix the assembly in head.S to point at that
for cpu 0.  For other cpus I's also need to pass the allocation
address of their per-cpu block to the early asm code so they
could set up ar.k3 too.

-Tony
