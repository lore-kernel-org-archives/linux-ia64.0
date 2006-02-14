From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Tue, 14 Feb 2006 07:34:19 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 002/010] Memory hotplug for new nodes with pgdat allocation. (Wait tabl
Message-Id: <20060214160857.ECE9.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210223841.C532.Y-GOTO@jp.fujitsu.com> <1139589198.9209.82.camel@localhost.localdomain>
In-Reply-To: <1139589198.9209.82.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

Sorry for late response....

> On Fri, 2006-02-10 at 23:20 +0900, Yasunori Goto wrote:
> > This patch is to initialize wait table and zonelists for new pgdat.
> > When new node is added, free_area_init_node() is called to initialize
> > pgdat. But, wait table must be allocated by kmalloc (not bootmem) for
> > it.
> > And, zonelists is accessed from any other process every time,
> > So, stop_machine_run() is used for safety update.
> 
> I do notice that you're not using init_currently_empty_zone() to
> initialize currently empty zones.  Why?

Did you mention about here in free_area_init_core()?
I recall about here.

              :
	if (!size)
		continue;

	zonetable_add(zone, nid, j, zone_start_pfn, size);
	zone_wait_table_init(zone, size);
	init_currently_empty_zone(zone, zone_start_pfn, size);
	zone_start_pfn += size;
              :

All of zone_size[] is set zero at new_pgdat_init().
So, init_currently_empty_zone() is not called at this point. Indeed.

However, when __add_section() is called for first section on the node 
after that, hot_add_zone_init() is called, and it calls
init_currently_empty_zone().

--- pgdat2.orig/mm/memory_hotplug.c	2006-02-10 16:59:51.000000000 +0900
+++ pgdat2/mm/memory_hotplug.c	2006-02-10 17:02:34.000000000 +0900
@@ -48,6 +48,8 @@ static int __add_section(struct zone *zo
 
 	ret = sparse_add_one_section(zone, phys_start_pfn, nr_pages);
 
+	hot_add_zone_init(zone, phys_start_pfn, PAGES_PER_SECTION);
+

Thanks.

-- 
Yasunori Goto 


