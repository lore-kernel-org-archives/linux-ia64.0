From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Sep 2004 22:37:25 +0000
Subject: RE: [PATCH] OS_MCA Recovery from poisoned memory read
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020516D5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This is the latest/Updated OS_MCA handler which try to do recovery
>from multibit-ECC/poisoned memory-read error on user-land.
>(Thank you very much for comments, Keith and Grant!)
>
>I'd still appreciate it if anyone having good test environment
>could apply my patch and could report how it works.
>(especially reports on non-Tiger/non-Intel platform are welcome.)
>
>Tony, isn't it about time you thought about applying my patch to
>your linux-ia64-test-2.6.8.1/test-2.6 tree?

I just pushed this into the linux-ia64-test-2.6.9 tree, so it
will show up in a "-mm" patch from Andrew soon.

-Tony
