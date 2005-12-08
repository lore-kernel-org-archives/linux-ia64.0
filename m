From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Dec 2005 18:53:14 +0000
Subject: RE: [BUG] Variable stopmachine_state should be volatile
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0526C57B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>, Arjan van de Ven <arjan@infradead.org>, Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, linux-ia64@vger.kernel.org

> The right approach is to define ia64_hint to ia64_barrier in file
> include/asm-ia64/intel_intrin.h. I tested the new approach and it
> does work.

Does that get you a "hint@pause" instruction inside the loop?  If not, then
it isn't all the way to the "right" approach.

-Tony
