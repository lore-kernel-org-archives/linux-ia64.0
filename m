From: Andrew Morton <akpm@osdl.org>
Date: Fri, 26 Mar 2004 00:22:32 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <20040325162232.3da62aea.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1739144.1080259161@[192.168.0.89]>
	<2668.1080259844@kao2.melbourne.sgi.com>
In-Reply-To: <2668.1080259844@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: apw@shadowen.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@aracnet.com

Keith Owens <kaos@sgi.com> wrote:
>
> FWIW, lkcd (crash dump) treats hugetlb pages as normal kernel pages and
> dumps them, which is pointless and wastes a lot of time.  To avoid
> dumping these pages in lkcd, I had to add a PG_hugetlb flag.  lkcd runs
> at the page level, not mm or vma, so VM_hugetlb was not available.  In
> set_hugetlb_mem_size()
> 
> 	for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
> 		SetPageReserved(map);
> 		SetPageHugetlb(map);
> 		map++;
> 	}
> 
> In dump_base.c, I changed kernel_page(), referenced_page() and
> unreferenced_page() to test for PageHugetlb() before PageReserved().

That makes sense.

> Since you are looking at identifying hugetlb pages, could any other
> code benefit from a PG_hugetlb flag?

In the overcommit code we don't actually have the page yet.  We're asking
"do we have enough memory available to honour this mmap() invokation when
it later faults in real pages".

