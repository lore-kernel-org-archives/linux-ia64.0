From: Wupeng Ma <mawupeng1@huawei.com>
Date: Sat, 26 Mar 2022 06:46:32 +0000
Subject: [PATCH 9/9] ia64/efi: Code simplification in efi_init
Message-Id: <20220326064632.131637-10-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326064632.131637-1-mawupeng1@huawei.com>
In-Reply-To: <20220326064632.131637-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zyccr.com, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

Since efi_print_memmap() was made public, print EFI memory map in
efi_init() can be simplified by using efi_print_memmap().

Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
---
 arch/ia64/kernel/efi.c | 37 +------------------------------------
 1 file changed, 1 insertion(+), 36 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 31149e41f9be..4b8209b8797d 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -557,42 +557,7 @@ efi_init (void)
 
 #if EFI_DEBUG
 	/* print EFI memory map: */
-	{
-		efi_memory_desc_t *md;
-		void *p;
-		unsigned int i;
-
-		for (i = 0, p = efi_map_start; p < efi_map_end;
-		     ++i, p += efi_desc_size)
-		{
-			const char *unit;
-			unsigned long size;
-			char buf[64];
-
-			md = p;
-			size = md->num_pages << EFI_PAGE_SHIFT;
-
-			if ((size >> 40) > 0) {
-				size >>= 40;
-				unit = "TB";
-			} else if ((size >> 30) > 0) {
-				size >>= 30;
-				unit = "GB";
-			} else if ((size >> 20) > 0) {
-				size >>= 20;
-				unit = "MB";
-			} else {
-				size >>= 10;
-				unit = "KB";
-			}
-
-			printk("mem%02d: %s "
-			       "range=[0x%016llx-0x%016llx) (%4lu%s)\n",
-			       i, efi_md_typeattr_format(buf, sizeof(buf), md),
-			       md->phys_addr,
-			       md->phys_addr + efi_md_size(md), size, unit);
-		}
-	}
+	efi_print_memmap();
 #endif
 
 	efi_map_pal_code();
-- 
2.18.0.huawei.25
