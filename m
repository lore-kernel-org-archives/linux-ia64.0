From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 17 Mar 2006 13:56:02 +0000
Subject: Re: [patch] mspec - special memory driver and do_no_pfn handler
Message-Id: <441ABFF2.5060400@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net> <441ABEDD.4070003@de.ibm.com>
In-Reply-To: <441ABEDD.4070003@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: carsteno@de.ibm.com
Cc: Jes Sorensen <jes@sgi.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Hellwig <hch@lst.de>

Carsten Otte wrote:
> Jes Sorensen wrote:
> 
>>Index: linux-2.6/include/linux/mm.h
>>=================================>>--- linux-2.6.orig/include/linux/mm.h
>>+++ linux-2.6/include/linux/mm.h
>>@@ -199,6 +199,7 @@
>> 	void (*open)(struct vm_area_struct * area);
>> 	void (*close)(struct vm_area_struct * area);
>> 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int *type);
>>+	long (*nopfn)(struct vm_area_struct * area, unsigned long address, int *type);
>> 	int (*populate)(struct vm_area_struct * area, unsigned long address, unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock);
>> #ifdef CONFIG_NUMA
>> 	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
> 
> If you use address as parameter to nopfn, it won't work with highmem
> on 32bit systems. Alternative would be to use (unsigned long) phys. page
> frame number.
> 

It is vaddr, so that should be OK. Return is pfn, which is the important one.

> Your work in memory.c looks like the right thing to do.
> Afaics it will work for xip as well once I figure how to
> do COW. Cool stuff :-).
> 

I think you may be able to use VM_PFNMAP in much the same way as remap_pfn_range
does. You won't be able to support get_user_pages, of course.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
