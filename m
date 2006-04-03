From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 03 Apr 2006 17:50:22 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061E0E9B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I guess the TLB load is auto-locked, too.
No, the whole multi-level TLB walk is not locked.

> Anyway, what can we conclude from this for the ia64 architecture?

We can conclude that the generic Linux code that makes changes
to the page table tree has been written to take some care to
make changes in a "safe" way given that other processors may be
simltaneously walking the page tables.  Thus the pointer from the
higher level table to the lower level table is cleared, and we issue
the purge before we free the lower level table.

However, there have been changes to that code, and in particular
ia64 did re-instate quicklists ... so a re-audit to make sure that
none of the assumptions have been broken wouldn't be a bad idea.

-Tony
