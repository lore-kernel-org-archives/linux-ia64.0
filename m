From: Christoph Hellwig <hch@lst.de>
Date: Tue, 08 Sep 2020 16:47:46 +0000
Subject: dma-mapping cleanups
Message-Id: <20200908164758.3177341-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, iommu@lists.linux-foundation.org
Cc: Tomasz Figa <tfiga@chromium.org>, Joerg Roedel <joro@8bytes.org>, Robin Murphy <robin.murphy@arm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org

Hi all,

this series contains just the cleanup parts from the previous
"a saner API for allocating DMA addressable pages" series.  The
intent is to get this in to reduce the amount of patchbombing
for iterations of the real API work.
