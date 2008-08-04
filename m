From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 22:10:40 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308329139@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
	<57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com>
	<57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
 <20080804.150249.71509974.davem@davemloft.net>
In-Reply-To: <20080804.150249.71509974.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: "nacc@us.ibm.com" <nacc@us.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Can you guys on IA64 possibly set ar.k3 simply to zero or to some
> other similar value which cancels out the per-cpu computation?
>
> That's what sparc64 and other platforms do.

In cpu_init() we set ar.k3 to the base physical address of the percpu
area.  The alt-dtlb miss handler uses this register to set up a
TLB mapping from virtual address 0xffffffffffff0000 to this physical
address.

This means that most per-cpu accesses are very cheap (as the compiler
can use a small -ve offset from register r0 to load the virtual
address).

Accessing ar.k3 is a bit slow ... so making the per-cpu code
use that on every access to a per-cpu variable would be unpleasant.

-Tony
