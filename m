From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 01 Feb 2005 04:16:01 +0000
Subject: Re: page fault scalability patch V16 [3/4]: Drop page_table_lock
Message-Id: <41FF0281.6090903@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <41E5B7AD.40304@yahoo.com.au> <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com> <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com> <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com> <20050113180205.GA17600@muc.de> <Pine.LNX.4.58.0501131701150.21743@schroedinger.engr.sgi.com> <20050114043944.GB41559@muc.de> <Pine.LNX.4.58.0501140838240.27382@schroedinger.engr.sgi.com> <20050114170140.GB4634@muc.de> <Pine.LNX.4.58.0501281233560.19266@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501281237010.19266@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501281237010.19266@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

Christoph Lameter wrote:
> The page fault handler attempts to use the page_table_lock only for short
> time periods. It repeatedly drops and reacquires the lock. When the lock
> is reacquired, checks are made if the underlying pte has changed before
> replacing the pte value. These locations are a good fit for the use of
> ptep_cmpxchg.
> 
> The following patch allows to remove the first time the page_table_lock is
> acquired and uses atomic operations on the page table instead. A section
> using atomic pte operations is begun with
> 
> 	page_table_atomic_start(struct mm_struct *)
> 
> and ends with
> 
> 	page_table_atomic_stop(struct mm_struct *)
> 

Hmm, this is moving toward the direction my patches take.

I think it may be the right way to go if you're lifting the ptl
from some core things, because some architectures won't want to
audit and stuff, and some may need the lock.

Naturally I prefer the complete replacement that is made with
my patch - however this of course means one has to move
*everything* over to be pte_cmpxchg safe, which runs against
your goal of getting the low hanging fruit with as little fuss
as possible for the moment.


