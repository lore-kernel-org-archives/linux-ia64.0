From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 07 Oct 2004 06:28:29 +0000
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-Id: <4164E20D.5020400@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi,
Luck, Tony wrote:

>>Because pfn_valid() often returns 0 in inner loop of free_pages_bulk(),
>>I want to avoid page fault caused by using get_user() in pfn_valid().
> 
> 
> How often?  Surely this is only a problem at the edges of blocks
> of memory?  I suppose it depends on whether your discontig memory
> appears in blocks much smaller than MAXORDER.  But even there it
> should only be an issue coalescing buddies that are bigger than
> the granule size (since all of the pages in a granule on ia64 are
> guaranteed to exist, the buddy of any page must also exist).
> 
Currently, my Tiger4 shows  memory map like this.
this is a record of memmap_init() called by virtual_memmap_init().
NOTE: MAX_ORDER is 4Gbytes.

mem_map(1) from  36e    length 1fb6d  --- ZONE_DMA    (36e to 1fedb)
mem_map(2) from  1fedc  length   124  --- ZONE_DMA    (1fedc to 20000)
ZONE_DMA is 0G to 4G.
mem_map(3) from  40000  length 40000  --- ZONE_NORMAL (4G to 8G, this mem_map is aligned)
mem_map(4) from  a0000  length 20000  --- ZONE_NORMAL (10G to 12G)
mem_map(5) from  bfedc  length   124  --- ZONE_NORMAL (this is involved in mem_map(4))
ZONE_NORMAL is 4G to 12G.

node's start_pfn and end_pfn is aligned to granule size, but holes in memmap is not.
The vmemmap is aligned to # of page structs in one page.

virtual_memmap_init() is called directly from efi_memmap_walk() and
it doesn't take granule size of ia64 into account.

Hmm....
It looks what I should do is to make memmap to be aligned to ia64's granule.
thanks for your advise. I maybe considerd this problem too serious.

If vmemmap is aligned, ia64_pfn_valid() will work fine. or only 1 level table
will be needed.

Thanks.

Kame <kamezawa.hiroyu@jp.fujitsu.com>
