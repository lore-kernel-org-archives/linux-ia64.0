From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 21:03:32 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008272303.34228.ptesarik@suse.cz>
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

One more idea. The wrap-around case is the only one when the high word is 
modified. This is in fact the only case when the fetchadd.acq competes with 
the st2.rel about the actual contents of that location. I don't know if it 
matters...

Petr Tesarik
