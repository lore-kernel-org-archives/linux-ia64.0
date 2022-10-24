From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 24 Oct 2022 11:30:00 +0000
Subject: [PATCH 5.15 256/530] ia64: export memory_add_physaddr_to_nid to fix cxl build error
Message-Id: <20221024113056.660776851@linuxfoundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221024113044.976326639@linuxfoundation.org>
In-Reply-To: <20221024113044.976326639@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, kernel test robot <lkp@intel.com>, Randy Dunlap <rdunlap@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Ben Widawsky <bwidawsk@kernel.org>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Keith Mannthey <kmannth@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sashal@kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

[ Upstream commit 97c318bfbe84efded246e80428054f300042f110 ]

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
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/ia64/mm/numa.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index d6579ec3ea32..4c7b1f50e3b7 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -75,5 +75,6 @@ int memory_add_physaddr_to_nid(u64 addr)
 		return 0;
 	return nid;
 }
+EXPORT_SYMBOL(memory_add_physaddr_to_nid);
 #endif
 #endif
-- 
2.35.1


