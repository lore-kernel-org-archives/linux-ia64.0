From: Joe Perches <joe@perches.com>
Date: Fri, 05 Nov 2010 03:07:25 +0000
Subject: [PATCH 01/49] arch/ia64: Use vzalloc
Message-Id: <6c301491890dd0892a7e1a93bf1495f2131413f9.1288925424.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <trivial@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/perfmon.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 39e534f..3aee09d 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -829,10 +829,9 @@ pfm_rvmalloc(unsigned long size)
 	unsigned long addr;
 
 	size = PAGE_ALIGN(size);
-	mem  = vmalloc(size);
+	mem  = vzalloc(size);
 	if (mem) {
 		//printk("perfmon: CPU%d pfm_rvmalloc(%ld)=%p\n", smp_processor_id(), size, mem);
-		memset(mem, 0, size);
 		addr = (unsigned long)mem;
 		while (size > 0) {
 			pfm_reserve_page(addr);
-- 
1.7.3.1.g432b3.dirty

