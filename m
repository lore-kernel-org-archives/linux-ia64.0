From: David Miller <davem@davemloft.net>
Date: Fri, 26 May 2006 23:37:28 +0000
Subject: Re: [PATCH] fix update_mmu_cache in fremap.c
Message-Id: <20060526.163728.13768279.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0605261926350.24818@blonde.wat.veritas.com>
	<20060526.131059.27783433.davem@davemloft.net>
	<Pine.LNX.4.64.0605262340130.9720@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605262340130.9720@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hugh@veritas.com
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: Hugh Dickins <hugh@veritas.com>
Date: Fri, 26 May 2006 23:43:47 +0100 (BST)

> Sure it's important for not-previously-present mappings, when you're
> installing a present pte.  But the "file pte" being installed by
> install_file_pte is not a real pte - it's a non-present entry (like
> a swap entry), noting what file offset should be mapped there when
> there's a fault (in a non-linear vma where that's not obvious).

My bad, the update_mmu_cache() certainly is erroneous in that
case.

Thanks for the clarification.
