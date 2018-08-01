From: Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Aug 2018 16:02:43 +0000
Subject: DMA related cleanups for IA64
Message-Id: <20180801160252.25629-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org

Hi all,

this is a resend of the last two series plus additional cleanups.  The
driver of it were the odd dma barriers in the ia64 sync_single_* methods,
but once I started to look into that area the fallback got bigger and
bigger..
