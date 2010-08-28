From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 28 Aug 2010 05:01:18 +0000
Subject: RE: Serious problem with ticket spinlocks on ia64
Message-Id: <987664A83D2D224EAE907B061CE93D53015D91D6F5@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
 <201008272303.34228.ptesarik@suse.cz>
 <987664A83D2D224EAE907B061CE93D53015D91D45F@orsmsx505.amr.corp.intel.com>
 <201008280013.19941.ptesarik@suse.cz>
 <987664A83D2D224EAE907B061CE93D53015D91D604@orsmsx505.amr.corp.intel.com>
 <987664A83D2D224EAE907B061CE93D53015D91D645@orsmsx505.amr.corp.intel.com>
 <20100828002855.GI18967@zorg.emea.sgi.com>
In-Reply-To: <20100828002855.GI18967@zorg.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hedi Berriche <hedi@sgi.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>*Hasty* look seems to suggest that keeping the fancy asm bits but compiling >with
>-O2 -frename-registers makes it work equally well.
>
>Don't take my word for it though, double check it, it's been a long week and
>brain is anything but alert at this time of the night.

Yup - that makes the usermode version run just fine (no problems
in the first billion lock/unlock operations ... which is
quite a lot of wrap-arounds of the 15-bit ticket lock).

And since we already use -frename-registers when building the
kernel, no immediate help for the kernel problem. :-(

I may tinker with this test a bit to include some short random
amounts of hold-time for the lock, and delays between attempts
to acquire it (to make it look more like a contended kernel lock
and less like a continuous queue of processes trading around a
lock that is never free ... Petr's debug information definitely
showed the lock becoming free at the wraparound (lock = 0x0).

-Tony
