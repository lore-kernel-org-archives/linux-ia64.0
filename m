From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 10 Feb 2006 14:20:29 +0000
Subject: [RFC/PATCH: 000/010] Memory hotplug for new nodes with pgdat allocation.
Message-Id: <20060210223636.C52E.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

Hello.

I'll post newest patches for memory hotadd.
In this this patch, pgdat is allocated when new node is comming.
To initialize pgdat and zones, a set of patches are necessary.
  - to allcate and initialize pgdat, zone, zonelist.
  - to initialize node_data[] array (ia64)
  - to register sysfs file for new node.
  - to call memory_hotplug code from acpi container driver.

Note:
 - kmalloc is used for pgdat allocation in this version.
   So, even if pgdat is allocated, it will be allocated on the other node.
   This is only to simplify patches a bit. :-P
 - register sysfs file for new node is just for ia64.
   I hacked quickly for x86_64, but x86_64 doesn't use sysfs file
   for node. So, I gave up at least this week.....


This patches are for 2.6.16-rc2-mm1.

Please comment.

Thanks.
-- 
Yasunori Goto 


