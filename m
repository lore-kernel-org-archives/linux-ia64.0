From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 22 Aug 2007 16:19:59 +0000
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory
Message-Id: <20070822091959.aa38fd3e.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com>
In-Reply-To: <46CC48FD.4000607@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Wed, 22 Aug 2007 20:02:29 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> Hi Andrew,
> 
> Following Kernel panic was raised, when tried to boot using IA-64
> machine with 2.6.23-rc3-mm1 kernel.
> =======================> [   15.198125]  target0:0:8: Ending Domain Validation
> [   15.203117]  target0:0:8: asynchronous
> [   15.207377] scsi 0:0:8:0: Attached scsi generic sg1 type 3
> [   16.971340] GSI 41 (level, low) -> CPU 4 (0x1000) vector 72
> [   16.977053] ACPI: PCI Interrupt 0000:01:03.1[B] -> GSI 41 (level, 
> low) -> IRQ 72
> [   16.984767] mptbase: Initiating ioc1 bringup
> [   17.465344] ioc1: LSI53C1030 C0: Capabilities={Initiator}
> [   15.180382] scsi1 : ioc1: LSI53C1030 C0, FwRev032821h, Ports=1, 
> MaxQ"2, IRQr
> [   20.376426] GSI 142 (level, low) -> CPU 5 (0x1200) vector 73
> [   20.382298] ACPI: PCI Interrupt 0000:41:03.0[A] -> GSI 142 (level, 
> low) -> IRQ 73
> [   20.390209] mptbase: Initiating ioc2 bringup
> [   20.873561] ioc2: LSI53C1030 C0: Capabilities={Initiator}
> [   20.880366] DMA: Out of SW-IOMMU space for 263200 bytes at device ?
> [   20.886858] Kernel panic - not syncing: DMA: Memory would be corrupted

Gad, never seen that before.  Andi, Tony: help?
