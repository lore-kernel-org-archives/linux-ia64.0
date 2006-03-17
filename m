From: Jes Sorensen <jes@sgi.com>
Date: Fri, 17 Mar 2006 13:58:06 +0000
Subject: Re: [patch] mspec - special memory driver and do_no_pfn handler
Message-Id: <441AC06E.1090909@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net> <441ABEDD.4070003@de.ibm.com>
In-Reply-To: <441ABEDD.4070003@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: carsteno@de.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Hellwig <hch@lst.de>

Carsten Otte wrote:
> Jes Sorensen wrote:
>> Index: linux-2.6/include/linux/mm.h
>> =================================>> --- linux-2.6.orig/include/linux/mm.h
>> +++ linux-2.6/include/linux/mm.h
>> @@ -199,6 +199,7 @@
>>  	void (*open)(struct vm_area_struct * area);
>>  	void (*close)(struct vm_area_struct * area);
>>  	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int *type);
>> +	long (*nopfn)(struct vm_area_struct * area, unsigned long address, int *type);
>>  	int (*populate)(struct vm_area_struct * area, unsigned long address, unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock);
>>  #ifdef CONFIG_NUMA
>>  	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
> If you use address as parameter to nopfn, it won't work with highmem
> on 32bit systems. Alternative would be to use (unsigned long) phys. page
> frame number.

Hi Carsten,

The address comes from handle_pte_fault() passing it to do_no_pfn()
passing it to ->nopfn(), ie. it's the faulted address, not the physical
one.

> Your work in memory.c looks like the right thing to do.
> Afaics it will work for xip as well once I figure how to
> do COW. Cool stuff :-).

:-)

Cheers,
Jes


