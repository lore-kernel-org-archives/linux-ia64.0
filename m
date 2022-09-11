From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 11 Sep 2022 01:26:16 +0000
Subject: [PATCH] ia64: export memory_add_physaddr_to_nid to fix cxl build error
Message-Id: <20220911012616.29948-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, kernel test robot <lkp@intel.com>, Dan Williams <dan.j.williams@intel.com>, Ben Widawsky <bwidawsk@kernel.org>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Keith Mannthey <kmannth@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

cxl_pmem.ko uses memory_add_physaddr_to_nid() but ia64 does not export it,
so this causes a build error:

ERROR: modpost: "memory_add_physaddr_to_nid" [drivers/cxl/cxl_pmem.ko] undefined!

Fix this by exporting that function.

Fixes: 8c2676a5870a ("hot-add-mem x86_64: memory_add_physaddr_to_nid node fixup")
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ben Widawsky <bwidawsk@kernel.org>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: linux-ia64@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Keith Mannthey <kmannth@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Arnd, can you take this in your one-off fixes arch tree, or would
you prefer for Andrew to take it?

 arch/ia64/mm/numa.c |    1 +
 1 file changed, 1 insertion(+)

--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -75,5 +75,6 @@ int memory_add_physaddr_to_nid(u64 addr)
 		return 0;
 	return nid;
 }
+EXPORT_SYMBOL(memory_add_physaddr_to_nid);
 #endif
 #endif
