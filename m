From: Andrew Morton <akpm@osdl.org>
Date: Fri, 22 Oct 2004 08:53:42 +0000
Subject: ia64 get_fs() build fix
Message-Id: <20041022015342.2add97ee.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Not sure how I managed to do this, but...


In file included from arch/ia64/ia32/binfmt_elf32.c:22:
arch/ia64/ia32/elfcore32.h: In function `elf_core_copy_task_fpregs':            arch/ia64/ia32/elfcore32.h:111: warning: implicit declaration of function `get_fs'                                                                              arch/ia64/ia32/elfcore32.h:111: error: incompatible types in assignment
arch/ia64/ia32/elfcore32.h:112: warning: implicit declaration of function `set_fs'
arch/ia64/ia32/elfcore32.h:112: error: `KERNEL_DS' undeclared (first use in this function)
arch/ia64/ia32/elfcore32.h:112: error: (Each undeclared identifier is reported only once
arch/ia64/ia32/elfcore32.h:112: error: for each function it appears in.)        arch/ia64/ia32/elfcore32.h: In function `elf_core_copy_task_xfpregs':
arch/ia64/ia32/elfcore32.h:129: error: incompatible types in assignment         arch/ia64/ia32/elfcore32.h:130: error: `KERNEL_DS' undeclared (first use in this function)

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/ia64/ia32/elfcore32.h |    1 +
 1 files changed, 1 insertion(+)

diff -puN arch/ia64/ia32/elfcore32.h~ia64-get_fs-build-fix arch/ia64/ia32/elfcore32.h
--- 25/arch/ia64/ia32/elfcore32.h~ia64-get_fs-build-fix	Fri Oct 22 16:42:20 2004
+++ 25-akpm/arch/ia64/ia32/elfcore32.h	Fri Oct 22 16:42:35 2004
@@ -9,6 +9,7 @@
 #define _ELFCORE32_H_
 
 #include <asm/intrinsics.h>
+#include <asm/uaccess.h>
 
 #define USE_ELF_CORE_DUMP 1
 
_

