From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Aug 2010 23:55:46 +0000
Subject: RE: Serious problem with ticket spinlocks on ia64
Message-Id: <987664A83D2D224EAE907B061CE93D53015D91D645@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
 <201008272303.34228.ptesarik@suse.cz>
 <987664A83D2D224EAE907B061CE93D53015D91D45F@orsmsx505.amr.corp.intel.com>
 <201008280013.19941.ptesarik@suse.cz>
 <987664A83D2D224EAE907B061CE93D53015D91D604@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D53015D91D604@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hedi Berriche <hedi@sgi.com>

> this fails so catastrophically

Interesting ... getting rid of some of the fancy asm bits
(replacing both the ld4.c.nc and the ld2.bias with simple
"serve = *p" and "tmp = *p") makes this run a lot better.

-Tony

