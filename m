From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 09 Dec 2004 23:29:45 +0000
Subject: Re: page fault scalability patch V12: rss tasklist vs sloppy rss
Message-Id: <20041209232945.GH2714@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0412091830580.17648-300000@localhost.localdomain> <Pine.LNX.4.58.0412091348130.7478@schroedinger.engr.sgi.com> <20041209225259.GG2714@holomorphy.com> <Pine.LNX.4.58.0412091500360.1102@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412091500360.1102@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Dec 09, 2004 at 03:07:13PM -0800, Christoph Lameter wrote:
> Sloppy rss left the rss in the section of mm that contained the counters.
> So that has a separate cacheline. The idea of putting the atomic ops in a
> group was to only have one exclusive cacheline for mmap_sem and the rss.
> Which could lead to more bouncing of a single cache line rather than
> bouncing multiple cache lines less. But it seems to me that the problem
> essentially remains the same if the rss counter is not split.

The prior results Robin Holt cited were that the counter needed to be
in a different cacheline from the ->mmap_sem and ->page_table_lock.
We shouldn't need to evaluate splitting for the atomic RSS algorithm.

A faithful implementation would just move the atomic counters away from
the ->mmap_sem and ->page_table_lock (just shuffle some mm fields).
Obviously a complete set of results won't be needed unless it's very
surprisingly competitive with the stronger algorithms. Things should be
fine just making sure that behaves similarly to the one with the shared
cacheline with ->mmap_sem in the sense of having a curve of similar shape
on smaller systems. The absolute difference probably doesn't matter,
but there is something to prove, and the largest risk of not doing so
is exaggerating the low-end performance benefits of stronger algorithms.

-- wli
