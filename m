From: David Hildenbrand <david@redhat.com>
Date: Wed, 16 Nov 2022 10:26:51 +0000
Subject: [PATCH mm-unstable v1 12/20] RDMA/siw: remove FOLL_FORCE usage
Message-Id: <20221116102659.70287-13-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
In-Reply-To: <20221116102659.70287-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Muchun Song <songmuchun@bytedance.com>, Shuah Khan <shuah@kernel.org>, Lucas Stach <l.stach@pengutronix.de>, David Airlie <airlied@gmail.com>, Oded Gabbay <ogabbay@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Alex Williamson <alex.williamson@redhat.com>, David Hildenbrand <david@redhat.com>, Bernard Metzler <bmt@zurich.ibm.com>, Leon Romanovsky <leon@kernel.org>

GUP now supports reliable R/O long-term pinning in COW mappings, such
that we break COW early. MAP_SHARED VMAs only use the shared zeropage so
far in one corner case (DAXFS file with holes), which can be ignored
because GUP does not support long-term pinning in fsdax (see
check_vma_flags()).

Consequently, FOLL_FORCE | FOLL_WRITE | FOLL_LONGTERM is no longer required
for reliable R/O long-term pinning: FOLL_LONGTERM is sufficient. So stop
using FOLL_FORCE, which is really only for ptrace access.

Cc: Bernard Metzler <bmt@zurich.ibm.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Leon Romanovsky <leon@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/infiniband/sw/siw/siw_mem.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/sw/siw/siw_mem.c b/drivers/infiniband/sw/siw/siw_mem.c
index 61c17db70d65..b2b33dd3b4fa 100644
--- a/drivers/infiniband/sw/siw/siw_mem.c
+++ b/drivers/infiniband/sw/siw/siw_mem.c
@@ -368,7 +368,7 @@ struct siw_umem *siw_umem_get(u64 start, u64 len, bool writable)
 	struct mm_struct *mm_s;
 	u64 first_page_va;
 	unsigned long mlock_limit;
-	unsigned int foll_flags = FOLL_WRITE;
+	unsigned int foll_flags = FOLL_LONGTERM;
 	int num_pages, num_chunks, i, rv = 0;
 
 	if (!can_do_mlock())
@@ -391,8 +391,8 @@ struct siw_umem *siw_umem_get(u64 start, u64 len, bool writable)
 
 	mmgrab(mm_s);
 
-	if (!writable)
-		foll_flags |= FOLL_FORCE;
+	if (writable)
+		foll_flags |= FOLL_WRITE;
 
 	mmap_read_lock(mm_s);
 
@@ -423,8 +423,7 @@ struct siw_umem *siw_umem_get(u64 start, u64 len, bool writable)
 		while (nents) {
 			struct page **plist = &umem->page_chunk[i].plist[got];
 
-			rv = pin_user_pages(first_page_va, nents,
-					    foll_flags | FOLL_LONGTERM,
+			rv = pin_user_pages(first_page_va, nents, foll_flags,
 					    plist, NULL);
 			if (rv < 0)
 				goto out_sem_up;
-- 
2.38.1
