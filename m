From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Mon, 08 Jul 2002 22:08:17 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905740@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

> ChangeLog

> 	- Fix bootmem so machine boots much faster if there are large holes in
> 	  the physical memory map.

This change seemed to cause a problem on my machine.
When a system has physical memory >4G, IO TLB is allocated above 4G
like this;

   Placing software IO TLB between 0xe00000010222c000 - 0xe00000010242c000

and then swiotlb_map_single() caused PANIC.

IO TLB is allocated by alloc_bootmem_low_pages(), and this is just a
macro calling __alloc_bootmem().

    #define alloc_bootmem_low_pages(x) \
            __alloc_bootmem((x), PAGE_SIZE, 0)

Once alloc_bootmem() is called, "last_success" is set to > 4G.
And then alloc_bootmem_low_pages() becomes to allocates memory > 4G. :-(
alloc_bootmem_low_page() doesn't ensure to allocate memory < 4G,
but swiotlb expects to it allocates very low address memory.

Here is a patch for mm/bootmem.c to fix the problem.
Any comment?

*** bootmem.c.bk        Mon Jul  8 13:59:29 2002
--- bootmem.c   Mon Jul  8 14:00:37 2002
***************
*** 168,179 ****
        if (goal && (goal >= bdata->node_boot_start) &&
                        ((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
                preferred = goal - bdata->node_boot_start;
        } else
                preferred = 0;

-       if (last_success >= preferred)
-               preferred = last_success;
-
        preferred = ((preferred + align - 1) & ~(align - 1)) >> PAGE_SHIFT;
        preferred += offset;
        areasize = (size+PAGE_SIZE-1)/PAGE_SIZE;
--- 168,179 ----
        if (goal && (goal >= bdata->node_boot_start) &&
                        ((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
                preferred = goal - bdata->node_boot_start;
+
+               if (last_success >= preferred)
+                       preferred = last_success;
        } else
                preferred = 0;

        preferred = ((preferred + align - 1) & ~(align - 1)) >> PAGE_SHIFT;
        preferred += offset;
        areasize = (size+PAGE_SIZE-1)/PAGE_SIZE;


Regards,
Kimi

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


