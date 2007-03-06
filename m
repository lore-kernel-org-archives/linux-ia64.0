From: Bernhard Walle <bwalle@suse.de>
Date: Tue, 06 Mar 2007 18:07:32 +0000
Subject: [PATCH] saved_max_pfn too small on a specific machine
Message-Id: <20070306180732.GA3151@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I has a problem with the patch "Make saved_max_pfn point to max_pfn of
entire system":

On a HP rx8640 system with following memory map, the saved_max_pfn was wrong,
i.e. there was memory in /proc/iomem marked as "System RAM" but above
saved_max_pfn. This patch fixes the problem.

If you have a better solution, please give me some hints. Thanks!

Memory map:

mem00: type=7, attr=0x8, range=[0x0000000000000000-0x0000000004000000) (64MB)
mem01: type=2, attr=0x8, range=[0x0000000004000000-0x0000000004c92000) (12MB)
mem02: type=7, attr=0x8, range=[0x0000000004c92000-0x000000003fffc000) (947MB)
mem03: type=6, attr=0x8000000000000008, range=[0x000000003fffc000-0x000000003fffe000) (0MB)
mem04: type=0, attr=0x8000000000000008, range=[0x000000003fffe000-0x0000000040000000) (0MB)
mem05: type, attr=0x8000000000000001, range=[0x00000000fed00000-0x00000000fed80000) (0MB)
mem06: type, attr=0x8000000000000001, range=[0x00000000fee00000-0x00000000fef00000) (1MB)
mem07: type, attr=0x8000000000000001, range=[0x00000000ff000000-0x0000000100000000) (16MB)
mem08: type=7, attr=0x8, range=[0x0000000100000000-0x0000000400000000) (12288MB)
mem09: type=7, attr=0x8, range=[0x0000004040000000-0x0000004100000000) (3072MB)
mem10: type=7, attr=0x8, range=[0x0000078400000000-0x00000787fa96a000) (16297MB)
mem11: type=2, attr=0x8, range=[0x00000787fa96a000-0x00000787fada0000) (4MB)
mem12: type=7, attr=0x8, range=[0x00000787fada0000-0x00000787fada1000) (0MB)
mem13: type=1, attr=0x8, range=[0x00000787fada1000-0x00000787fae00000) (0MB)
mem14: type=7, attr=0x8, range=[0x00000787fae00000-0x00000787fb39e000) (5MB)
mem15: type=4, attr=0x8, range=[0x00000787fb39e000-0x00000787fb3a0000) (0MB)
mem16: type=7, attr=0x8, range=[0x00000787fb3a0000-0x00000787fb3a2000) (0MB)
mem17: type=4, attr=0x8, range=[0x00000787fb3a2000-0x00000787fb3a8000) (0MB)
mem18: type=7, attr=0x8, range=[0x00000787fb3a8000-0x00000787fb3aa000) (0MB)
mem19: type=4, attr=0x8, range=[0x00000787fb3aa000-0x00000787fb800000) (4MB)
mem20: type=7, attr=0x8, range=[0x00000787fb800000-0x00000787fbb3c000) (3MB)
mem21: type=3, attr=0x8, range=[0x00000787fbb3c000-0x00000787fbba2000) (0MB)
mem22: type=5, attr=0x8000000000000008, range=[0x00000787fbba2000-0x00000787fbc80000) (0MB)
mem23: type=7, attr=0x8, range=[0x00000787fbc80000-0x00000787fbde8000) (1MB)
mem24: type=6, attr=0x8000000000000008, range=[0x00000787fbde8000-0x00000787fbe00000) (0MB)
mem25: type, attr=0x8000000000000008, range=[0x00000787fc000000-0x00000787fc400000) (4MB)
mem26: type=5, attr=0x8000000000000008, range=[0x00000787fc400000-0x00000787fd640000) (18MB)
mem27: type=0, attr=0x8000000000000008, range=[0x00000787fd640000-0x00000787ffc20000) (37MB)
mem28: type=5, attr=0x8000000000000008, range=[0x00000787ffc20000-0x0000078800000000) (3MB)
mem29: type, attr=0x3, range=[0x00000f0100000000-0x00000f017ee00000) (2030MB)
mem30: type, attr=0x3, range=[0x00000f0180000000-0x00000f01fee00000) (2030MB)
mem31: type, attr=0x3, range=[0x00000f1100000000-0x00000f117ee00000) (2030MB)
mem32: type, attr=0x3, range=[0x00000f2100000000-0x00000f217ee00000) (2030MB)
mem33: type, attr=0x3, range=[0x00000f3100000000-0x00000f317ee00000) (2030MB)
mem34: type, attr=0x3, range=[0x00000f4100000000-0x00000f417ee00000) (2030MB)
mem35: type, attr=0x3, range=[0x00000f5100000000-0x00000f517ee00000) (2030MB)
mem36: type, attr=0x3, range=[0x00000f6100000000-0x00000f617ee00000) (2030MB)
mem37: type, attr=0x3, range=[0x00000f7100000000-0x00000f717ee00000) (2030MB)
mem38: type, attr=0x8000000000000001, range=[0x00000f8100000000-0x00000f8104000000) (64MB)
mem39: type, attr=0x1, range=[0x00000f8110000000-0x00000f8110001000) (0MB)
mem40: type, attr=0x1, range=[0x00000f8110002000-0x00000f8110003000) (0MB)
mem41: type, attr=0x1, range=[0x00000f8110004000-0x00000f8110005000) (0MB)
mem42: type, attr=0x1, range=[0x00000f8110008000-0x00000f8110009000) (0MB)
mem43: type, attr=0x1, range=[0x00000f811000c000-0x00000f811000d000) (0MB)
mem44: type, attr=0x1, range=[0x00000f8110010000-0x00000f8110011000) (0MB)
mem45: type, attr=0x1, range=[0x00000f8110014000-0x00000f8110015000) (0MB)
mem46: type, attr=0x1, range=[0x00000f8110018000-0x00000f8110019000) (0MB)
mem47: type, attr=0x1, range=[0x00000f811001c000-0x00000f811001d000) (0MB)
mem48: type, attr=0x1, range=[0x00000f8120000000-0x00000f8120008000) (0MB)
mem49: type, attr=0x8000000000000001, range=[0x00000ffc00000000-0x00000ffc70800000) (1800MB)
mem50: type, attr=0x1, range=[0x00000ffc70800000-0x00000ffdf0800000) (6144MB)
mem51: type, attr=0x8000000000000001, range=[0x00000ffff6000000-0x00000ffff6800000) (8MB)
mem52: type, attr=0x8000000000000001, range=[0x00000ffffc000000-0x00000ffffc800000) (8MB)


Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 arch/ia64/kernel/efi.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.16-SLES10_SP1_BRANCH/arch/ia64/kernel/efi.c
=================================--- linux-2.6.16-SLES10_SP1_BRANCH.orig/arch/ia64/kernel/efi.c
+++ linux-2.6.16-SLES10_SP1_BRANCH/arch/ia64/kernel/efi.c
@@ -959,8 +959,8 @@ efi_memmap_init(unsigned long *s, unsign
 
 #ifdef CONFIG_CRASH_DUMP
 		/* saved_max_pfn should ignore max_addr= command line arg */ 
-		if (saved_max_pfn < (ae >> PAGE_SHIFT))
-			saved_max_pfn = (ae >> PAGE_SHIFT);
+		if (saved_max_pfn < (efi_md_end(md) >> PAGE_SHIFT))
+			saved_max_pfn = (efi_md_end(md) >> PAGE_SHIFT);
 #endif
 		/* keep within max_addr= and min_addr= command line arg */
 		as = max(as, min_addr);

