From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Aug 2007 20:46:39 +0000
Subject: RE: [PATCH] Failure to grow RBS
Message-Id: <617E1C2C70743745A92448908E030B2A022DB5C2@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070813132350.GC14980@transitive.com>
In-Reply-To: <20070813132350.GC14980@transitive.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I recently uncovered a bug in the ia64_do_page_fault code that can
> cause a failure to grow the register backing store, or any mapping
> that is marked as VM_GROWSUP if the mapping is the highest mapped area
> of memory.

It looks like we'd still deal poorly with a generic VM_GROWSUP segment
(the "address = prev_vma->vm_end" test in the first "if" in the
check_expansion code looks like it assumes that we will hit the
address immediately after the grows-up block ... though that conflicts
with the code in the else clause that tests to let us grow up by at
most a page :-()

But it looks on paper like this solves the RBS case.

Needs a "Signed-off-by" line.

-Tony
