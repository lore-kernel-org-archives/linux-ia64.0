From: Hugh Dickins <hugh@veritas.com>
Date: Fri, 26 May 2006 22:43:47 +0000
Subject: Re: [PATCH] fix update_mmu_cache in fremap.c
Message-Id: <Pine.LNX.4.64.0605262340130.9720@blonde.wat.veritas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0605261926350.24818@blonde.wat.veritas.com>
 <20060526.131059.27783433.davem@davemloft.net>
In-Reply-To: <20060526.131059.27783433.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 26 May 2006, David Miller wrote:
> From: Hugh Dickins <hugh@veritas.com>
> Date: Fri, 26 May 2006 19:28:14 +0100 (BST)
> 
> > There are two calls to update_mmu_cache in fremap.c, both defective.
> > The one in install_page needs to be accompanied by lazy_mmu_prot_update
> > (some other cleanup time, move that into ia64 update_mmu_cache itself); and
> > the one in install_file_pte should be removed since the pte is not present.
> > 
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> 
> Where did that rule come from?  We should call update_mmu_cache() even
> if the PTE was not present before, look at the fault path in
> mm/memory.c, it does this too.
> 
> This is where we install hash table entries for newly installed
> mappings on sparc64 and powerpc, so this update_mmu_cache() call
> is important even for not-previously-present mappings.

Sure it's important for not-previously-present mappings, when you're
installing a present pte.  But the "file pte" being installed by
install_file_pte is not a real pte - it's a non-present entry (like
a swap entry), noting what file offset should be mapped there when
there's a fault (in a non-linear vma where that's not obvious).

Hugh
