From: Hedi Berriche <hedi@sgi.com>
Date: Fri, 27 Aug 2010 18:20:39 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <20100827182039.GC18967@zorg.emea.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com> <201008271916.30369.ptesarik@suse.cz>
In-Reply-To: <201008271916.30369.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Aug 27, 2010 at 18:16 Petr Tesarik wrote:
| On Friday 27 of August 2010 18:08:03 Luck, Tony wrote:
| > > Hedi Berriche sent me a simple test case that can
| > > trigger the failure on the siglock.
| >
| > Can you post the test case please. How long does it typically take
| > to reproduce the problem?
| 
| I let Hedi send it. It's really easy to reproduce. In fact, I can reproduce it 
| within 5 minutes on an 8-CPU system.

Test case provided via private email.

Cheers,
Hedi.
-- 
Hedi Berriche
Global Product Support
http://www.sgi.com/support
