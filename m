From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:26 +0000
Subject: [PATCH 11/50] xen: import arch generic part of xencomm.
Message-Id: <1204741146511-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On xen/ia64 and xen/powerpc hypercall arguments are passed by pseudo
physical address (guest physical address) so that it's necessary to
convert from virtual address into pseudo physical address. The frame
work is called xencomm.
Import arch generic part of xencomm.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/xen/Makefile            |    1 +
 drivers/xen/xencomm.c           |  232 +++++++++++++++++++++++++++++++++++++++
 include/xen/interface/xencomm.h |   41 +++++++
 include/xen/xencomm.h           |   77 +++++++++++++
 4 files changed, 351 insertions(+), 0 deletions(-)
 create mode 100644 drivers/xen/xencomm.c
 create mode 100644 include/xen/interface/xencomm.h
 create mode 100644 include/xen/xencomm.h

diff --git a/drivers/xen/Makefile b/drivers/xen/Makefile
index 823ce78..43f014c 100644
--- a/drivers/xen/Makefile
+++ b/drivers/xen/Makefile
@@ -1,2 +1,3 @@
 obj-y	+= grant-table.o features.o events.o
 obj-y	+= xenbus/
+obj-$(CONFIG_XEN_XENCOMM)	+= xencomm.o
diff --git a/drivers/xen/xencomm.c b/drivers/xen/xencomm.c
new file mode 100644
index 0000000..797cb4e
--- /dev/null
+++ b/drivers/xen/xencomm.c
@@ -0,0 +1,232 @@
+/*
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ *
+ * Copyright (C) IBM Corp. 2006
+ *
+ * Authors: Hollis Blanchard <hollisb@us.ibm.com>
+ */
+
+#include <linux/gfp.h>
+#include <linux/mm.h>
+#include <asm/page.h>
+#include <xen/xencomm.h>
+#include <xen/interface/xen.h>
+#ifdef __ia64__
+#include <asm/xen/xencomm.h>	/* for is_kern_addr() */
+#endif
+
+#ifdef HAVE_XEN_PLATFORM_COMPAT_H
+#include <xen/platform-compat.h>
+#endif
+
+static int xencomm_init(struct xencomm_desc *desc,
+			void *buffer, unsigned long bytes)
+{
+	unsigned long recorded = 0;
+	int i = 0;
+
+	while ((recorded < bytes) && (i < desc->nr_addrs)) {
+		unsigned long vaddr = (unsigned long)buffer + recorded;
+		unsigned long paddr;
+		int offset;
+		int chunksz;
+
+		offset = vaddr % PAGE_SIZE; /* handle partial pages */
+		chunksz = min(PAGE_SIZE - offset, bytes - recorded);
+
+		paddr = xencomm_vtop(vaddr);
+		if (paddr = ~0UL) {
+			printk(KERN_DEBUG "%s: couldn't translate vaddr %lx\n",
+			       __func__, vaddr);
+			return -EINVAL;
+		}
+
+		desc->address[i++] = paddr;
+		recorded += chunksz;
+	}
+
+	if (recorded < bytes) {
+		printk(KERN_DEBUG
+		       "%s: could only translate %ld of %ld bytes\n",
+		       __func__, recorded, bytes);
+		return -ENOSPC;
+	}
+
+	/* mark remaining addresses invalid (just for safety) */
+	while (i < desc->nr_addrs)
+		desc->address[i++] = XENCOMM_INVALID;
+
+	desc->magic = XENCOMM_MAGIC;
+
+	return 0;
+}
+
+static struct xencomm_desc *xencomm_alloc(gfp_t gfp_mask,
+					  void *buffer, unsigned long bytes)
+{
+	struct xencomm_desc *desc;
+	unsigned long buffer_ulong = (unsigned long)buffer;
+	unsigned long start = buffer_ulong & PAGE_MASK;
+	unsigned long end = (buffer_ulong + bytes) | ~PAGE_MASK;
+	unsigned long nr_addrs = (end - start + 1) >> PAGE_SHIFT;
+	unsigned long size = sizeof(*desc) +
+		sizeof(desc->address[0]) * nr_addrs;
+
+	/*
+	 * slab allocator returns at least sizeof(void*) aligned pointer.
+	 * When sizeof(*desc) > sizeof(void*), struct xencomm_desc might
+	 * cross page boundary.
+	 */
+	if (sizeof(*desc) > sizeof(void *)) {
+		unsigned long order = get_order(size);
+		desc = (struct xencomm_desc *)__get_free_pages(gfp_mask,
+							       order);
+		if (desc = NULL)
+			return NULL;
+
+		desc->nr_addrs +			((PAGE_SIZE << order) - sizeof(struct xencomm_desc)) /
+			sizeof(*desc->address);
+	} else {
+		desc = kmalloc(size, gfp_mask);
+		if (desc = NULL)
+			return NULL;
+
+		desc->nr_addrs = nr_addrs;
+	}
+	return desc;
+}
+
+void xencomm_free(struct xencomm_handle *desc)
+{
+	if (desc && !((ulong)desc & XENCOMM_INLINE_FLAG)) {
+		struct xencomm_desc *desc__ = (struct xencomm_desc *)desc;
+		if (sizeof(*desc__) > sizeof(void *)) {
+			unsigned long size = sizeof(*desc__) +
+				sizeof(desc__->address[0]) * desc__->nr_addrs;
+			unsigned long order = get_order(size);
+			free_pages((unsigned long)__va(desc), order);
+		} else
+			kfree(__va(desc));
+	}
+}
+
+static int xencomm_create(void *buffer, unsigned long bytes,
+			  struct xencomm_desc **ret, gfp_t gfp_mask)
+{
+	struct xencomm_desc *desc;
+	int rc;
+
+	pr_debug("%s: %p[%ld]\n", __func__, buffer, bytes);
+
+	if (bytes = 0) {
+		/* don't create a descriptor; Xen recognizes NULL. */
+		BUG_ON(buffer != NULL);
+		*ret = NULL;
+		return 0;
+	}
+
+	BUG_ON(buffer = NULL); /* 'bytes' is non-zero */
+
+	desc = xencomm_alloc(gfp_mask, buffer, bytes);
+	if (!desc) {
+		printk(KERN_DEBUG "%s failure\n", "xencomm_alloc");
+		return -ENOMEM;
+	}
+
+	rc = xencomm_init(desc, buffer, bytes);
+	if (rc) {
+		printk(KERN_DEBUG "%s failure: %d\n", "xencomm_init", rc);
+		xencomm_free((struct xencomm_handle *)__pa(desc));
+		return rc;
+	}
+
+	*ret = desc;
+	return 0;
+}
+
+/* check if memory address is within VMALLOC region  */
+static int is_phys_contiguous(unsigned long addr)
+{
+	if (!is_kernel_addr(addr))
+		return 0;
+
+	return (addr < VMALLOC_START) || (addr >= VMALLOC_END);
+}
+
+static struct xencomm_handle *xencomm_create_inline(void *ptr)
+{
+	unsigned long paddr;
+
+	BUG_ON(!is_phys_contiguous((unsigned long)ptr));
+
+	paddr = (unsigned long)xencomm_pa(ptr);
+	BUG_ON(paddr & XENCOMM_INLINE_FLAG);
+	return (struct xencomm_handle *)(paddr | XENCOMM_INLINE_FLAG);
+}
+
+/* "mini" routine, for stack-based communications: */
+static int xencomm_create_mini(void *buffer,
+	unsigned long bytes, struct xencomm_mini *xc_desc,
+	struct xencomm_desc **ret)
+{
+	int rc = 0;
+	struct xencomm_desc *desc;
+	BUG_ON(((unsigned long)xc_desc) % sizeof(*xc_desc) != 0);
+
+	desc = (void *)xc_desc;
+
+	desc->nr_addrs = XENCOMM_MINI_ADDRS;
+
+	rc = xencomm_init(desc, buffer, bytes);
+	if (!rc)
+		*ret = desc;
+
+	return rc;
+}
+
+struct xencomm_handle *xencomm_map(void *ptr, unsigned long bytes)
+{
+	int rc;
+	struct xencomm_desc *desc;
+
+	if (is_phys_contiguous((unsigned long)ptr))
+		return xencomm_create_inline(ptr);
+
+	rc = xencomm_create(ptr, bytes, &desc, GFP_KERNEL);
+
+	if (rc || desc = NULL)
+		return NULL;
+
+	return xencomm_pa(desc);
+}
+
+struct xencomm_handle *__xencomm_map_no_alloc(void *ptr, unsigned long bytes,
+			struct xencomm_mini *xc_desc)
+{
+	int rc;
+	struct xencomm_desc *desc = NULL;
+
+	if (is_phys_contiguous((unsigned long)ptr))
+		return xencomm_create_inline(ptr);
+
+	rc = xencomm_create_mini(ptr, bytes, xc_desc,
+				&desc);
+
+	if (rc)
+		return NULL;
+
+	return xencomm_pa(desc);
+}
diff --git a/include/xen/interface/xencomm.h b/include/xen/interface/xencomm.h
new file mode 100644
index 0000000..ac45e07
--- /dev/null
+++ b/include/xen/interface/xencomm.h
@@ -0,0 +1,41 @@
+/*
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this software and associated documentation files (the "Software"), to
+ * deal in the Software without restriction, including without limitation the
+ * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
+ * sell copies of the Software, and to permit persons to whom the Software is
+ * furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
+ * DEALINGS IN THE SOFTWARE.
+ *
+ * Copyright (C) IBM Corp. 2006
+ */
+
+#ifndef _XEN_XENCOMM_H_
+#define _XEN_XENCOMM_H_
+
+/* A xencomm descriptor is a scatter/gather list containing physical
+ * addresses corresponding to a virtually contiguous memory area. The
+ * hypervisor translates these physical addresses to machine addresses to copy
+ * to and from the virtually contiguous area.
+ */
+
+#define XENCOMM_MAGIC 0x58434F4D /* 'XCOM' */
+#define XENCOMM_INVALID (~0UL)
+
+struct xencomm_desc {
+    uint32_t magic;
+    uint32_t nr_addrs; /* the number of entries in address[] */
+    uint64_t address[0];
+};
+
+#endif /* _XEN_XENCOMM_H_ */
diff --git a/include/xen/xencomm.h b/include/xen/xencomm.h
new file mode 100644
index 0000000..e43b039
--- /dev/null
+++ b/include/xen/xencomm.h
@@ -0,0 +1,77 @@
+/*
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ *
+ * Copyright (C) IBM Corp. 2006
+ *
+ * Authors: Hollis Blanchard <hollisb@us.ibm.com>
+ *          Jerone Young <jyoung5@us.ibm.com>
+ */
+
+#ifndef _LINUX_XENCOMM_H_
+#define _LINUX_XENCOMM_H_
+
+#include <xen/interface/xencomm.h>
+
+#define XENCOMM_MINI_ADDRS 3
+struct xencomm_mini {
+	struct xencomm_desc _desc;
+	uint64_t address[XENCOMM_MINI_ADDRS];
+};
+
+/* To avoid additionnal virt to phys conversion, an opaque structure is
+   presented.  */
+struct xencomm_handle;
+
+extern void xencomm_free(struct xencomm_handle *desc);
+extern struct xencomm_handle *xencomm_map(void *ptr, unsigned long bytes);
+extern struct xencomm_handle *__xencomm_map_no_alloc(void *ptr,
+			unsigned long bytes,  struct xencomm_mini *xc_area);
+
+#if 0
+#define XENCOMM_MINI_ALIGNED(xc_desc, n)				\
+	struct xencomm_mini xc_desc ## _base[(n)]			\
+	__attribute__((__aligned__(sizeof(struct xencomm_mini))));	\
+	struct xencomm_mini *xc_desc = &xc_desc ## _base[0];
+#else
+/*
+ * gcc bug workaround:
+ * http://gcc.gnu.org/bugzilla/show_bug.cgi?id660
+ * gcc doesn't handle properly stack variable with
+ * __attribute__((__align__(sizeof(struct xencomm_mini))))
+ */
+#define XENCOMM_MINI_ALIGNED(xc_desc, n)				\
+	unsigned char xc_desc ## _base[((n) + 1 ) *			\
+				       sizeof(struct xencomm_mini)];	\
+	struct xencomm_mini *xc_desc = (struct xencomm_mini *)		\
+		((unsigned long)xc_desc ## _base +			\
+		 (sizeof(struct xencomm_mini) -				\
+		  ((unsigned long)xc_desc ## _base) %			\
+		  sizeof(struct xencomm_mini)));
+#endif
+#define xencomm_map_no_alloc(ptr, bytes)			\
+	({ XENCOMM_MINI_ALIGNED(xc_desc, 1);			\
+		__xencomm_map_no_alloc(ptr, bytes, xc_desc); })
+
+/* provided by architecture code: */
+extern unsigned long xencomm_vtop(unsigned long vaddr);
+
+static inline void *xencomm_pa(void *ptr)
+{
+	return (void *)xencomm_vtop((unsigned long)ptr);
+}
+
+#define xen_guest_handle(hnd)  ((hnd).p)
+
+#endif /* _LINUX_XENCOMM_H_ */
-- 
1.5.3

