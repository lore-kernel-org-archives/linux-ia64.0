From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 19 Nov 2004 06:56:17 +0000
Subject: pte bit spin lock
Message-Id: <419D9911.1080306@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi list,

I was wondering if it might be possible to change arch/ia64/kernel/ivt.S
routines that modify pte access bits, to first take a "spin lock bit" in
the pte before any other modifications to it, and clear the lock bit when
done?

And second question, a pte's memory doesn't ever get updated transparently
by the hardware on ia64, does it?


I have been helping Christoph to look at some ways to reduce page_table_lock
locking. It appears that the ptl can be entirely removed by using per-pte
locks, however this can only be efficient if *all* updates to the pte obey
the lock (if not, then all accesses, and the pte-unlock have to be atomic so
the dirty bit doesn't get lost).

And my last question... I wonder if someone might be able to help me do the
assembly for the locking in ivt.S provided it is a small job and I give the
specification? Sorry, I have no idea about ia64 assembly :(

Thanks,
Nick
