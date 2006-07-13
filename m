From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Jul 2006 20:37:17 +0000
Subject: RE: [PATCH] ia64: race flushing icache in COW path
Message-Id: <617E1C2C70743745A92448908E030B2A38D779@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200607131700.k6DH0c5t001038@agluck-lia64.sc.intel.com>
In-Reply-To: <200607131700.k6DH0c5t001038@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Baron <jbaron@redhat.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> lazy_mmu_prot_update() is used in a number of other places *after* the pte 
> is established. An explanation as to why this case is different, would be 
> interesting.

The other places do need a close look, it seems that some of
them may not be needed (e.g. the one inside "if (reuse) { }" at
the top of do_wp_page() ... at the moment I'm struggling to see
what it manages to achieve).

Most of the rest are in cases where we are adding a new virtual
page (comments like "No need to invalidate - it was non-present
before").  These may also need to have the order shuffled, but
they seem unlikely to be the cause of a bug (it is unlikely
that an application has threads that branch to new anonymous
pages as they are being attached to the process).

So you are right that there may be some more work here, but
I wanted to get the one-liner that is a clear and obvious
bugfix posted without being cluttered with some less obvious
fixes.

-Tony
