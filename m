From: Tiezhu Yang <yangtiezhu@loongson.cn>
Date: Tue, 09 May 2023 07:05:03 +0000
Subject: [RFC PATCH] asm-generic: Unify uapi bitsperlong.h
Message-Id: <1683615903-10862-1-git-send-email-yangtiezhu@loongson.cn>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, bpf@vger.kernel.org, linux-perf-users@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org, loongson-kernel@lists.loongnix.cn

Now we specify the minimal version of GCC as 5.1 and Clang/LLVM as 11.0.0
in Documentation/process/changes.rst, __CHAR_BIT__ and __SIZEOF_LONG__ are
usable, just define __BITS_PER_LONG as (__CHAR_BIT__ * __SIZEOF_LONG__) in
asm-generic uapi bitsperlong.h, simpler, works everywhere.

Remove all the arch specific uapi bitsperlong.h which will be generated as
arch/*/include/generated/uapi/asm/bitsperlong.h.

Suggested-by: Xi Ruoyao <xry111@xry111.site>
Link: https://lore.kernel.org/all/d3e255e4746de44c9903c4433616d44ffcf18d1b.camel@xry111.site/
Signed-off-by: Tiezhu Yang <yangtiezhu@loongson.cn>
---

This is based on 6.4-rc1

 arch/alpha/include/uapi/asm/bitsperlong.h          |  9 --------
 arch/arm64/include/uapi/asm/bitsperlong.h          | 24 -------------------
 arch/ia64/include/uapi/asm/bitsperlong.h           |  9 --------
 arch/loongarch/include/uapi/asm/bitsperlong.h      |  9 --------
 arch/mips/include/uapi/asm/bitsperlong.h           |  9 --------
 arch/parisc/include/uapi/asm/bitsperlong.h         | 13 -----------
 arch/powerpc/include/uapi/asm/bitsperlong.h        | 13 -----------
 arch/riscv/include/uapi/asm/bitsperlong.h          | 14 -----------
 arch/s390/include/uapi/asm/bitsperlong.h           | 14 -----------
 arch/sparc/include/uapi/asm/bitsperlong.h          | 14 -----------
 arch/x86/include/uapi/asm/bitsperlong.h            | 14 -----------
 include/uapi/asm-generic/bitsperlong.h             | 11 +--------
 tools/arch/alpha/include/uapi/asm/bitsperlong.h    |  9 --------
 tools/arch/arm64/include/uapi/asm/bitsperlong.h    | 24 -------------------
 tools/arch/hexagon/include/uapi/asm/bitsperlong.h  | 27 ----------------------
 tools/arch/ia64/include/uapi/asm/bitsperlong.h     |  9 --------
 .../arch/loongarch/include/uapi/asm/bitsperlong.h  |  9 --------
 .../arch/microblaze/include/uapi/asm/bitsperlong.h |  2 --
 tools/arch/mips/include/uapi/asm/bitsperlong.h     |  9 --------
 tools/arch/parisc/include/uapi/asm/bitsperlong.h   | 15 ------------
 tools/arch/powerpc/include/uapi/asm/bitsperlong.h  | 13 -----------
 tools/arch/riscv/include/uapi/asm/bitsperlong.h    | 14 -----------
 tools/arch/s390/include/uapi/asm/bitsperlong.h     | 13 -----------
 tools/arch/sparc/include/uapi/asm/bitsperlong.h    | 13 -----------
 tools/arch/x86/include/uapi/asm/bitsperlong.h      | 13 -----------
 tools/include/uapi/asm-generic/bitsperlong.h       | 12 ++--------
 tools/include/uapi/asm/bitsperlong.h               | 24 -------------------
 27 files changed, 3 insertions(+), 356 deletions(-)
 delete mode 100644 arch/alpha/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/arm64/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/ia64/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/loongarch/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/mips/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/parisc/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/powerpc/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/riscv/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/s390/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/sparc/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/x86/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/alpha/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/arm64/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/hexagon/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/ia64/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/loongarch/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/microblaze/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/mips/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/parisc/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/powerpc/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/riscv/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/s390/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/sparc/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/arch/x86/include/uapi/asm/bitsperlong.h
 delete mode 100644 tools/include/uapi/asm/bitsperlong.h

diff --git a/arch/alpha/include/uapi/asm/bitsperlong.h b/arch/alpha/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 6c5bf7d..0000000
--- a/arch/alpha/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_ALPHA_BITSPERLONG_H
-#define __ASM_ALPHA_BITSPERLONG_H
-
-#define __BITS_PER_LONG 64
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_ALPHA_BITSPERLONG_H */
diff --git a/arch/arm64/include/uapi/asm/bitsperlong.h b/arch/arm64/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 485d60be..0000000
--- a/arch/arm64/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,24 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-/*
- * Copyright (C) 2012 ARM Ltd.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program.  If not, see <http://www.gnu.org/licenses/>.
- */
-#ifndef __ASM_BITSPERLONG_H
-#define __ASM_BITSPERLONG_H
-
-#define __BITS_PER_LONG 64
-
-#include <asm-generic/bitsperlong.h>
-
-#endif	/* __ASM_BITSPERLONG_H */
diff --git a/arch/ia64/include/uapi/asm/bitsperlong.h b/arch/ia64/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 1146d55..0000000
--- a/arch/ia64/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_IA64_BITSPERLONG_H
-#define __ASM_IA64_BITSPERLONG_H
-
-#define __BITS_PER_LONG 64
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_IA64_BITSPERLONG_H */
diff --git a/arch/loongarch/include/uapi/asm/bitsperlong.h b/arch/loongarch/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 00b4ba1..0000000
--- a/arch/loongarch/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_LOONGARCH_BITSPERLONG_H
-#define __ASM_LOONGARCH_BITSPERLONG_H
-
-#define __BITS_PER_LONG (__SIZEOF_LONG__ * 8)
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_LOONGARCH_BITSPERLONG_H */
diff --git a/arch/mips/include/uapi/asm/bitsperlong.h b/arch/mips/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 7268380d..0000000
--- a/arch/mips/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_MIPS_BITSPERLONG_H
-#define __ASM_MIPS_BITSPERLONG_H
-
-#define __BITS_PER_LONG _MIPS_SZLONG
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_MIPS_BITSPERLONG_H */
diff --git a/arch/parisc/include/uapi/asm/bitsperlong.h b/arch/parisc/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 307e2ef..0000000
--- a/arch/parisc/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,13 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_PARISC_BITSPERLONG_H
-#define __ASM_PARISC_BITSPERLONG_H
-
-#if defined(__LP64__)
-#define __BITS_PER_LONG 64
-#else
-#define __BITS_PER_LONG 32
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_PARISC_BITSPERLONG_H */
diff --git a/arch/powerpc/include/uapi/asm/bitsperlong.h b/arch/powerpc/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 46ece3e..0000000
--- a/arch/powerpc/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,13 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_POWERPC_BITSPERLONG_H
-#define __ASM_POWERPC_BITSPERLONG_H
-
-#if defined(__powerpc64__)
-# define __BITS_PER_LONG 64
-#else
-# define __BITS_PER_LONG 32
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_POWERPC_BITSPERLONG_H */
diff --git a/arch/riscv/include/uapi/asm/bitsperlong.h b/arch/riscv/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 7d0b32e..0000000
--- a/arch/riscv/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,14 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0-only WITH Linux-syscall-note */
-/*
- * Copyright (C) 2012 ARM Ltd.
- * Copyright (C) 2015 Regents of the University of California
- */
-
-#ifndef _UAPI_ASM_RISCV_BITSPERLONG_H
-#define _UAPI_ASM_RISCV_BITSPERLONG_H
-
-#define __BITS_PER_LONG (__SIZEOF_POINTER__ * 8)
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* _UAPI_ASM_RISCV_BITSPERLONG_H */
diff --git a/arch/s390/include/uapi/asm/bitsperlong.h b/arch/s390/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index cceaf47..0000000
--- a/arch/s390/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,14 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_S390_BITSPERLONG_H
-#define __ASM_S390_BITSPERLONG_H
-
-#ifndef __s390x__
-#define __BITS_PER_LONG 32
-#else
-#define __BITS_PER_LONG 64
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_S390_BITSPERLONG_H */
-
diff --git a/arch/sparc/include/uapi/asm/bitsperlong.h b/arch/sparc/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index cd9a432..0000000
--- a/arch/sparc/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,14 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_ALPHA_BITSPERLONG_H
-#define __ASM_ALPHA_BITSPERLONG_H
-
-#if defined(__sparc__) && defined(__arch64__)
-#define __BITS_PER_LONG 64
-#else
-#define __BITS_PER_LONG 32
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_ALPHA_BITSPERLONG_H */
-
diff --git a/arch/x86/include/uapi/asm/bitsperlong.h b/arch/x86/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 5d72c845..0000000
--- a/arch/x86/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,14 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_X86_BITSPERLONG_H
-#define __ASM_X86_BITSPERLONG_H
-
-#if defined(__x86_64__) && !defined(__ILP32__)
-# define __BITS_PER_LONG 64
-#else
-# define __BITS_PER_LONG 32
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_X86_BITSPERLONG_H */
-
diff --git a/include/uapi/asm-generic/bitsperlong.h b/include/uapi/asm-generic/bitsperlong.h
index 693d9a4..a230ba3 100644
--- a/include/uapi/asm-generic/bitsperlong.h
+++ b/include/uapi/asm-generic/bitsperlong.h
@@ -2,15 +2,6 @@
 #ifndef _UAPI__ASM_GENERIC_BITS_PER_LONG
 #define _UAPI__ASM_GENERIC_BITS_PER_LONG
 
-/*
- * There seems to be no way of detecting this automatically from user
- * space, so 64 bit architectures should override this in their
- * bitsperlong.h. In particular, an architecture that supports
- * both 32 and 64 bit user space must not rely on CONFIG_64BIT
- * to decide it, but rather check a compiler provided macro.
- */
-#ifndef __BITS_PER_LONG
-#define __BITS_PER_LONG 32
-#endif
+#define __BITS_PER_LONG (__CHAR_BIT__ * __SIZEOF_LONG__)
 
 #endif /* _UAPI__ASM_GENERIC_BITS_PER_LONG */
diff --git a/tools/arch/alpha/include/uapi/asm/bitsperlong.h b/tools/arch/alpha/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 6c5bf7d..0000000
--- a/tools/arch/alpha/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_ALPHA_BITSPERLONG_H
-#define __ASM_ALPHA_BITSPERLONG_H
-
-#define __BITS_PER_LONG 64
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_ALPHA_BITSPERLONG_H */
diff --git a/tools/arch/arm64/include/uapi/asm/bitsperlong.h b/tools/arch/arm64/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 485d60be..0000000
--- a/tools/arch/arm64/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,24 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-/*
- * Copyright (C) 2012 ARM Ltd.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program.  If not, see <http://www.gnu.org/licenses/>.
- */
-#ifndef __ASM_BITSPERLONG_H
-#define __ASM_BITSPERLONG_H
-
-#define __BITS_PER_LONG 64
-
-#include <asm-generic/bitsperlong.h>
-
-#endif	/* __ASM_BITSPERLONG_H */
diff --git a/tools/arch/hexagon/include/uapi/asm/bitsperlong.h b/tools/arch/hexagon/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 5adca0d..0000000
--- a/tools/arch/hexagon/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,27 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-/*
- * Copyright (c) 2010-2011, The Linux Foundation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 and
- * only version 2 as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA.
- */
-
-#ifndef __ASM_HEXAGON_BITSPERLONG_H
-#define __ASM_HEXAGON_BITSPERLONG_H
-
-#define __BITS_PER_LONG 32
-
-#include <asm-generic/bitsperlong.h>
-
-#endif
diff --git a/tools/arch/ia64/include/uapi/asm/bitsperlong.h b/tools/arch/ia64/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 1146d55..0000000
--- a/tools/arch/ia64/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_IA64_BITSPERLONG_H
-#define __ASM_IA64_BITSPERLONG_H
-
-#define __BITS_PER_LONG 64
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_IA64_BITSPERLONG_H */
diff --git a/tools/arch/loongarch/include/uapi/asm/bitsperlong.h b/tools/arch/loongarch/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 00b4ba1..0000000
--- a/tools/arch/loongarch/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_LOONGARCH_BITSPERLONG_H
-#define __ASM_LOONGARCH_BITSPERLONG_H
-
-#define __BITS_PER_LONG (__SIZEOF_LONG__ * 8)
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_LOONGARCH_BITSPERLONG_H */
diff --git a/tools/arch/microblaze/include/uapi/asm/bitsperlong.h b/tools/arch/microblaze/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 76da34b..0000000
--- a/tools/arch/microblaze/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,2 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#include <asm-generic/bitsperlong.h>
diff --git a/tools/arch/mips/include/uapi/asm/bitsperlong.h b/tools/arch/mips/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 7268380d..0000000
--- a/tools/arch/mips/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,9 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_MIPS_BITSPERLONG_H
-#define __ASM_MIPS_BITSPERLONG_H
-
-#define __BITS_PER_LONG _MIPS_SZLONG
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_MIPS_BITSPERLONG_H */
diff --git a/tools/arch/parisc/include/uapi/asm/bitsperlong.h b/tools/arch/parisc/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 23ac756..0000000
--- a/tools/arch/parisc/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_PARISC_BITSPERLONG_H
-#define __ASM_PARISC_BITSPERLONG_H
-
-#if defined(__LP64__)
-#define __BITS_PER_LONG 64
-#define SHIFT_PER_LONG 6
-#else
-#define __BITS_PER_LONG 32
-#define SHIFT_PER_LONG 5
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_PARISC_BITSPERLONG_H */
diff --git a/tools/arch/powerpc/include/uapi/asm/bitsperlong.h b/tools/arch/powerpc/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 46ece3e..0000000
--- a/tools/arch/powerpc/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,13 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_POWERPC_BITSPERLONG_H
-#define __ASM_POWERPC_BITSPERLONG_H
-
-#if defined(__powerpc64__)
-# define __BITS_PER_LONG 64
-#else
-# define __BITS_PER_LONG 32
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_POWERPC_BITSPERLONG_H */
diff --git a/tools/arch/riscv/include/uapi/asm/bitsperlong.h b/tools/arch/riscv/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 0b9b58b..0000000
--- a/tools/arch/riscv/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,14 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0-only */
-/*
- * Copyright (C) 2012 ARM Ltd.
- * Copyright (C) 2015 Regents of the University of California
- */
-
-#ifndef _UAPI_ASM_RISCV_BITSPERLONG_H
-#define _UAPI_ASM_RISCV_BITSPERLONG_H
-
-#define __BITS_PER_LONG (__SIZEOF_POINTER__ * 8)
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* _UAPI_ASM_RISCV_BITSPERLONG_H */
diff --git a/tools/arch/s390/include/uapi/asm/bitsperlong.h b/tools/arch/s390/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index d2bb620..0000000
--- a/tools/arch/s390/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,13 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_S390_BITSPERLONG_H
-#define __ASM_S390_BITSPERLONG_H
-
-#ifndef __s390x__
-#define __BITS_PER_LONG 32
-#else
-#define __BITS_PER_LONG 64
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_S390_BITSPERLONG_H */
diff --git a/tools/arch/sparc/include/uapi/asm/bitsperlong.h b/tools/arch/sparc/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index 3b4e617..0000000
--- a/tools/arch/sparc/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,13 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_ALPHA_BITSPERLONG_H
-#define __ASM_ALPHA_BITSPERLONG_H
-
-#if defined(__sparc__) && defined(__arch64__)
-#define __BITS_PER_LONG 64
-#else
-#define __BITS_PER_LONG 32
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_ALPHA_BITSPERLONG_H */
diff --git a/tools/arch/x86/include/uapi/asm/bitsperlong.h b/tools/arch/x86/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index f8a92e0..0000000
--- a/tools/arch/x86/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,13 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
-#ifndef __ASM_X86_BITSPERLONG_H
-#define __ASM_X86_BITSPERLONG_H
-
-#if defined(__x86_64__) && !defined(__ILP32__)
-# define __BITS_PER_LONG 64
-#else
-# define __BITS_PER_LONG 32
-#endif
-
-#include <asm-generic/bitsperlong.h>
-
-#endif /* __ASM_X86_BITSPERLONG_H */
diff --git a/tools/include/uapi/asm-generic/bitsperlong.h b/tools/include/uapi/asm-generic/bitsperlong.h
index 23e6c41..a230ba3 100644
--- a/tools/include/uapi/asm-generic/bitsperlong.h
+++ b/tools/include/uapi/asm-generic/bitsperlong.h
@@ -1,15 +1,7 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 #ifndef _UAPI__ASM_GENERIC_BITS_PER_LONG
 #define _UAPI__ASM_GENERIC_BITS_PER_LONG
 
-/*
- * There seems to be no way of detecting this automatically from user
- * space, so 64 bit architectures should override this in their
- * bitsperlong.h. In particular, an architecture that supports
- * both 32 and 64 bit user space must not rely on CONFIG_64BIT
- * to decide it, but rather check a compiler provided macro.
- */
-#ifndef __BITS_PER_LONG
-#define __BITS_PER_LONG 32
-#endif
+#define __BITS_PER_LONG (__CHAR_BIT__ * __SIZEOF_LONG__)
 
 #endif /* _UAPI__ASM_GENERIC_BITS_PER_LONG */
diff --git a/tools/include/uapi/asm/bitsperlong.h b/tools/include/uapi/asm/bitsperlong.h
deleted file mode 100644
index da52065..0000000
--- a/tools/include/uapi/asm/bitsperlong.h
+++ /dev/null
@@ -1,24 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#if defined(__i386__) || defined(__x86_64__)
-#include "../../../arch/x86/include/uapi/asm/bitsperlong.h"
-#elif defined(__aarch64__)
-#include "../../../arch/arm64/include/uapi/asm/bitsperlong.h"
-#elif defined(__powerpc__)
-#include "../../../arch/powerpc/include/uapi/asm/bitsperlong.h"
-#elif defined(__s390__)
-#include "../../../arch/s390/include/uapi/asm/bitsperlong.h"
-#elif defined(__sparc__)
-#include "../../../arch/sparc/include/uapi/asm/bitsperlong.h"
-#elif defined(__mips__)
-#include "../../../arch/mips/include/uapi/asm/bitsperlong.h"
-#elif defined(__ia64__)
-#include "../../../arch/ia64/include/uapi/asm/bitsperlong.h"
-#elif defined(__riscv)
-#include "../../../arch/riscv/include/uapi/asm/bitsperlong.h"
-#elif defined(__alpha__)
-#include "../../../arch/alpha/include/uapi/asm/bitsperlong.h"
-#elif defined(__loongarch__)
-#include "../../../arch/loongarch/include/uapi/asm/bitsperlong.h"
-#else
-#include <asm-generic/bitsperlong.h>
-#endif
-- 
2.1.0
