From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 29 Sep 2003 17:05:52 +0000
Subject: Re: [PATCH] compile discontig with -Whch
Message-Id: <marc-linux-ia64-106486069927693@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106460503816753@msgid-missing>
In-Reply-To: <marc-linux-ia64-106460503816753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 26, 2003 at 12:36:20PM -0700, Jesse Barnes wrote:
> Incorporate some more feedback from hch like moving more stuff to
> contig.c, removing some unneeded functions, etc..  Still left todo:
> 
>   o move CONFIG_VIRTUAL_MEM_MAP stuff out of init.c into its own file?
>   o do real CONFIG_DISCONTIG versions of page_to_pfn, pfn_to_page, etc.
>     so we don't need the global mem_map (or use vmem_map instead, but
>     we'd like CONFIG_DISCONTIG to work w/o CONFIG_VIRTUAL_MEM_MAP anyway
>     so...)

Erich and Tak, are you guys interested in having CONFIG_DISCONTIGMEM
work w/o CONFIG_VIRTUAL_MEM_MAP?  I think we can get it working for your
platform pretty easily, but making it work for platforms with
potentially very large holes in each node looks like it'll require
changes to the bootmem allocator at the very least, and so is probably a
2.7 thing.  But if you don't care, I won't worry about it now.

Thanks,
Jesse
