From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 07 Oct 2004 00:10:44 +0000
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-Id: <41648984.1080904@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <416392BF.1020708@jp.fujitsu.com>
 <1209350000.1097075647@[10.10.2.4]>
In-Reply-To: <1209350000.1097075647@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Martin J. Bligh wrote:

>>This is generic parts.
>>
>>Boot-time routine:
>>At first, information of valid pages is gathered into a list.
>>After gathering all information, 2 level table are created.
>>Why I create table instead of using a list is only for good cache hit.
>>
>>pfn_valid_init()  <- initilize some structures
>>validate_pages(start,size) <- gather valid pfn information
>>pfn_valid_setup() <- create 1st and 2nd table.
> 
> 
> 
> Boggle. what on earth are you trying to do?
> 
I just want to test whether a struct page for that pfn exists or not.
ia64 has holes in memmap in a zone, so ia64_pfn_valid() uses get_user() to test
whether a page struct exists or not.

In my no-bitmap buddy allocator, I must call pfn_valid() for ia64 at every loop
in free_pages_bulk()(in mm/page_alloc.c).
Beacause of holes in memmap, bad_range()(in mm/page_alloc.c) cannot work enough.

code will be like this:
while(...) {
      pfn_of_buddy = some_func(pfn);
      if( bad_range(pfn_of_buddy) )
	       break;
      if( pfn_valid(pfn_of_buddy) )   <----- only for ia64.
                                             this will disappear in other archs.
	       break;
      ....
}

Because pfn_valid() often returns 0 in inner loop of free_pages_bulk(),
I want to avoid page fault caused by using get_user() in pfn_valid().

I have 2 plan (1) modify pfn_valid or (2) modify bad_range().
this is plan(1).

In plan(2), 1st/2nd tables are attached to each zone/pgdat.


> pfn_valid does exactly one thing - it checks whether there is a struct
> page for that pfn. Nothing else. Surely that can't possibly take a tenth
> of this amount of code?
> 
> M.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

