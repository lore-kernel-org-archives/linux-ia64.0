From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Aug 2007 20:53:03 +0000
Subject: RE: [PATCH] flush icache before set_pte() on ia64 take9 [2/2] flush icache at set_pte
Message-Id: <617E1C2C70743745A92448908E030B2A0224C71C@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com> <20070809135721.08841cd7.kamezawa.hiroyu@jp.fujitsu.com> <617E1C2C70743745A92448908E030B2A0224C511@scsmsx411.amr.corp.intel.com> <ed5aea430708101146w3c08b499g99317930c7ecbd79@mail.gmail.com>
In-Reply-To: <ed5aea430708101146w3c08b499g99317930c7ecbd79@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <dmosberger@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net, Zoltan.Menyhart@bull.net, nickpiggin@yahoo.com.au

> What about code-size?

   text    data     bss     dec     hex filename
9499911  911620 1313065 11724596         b2e734 vmlinux-before

   text    data     bss     dec     hex filename
9504047  911620 1313065 11728732         b2f75c vmlinux-after

So about 4K extra.  In the kernel I built (tiger_defconfig) there
are 27 call-sites for __ia64_sync_icache_dcache ... so that amounts
to about 150 bytes each ... or close to 10 bundles.

> Also, is it OK to call a function from all places where a set_pte() is
> being done?  I'd hope so, but it's a really low-level operation...

These are all from normal-looking C code ... so RSE must be valid.
What other weird things might be be doing that would make it a
problem for the new code to make a function call?

-Tony
