From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 28 Sep 2005 21:50:47 +0000
Subject: [patch 2.6.14-rc2 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <09282005175047.10096@bilbo.tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <12c511ca050926194784b63e5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz
Cc: ak@suse.de, tony.luck@intel.com, Asit.K.Mallick@intel.com, gregkh@suse.de

Conduct some maintenance of the swiotlb code:

	-- Move the code from arch/ia64/lib/ to lib/

	-- Cleanup some cruft (code duplication)

	-- Add support for syncing sub-ranges of mappings

	-- Add support for syncing DMA_BIDIRECTIONAL mappings

	-- Comment fixup & change record

Also, tack-on an x86_64 implementation of dma_sync_single_range_for_cpu
and dma_sync_single_range_for _device.  This makes use of the new
swiotlb sync sub-range support.

In this (third) round, the new location for swiotlb is (again) lib/swiotlb.c.

This set does NOT include the PCI excision that Tony Luck started after the
last round of discussion.

Patches to follow...
