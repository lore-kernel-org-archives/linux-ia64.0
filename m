From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Dec 2011 23:10:20 +0000
Subject: RE: Overlapping reserved regions at boot
Message-Id: <0207C53569FE594381A4F2EB66570B2A018EFB7B85@orsmsx508.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201111291501.51657.ptesarik@suse.cz>
 <201112071522.34034.ptesarik@suse.cz>
In-Reply-To: <201112071522.34034.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> OK guys, I take it that nobody is interested in ia64 any longer, but assuming 
> that there will probably be no other fix to the issue, can you at least 
> confirm that the fix is acceptable?

Sorry - way behind on my mail list reading.

It might be better to not make the overlap to begin with - but I can see
that would have a rather larger code impact.  So this looks good.

Queued for 3.3 merge

-Tony

