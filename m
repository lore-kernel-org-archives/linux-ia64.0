From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Aug 2010 21:11:55 +0000
Subject: RE: Serious problem with ticket spinlocks on ia64
Message-Id: <987664A83D2D224EAE907B061CE93D53015D91D45F@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
 <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com>
 <987664A83D2D224EAE907B061CE93D53015D91D3B7@orsmsx505.amr.corp.intel.com>
 <201008272303.34228.ptesarik@suse.cz>
In-Reply-To: <201008272303.34228.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hedi Berriche <hedi@sgi.com>

> One more idea. The wrap-around case is the only one when the high word is 
> modified. This is in fact the only case when the fetchadd.acq competes with 
> the st2.rel about the actual contents of that location. I don't know if it 
> matters...

I pondered that for a while - but I have difficulty believing that
fetchadd looks at which bits changed and only writes back the bytes
that did.

-Tony
