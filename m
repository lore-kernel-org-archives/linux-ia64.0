From: Robin Holt <holt@sgi.com>
Date: Thu, 03 Mar 2005 13:49:42 +0000
Subject: Re: [Patch 3/3] Shrink quicklist based upon node free memory.
Message-Id: <20050303134942.GC26896@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050302184312.GD16517@lnx-holt.americas.sgi.com>
In-Reply-To: <20050302184312.GD16517@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How about the following?

static inline long
min_pages_to_free (void)
{
        long pages_to_free;

        pages_to_free = pgtable_quicklist_size - max_pgt_pages();
        pages_to_free = min(pages_to_free, 1L << NODE_FREE_PAGES_SHIFT);
        return pages_to_free;
}


void
check_pgt_cache (void)
{
        long pages_to_free;

        if (unlikely(pgtable_quicklist_size <= MIN_PGT_PAGES))
                return;

        preempt_disable();
        while (unlikely((pages_to_free=min_pages_to_free()) > 0)) {
                while (pages_to_free--) {
                        free_page((unsigned long)pgtable_quicklist_alloc());
                }
                preempt_enable();
                preempt_disable();
        }
        preempt_enable();
}

