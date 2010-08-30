From: Tony Luck <tony.luck@intel.com>
Date: Mon, 30 Aug 2010 22:43:23 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <AANLkTin4cn84xu3go-Tj-CYSLp0W6uO1HRtA6_CQu8nJ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
	<987664A83D2D224EAE907B061CE93D53015D91D6F5@orsmsx505.amr.corp.intel.com>
	<987664A83D2D224EAE907B061CE93D53015D9B14DC@orsmsx505.amr.corp.intel.com>
	<201008302341.14312.ptesarik@suse.cz>
In-Reply-To: <201008302341.14312.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Hedi Berriche <hedi@sgi.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 30, 2010 at 2:41 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
> IIUC, the subsequent compare can use an undefined value (r20 is not modified
> anywhere in this function, except by the ld4.c.nc, but that happens only on
> an ALAT miss, right?).

I don't see that in my kernel - but you raise a good point. The idea in this
code is that invala makes sure that we don't have a matching ALAT entry
on the first iteration of the loop, so we will do the load. Then we loop not
actually doing the access until the ALAT tells us that the location may
have changed, when we load again.  But this assumes that the compiler
didn't decide to re-use the register for something else in the loop. So
things may be a bit fragile if some aggressive optimization happen after
the routine is inlined.

Does Hedi's test fail for you if you drop the fancy ALAT trick?
I.e. just use "serve = *p;" in __ticket_spin_lock()? [& similar in
__ticket_spin_unlock_wait() if you want - but I don't think that
is ever used for siglock]

-Tony
