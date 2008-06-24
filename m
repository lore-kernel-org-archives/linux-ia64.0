From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jun 2008 17:42:22 +0000
Subject: RE: [PATCH 3/14] arch/ia64: Eliminate NULL test and memset after
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3062D2438@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0806241021360.26777@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.0806241021360.26777@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia@diku.dk>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>

> As noted by Akinobu Mita in patch b1fceac2b9e04d278316b2faddf276015fc06e3b,
> alloc_bootmem and related functions never return NULL and always return a
> zeroed region of memory.  Thus a NULL test or memset after calls to these
> functions is unnecessary.

There is no commit b1fceac2b9e04d278316b2faddf276015fc06e3b in Linus' tree.

In addition the current alloc_bootmem() is a macro that uses __alloc_bootmem
which most defintely can return NULL.

Is this against -mm or linux-next?

-Tony
