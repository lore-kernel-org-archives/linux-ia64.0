From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 06 Oct 2004 07:33:52 +0000
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : intro[0/2]
Message-Id: <41639FE0.5060409@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221CC82@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0221CC82@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>


Hi,

Luck, Tony wrote:
>>ia64's ia64_pfn_valid() uses get_user() for checking whether a 
>>page struct is available or not. I think this is an irregular 
>>implementation and following patches
>>are a more generic replacement, careful_pfn_valid(). It uses 2 
>>level table.
> 
> 
> It is odd ... but a somewhat convenient way to make check whether
> the page struct exists, while handling the fault if it is in an
> area of virtual mem_map that doesn't exist.  I think that in practice
> we rarely call it with a pfn that generates a fault (except in error
> paths).

I understand it's rare case.
Honestly, this patch is for no-bitmap buddy allocator (I posted before).
pfn_valid() returns 0 in many case in no-bitmap buddy allocator
(because MAX_ORDER is 4GB).
So I decided to write experimental pfn_valid() which doesn't cause fault.


> How big will the pfn_validmap[] be for a very sparse physical space
> like SGI Altix?  I'm not sure I see how PFN_VALID_MAPSHIFT is 
> generated for each system.
> 
PFN_VALID_MAPSHIFT can be overwritten in each asm-xxx/page.h. (can be in config.h)
I think each special architecture can find suitable value, if it wants.
If Altrix has XXX Tbytes for each node, setting 1 cache line(64bytes2entry) covers
each node's maximum size will be good.

1st level table.
With current configuration, 1Gbytes per 2byte, 8Tbytes per 1 page(16kpages)

2nd level table.
1 entry per 8 bytes. Entries are coalesced with each other as much as possible.
If memory layout is like a bee's nest, careful_pfn_valid() will need great amount
of memory and cannot work fine because of searching.


BTW, how sparse SGI Altix ?

> Why do we need a loop when looking in the 2nd level?  Can't the
> entry from the 1st level point us to the right place?
> 
consider this case.

a 1st level entry covers 0x1000 - 0x2000
[valid range          ]  0x1000 - 0x1100
                          0x1200 - 0x1500
                          0x1600 - 0x2000

pfn_valid(0x1501)
             -> by 1st level, we get 0x1000-0x1100
                              into loop  0x1200-0x1500
                                         0x1600-       returns 0.

walking 2nd level table can reduce size of 1st table.
I'd like to avoid cache-miss rather than avoiding small walk.


- Kame

