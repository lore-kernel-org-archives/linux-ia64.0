From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 29 Jul 2003 19:03:00 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105950566703962@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 11:45:40AM -0700, Luck, Tony wrote:

> Even though you are the only user ... it would seem prudent
> to define some generic interface.

I agree but I'm more inclined to think that should be part of an EFI
interfaces cleanup though and more medium to long term perhaps?  I'd
rather see a small limited interface initially and then have that
'fixed' as requirements become more obvious.

> 2) There is no way for another non-kernel user of uncacheable
>    memory to share the resource with you.

The current fetchop driver export interfaces:

    /*-----------------------------------------------------------------------------
     * KERNEL APIs
     * 	Note: right now, these APIs return a full page of fetchops.  If these
     *	interfaces are used often for tasks which do not require a full page of
     *	fetchops, new APIs should be added to suballocate out of a single page.
     */

    unsigned long
    fetchop_kalloc_page(int nid)
    {
	    if (fetchop_update_stats(1, 1) < 0)
		    return 0;
	    return fetchop_alloc_page(nid);
    }
    EXPORT_SYMBOL(fetchop_kalloc_page);


    void
    fetchop_kfree_page(unsigned long maddr)
    {
	    fetchop_free_page(maddr);
	    fetchop_update_stats(-1, -1);
    }
    EXPORT_SYMBOL(fetchop_kfree_page);

Might these be more generically useful at some later stage?


Thanks,
  --cw
