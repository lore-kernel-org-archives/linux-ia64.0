From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 18 Jun 2008 20:39:02 +0000
Subject: RE: [PATCH 09/27] ia64/xen: implement the arch specific part of
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30621364B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840434082-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840434082-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On ia64/xen, pointer argument for the hypercall is passed
> by pseudo physical address (guest phsysical address.)
s/phsysical/physical/

> So it is necessary to convert virtual address into pseudo physical
> address rigth before issuing hypercall. The frame work is called
s/rigth/right/



+#ifdef HAVE_XEN_PLATFORM_COMPAT_H
+#include <xen/platform-compat.h>
+#endif

What is this for?  This patch series doesn't make this file.


+static unsigned long kernel_start_pa;
+
+void
+xencomm_initialize(void)
+{
+       kernel_start_pa = KERNEL_START - ia64_tpa(KERNEL_START);
+}

"kernel_start_pa" is an unhelpful name ... this variable doesn't
contain the starting physical address (which is what the name
sounds like).  Perhaps "kernel_virtual_offset" is better?


+       if (vaddr > TASK_SIZE) {
+               /* kernel address */
+               return __pa(vaddr);
+       }

Can this routine ever be given the address of a percpu variable?
This will return the wrong value if someone does.

+#define is_kernel_addr(x)                                      \
+       ((PAGE_OFFSET <= (x) &&                                 \
+         (x) < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) || \
+        (KERNEL_START <= (x) &&                                \
+         (x) < KERNEL_START + KERNEL_TR_PAGE_SIZE))

Misleading name.  What does it consider a "kernel_addr"? Just
region 7 (up to physical address limit) and the piece of region
5 that is mapped by itr[0]/dtr[0].  Preferebly pick a better name
or add a comment here saying what this is testing for.

-Tony
