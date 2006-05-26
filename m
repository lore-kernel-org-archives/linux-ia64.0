From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 26 May 2006 10:23:07 +0000
Subject: Re: [RFC][PATCH] ia64 node hotplug -- cpu - node relationship fix [0/2] intro
Message-Id: <20060526184011.EEAA.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060526175622.13057d7e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060526175622.13057d7e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org, ashok.raj@intel.com, steiner@sgi.com, tony.luck@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> 1. empty-node-fix : avoid creating empty node
>    SRAT's enable bit just shows 'you can read this entry'. But the kernel know
>    this and checks each entries are vaild or not later.
>
>    But pxm_bit/node_online_mask is not treated as they should be.
>    The kernel creates empty node, which has no cpu, no memory.

I would like to mention about background of this more.

I thought if enable bit of each SRAT entry is on, then its entry's
object is usable for OS.

However, SRAT specification says only
"If clear, the OSPM ignores the contents of the Processor Local
 APIC/SAPIC (or Memory) Affinity Structure."

So, our firmware team (or Micro $oft) interprets this
"If enable bit is on, then this entry is just readable by OS.
 The object of its entry MIGHT NOT EXIST. This entry can be used for
 reserve resource for memory/cpu which can be hot-add later."
They implemented it.

I really really hate this. :-(
But, indeed, ACPI spec. says just IGNORE if clear. They are correct.

Current linux code checks memory and cpu existence by other ways.
But, PXM remains even if they don't exist. The first patch is to remove it.

Bye.

-- 
Yasunori Goto 


