From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Tue, 23 Jul 2019 11:32:52 +0000
Subject: [PATCH] ia64: remove unneeded uapi asm-generic wrappers
Message-Id: <20190723113252.14900-1-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kernel@vger.kernel.org

These are listed in include/uapi/asm-generic/Kbuild, so Kbuild will
automatically generate them.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 arch/ia64/include/uapi/asm/errno.h  | 2 --
 arch/ia64/include/uapi/asm/ioctl.h  | 2 --
 arch/ia64/include/uapi/asm/ioctls.h | 7 -------
 3 files changed, 11 deletions(-)
 delete mode 100644 arch/ia64/include/uapi/asm/errno.h
 delete mode 100644 arch/ia64/include/uapi/asm/ioctl.h
 delete mode 100644 arch/ia64/include/uapi/asm/ioctls.h

diff --git a/arch/ia64/include/uapi/asm/errno.h b/arch/ia64/include/uapi/asm/errno.h
deleted file mode 100644
index 9addba592646..000000000000
--- a/arch/ia64/include/uapi/asm/errno.h
+++ /dev/null
@@ -1,2 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#include <asm-generic/errno.h>
diff --git a/arch/ia64/include/uapi/asm/ioctl.h b/arch/ia64/include/uapi/asm/ioctl.h
deleted file mode 100644
index b809c4566e5f..000000000000
--- a/arch/ia64/include/uapi/asm/ioctl.h
+++ /dev/null
@@ -1,2 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#include <asm-generic/ioctl.h>
diff --git a/arch/ia64/include/uapi/asm/ioctls.h b/arch/ia64/include/uapi/asm/ioctls.h
deleted file mode 100644
index b86001940209..000000000000
--- a/arch/ia64/include/uapi/asm/ioctls.h
+++ /dev/null
@@ -1,7 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef _ASM_IA64_IOCTLS_H
-#define _ASM_IA64_IOCTLS_H
-
-#include <asm-generic/ioctls.h>
-
-#endif /* _ASM_IA64_IOCTLS_H */
-- 
2.17.1
