From: Suparna Bhattacharya <suparna@in.ibm.com>
Date: Fri, 26 Mar 2004 03:41:13 +0000
Subject: Re: [Lse-tech] Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <20040326085826.GA3332@in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1739144.1080259161@[192.168.0.89]> <2668.1080259844@kao2.melbourne.sgi.com> <20040325162232.3da62aea.akpm@osdl.org>
In-Reply-To: <20040325162232.3da62aea.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Keith Owens <kaos@sgi.com>, apw@shadowen.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@aracnet.com

On Thu, Mar 25, 2004 at 04:22:32PM -0800, Andrew Morton wrote:
> Keith Owens <kaos@sgi.com> wrote:
> >
> > FWIW, lkcd (crash dump) treats hugetlb pages as normal kernel pages and
> > dumps them, which is pointless and wastes a lot of time.  To avoid
> > dumping these pages in lkcd, I had to add a PG_hugetlb flag.  lkcd runs

This should already be fixed in recent versions of lkcd. It uses a
little bit of trickery to avoid an extra page flag -- hugetlb pages are 
detected as "in use" as well as reserved, unlike other reserved pages 
which helps identify them.

/* to track all used (compound + zero order) pages */
#define PageInuse(p)   (PageCompound(p) || page_count(p))

.
.

static inline int kernel_page(struct page *p)
{
        /* Need to exclude hugetlb pages. Clue: reserved but inuse */
        return (PageReserved(p) && !PageInuse(p)) || (!PageLRU(p) && PageInuse(p));
}

Regards
Suparna

> > at the page level, not mm or vma, so VM_hugetlb was not available.  In
> > set_hugetlb_mem_size()
> > 
> > 	for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
> > 		SetPageReserved(map);
> > 		SetPageHugetlb(map);
> > 		map++;
> > 	}
> > 
> > In dump_base.c, I changed kernel_page(), referenced_page() and
> > unreferenced_page() to test for PageHugetlb() before PageReserved().
> 
> That makes sense.
> 
> > Since you are looking at identifying hugetlb pages, could any other
> > code benefit from a PG_hugetlb flag?
> 
> In the overcommit code we don't actually have the page yet.  We're asking
> "do we have enough memory available to honour this mmap() invokation when
> it later faults in real pages".
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id70&alloc_id638&op=click
> _______________________________________________
> Lse-tech mailing list
> Lse-tech@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lse-tech

-- 
Suparna Bhattacharya (suparna@in.ibm.com)
Linux Technology Center
IBM Software Lab, India

