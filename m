From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Aug 2010 20:29:41 +0000
Subject: RE: Serious problem with ticket spinlocks on ia64
Message-Id: <987664A83D2D224EAE907B061CE93D53015D91D3B7@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
 <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hedi Berriche <hedi@sgi.com>

> If this is a memory ordering problem (and that seems quite plausible)
> then a liberal sprinkling of "ia64_mf()" calls throughout the spinlock
> routines would probably make it go away.

I think I take this back ... if it were a memory ordering problem, then
it could show up any time - not just at wrap-around.

-Tony
