From: mel@skynet.ie (Mel Gorman)
Date: Thu, 23 Aug 2007 09:15:56 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted
Message-Id: <20070823091556.GA18456@skynet.ie>
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com> <20070822091959.aa38fd3e.akpm@linux-foundation.org> <20070822172541.GA8058@bingen.suse.de> <46CC811C.9010600@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2D39@scsmsx411.amr.corp.intel.com> <46CCB79E.7070109@linux.vnet.ibm.com> <617E1C2C70743745A92448908E030B2A023B2F6A@scsmsx411.amr.corp.intel.com> <20070822231111.GD89849@sgi.com> <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jeremy Higdon <jeremy@sgi.com>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org

On (22/08/07 16:27), Luck, Tony didst pronounce:
> > The more ioc's you have, the more space you will use.
> 
> Default SW IOTLB allocation is 64MB ... how much should we see
> used per ioc?
> 
> Kamelesh: You could try increasing the amount of sw iotlb space
> available by booting with a swiotlb1072 argument (argument
> value is the number of 2K slabs to allocate ... 131072 would
> give you four times as much space as the default allocation).
> 

I tried that value and just in case swiotlb&2144. An IA-64 machines I
have here fails with the same message anyway. i.e.

[   19.834906] mptbase: Initiating ioc1 bringup
[   20.317152] ioc1: LSI53C1030 C0: Capabilities={Initiator}
[   15.474303] scsi1 : ioc1: LSI53C1030 C0, FwRev032821h, Ports=1, MaxQ"2, IRQr
[   20.669730] GSI 142 (level, low) -> CPU 5 (0x1200) vector 73
[   20.675602] ACPI: PCI Interrupt 0000:41:03.0[A] -> GSI 142 (level, low) -> IRQ 73
[   20.683508] mptbase: Initiating ioc2 bringup
[   21.166796] ioc2: LSI53C1030 C0: Capabilities={Initiator}
[   21.180539] DMA: Out of SW-IOMMU space for 263200 bytes at device ?
[   21.187018] Kernel panic - not syncing: DMA: Memory would be corrupted

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
