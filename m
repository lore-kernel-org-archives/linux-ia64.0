From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Thu, 17 Jul 2008 03:25:36 +0000
Subject: Re: [PATCH 10/29] ia64/xen: implement the arch specific part of xencomm.
Message-Id: <96C8E7BCC74EB0takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606621561-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606621561-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Isaku

Thank you for your work.
one small comment.

>On ia64/xen, pointer argument for the hypercall is passed
>by pseudo physical address (guest physical address.)
>So it is necessary to convert virtual address into pseudo physical
>address right before issuing hypercall. The frame work is called
>xencomm. This patch implements arch specific part.
>
>Signed-off-by: Alex Williamson <alex.williamson@hp.com>
>Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
>Cc: "Luck, Tony" <tony.luck@intel.com>
>---
> arch/ia64/xen/Makefile         |    2 +-
> arch/ia64/xen/xencomm.c        |   94 ++++++++++++++++++++++++++++++++++++++
>++
> include/asm-ia64/xen/xencomm.h |   41 +++++++++++++++++
> 3 files changed, 136 insertions(+), 1 deletions(-)
> create mode 100644 arch/ia64/xen/xencomm.c
> create mode 100644 include/asm-ia64/xen/xencomm.h
>
>diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
>index c200704..ad0c9f7 100644
>--- a/arch/ia64/xen/Makefile
>+++ b/arch/ia64/xen/Makefile
>@@ -2,4 +2,4 @@
> # Makefile for Xen components
> #
> 
>-obj-y := hypercall.o
>+obj-y := hypercall.o xencomm.o
>diff --git a/arch/ia64/xen/xencomm.c b/arch/ia64/xen/xencomm.c
>new file mode 100644
>index 0000000..2a57058
>--- /dev/null
>+++ b/arch/ia64/xen/xencomm.c
>@@ -0,0 +1,94 @@
>+/*
>+ * Copyright (C) 2006 Hollis Blanchard <hollisb@us.ibm.com>, IBM Corporation
>+ *
>+ * This program is free software; you can redistribute it and/or modify
>+ * it under the terms of the GNU General Public License as published by
>+ * the Free Software Foundation; either version 2 of the License, or
>+ * (at your option) any later version.
>+ *
>+ * This program is distributed in the hope that it will be useful,
>+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
>+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>+ * GNU General Public License for more details.
>+ *
>+ * You should have received a copy of the GNU General Public License
>+ * along with this program; if not, write to the Free Software
>+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
>+ */
>+
>+#include <linux/mm.h>
>+
>+static unsigned long kernel_virtual_offset;
>+
>+void
>+xencomm_initialize(void)
>+{
>+	kernel_virtual_offset = KERNEL_START - ia64_tpa(KERNEL_START);
>+}
>+
>+/* Translate virtual address to physical address.  */
>+unsigned long
>+xencomm_vtop(unsigned long vaddr)
>+{
>+	struct page *page;
>+	struct vm_area_struct *vma;
>+
>+	if (vaddr = 0)
>+		return 0;
>+
It should be "return 0UL";

Best Regards,

Akio Takebe

