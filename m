From: Robin Holt <holt@sgi.com>
Date: Wed, 07 Jul 2004 19:30:26 +0000
Subject: Why was the PTE quicklist removed?
Message-Id: <20040707193025.GA12577@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I looked at include/asm-ia64/pgalloc.h and noticed that someone removed
the use of the pte_quicklist in pte_free.  When I look at the bitkeeper
change log for this, it appears to have been removed by ChangeSet
1.369.41.1.

How can I find the original author of this change?  I don't see any
reasons given on the ia64 list for removing the quicklist code.
Should I be looking somewhere else?

Thanks,
Robin Holt
