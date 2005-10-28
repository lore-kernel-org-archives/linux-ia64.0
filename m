From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 28 Oct 2005 23:23:27 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04D00FCF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> At one point, I discussed 4-level page tables on the ia64 mailing
> list but did not find that discussion in my quick search from
> marc.

IIRC the previous discussion foundered on the general usefulness
of 4-level page tables.  3-level table with a 16K page size provide
a virtual address space that is plenty big enough for the majority
of users (640K should be enough for anyone, so 128T is just over the
top :-).  So 4-level tables are definitely targetted at a small niche.

Making this a config option would be one approach ... but would
almost certainly leave you in the same predicament with the OSDs
that you are in now (if they won't ship a 64K pagesize configured
kernel, I doubt that they will jump for joy about a 4-level page
table config).

Run-time switching between 3-level and 4-level would quite possibly
have even more overhead than just running a 4-level table.

Thanks for supplying the kernbench numbers on this.  I'll see
if I can get Ken interested in running his favorite online
transaction processing benchmark on a 4-level kernel to see
what happens to it.

The worst-case loser from this might be a benchmark that runs
oodles of small processes (partly from the overhead of the extra
page, and partly because I suspect that fork/exec/exit might see
the most impact).  So I'd like to see some AIM7 numbers too.

But overall ... it looks likely that the only possible direction
for the benchmarks is towards worse performance.  Maybe it is a
small to insignificant amount, but there doesn't appear to be
any upside (performance-wise).

Your other potential hope would be long format VHPT.  At least
that has some usage models where performance is better.

-Tony
