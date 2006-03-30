From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Mar 2006 18:18:53 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061AA7DB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> What about the earlier proposal of advancing at pmd and pud granule by
> walking the page table?  There it can walk at 32MB/64GB step.

That puts constraints on where the platform may align physical
memory.  32M may not be unreasonable (Can you even buy DIMMS that
small anymore?) But 64G is way too large.

Since we only deal with blocks of memory in IA64_GRANULE_SIZE
pieces (16M or 64M) that would seem to be the natural skip
amount.

-Tony
