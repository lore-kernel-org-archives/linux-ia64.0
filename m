From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Thu, 07 Oct 2004 14:38:08 +0000
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-Id: <1248570000.1097159887@[10.10.2.4]>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com> <4164E20D.5020400@jp.fujitsu.com>
In-Reply-To: <4164E20D.5020400@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

> mem_map(1) from  36e    length 1fb6d  --- ZONE_DMA    (36e to 1fedb)
> mem_map(2) from  1fedc  length   124  --- ZONE_DMA    (1fedc to 20000)
> ZONE_DMA is 0G to 4G.
> mem_map(3) from  40000  length 40000  --- ZONE_NORMAL (4G to 8G, this mem_map is aligned)
> mem_map(4) from  a0000  length 20000  --- ZONE_NORMAL (10G to 12G)
> mem_map(5) from  bfedc  length   124  --- ZONE_NORMAL (this is involved in mem_map(4))
> ZONE_NORMAL is 4G to 12G.
> 
> node's start_pfn and end_pfn is aligned to granule size, but holes in memmap is not.
> The vmemmap is aligned to # of page structs in one page.
> 
> virtual_memmap_init() is called directly from efi_memmap_walk() and
> it doesn't take granule size of ia64 into account.
> 
> Hmm....
> It looks what I should do is to make memmap to be aligned to ia64's granule.
> thanks for your advise. I maybe considerd this problem too serious.
> 
> If vmemmap is aligned, ia64_pfn_valid() will work fine. or only 1 level table
> will be needed.

The normal way to fix the above is just to have a bitmap array to test - 
in your case a 1GB granularity would be sufficicent. That takes < 1 word
to implement for the example above ;-)

M.

