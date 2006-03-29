From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 29 Mar 2006 02:09:03 +0000
Subject: [RFC][PATCH] avoid creating empty nodes [0/2]
Message-Id: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I tesetd new firmware , which supports NUMA cpu/memory hot-add 
(with Windows), I found Linux/ia64 creates nodes with no cpus, no memory.

This is because of acpi_numa_fixup(). It onlines nodes when they find pxms.
Because SRAT can contain resources which doesn't exist at boot,
the kernel can create a node with a empty pxm which includes not-exisitng cpus
and not-exisitng memory.

Now, I think this is a bug. These patches will fix it.
These patches are against 2.6.16-mm1.

--Kame
 

