From: Andi Kleen <ak@suse.de>
Date: Wed, 22 Aug 2007 16:35:53 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted
Message-Id: <20070822172541.GA8058@bingen.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com> <20070822091959.aa38fd3e.akpm@linux-foundation.org>
In-Reply-To: <20070822091959.aa38fd3e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

> > [   20.880366] DMA: Out of SW-IOMMU space for 263200 bytes at device ?
> > [   20.886858] Kernel panic - not syncing: DMA: Memory would be corrupted
> 
> Gad, never seen that before.  Andi, Tony: help?

Either the driver is leaking or more likely something went 
wrong with the swiotlb initialization. Earlier boot messages
might tell

-Andi
