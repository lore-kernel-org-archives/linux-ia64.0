From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Jul 2007 04:36:57 +0000
Subject: [PATCH] flush cache fixes for ia64 [0/2] intro
Message-Id: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Zoltan.Menyhart@bull.net, Christoph Lameter <clameter@sgi.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

This patch set is flush_cache_xxx fixes for ia64, take4.
against 2.6.23-rc1.

Consists of 2 patches.

1. page migration fix         ... Christoph, could you review this ?

2. remove lazy_mmu_prot_update() and introduce sync_icache_dcache() 
   If name or style is wrong, please point out.

Any comments are welcome.

Thanks,
-Kame

