From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 03 Sep 2010 14:52:55 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201009031652.56476.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <201009031104.38433.ptesarik@suse.cz> <201009031635.25093.ptesarik@suse.cz>
In-Reply-To: <201009031635.25093.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Friday 03 of September 2010 16:35:23 Petr Tesarik wrote:
> On Friday 03 of September 2010 11:04:37 Petr Tesarik wrote:
> > [...]
> > I'm now trying to modify the lock primitives:
> >
> > 1. replace the fetchadd4.acq with looping over cmpxchg
>
> I did this and I feel dumber than ever.

One more thing - the crash dump I got from that run shows that CPU 2 was just 
going through zap_page_range(), so it probably also did a few global TLB 
flushes. I'm not sure how this should matter, but any idea is good now, I 
think.

Anyway, if a global TLB flush is necessary to trigger the bug, it would also 
explain why we couldn't reproduce it in user-space.

OK, I know I'm just wildly guessing (and don't have any explanation for the 
wrap-around mystery) ... but does anybody have a better idea?

Petr Tesarik
