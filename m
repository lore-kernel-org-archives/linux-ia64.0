From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 10 Dec 2004 04:54:41 +0000
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
Message-Id: <41B92C11.80106@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0412091830580.17648-300000@localhost.localdomain> <41B92567.8070809@yahoo.com.au>
In-Reply-To: <41B92567.8070809@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Nick Piggin wrote:

> Yep, the update_mmu_cache issue is real. There is a parallel problem
> that is update_mmu_cache can be called on a pte who's page has since
> been evicted and reused. Again, that looks safe on IA64, but maybe
> not on other architectures.
> 
> It can be solved by moving lru_cache_add to after update_mmu_cache in
> all cases but the "update accessed bit" type fault. I solved that by
> simply defining that out for architectures that don't need it - a raced
> fault will simply get repeated if need be.
> 

The page-freed-before-update_mmu_cache issue can be solved in that way,
not the set_pte and update_mmu_cache not performed under the same ptl
section issue that you raised.
