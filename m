From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 26 Sep 2005 21:01:19 +0000
Subject: [patch 2.6.14-rc2 0/5] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <09262005170119.15628@bilbo.tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04795ED2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz
Cc: ak@suse.de, tony.luck@intel.com, Asit.K.Mallick@intel.com, gregkh@suse.de

Conduct some maintenance of the swiotlb code:

	-- Move the code from arch/ia64/lib to drivers/pci

	-- Cleanup some cruft (code duplication)

	-- Add support for syncing sub-ranges of mappings

	-- Add support for syncing DMA_BIDIRECTIONAL mappings

	-- Comment fixup & change record

Also, tack-on an x86_64 implementation of dma_sync_single_range_for_cpu
and dma_sync_single_range_for _device.  This makes use of the new
swiotlb sync sub-range support.

In this round, the new location for swiotlb is driver/pci/swiotlb.c.
This is the result of discussions on lkml pointing-out that swiotlb is
closely related to PCI.

Patches to follow...
