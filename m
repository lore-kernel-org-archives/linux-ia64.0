From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:36 +0000
Subject: [PATCH 21/50] ia64/pv_ops: header file to switch paravirtualized assembly instructions.
Message-Id: <12047411461445-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/inst_paravirt.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kernel/inst_paravirt.h

diff --git a/arch/ia64/kernel/inst_paravirt.h b/arch/ia64/kernel/inst_paravirt.h
new file mode 100644
index 0000000..689c343
--- /dev/null
+++ b/arch/ia64/kernel/inst_paravirt.h
@@ -0,0 +1,28 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/inst_paravirt.h
+ *
+ * Copyright (c) 2007 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifdef __IA64_ASM_PARAVIRTUALIZED_XEN
+#include "../xen/inst_xen.h"
+#include "../xen/xenminstate.h"
+#else
+#include "inst_native.h"
+#endif
-- 
1.5.3

