From: Keith Owens <kaos@sgi.com>
Date: Fri, 26 Mar 2004 00:10:44 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <2668.1080259844@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Thu, 25 Mar 2004 23:59:21 -0000."
             <1739144.1080259161@[192.168.0.89]> 
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@aracnet.com

On Thu, 25 Mar 2004 23:59:21 +0000, 
Andy Whitcroft <apw@shadowen.org> wrote:
>--On 25 March 2004 15:51 -0800 Andrew Morton <akpm@osdl.org> wrote:
>
>> I think it's simply:
>>
>> - Make normal overcommit logic skip hugepages completely
>>
>> - Teach the overcommit_memory=2 logic that hugepages are basically
>>   "pinned", so subtract them from the arithmetic.
>>
>> And that's it.  The hugepages are semantically quite different from normal
>> memory (prefaulted, preallocated, unswappable) and we've deliberately
>> avoided pretending otherwise.
>
>True currently.  Though the thread that prompted this was in response to 
>the time taken for this prefault and for the wish to fault them.
>
>I'll have a poke about at it and see how small I can make it.

FWIW, lkcd (crash dump) treats hugetlb pages as normal kernel pages and
dumps them, which is pointless and wastes a lot of time.  To avoid
dumping these pages in lkcd, I had to add a PG_hugetlb flag.  lkcd runs
at the page level, not mm or vma, so VM_hugetlb was not available.  In
set_hugetlb_mem_size()

	for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
		SetPageReserved(map);
		SetPageHugetlb(map);
		map++;
	}

In dump_base.c, I changed kernel_page(), referenced_page() and
unreferenced_page() to test for PageHugetlb() before PageReserved().

Since you are looking at identifying hugetlb pages, could any other
code benefit from a PG_hugetlb flag?

