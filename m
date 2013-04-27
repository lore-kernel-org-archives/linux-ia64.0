From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 27 Apr 2013 18:20:31 +0000
Subject: [PATCH -next] ia64, metag: Do not export min_low_pfn in arch-specific code
Message-Id: <1367086831-10740-1-git-send-email-geert@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sanjay Lal <sanjayl@kymasys.com>, Ralf Baechle <ralf@linux-mips.org>
Cc: kvm@vger.kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, James Hogan <james.hogan@imgtec.com>, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

As of commit 787dcbe6984b3638e94f60d807dcb51bb8a07211 ("MIPS: Export
symbols used by KVM/MIPS module"), min_low_pfn is already exported by
the generic mm/bootmem.c, causing:

WARNING: vmlinux: 'min_low_pfn' exported twice. Previous export was in vmlinux

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/ia64/kernel/ia64_ksyms.c   |    1 -
 arch/metag/kernel/metag_ksyms.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index 5b7791d..ca95c8b 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -25,7 +25,6 @@ EXPORT_SYMBOL(copy_page);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 #include <linux/bootmem.h>
-EXPORT_SYMBOL(min_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 #endif
 
diff --git a/arch/metag/kernel/metag_ksyms.c b/arch/metag/kernel/metag_ksyms.c
index ec872ef..08e9b6f 100644
--- a/arch/metag/kernel/metag_ksyms.c
+++ b/arch/metag/kernel/metag_ksyms.c
@@ -12,7 +12,6 @@ EXPORT_SYMBOL(copy_page);
 #ifdef CONFIG_FLATMEM
 /* needed for the pfn_valid macro */
 EXPORT_SYMBOL(max_pfn);
-EXPORT_SYMBOL(min_low_pfn);
 #endif
 
 /* TBI symbols */
-- 
1.7.0.4

