From: Wupeng Ma <mawupeng1@huawei.com>
Date: Thu, 14 Apr 2022 09:56:00 +0000
Subject: [PATCH v2 7/9] mm: Calc the right pfn if page size is not 4K
Message-Id: <20220414101314.1250667-8-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220414101314.1250667-1-mawupeng1@huawei.com>
In-Reply-To: <20220414101314.1250667-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zyccr.com, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

Previous 0x100000 is used to check the 4G limit in
find_zone_movable_pfns_for_nodes(). This is right in x86 because
the page size can only be 4K. But 16K and 64K are available in
arm64. So replace it with PHYS_PFN(SZ_4G).

Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e5b4488a0c5..570d0ebf98df 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7870,7 +7870,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 
 			usable_startpfn = memblock_region_memory_base_pfn(r);
 
-			if (usable_startpfn < 0x100000) {
+			if (usable_startpfn < PHYS_PFN(SZ_4G)) {
 				mem_below_4gb_not_mirrored = true;
 				continue;
 			}
-- 
2.18.0.huawei.25
