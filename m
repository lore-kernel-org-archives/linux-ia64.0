From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 22:13:18 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008280013.19941.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <201008272303.34228.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D45F@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D53015D91D45F@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hedi Berriche <hedi@sgi.com>

On Friday 27 of August 2010 23:11:55 Luck, Tony wrote:
> > One more idea. The wrap-around case is the only one when the high word is
> > modified. This is in fact the only case when the fetchadd.acq competes
> > with the st2.rel about the actual contents of that location. I don't know
> > if it matters...
>
> I pondered that for a while - but I have difficulty believing that
> fetchadd looks at which bits changed and only writes back the bytes
> that did.

OTOH the counter is only 15-bit, so it also wraps around at 0xfffe7fff, but
I have never seen it fail there. It always fails after the wrap-around from 
0xfffeffff.

Petr Tesarik
