From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Jan 2009 00:05:22 +0000
Subject: RE: [Patch V3 0/3] Enable irqs when waiting for rwlocks
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35CBE569C@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081104122405.046233722@attica.americas.sgi.com>
 <20090107153520.b91b5956.akpm@linux-foundation.org>
In-Reply-To: <20090107153520.b91b5956.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, "holt@sgi.com" <holt@sgi.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "ptesarik@suse.cz" <ptesarik@suse.cz>, "tee@sgi.com" <tee@sgi.com>, "holt@sgi.com" <holt@sgi.com>, "peterz@infradead.org" <peterz@infradead.org>, "mingo@elte.hu" <mingo@elte.hu>

> > SGI has observed that on large systems, interrupts are not serviced for
> > a long period of time when waiting for a rwlock. The following patch
> > series re-enables irqs while waiting for the lock, resembling the code
> > which is already there for spinlocks.

> I'm not seeing any Tony Luck acks on this work?

I was initially concerned about how to get enough testing
for this to gain confidence that it doesn't unexpectedly
break something.  But Robin pointed out that Novell has
been shipping an equivalent patch in SLES10 without seeing
anything nasty.

Acked-by: Tony Luck <tony.luck@intel.com>
