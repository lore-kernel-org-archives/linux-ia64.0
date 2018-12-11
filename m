From: Christoph Hellwig <hch@lst.de>
Date: Tue, 11 Dec 2018 06:51:12 +0000
Subject: Re: [RFC] avoid indirect calls for DMA direct mappings v2
Message-Id: <20181211065112.GA13668@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de> <20181210215113.GA22180@agluck-desk>
In-Reply-To: <20181210215113.GA22180@agluck-desk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 10, 2018 at 01:51:13PM -0800, Luck, Tony wrote:
> But the ia64 build fails with:

Yes, I just got the same complaint form the buildbot, unfortunately
I don't have a good ia64 cross compiler locally given that Debian
is lacking one, and the one provided by the buildbot doesn't build on
Debian either..

This should fix it:

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 2c51733f1dfd..a007afaa556c 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -8,6 +8,7 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 
+#include <linux/dma-noncoherent.h>
 #include <linux/efi.h>
 #include <linux/elf.h>
 #include <linux/memblock.h>
