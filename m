From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 31 Aug 2010 22:17:28 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <AANLkTinHOpcdAJd0_4G=OFAnMZaXKeOsqnbjJMAxCume@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
	<987664A83D2D224EAE907B061CE93D53015D91D6F5@orsmsx505.amr.corp.intel.com>
	<987664A83D2D224EAE907B061CE93D53015D9B14DC@orsmsx505.amr.corp.intel.com>
	<201008302341.14312.ptesarik@suse.cz>
	<AANLkTin4cn84xu3go-Tj-CYSLp0W6uO1HRtA6_CQu8nJ@mail.gmail.com>
In-Reply-To: <AANLkTin4cn84xu3go-Tj-CYSLp0W6uO1HRtA6_CQu8nJ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Hedi Berriche <hedi@sgi.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 30, 2010 at 3:43 PM, Tony Luck <tony.luck@intel.com> wrote:
> Does Hedi's test fail for you if you drop the fancy ALAT trick?
> I.e. just use "serve = *p;" in __ticket_spin_lock()?

Answering my own question ... it failed in 47 minutes with the breakit
script on iteration 2812 :-(

So it would appear that the problem isn't related to the ALAT, or weird
compiler optimizations around the inline asm.

-Tony
