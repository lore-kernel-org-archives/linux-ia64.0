From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 09 Dec 2004 23:07:13 +0000
Subject: Re: page fault scalability patch V12: rss tasklist vs sloppy rss
Message-Id: <Pine.LNX.4.58.0412091500360.1102@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0412091830580.17648-300000@localhost.localdomain>
 <Pine.LNX.4.58.0412091348130.7478@schroedinger.engr.sgi.com>
 <20041209225259.GG2714@holomorphy.com>
In-Reply-To: <20041209225259.GG2714@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 9 Dec 2004, William Lee Irwin III wrote:
> Unless the algorithms being compared are properly implemented, they're
> straw men, not valid comparisons.

Sloppy rss left the rss in the section of mm that contained the counters.
So that has a separate cacheline. The idea of putting the atomic ops in a
group was to only have one exclusive cacheline for mmap_sem and the rss.
Which could lead to more bouncing of a single cache line rather than
bouncing multiple cache lines less. But it seems to me that the problem
essentially remains the same if the rss counter is not split.
