From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 04 Dec 2009 19:16:22 +0000
Subject: RE: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <4BDB13256095B24D9644F65379E604265C12@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
	 <20090828062212.GB11552@elte.hu>
 <3877989d0912032329u7c05a761wfdd5c7000b43218d@mail.gmail.com>
In-Reply-To: <3877989d0912032329u7c05a761wfdd5c7000b43218d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>, Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Felix Blyakher <felixb@sgi.com>, "Li, Shaohua" <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>

Luming,

Can you send the config file that you used to test this.

I turned on a bunch of LOCKDEP related things, but I may have
stumbled into areas that aren't working yet because my kernel
didn't boot (or say anything on the console, even with early
serial uart console enabled).

I'd like to take this patch so we can fix it up with incremental
patches ... but I'd like a better idea of what works now and
what doesn't.

Thanks

-Tony
