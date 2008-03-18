From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 18 Mar 2008 17:46:59 +0000
Subject: RE: [Patch 0/3] Modify how per_cpu allocations are done. -V8
Message-Id: <1FE6DD409037234FAB833C420AA843ECD91BE7@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175519.892353127@attica.americas.sgi.com>
In-Reply-To: <20080213175519.892353127@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Have you had a chance to test this revised patchset on your tiger box?

Yes.  The new patchset still builds cleanly for all my test configs, and
this time it boots on my Tiger.

I'm still wondering about the direction you've taken though.  One
of the goals of this patchset is to reduce boot-time memory
allocation by making sure that we don't allocate per-cpu resources
for cpus that will never exist.  But not all systems provide
enough information to determine this reliably (and Linux doesn't
get around to looking at that information until after we need to
do these allocations) so you've added the "early_cpu_possible_map"
which in some cases has to err on the safe side in how many cpus
it thinks may ever exist ... and so we may allocate resources for
some non-existant cpus.

The existing MCA part of the code appears to be more conservative
than the code that you are adding.  It allocates for cpu0 using
bootmem_alloc, and then for other cpus on an as-needed basis using
alloc_pages_node().  The current code is very ugly ... needing
an "__init refok" function, and not dealing well with possible
allocation failures.  A clean-up is definitely needed, but can't
we still maintain the alloc-on-demand part (perhaps moving it
from being run by the new cpu itself to some pre-bring-up-code
that will be run by the cpu that is going to initiate bringing
the cpu online ... which would make the error handling path
easier).

-Tony
