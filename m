From: Wupeng Ma <mawupeng1@huawei.com>
Date: Sat, 26 Mar 2022 06:46:31 +0000
Subject: [PATCH 8/9] efi: Disable mirror feature if kernelcore is not specified
Message-Id: <20220326064632.131637-9-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326064632.131637-1-mawupeng1@huawei.com>
In-Reply-To: <20220326064632.131637-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zyccr.com, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

With this patch, kernel will check mirrored_kernelcore before calling
efi_find_mirror() which will enable basic mirrored feature.

If system have some mirrored memory and mirrored feature is not specified
in boot parameter, the basic mirrored feature will be enabled and this will
lead to the following situations:

- memblock memory allocation perfers mirrored region. This may have some
  unexpected influence on numa affinity.

- contiguous memory will be splited into several parts if parts of them
  is mirrored memory via memblock_mark_mirror().

Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
---
 drivers/firmware/efi/efi.c | 3 +++
 include/linux/mm.h         | 2 ++
 mm/page_alloc.c            | 2 +-
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index eb9ebf4efea1..18d86602424a 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -446,6 +446,9 @@ void __init efi_find_mirror(void)
 	if (!efi_enabled(EFI_MEMMAP))
 		return;
 
+	if (!mirrored_kernelcore)
+		return;
+
 	for_each_efi_memory_desc(md) {
 		unsigned long long start = md->phys_addr;
 		unsigned long long size = md->num_pages << EFI_PAGE_SHIFT;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7a3dd7e617e4..4e266e03674d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2541,6 +2541,8 @@ extern void get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn);
 extern unsigned long find_min_pfn_with_active_regions(void);
 
+extern bool mirrored_kernelcore;
+
 #ifndef CONFIG_NUMA
 static inline int early_pfn_to_nid(unsigned long pfn)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 41fd987b5b93..61af9e235e43 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -355,7 +355,7 @@ static unsigned long required_kernelcore_percent __initdata;
 static unsigned long required_movablecore __initdata;
 static unsigned long required_movablecore_percent __initdata;
 static unsigned long zone_movable_pfn[MAX_NUMNODES] __initdata;
-static bool mirrored_kernelcore __meminitdata;
+bool mirrored_kernelcore __meminitdata;
 
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
 int movable_zone;
-- 
2.18.0.huawei.25
