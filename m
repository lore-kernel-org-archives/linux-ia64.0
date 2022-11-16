From: David Hildenbrand <david@redhat.com>
Date: Wed, 16 Nov 2022 10:26:44 +0000
Subject: [PATCH mm-unstable v1 05/20] mm: add early FAULT_FLAG_WRITE consistency checks
Message-Id: <20221116102659.70287-6-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221116102659.70287-1-david@redhat.com>
In-Reply-To: <20221116102659.70287-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, etnaviv@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Muchun Song <songmuchun@bytedance.com>, Shuah Khan <shuah@kernel.org>, Lucas Stach <l.stach@pengutronix.de>, David Airlie <airlied@gmail.com>, Oded Gabbay <ogabbay@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Alex Williamson <alex.williamson@redhat.com>, David Hildenbrand <david@redhat.com>

Let's catch abuse of FAULT_FLAG_WRITE early, such that we don't have to
care in all other handlers and might get "surprises" if we forget to do
so.

Write faults without VM_MAYWRITE don't make any sense, and our
maybe_mkwrite() logic could have hidden such abuse for now.

Write faults without VM_WRITE on something that is not a COW mapping is
similarly broken, and e.g., do_wp_page() could end up placing an
anonymous page into a shared mapping, which would be bad.

This is a preparation for reliable R/O long-term pinning of pages in
private mappings, whereby we want to make sure that we will never break
COW in a read-only private mapping.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index e014435a87db..c4fa378ec2a0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -5170,6 +5170,14 @@ static vm_fault_t sanitize_fault_flags(struct vm_area_struct *vma,
 		 */
 		if (!is_cow_mapping(vma->vm_flags))
 			*flags &= ~FAULT_FLAG_UNSHARE;
+	} else if (*flags & FAULT_FLAG_WRITE) {
+		/* Write faults on read-only mappings are impossible ... */
+		if (WARN_ON_ONCE(!(vma->vm_flags & VM_MAYWRITE)))
+			return VM_FAULT_SIGSEGV;
+		/* ... and FOLL_FORCE only applies to COW mappings. */
+		if (WARN_ON_ONCE(!(vma->vm_flags & VM_WRITE) &&
+				 !is_cow_mapping(vma->vm_flags)))
+			return VM_FAULT_SIGSEGV;
 	}
 	return 0;
 }
-- 
2.38.1
