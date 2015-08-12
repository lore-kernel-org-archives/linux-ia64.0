From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:32 +0000
Subject: [PATCH 13/31] sparc/ldc: handle page-less SG entries
Message-Id: <1439363150-8661-14-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Use

    sg_phys(sg) & PAGE_MASK

instead of

    page_to_pfn(sg_page(sg)) << PAGE_SHIFT

to get at the page-aligned physical address ofa SG entry, so that
we don't require a page backing for SG entries.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/kernel/ldc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/kernel/ldc.c b/arch/sparc/kernel/ldc.c
index 1ae5eb1..0a29974 100644
--- a/arch/sparc/kernel/ldc.c
+++ b/arch/sparc/kernel/ldc.c
@@ -2051,7 +2051,7 @@ static void fill_cookies(struct cookie_state *sp, unsigned long pa,
 
 static int sg_count_one(struct scatterlist *sg)
 {
-	unsigned long base = page_to_pfn(sg_page(sg)) << PAGE_SHIFT;
+	unsigned long base = sg_phys(sg) & PAGE_MASK;
 	long len = sg->length;
 
 	if ((sg->offset | len) & (8UL - 1))
@@ -2114,7 +2114,7 @@ int ldc_map_sg(struct ldc_channel *lp,
 	state.nc = 0;
 
 	for_each_sg(sg, s, num_sg, i) {
-		fill_cookies(&state, page_to_pfn(sg_page(s)) << PAGE_SHIFT,
+		fill_cookies(&state, sg_phys(s) & PAGE_MASK,
 			     s->offset, s->length);
 	}
 
-- 
1.9.1

