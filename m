From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jun 2008 17:59:51 +0000
Subject: RE: [PATCH 3/14] arch/ia64: Eliminate NULL test and memset after
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3062D2488@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0806241021360.26777@ask.diku.dk>
 <57C9024A16AD2D4C97DC78E552063EA3062D2438@orsmsx505.amr.corp.intel.com>
 <Pine.LNX.4.64.0806241948120.26777@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.0806241948120.26777@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia@diku.dk>
Cc: "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>

>> There is no commit b1fceac2b9e04d278316b2faddf276015fc06e3b in Linus' tree.
>
> I am not sure to know how to tell precisely where you are looking, but you
> can find it here:

You are right ... I'm not at all sure where I was looking either.  I cut
& pasted the commit to a "git show ....", and it came up with nothing.  But
now it works!  Some strange user error on my part.  Sorry.

-Tony
