From: Randolph Chung <tausq@debian.org>
Date: Thu, 02 Sep 2004 17:43:19 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040902174319.GN19210@tausq.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Are you creating the whole memmap and then freeing up the holes?  IIRC that's 
> what's done for x86 NUMA boxes, but that won't work if the inital memmap is 
> too big to fit in memory in the first place.

this is what we do:

        for (i = 0; i < npmem_ranges; i++) {
                unsigned long start_pfn;
                unsigned long npages;

                start_pfn = pmem_ranges[i].start_pfn;
                npages = pmem_ranges[i].pages;

                bootmap_size = init_bootmem_node(NODE_DATA(i),
                                                bootmap_pfn,
                                                start_pfn,
                                                (start_pfn + npages) );
                free_bootmem_node(NODE_DATA(i),
                                  (start_pfn << PAGE_SHIFT),
                                  (npages << PAGE_SHIFT) );
                bootmap_pfn += (bootmap_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
                if ((start_pfn + npages) > max_pfn)
                        max_pfn = start_pfn + npages;
        }

we don't do anything explicit with the holes when DISCONTIGMEM is
enabled. when it's not enabled we are able to work with small holes by
using the technique you mentioned above.

randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/
