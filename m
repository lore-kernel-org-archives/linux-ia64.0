From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Sun, 28 Mar 2004 19:10:05 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <98220000.1080501001@[10.10.2.4]>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk> <20040325130433.0a61d7ef.akpm@osdl.org> <41997489.1080257240@42.150.104.212.access.eclipse.net.uk> <4067131A.7000405@sgi.com>
In-Reply-To: <4067131A.7000405@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

> As I understood this originally, the suggestion was to reserve hugetlb 
> pages at mmap() or shm_get() time so that the user would get an -ENOMEM 
> at that time if there aren't enough hugetlb pages to (eventually) satisfy 
> the request, as per the notion that we shouldn't modify the user API due 
> to going with allocate on fault instead of hugetlb_prefault().

Yup, but there were two parts to it:

1. Stop hugepages using the existing overcommit pool for small pages, 
which breaks small page allocations by prematurely the pool.
2. Give hugepages their own over-commit pool, instead of prefaulting.

Personally I think we need both (as you seem to), but (1) is probably
more urgent.

> Since the reservation belongs to the mapped object (file or segment), 
> I've been storing the current file/segments's reservation in the file 
> system dependent part of the inode.  That way, it is easily accessible 
> when the hugetlbfs file or SysV segment is removed and we can reduce 
> the total number of reserved pages by that file's reservation at that 
> time.  This also allows us to handle the reservation in the absence 
> of a vma, as per Andy'c comment below.

Do we need to store it there, or is one central pool number sufficient?
I would have thought it was ...

> Admittedly this doesn't alow one to request that hugetlbpages be 
> overcommitted, or to handle problems caused to the "normal" page 
> overcommit code due to the presence of hugepages.  But we figure that 
> anyone that is actually using hugetlb pages is likely to take over 
> almost all of main memory anyway in a single job, so overcommit 
> doesn't make much sense to us.

Seeing as you can't swap them, overcommitting makes no sense to me
either ;-)

M.

