From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 20 Oct 2006 01:20:40 +0000
Subject: Re: [RFC] virtual memmap for sparsemem [2/2] for ia64.
Message-Id: <20061020102040.5260e600.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
	<4537985B.2010908@shadowen.org>
In-Reply-To: <4537985B.2010908@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Oct 2006 16:23:07 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

>
> > +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> > +	vmalloc_end -= NR_MEM_SECTIONS * PAGES_PER_SECTION * sizeof(struct page);
> > +	init_vmemmap_sparsemem(vmalloc_end);
> > +#endif
> 
> I thought I saw that this macro was defined to nothing when
> SPARSEMEM_VMEMMAP was undefined, so I'd expect you not to need the
> #ifdef round it here.  If its not defined when SPARSEMEM isn't defined
> then we should probabally change things so it is.  We do that for the
> sparse_init() and sparse_index_init() in linux/mmzone.h, so it would
> seem reasonable to do the same for this.
> 
Okay, I'll check it.

-Kame

