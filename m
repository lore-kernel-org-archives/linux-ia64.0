From: Robin Holt <holt@sgi.com>
Date: Wed, 16 Feb 2005 20:20:41 +0000
Subject: A proposal for fixing the current problems with page tables.
Message-Id: <20050216202041.GB13528@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I would like to propose the following changes to how page tables are
used on ia64.

1) pgd, pmd, and pte free should return the zeroed page to the allocator
for reuse.  Currently, you can read "the allocator" as quicklists.
I am going to propose slab.

2) Use a zeroed slab for quicklist allocations instead of per cpu
quicklists.  This makes cache freeing take less drastic measures when
shrinking the size.  As an example of the issue at hand, on some of
our larger configurations, the quicklist high water mark ends up being
more memory than the node contains.  This results in never freeing pages
at all.  On some of the moderately sized machines, the high water ends
up being approx 1/2 of memory on the node.  When we finally trip that
setpoint, the freeing continues until there are 15 entries left in the
list. This shrink is done out of the timer tick.  This has resulted
in noticable pauses on systems in the field.  The high water/low water
issue is avoided by slabs.

3) Introduce 4 level page tables.  I am leaning strongly toward doing this
as 4 16k page tables max (size depending upon system PAGE_SIZE >= 16K).

4) Make the slab allocations node aware.  The wording is intentionally
deceptive.  I have not looked at the slab code in quite some time,
but just a quick think through makes me lean towards having a slab per
controlling node instead of making the slab code understand nodes.


Is this the right direction to proceed?  Are there other issues with page
tables which I have missed or at the very least glossed over too quickly?

Thanks,
Robin Holt
