From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 01 Aug 2007 09:27:37 +0000
Subject: Re: [PATCH] flush icache before set_pte take6. [4/4] optimization
Message-Id: <46B05209.4050103@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com><20070731114155.5785123c.kamezawa.hiroyu@jp.fujitsu.com><ed5aea430707302115h484620f1le51fc054436b273a@mail.gmail.com> <20070731132932.8e21d48c.kamezawa.hiroyu@jp.fujitsu.com> <019b01c7d395$27d692b0$3e3af40f@americas.hpqcorp.net>
In-Reply-To: <019b01c7d395$27d692b0$3e3af40f@americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jim Hull <jim.hull@hp.com>
Cc: 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'David Mosberger-Tang' <dmosberger@gmail.com>, 'LKML' <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, tony.luck@intel.com, 'Christoph Lameter' <clameter@sgi.com>

Jim Hull wrote:
> Not just crazy, but wrong - this *can* happen on pre-Montecito.  Even though
> L1D is write-through and L2 was mixed I/D, the L1 I-cache could contain
> stale instrutions if there are missing flushes.

I cannot agree with you.

In order to consider an L1 I-cache entry as valid, a corresponding
virtual -> physic address translation should be valid in one of the L1 ITLBs.

"See 6.1.1. Instruction TLBS" of the I2 Proc. Ref. Man. for SW Dev. & Opt.

You cannot have a valid L1 ITLB entry unless you have a corresponding valid
L2 ITLB entry.

When you remove a PTE (or switch off the exec bit) and you flush the L2 ITLB
matching the old translation (and you kill the corresponding L1 ITLBs),
you do invalidate the corresponding L1 I-cache entries.

Therefore CPU models without split L2 caches are safe.

Thanks,

Zoltan
