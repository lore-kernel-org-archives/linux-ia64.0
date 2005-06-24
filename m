From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 24 Jun 2005 21:20:17 +0000
Subject: RE: [patch] Memory Error Handling Improvement
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03C689B4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>Fine, but what about stores?

Stores have too many extra levels of buffering to have much hope.  But just
because we can't help the store case doesn't mean that we shouldn't do
something about the load case.

>Furthermore, there are many ways to enter the kernel, so it still
>makes no sense to me to consider external interrupts only.  System
>calls for one are certainly quite common, too.

Agreed.  It would be much better if we had some clean & easy way to tag
all of the kernel entry sequences for a check like this.  The cost of
checking to see whether we are in any of these code regions could be
quite high ... but we only pay it if there is an error, so as long as
it isn't outrageous it should be okay.

-Tony
