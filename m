From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 17 Jun 2011 08:47:27 +0000
Subject: [PATCH 08/10] ia64: change valid_phys_addr_range's @addr param to phys_addr_t
Message-Id: <201106171047.27809.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
In-Reply-To: <201106171038.25988.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On ia64, this doesn't change anything, because the size of phys_addr_t
is always the same as the size of unsigned long.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
---
 arch/ia64/include/asm/io.h |    2 +-
 arch/ia64/kernel/efi.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index e5a6c35..d9d3848 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -91,7 +91,7 @@ phys_to_virt (unsigned long address)
 
 #define ARCH_HAS_VALID_PHYS_ADDR_RANGE
 extern u64 kern_mem_attribute (unsigned long phys_addr, unsigned long size);
-extern int valid_phys_addr_range (unsigned long addr, size_t count); /* efi.c */
+extern int valid_phys_addr_range (phys_addr_t addr, size_t count); /* efi.c */
 extern int valid_mmap_phys_addr_range (unsigned long pfn, size_t count);
 
 /*
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 6fc03af..b12d2b4 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -869,7 +869,7 @@ kern_mem_attribute (unsigned long phys_addr, unsigned long size)
 EXPORT_SYMBOL(kern_mem_attribute);
 
 int
-valid_phys_addr_range (unsigned long phys_addr, unsigned long size)
+valid_phys_addr_range (phys_addr_t phys_addr, unsigned long size)
 {
 	u64 attr;
 
-- 
1.7.3.4
