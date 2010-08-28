From: Hedi Berriche <hedi@sgi.com>
Date: Sat, 28 Aug 2010 00:28:55 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <20100828002855.GI18967@zorg.emea.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <201008272303.34228.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D45F@orsmsx505.amr.corp.intel.com> <201008280013.19941.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D604@orsmsx505.amr.corp.intel.com> <987664A83D2D224EAE907B061CE93D53015D91D645@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D53015D91D645@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat, Aug 28, 2010 at 00:55 Tony Luck wrote:
| > this fails so catastrophically
| 
| Interesting ... getting rid of some of the fancy asm bits
| (replacing both the ld4.c.nc and the ld2.bias with simple
| "serve = *p" and "tmp = *p") makes this run a lot better.

*Hasty* look seems to suggest that keeping the fancy asm bits but compiling with
-O2 -frename-registers makes it work equally well.

Don't take my word for it though, double check it, it's been a long week and
brain is anything but alert at this time of the night.

Cheers,
Hedi.
-- 
Hedi Berriche
Global Product Support
http://www.sgi.com/support
