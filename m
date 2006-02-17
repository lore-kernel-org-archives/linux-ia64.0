From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 17 Feb 2006 13:28:17 +0000
Subject: [PATCH: 000/012] Memory hotplug for new nodes v.2.
Message-Id: <20060217210625.4068.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

Hello.

I'll post newest patches for memory hotadd as V2.
In this patch, pgdat is allocated when new node is comming.
To initialize pgdat and zones, a set of patches are necessary.
  - to call memory_hotplug code from acpi container driver.
  - to allcate and initialize pgdat, zone, zonelist.
  - to initialize node_data[] array (ia64)
  - to register sysfs file for new node.
This patch set is not only for ia64 but also for x86-64.

Note:
 - kmalloc is used for pgdat allocation in this version.
   So, even if pgdat is allocated, it will be allocated on the other node.
   This is only to simplify patches a bit. :-P

This patches are for 2.6.16-rc3-mm1.

Followings are updates.
  - update for 2.6.16-rc3-mm1.
  - not only ia64, This is tested on x86_64 with NUMA emulation too. :-)
  - wait_table_size() allcation is changed.
      - Take max size as much as possible.
      - Change using GFP_ATOMIC. It is inside of zone_init_lock.
        (Warining message of might_sleep() is very well.)
  - stop_machine_run(build_zonelists) is move to outside of lock.
  - pgdat_insert() is moved to generic code to be used by x86_64.
  - add decision of ZONE_DMA32 or ZONE_NORMAL to x86_64's add_memory().
  - Make a separated patch to change from __init to __meminit.
  - Fix some typo


Please comment.


-- 
Yasunori Goto 


