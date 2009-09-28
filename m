From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 28 Sep 2009 22:54:09 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909281549550.6996@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 28 Sep 2009, Luck, Tony wrote:
> 
> 	ticket = ia64_fetchadd(1, p, acq);
> 
> 	if (!(((ticket >> TICKET_SHIFT) ^ ticket) & ((1L << TICKET_BITS) - 1)))
> 		return;

I think the above is wrong.

Doesn't 'fetchadd' return the _old_ value? 

If so, the "fastcase" above will not trigger in the normal case, so you'll 
always fall down to the slowcase:

> 	do {
> 		cpu_relax();
> 		serve = ACCESS_ONCE(*p);
> 	} while (((serve >> TICKET_SHIFT) ^ ticket) & ((1 << TICKET_BITS) - 1));

Or did I miss something?

		Linus
