From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jul 2007 16:44:35 +0000
Subject: RE: [PATCH] flush icache before set_pte take6. [4/4] optimization for cpus other than montecito
Message-Id: <617E1C2C70743745A92448908E030B2A020E3B1C@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <ed5aea430707302115h484620f1le51fc054436b273a@mail.gmail.com>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <dmosberger@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Zoltan.Menyhart@bull.net, Christoph Lameter <clameter@sgi.com>

> This seems crazy to me.  Flushing should occur according to the
> *architecture*, not model-by-model.  Even if we happen to get "lucky"
> on pre-Montecito CPUs, that doesn't justify such ugly hacks.  Or you
> really want to debug this *again* come next CPU?

Ditto.  The only reason we should ever have model specific checks should
be to work around model specific errata (e.g. the McKinley Errata #9 code
in patch.c).

-Tony
