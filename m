From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Aug 2007 17:22:26 +0000
Subject: RE: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted
Message-Id: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com> <20070823091556.GA18456@skynet.ie> <20070823221005.0D76.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20070823221005.0D76.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>
Cc: Jeremy Higdon <jeremy@sgi.com>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org

> __get_free_pages() of swiotlb_alloc_coherent() fails in rc3-mm1.
> But, it doesn't fail on rc2-mm2, and kernel can boot up.

That looks to be part of the problem here ... failing an order=3
allocation during boot on a system that just a few lines earlier
in the boot log reported "Memory: 37474000k/37680640k available"
looks bad ... but perhaps having *more* memory is part of your problem.
You may have run low on GFP_DMA memory because some allocation
scaled by memory size has chewed up a lot of your memory.  To check
this try booting with a "mem=4G" parameter and see if that helps
you.

But it is also bad that the swiotlb() code failed to handle this.
Can you check whether the problem is related to the size of the
allocation being just over 256K (a magic number for swiotlb since
IO_TLB_SEGSIZE is 128 times a slab size of 2k).  Try changing
lib/swiotlb.c to set IO_TLB_SEGSIZE to 256 instead.

-Tony
