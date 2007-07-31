From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jul 2007 16:39:58 +0000
Subject: RE: [PATCH] flush icache before set_pte take6. [3/4] add montecito brand name
Message-Id: <617E1C2C70743745A92448908E030B2A020E3B04@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070731114007.b3c62cd3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Zoltan.Menyhart@bull.net, Christoph Lameter <clameter@sgi.com>

+		} else if (family = 0x20)
+			memcpy(brand, "Montecito", 10);

NAK.

We don't really have names for the different cpu families. "Montecito"
is definitely not the right string to apply here (Montvale will also
have family = 0x20).  The old McKinley/Madison strings are intended
to provide some information for old processors where PAL did not
support PAL_BRAND_INFO.  All new cpus (from Montecito onward) will
support this PAL call, so there should be no need to add more code to
make names out of [family,model] tuples.

-Tony
