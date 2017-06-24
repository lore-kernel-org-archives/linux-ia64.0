From: Palmer Dabbelt <palmer@dabbelt.com>
Date: Sat, 24 Jun 2017 01:50:44 +0000
Subject: [PATCH 3/3] arc: kernel/pcibios.c is empty, delete it
Message-Id: <20170624015044.16746-4-palmer@dabbelt.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170624015044.16746-1-palmer@dabbelt.com>
In-Reply-To: <20170624015044.16746-1-palmer@dabbelt.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
---
 arch/arc/kernel/Makefile  | 1 -
 arch/arc/kernel/pcibios.c | 9 ---------
 2 files changed, 10 deletions(-)
 delete mode 100644 arch/arc/kernel/pcibios.c

diff --git a/arch/arc/kernel/Makefile b/arch/arc/kernel/Makefile
index 8942c5c3b4c5..2dc5f4296d44 100644
--- a/arch/arc/kernel/Makefile
+++ b/arch/arc/kernel/Makefile
@@ -12,7 +12,6 @@ obj-y	:= arcksyms.o setup.o irq.o reset.o ptrace.o process.o devtree.o
 obj-y	+= signal.o traps.o sys.o troubleshoot.o stacktrace.o disasm.o
 obj-$(CONFIG_ISA_ARCOMPACT)		+= entry-compact.o intc-compact.o
 obj-$(CONFIG_ISA_ARCV2)			+= entry-arcv2.o intc-arcv2.o
-obj-$(CONFIG_PCI)  			+= pcibios.o
 
 obj-$(CONFIG_MODULES)			+= arcksyms.o module.o
 obj-$(CONFIG_SMP) 			+= smp.o
diff --git a/arch/arc/kernel/pcibios.c b/arch/arc/kernel/pcibios.c
deleted file mode 100644
index 05aba5a7b5d2..000000000000
--- a/arch/arc/kernel/pcibios.c
+++ /dev/null
@@ -1,9 +0,0 @@
-/*
- * Copyright (C) 2014-2015 Synopsys, Inc. (www.synopsys.com)
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/pci.h>
-- 
2.13.0

