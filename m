From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 20 Nov 2004 03:04:25 +0000
Subject: Re: page fault scalability patch V11 [0/7]: overview
Message-Id: <20041120030425.GF2714@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <419D581F.2080302@yahoo.com.au> <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com> <419D5E09.20805@yahoo.com.au> <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <20041120020401.GC2714@holomorphy.com> <419EA96E.9030206@yahoo.com.au> <20041120023443.GD2714@holomorphy.com> <419EAEA8.2060204@yahoo.com.au>
In-Reply-To: <419EAEA8.2060204@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Robin Holt <holt@sgi.com>

William Lee Irwin III wrote:
>> Furthermore, see Robin Holt's results regarding the performance of the
>> atomic operations and their relation to cacheline sharing.

On Sat, Nov 20, 2004 at 01:40:40PM +1100, Nick Piggin wrote:
> Well yeah, but a. their patch isn't in 2.6 (or 2.4), and b. anon_rss

Irrelevant. Unshare cachelines with hot mm-global ones, and the
"problem" goes away.

This stuff is going on and on about some purist "no atomic operations
anywhere" weirdness even though killing the last atomic operation
creates problems and doesn't improve performance.


On Sat, Nov 20, 2004 at 01:40:40PM +1100, Nick Piggin wrote:
> means another atomic op. While this doesn't immediately make it a
> showstopper, it is gradually slowing down the single threaded page
> fault path too, which is bad.

William Lee Irwin III wrote:
>> And frankly, the argument that the space overhead of per-cpu counters
>> is problematic is not compelling. Even at 1024 cpus it's smaller than
>> an ia64 pagetable page, of which there are numerous instances attached
>> to each mm.

On Sat, Nov 20, 2004 at 01:40:40PM +1100, Nick Piggin wrote:
> 1024 CPUs * 64 byte cachelines = 64K, no? Well I'm sure they probably
> don't even care about 64K on their large machines, but...
> On i386 this would be maybe 32 * 128 byte = 4K per task for distro
> kernels. Not so good.

Why the Hell would you bother giving each cpu a separate cacheline?
The odds of bouncing significantly merely amongst the counters are not
particularly high.


-- wli
