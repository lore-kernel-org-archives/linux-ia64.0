From: David Miller <davem@davemloft.net>
Date: Fri, 26 May 2006 20:10:59 +0000
Subject: Re: [PATCH] fix update_mmu_cache in fremap.c
Message-Id: <20060526.131059.27783433.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0605261926350.24818@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605261926350.24818@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hugh@veritas.com
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: Hugh Dickins <hugh@veritas.com>
Date: Fri, 26 May 2006 19:28:14 +0100 (BST)

> There are two calls to update_mmu_cache in fremap.c, both defective.
> The one in install_page needs to be accompanied by lazy_mmu_prot_update
> (some other cleanup time, move that into ia64 update_mmu_cache itself); and
> the one in install_file_pte should be removed since the pte is not present.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Where did that rule come from?  We should call update_mmu_cache() even
if the PTE was not present before, look at the fault path in
mm/memory.c, it does this too.

This is where we install hash table entries for newly installed
mappings on sparc64 and powerpc, so this update_mmu_cache() call
is important even for not-previously-present mappings.
