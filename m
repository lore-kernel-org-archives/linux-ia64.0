From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 21 Sep 2006 05:01:04 +0000
Subject: [Patch] Kexec-tools: Fix physcal address value in vmcore ELF
Message-Id: <1158814864.2718.17.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I used fixed 64M as physical offset in vmcore ELF segment header.
This gives trouble to crash utility to analyze vmcore on platform that
load kernel to a different address.

This patch will fix it.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c kexec-tools-1.101-fix/kexec/arch/ia64/crashdump-ia64.c
--- kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c	2006-09-20 15:29:29.000000000 +0800
+++ kexec-tools-1.101-fix/kexec/arch/ia64/crashdump-ia64.c	2006-09-20 15:32:27.000000000 +0800
@@ -28,7 +28,7 @@
 #include "crashdump-ia64.h"
 
 int memory_ranges = 0;
-#define LOAD_OFFSET 	(0xa000000000000000UL + 0x100000000UL - (1UL<<26))
+#define LOAD_OFFSET 	(0xa000000000000000UL + 0x100000000UL - kernel_code_start)
 #define MAX_LINE        160
 /* Stores a sorted list of RAM memory ranges for which to create elf headers.
  * A separate program header is created for backup region */

