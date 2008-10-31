From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 31 Oct 2008 20:22:56 +0000
Subject: RE: [PATCH V2 0/2] enable irqs when waiting for rwlocks
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35A7ED9D3@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224777451.11530.52.camel@elijah.suse.cz>
 <1225443142.6825.4.camel@elijah.suse.cz>
In-Reply-To: <1225443142.6825.4.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Any comments on my second patch series? Not even an Acked-by? Dislike of
> the concept? Should I post it again?

Better response to interrupts is good, but it comes at the
cost of longer latency acquiring the lock (in the case where
an interrupt happens while we are waiting for the lock, and
the lock is freed while we are off executing the interrupt
handler).

Any suggestions on how to measure the trade-off here?  Possibly
it doesn't matter because this may only be significant when
the lock is heavily contended and you are probably aleady
hosed in this case.

-Tony
