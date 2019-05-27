From: David Hildenbrand <david@redhat.com>
Date: Mon, 27 May 2019 11:11:43 +0000
Subject: [PATCH v3 02/11] s390x/mm: Fail when an altmap is used for arch_add_memory()
Message-Id: <20190527111152.16324-3-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Oscar Salvador <osalvador@suse.com>, linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Vasily Gorbik <gor@linux.ibm.com>, linux-sh@vger.kernel.org, David Hildenbrand <david@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org

ZONE_DEVICE is not yet supported, fail if an altmap is passed, so we
don't forget arch_add_memory()/arch_remove_memory() when unlocking
support.

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.com>
Suggested-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/s390/mm/init.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 14d1eae9fe43..d552e330fbcc 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -226,6 +226,9 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	if (WARN_ON_ONCE(restrictions->altmap))
+		return -EINVAL;
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
-- 
2.20.1
