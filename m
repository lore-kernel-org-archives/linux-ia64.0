From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Mar 2005 18:34:07 +0000
Subject: [Patch 0/3] Page Table quicklist fixups.
Message-Id: <20050302183407.GA16517@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

I have a new set of patches.  The changes incorporate the comments from
the previous submission with two exceptions.

1) Kenneth Chen suggested hooking the quicklist shrink into the page_alloc
code so pages could be reclaimed when memory conditions are tight.
This work is beyond the scope of these changes.  These changes to not
make that already existing circumstance worse.

2) David Mosberger requested the pte, pmd, and pgd allocations pass
a size into the pgtable_alloc_one routine and introduce a BUG_ON.
I have not fully digested this change yet.  When that gets resolved,
I would think these are ready for inclusion.

Thanks,
Robin Holt
