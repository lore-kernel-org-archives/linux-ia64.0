From: David Hildenbrand <david@redhat.com>
Date: Wed, 16 Nov 2022 10:26:54 +0000
Subject: [PATCH mm-unstable v1 15/20] media: pci/ivtv: remove FOLL_FORCE usage
Message-Id: <20221116102659.70287-16-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
In-Reply-To: <20221116102659.70287-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Muchun Song <songmuchun@bytedance.com>, Shuah Khan <shuah@kernel.org>, Lucas Stach <l.stach@pengutronix.de>, David Airlie <airlied@gmail.com>, Oded Gabbay <ogabbay@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Alex Williamson <alex.williamson@redhat.com>, David Hildenbrand <david@redhat.com>, Andy Walls <awalls@md.metrocast.net>, Mauro Carvalho Chehab <mchehab@kernel.org>

FOLL_FORCE is really only for ptrace access. R/O pinning a page is
supposed to fail if the VMA misses proper access permissions (no VM_READ).

Let's just remove FOLL_FORCE usage here; there would have to be a pretty
good reason to allow arbitrary drivers to R/O pin pages in a PROT_NONE
VMA. Most probably, FOLL_FORCE usage is just some legacy leftover.

Cc: Andy Walls <awalls@md.metrocast.net>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/media/pci/ivtv/ivtv-udma.c | 2 +-
 drivers/media/pci/ivtv/ivtv-yuv.c  | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/media/pci/ivtv/ivtv-udma.c b/drivers/media/pci/ivtv/ivtv-udma.c
index 210be8290f24..99b9f55ca829 100644
--- a/drivers/media/pci/ivtv/ivtv-udma.c
+++ b/drivers/media/pci/ivtv/ivtv-udma.c
@@ -115,7 +115,7 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
 
 	/* Pin user pages for DMA Xfer */
 	err = pin_user_pages_unlocked(user_dma.uaddr, user_dma.page_count,
-			dma->map, FOLL_FORCE);
+			dma->map, 0);
 
 	if (user_dma.page_count != err) {
 		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
diff --git a/drivers/media/pci/ivtv/ivtv-yuv.c b/drivers/media/pci/ivtv/ivtv-yuv.c
index 4ba10c34a16a..582146f8d70d 100644
--- a/drivers/media/pci/ivtv/ivtv-yuv.c
+++ b/drivers/media/pci/ivtv/ivtv-yuv.c
@@ -63,12 +63,11 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
 
 	/* Pin user pages for DMA Xfer */
 	y_pages = pin_user_pages_unlocked(y_dma.uaddr,
-			y_dma.page_count, &dma->map[0], FOLL_FORCE);
+			y_dma.page_count, &dma->map[0], 0);
 	uv_pages = 0; /* silence gcc. value is set and consumed only if: */
 	if (y_pages = y_dma.page_count) {
 		uv_pages = pin_user_pages_unlocked(uv_dma.uaddr,
-				uv_dma.page_count, &dma->map[y_pages],
-				FOLL_FORCE);
+				uv_dma.page_count, &dma->map[y_pages], 0);
 	}
 
 	if (y_pages != y_dma.page_count || uv_pages != uv_dma.page_count) {
-- 
2.38.1
