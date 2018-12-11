From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Dec 2018 16:42:55 +0000
Subject: RE: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7D492095@ORSMSX110.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
 <20181210215113.GA22180@agluck-desk> <20181211065112.GA13668@lst.de>
In-Reply-To: <20181211065112.GA13668@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?iso-8859-1?Q?Toke_H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "Busch, Keith" <keith.busch@intel.com>, "Derrick, Jonathan" <jonathan.derrick@intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> This should fix it:
...
> +#include <linux/dma-noncoherent.h>

Not quite. Still have an issue with __phys_to_pfn(paddr)

Trying ti #include <asm-generic/memory_model.h> gave we a raft of redefined
macros. So I just added

#define      __phys_to_pfn(paddr)    PHYS_PFN(paddr)

to arch/ia64/mm/init.c

That made the build work. But boot spontaneously resets after:

mptsas: ioc1: attaching ssp device: fw_channel 0, fw_id 6, phy 6, sas_addr 0x5000c5000ecada69
scsi 5:0:0:0: Direct-Access     SEAGATE  ST9146802SS      0003 PQ: 0 ANSI: 5
EFI Variables Facility v0.08 2004-May-17
sd 5:0:0:0: [sdb] 286749488 512-byte logical blocks: (147 GB/137 GiB)
sd 5:0:0:0: [sdb] Write Protect is off
sd 5:0:0:0: [sdb] Write cache: enabled, read cache: enabled, supports DPO and FUA
 sdb: sdb1 sdb2
sd 5:0:0:0: [sdb] Attached SCSI disk

But that might not be your fault. My ancient system is getting flaky. A v4.19 build that
has booted before is also resetting :-(

-Tony

