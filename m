From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Sep 2004 22:11:16 +0000
Subject: RE: [PATCH] general config option cleanup
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01FB77FE@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409081447.38703.jbarnes@engr.sgi.com>
In-Reply-To: <200409081447.38703.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I don't really like this.  It penalises platforms like Intel's 
>Tiger box that have contiguous memory.  I'd really like to
>see VIRTUAL_MEM_MAP go away and the DISCONTIGMEM code be
>usable for both zx1/sx1000 and sn2.

Caveat: I haven't read all of Jesse's patch yet.

CONFIG_VIRTUAL_MEM_MAP isn't entirely accurately named.  It
*used* to enable the virtual mem_map, but quite a while ago
the code was changed so that even if VIRTUAL_MEM_MAP was set,
you would only actually use a virtual mem_map if you had big
holes in your physical address space.  See the:

	if (max_gap < LARGE_GAP)

in arch/ia64/mm/contig.c

Also ... Tiger systems only have contiguous physical memory
if they have <= 2GB.  There is a hole in the physical address
space from 2G to 4G to make space for memory mapped I/O devices.

-Tony

