From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 20:41:14 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008272241.15735.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com> <987664A83D2D224EAE907B061CE93D53015D91D3B7@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D53015D91D3B7@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hedi Berriche <hedi@sgi.com>

On Friday 27 of August 2010 22:29:41 Luck, Tony wrote:
> > If this is a memory ordering problem (and that seems quite plausible)
> > then a liberal sprinkling of "ia64_mf()" calls throughout the spinlock
> > routines would probably make it go away.
>
> I think I take this back ... if it were a memory ordering problem, then
> it could show up any time - not just at wrap-around.

Well, I wasn't originally sure if it only happens at wrap-around. OTOH I've 
now modified my tests, so that they would also catch any other badness, and I 
still only got another two failures after wrap-around.

From looking at the traces, I'm afraid this smells like another Itanium 
erratum. I'm now trying to write a minimal test case...

Petr Tesarik
