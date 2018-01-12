From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:21 +0000
Subject: [PATCH 23/34] dma-mapping: provide a generic asm/dma-mapping.h
Message-Id: <20180112084232.2857-24-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

For architectures that just use the generic dma_noop_ops we can provide
a generic version of dma-mapping.h.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 MAINTAINERS                          |  1 +
 arch/m32r/include/asm/Kbuild         |  1 +
 arch/m32r/include/asm/dma-mapping.h  | 17 -----------------
 arch/riscv/include/asm/Kbuild        |  1 +
 arch/riscv/include/asm/dma-mapping.h | 30 ------------------------------
 arch/s390/include/asm/Kbuild         |  1 +
 arch/s390/include/asm/dma-mapping.h  | 17 -----------------
 include/asm-generic/dma-mapping.h    | 10 ++++++++++
 8 files changed, 14 insertions(+), 64 deletions(-)
 delete mode 100644 arch/m32r/include/asm/dma-mapping.h
 delete mode 100644 arch/riscv/include/asm/dma-mapping.h
 delete mode 100644 arch/s390/include/asm/dma-mapping.h
 create mode 100644 include/asm-generic/dma-mapping.h

diff --git a/MAINTAINERS b/MAINTAINERS
index d2cfdcce1db5..234e642e7149 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4338,6 +4338,7 @@ F:	lib/dma-noop.c
 F:	lib/dma-virt.c
 F:	drivers/base/dma-mapping.c
 F:	drivers/base/dma-coherent.c
+F:	include/asm-generic/dma-mapping.h
 F:	include/linux/dma-direct.h
 F:	include/linux/dma-mapping.h
 
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 7e11b125c35e..ca83fda8177b 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -1,5 +1,6 @@
 generic-y += clkdev.h
 generic-y += current.h
+generic-y += dma-mapping.h
 generic-y += exec.h
 generic-y += extable.h
 generic-y += irq_work.h
diff --git a/arch/m32r/include/asm/dma-mapping.h b/arch/m32r/include/asm/dma-mapping.h
deleted file mode 100644
index 8967fb659691..000000000000
--- a/arch/m32r/include/asm/dma-mapping.h
+++ /dev/null
@@ -1,17 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#ifndef _ASM_M32R_DMA_MAPPING_H
-#define _ASM_M32R_DMA_MAPPING_H
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/mm.h>
-#include <linux/scatterlist.h>
-#include <linux/dma-debug.h>
-#include <linux/io.h>
-
-static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
-{
-	return &dma_noop_ops;
-}
-
-#endif /* _ASM_M32R_DMA_MAPPING_H */
diff --git a/arch/riscv/include/asm/Kbuild b/arch/riscv/include/asm/Kbuild
index 970460a0b492..197460ccbf21 100644
--- a/arch/riscv/include/asm/Kbuild
+++ b/arch/riscv/include/asm/Kbuild
@@ -7,6 +7,7 @@ generic-y += device.h
 generic-y += div64.h
 generic-y += dma.h
 generic-y += dma-contiguous.h
+generic-y += dma-mapping.h
 generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += exec.h
diff --git a/arch/riscv/include/asm/dma-mapping.h b/arch/riscv/include/asm/dma-mapping.h
deleted file mode 100644
index 73849e2cc761..000000000000
--- a/arch/riscv/include/asm/dma-mapping.h
+++ /dev/null
@@ -1,30 +0,0 @@
-/*
- * Copyright (C) 2003-2004 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 2012 ARM Ltd.
- * Copyright (C) 2016 SiFive, Inc.
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
-#ifndef __ASM_RISCV_DMA_MAPPING_H
-#define __ASM_RISCV_DMA_MAPPING_H
-
-/* Use ops->dma_mapping_error (if it exists) or assume success */
-// #undef DMA_ERROR_CODE
-
-static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
-{
-	return &dma_noop_ops;
-}
-
-#endif	/* __ASM_RISCV_DMA_MAPPING_H */
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 048450869328..dade72be127b 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -4,6 +4,7 @@ generic-y += cacheflush.h
 generic-y += clkdev.h
 generic-y += device.h
 generic-y += dma-contiguous.h
+generic-y += dma-mapping.h
 generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += export.h
diff --git a/arch/s390/include/asm/dma-mapping.h b/arch/s390/include/asm/dma-mapping.h
deleted file mode 100644
index bdc2455483f6..000000000000
--- a/arch/s390/include/asm/dma-mapping.h
+++ /dev/null
@@ -1,17 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#ifndef _ASM_S390_DMA_MAPPING_H
-#define _ASM_S390_DMA_MAPPING_H
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/mm.h>
-#include <linux/scatterlist.h>
-#include <linux/dma-debug.h>
-#include <linux/io.h>
-
-static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
-{
-	return &dma_noop_ops;
-}
-
-#endif /* _ASM_S390_DMA_MAPPING_H */
diff --git a/include/asm-generic/dma-mapping.h b/include/asm-generic/dma-mapping.h
new file mode 100644
index 000000000000..164031531d85
--- /dev/null
+++ b/include/asm-generic/dma-mapping.h
@@ -0,0 +1,10 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_GENERIC_DMA_MAPPING_H
+#define _ASM_GENERIC_DMA_MAPPING_H
+
+static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
+{
+	return &dma_noop_ops;
+}
+
+#endif /* _ASM_GENERIC_DMA_MAPPING_H */
-- 
2.14.2

