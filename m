From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 06 Aug 2004 12:17:39 +0000
Subject: Re: [PATCH&RFC 2/2] OS_MCA Recovery from poisoned memory read
Message-Id: <411376E3.5020203@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41121484.40804@jp.fujitsu.com>
In-Reply-To: <41121484.40804@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you for your useful reply.

But, there is one thing that I want to confirm.

Keith Owens wrote:
> +static isolate_status_t
> +mca_page_isolate(unsigned long paddr)
> +{
> +       int i;
> +       struct page *p;
> +
> +       /* whether physical address is valid or not */
> +       if ( !ia64_phys_addr_valid(paddr) )  
> 
> The calls to mca_page_isolate() are racy.  That code is running in
> normal kernel context after exiting from the MCA handler.  Other cpus
> could be modifying the page tables at the same time, there could even
> be two cpus running mca_handler_bh() at the same time for the same
> page.

I agree that there could be multiple cpus running handler_bh at the
same time, so (even though it would be a rare case) I think it would be
better if I avoid the race using something like a spinlock.

ITOH, what the handler_bh should modify is not the page tables but the
flag in a struct page which pfn_to_page convert from a physical address.
Does the result of the translation from a physical address to a page that
includes the address can be changed? (Do you suppose Memory Hotplugs?)

Thanks,
H.Seto
