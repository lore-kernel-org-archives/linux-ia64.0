From: Logan Gunthorpe <logang@deltatee.com>
Date: Mon, 09 Dec 2019 19:13:46 +0000
Subject: [PATCH 6/6] mm/memremap: Set caching mode for PCI P2PDMA memory to WC
Message-Id: <20191209191346.5197-7-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191209191346.5197-1-logang@deltatee.com>
In-Reply-To: <20191209191346.5197-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>

PCI BAR IO memory should never be mapped as WB, however prior to this
the PAT bits were set WB and it was typically overridden by MTRR
registers set by the firmware.

Set PCI P2PDMA memory to be WC (writecombining) as the only current
user (the NVMe CMB) was originally mapped WC before the P2PDMA code
replaced the mapping with devm_memremap_pages().

Future use-cases may need to generalize this by adding flags to
select the caching type, as some P2PDMA cases will not want WC.
However, those use-cases are not upstream yet and this can be changed
when they arrive.

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 mm/memremap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memremap.c b/mm/memremap.c
index 4edcca074e15..ced32593e4a7 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -187,7 +187,10 @@ void *memremap_pages(struct dev_pagemap *pgmap, int nid)
 		}
 		break;
 	case MEMORY_DEVICE_DEVDAX:
+		need_devmap_managed = false;
+		break;
 	case MEMORY_DEVICE_PCI_P2PDMA:
+		pgprot = pgprot_writecombine(pgprot);
 		need_devmap_managed = false;
 		break;
 	default:
-- 
2.20.1
