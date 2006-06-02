From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 02 Jun 2006 20:46:00 +0000
Subject: [RFC 2/2][1/4] Xen/ia64 added files
Message-Id: <1149281160.5998.112.camel@lappy>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-LvePFxojTV3pKV77s9aG"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-LvePFxojTV3pKV77s9aG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


   Looks like this set of changes probably got stuck for being too big.
I'm not sure who moderates this list and how often they check on it, so
I'll split it up a bit more.  This first set is the new arch/ia64/xen c
files and Makefile.  The second is all the new header files.  The last
two sets will be all the new assembly files with the final being just
the xenivt.S.  Sorry for any duplicates should the previous massive
patch show up.  Thanks,

	Alex


 Makefile     |    8
 hypervisor.c |  722 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 util.c       |  115 +++++++++
 xenhpski.c   |   19 +
 4 files changed, 864 insertions(+)

-- 
Alex Williamson                             HP Open Source & Linux Org.

--=-LvePFxojTV3pKV77s9aG
Content-Disposition: attachment; filename=xen_ia64_adds_1.diff
Content-Type: text/x-patch; name=xen_ia64_adds_1.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -r 016512c08f6b -r 4489a633a5de arch/ia64/xen/Makefile
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/arch/ia64/xen/Makefile	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,8 @@
+#
+# Makefile for Xen components
+#
+
+obj-y := hypercall.o xenivt.o xenentry.o xensetup.o xenpal.o xenhpski.o
+
+obj-$(CONFIG_XEN_IA64_DOM0_VP) += hypervisor.o pci-dma-xen.o util.o
+pci-dma-xen-$(CONFIG_XEN_IA64_DOM0_VP) := ../../i386/kernel/pci-dma-xen.o
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/xen/hypervisor.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/arch/ia64/xen/hypervisor.c	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,722 @@
+/******************************************************************************
+ * include/asm-ia64/shadow.h
+ *
+ * Copyright (c) 2006 Isaku Yamahata <yamahata at valinux co jp>
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
+//#include <linux/kernel.h>
+#include <linux/spinlock.h>
+#include <linux/bootmem.h>
+#include <linux/vmalloc.h>
+#include <asm/page.h>
+#include <asm/hypervisor.h>
+#include <asm/hypercall.h>
+#include <xen/interface/memory.h>
+#include <xen/balloon.h>
+
+//XXX xen/ia64 copy_from_guest() is broken.
+//    This is a temporal work around until it is fixed.
+//    used by balloon.c netfront.c
+
+// get_xen_guest_handle is defined only when __XEN_TOOLS__ is defined
+// if the definition in arch-ia64.h is changed, this must be updated.
+#define get_xen_guest_handle(val, hnd)  do { val = (hnd).p; } while (0)
+
+int
+ia64_xenmem_reservation_op(unsigned long op,
+			   struct xen_memory_reservation* reservation__)
+{
+	struct xen_memory_reservation reservation = *reservation__;
+	unsigned long* frame_list;
+	unsigned long nr_extents = reservation__->nr_extents;
+	int ret = 0;
+	get_xen_guest_handle(frame_list, reservation__->extent_start);
+
+	BUG_ON(op != XENMEM_increase_reservation &&
+	       op != XENMEM_decrease_reservation &&
+	       op != XENMEM_populate_physmap);
+
+	while (nr_extents > 0) {
+		int tmp_ret;
+		volatile unsigned long dummy;
+
+		set_xen_guest_handle(reservation.extent_start, frame_list);
+		reservation.nr_extents = nr_extents;
+
+		dummy = frame_list[0];// re-install tlb entry before hypercall
+		tmp_ret = ____HYPERVISOR_memory_op(op, &reservation);
+		if (tmp_ret < 0) {
+			if (ret == 0) {
+				ret = tmp_ret;
+			}
+			break;
+		}
+		frame_list += tmp_ret;
+		nr_extents -= tmp_ret;
+		ret += tmp_ret;
+	}
+	return ret;
+}
+
+//XXX same as i386, x86_64 contiguous_bitmap_set(), contiguous_bitmap_clear()
+// move those to lib/contiguous_bitmap?
+//XXX discontigmem/sparsemem
+
+/*
+ * Bitmap is indexed by page number. If bit is set, the page is part of a
+ * xen_create_contiguous_region() area of memory.
+ */
+unsigned long *contiguous_bitmap;
+
+void
+contiguous_bitmap_init(unsigned long end_pfn)
+{
+	unsigned long size = (end_pfn + 2 * BITS_PER_LONG) >> 3;
+	contiguous_bitmap = alloc_bootmem_low_pages(size);
+	BUG_ON(!contiguous_bitmap);
+	memset(contiguous_bitmap, 0, size);
+}
+
+static void contiguous_bitmap_set(
+	unsigned long first_page, unsigned long nr_pages)
+{
+	unsigned long start_off, end_off, curr_idx, end_idx;
+
+	curr_idx  = first_page / BITS_PER_LONG;
+	start_off = first_page & (BITS_PER_LONG-1);
+	end_idx   = (first_page + nr_pages) / BITS_PER_LONG;
+	end_off   = (first_page + nr_pages) & (BITS_PER_LONG-1);
+
+	if (curr_idx == end_idx) {
+		contiguous_bitmap[curr_idx] |=
+			((1UL<<end_off)-1) & -(1UL<<start_off);
+	} else {
+		contiguous_bitmap[curr_idx] |= -(1UL<<start_off);
+		while ( ++curr_idx < end_idx )
+			contiguous_bitmap[curr_idx] = ~0UL;
+		contiguous_bitmap[curr_idx] |= (1UL<<end_off)-1;
+	}
+}
+
+static void contiguous_bitmap_clear(
+	unsigned long first_page, unsigned long nr_pages)
+{
+	unsigned long start_off, end_off, curr_idx, end_idx;
+
+	curr_idx  = first_page / BITS_PER_LONG;
+	start_off = first_page & (BITS_PER_LONG-1);
+	end_idx   = (first_page + nr_pages) / BITS_PER_LONG;
+	end_off   = (first_page + nr_pages) & (BITS_PER_LONG-1);
+
+	if (curr_idx == end_idx) {
+		contiguous_bitmap[curr_idx] &=
+			-(1UL<<end_off) | ((1UL<<start_off)-1);
+	} else {
+		contiguous_bitmap[curr_idx] &= (1UL<<start_off)-1;
+		while ( ++curr_idx != end_idx )
+			contiguous_bitmap[curr_idx] = 0;
+		contiguous_bitmap[curr_idx] &= -(1UL<<end_off);
+	}
+}
+
+static unsigned long
+HYPERVISOR_populate_physmap(unsigned long gpfn, unsigned int extent_order,
+			    unsigned int address_bits)
+{
+	unsigned long ret;
+        struct xen_memory_reservation reservation = {
+		.nr_extents   = 1,
+                .address_bits = address_bits,
+                .extent_order = extent_order,
+                .domid        = DOMID_SELF
+        };
+	set_xen_guest_handle(reservation.extent_start, &gpfn);
+	ret = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
+	BUG_ON(ret != 1);
+	return 0;
+}
+
+static unsigned long
+HYPERVISOR_remove_physmap(unsigned long gpfn, unsigned int extent_order)
+{
+	unsigned long ret;
+	struct xen_memory_reservation reservation = {
+		.nr_extents   = 1,
+		.address_bits = 0,
+		.extent_order = extent_order,
+		.domid        = DOMID_SELF
+	};
+	set_xen_guest_handle(reservation.extent_start, &gpfn);
+	ret = HYPERVISOR_memory_op(XENMEM_decrease_reservation, &reservation);
+	BUG_ON(ret != 1);
+	return 0;
+}
+
+/* Ensure multi-page extents are contiguous in machine memory. */
+int
+__xen_create_contiguous_region(unsigned long vstart,
+			       unsigned int order, unsigned int address_bits)
+{
+	unsigned long error = 0;
+	unsigned long gphys = __pa(vstart);
+	unsigned long start_gpfn = gphys >> PAGE_SHIFT;
+	unsigned long num_gpfn = 1 << order;
+	unsigned long i;
+	unsigned long flags;
+
+	scrub_pages(vstart, num_gpfn);
+
+	balloon_lock(flags);
+
+	error = HYPERVISOR_remove_physmap(start_gpfn, order);
+	if (error) {
+		goto fail;
+	}
+
+	error = HYPERVISOR_populate_physmap(start_gpfn, order, address_bits);
+	if (error) {
+		goto fail;
+	}
+	contiguous_bitmap_set(start_gpfn, num_gpfn);
+out:
+	balloon_unlock(flags);
+	return error;
+
+fail:
+	for (i = 0; i < num_gpfn; i++) {
+		error = HYPERVISOR_populate_physmap(start_gpfn + i, 0, 0);
+		if (error) {
+			BUG();//XXX
+		}
+	}
+	goto out;
+}
+
+void
+__xen_destroy_contiguous_region(unsigned long vstart, unsigned int order)
+{
+	unsigned long flags;
+	unsigned long error = 0;
+	unsigned long start_gpfn = __pa(vstart) >> PAGE_SHIFT;
+	unsigned long num_gpfn = 1UL << order;
+	unsigned long* gpfns;
+	struct xen_memory_reservation reservation;
+	unsigned long i;
+
+	gpfns = kmalloc(sizeof(gpfns[0]) * num_gpfn,
+			GFP_KERNEL | __GFP_NOFAIL);
+	for (i = 0; i < num_gpfn; i++) {
+		gpfns[i] = start_gpfn + i;
+	}
+
+	scrub_pages(vstart, num_gpfn);
+
+	balloon_lock(flags);
+
+	contiguous_bitmap_clear(start_gpfn, num_gpfn);
+	error = HYPERVISOR_remove_physmap(start_gpfn, order);
+	if (error) {
+		goto fail;
+	}
+
+	set_xen_guest_handle(reservation.extent_start, gpfns);
+	reservation.nr_extents   = num_gpfn;
+	reservation.address_bits = 0;
+	reservation.extent_order = 0;
+	reservation.domid        = DOMID_SELF;
+	error = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
+	if (error != num_gpfn) {
+		error = -EFAULT;//XXX
+		goto fail;
+	}
+	error = 0;
+out:
+	balloon_unlock(flags);
+	kfree(gpfns);
+	if (error) {
+		// error can't be returned.
+		BUG();//XXX
+	}
+	return;
+
+fail:
+	for (i = 0; i < num_gpfn; i++) {
+		int tmp_error;// don't overwrite error.
+		tmp_error = HYPERVISOR_populate_physmap(start_gpfn + i, 0, 0);
+		if (tmp_error) {
+			BUG();//XXX
+		}
+	}
+	goto out;
+}
+
+
+///////////////////////////////////////////////////////////////////////////
+// grant table hack
+// cmd: GNTTABOP_xxx
+
+#include <linux/mm.h>
+#include <xen/interface/xen.h>
+#include <xen/gnttab.h>
+
+static void
+gnttab_map_grant_ref_pre(struct gnttab_map_grant_ref *uop)
+{
+	uint32_t flags;
+
+	flags = uop->flags;
+
+	if (flags & GNTMAP_host_map) {
+		if (flags & GNTMAP_application_map) {
+			xprintd("GNTMAP_application_map is not supported yet: flags 0x%x\n", flags);
+			BUG();
+		}
+		if (flags & GNTMAP_contains_pte) {
+			xprintd("GNTMAP_contains_pte is not supported yet flags 0x%x\n", flags);
+			BUG();
+		}
+	} else if (flags & GNTMAP_device_map) {
+		xprintd("GNTMAP_device_map is not supported yet 0x%x\n", flags);
+		BUG();//XXX not yet. actually this flag is not used.
+	} else {
+		BUG();
+	}
+}
+
+int
+HYPERVISOR_grant_table_op(unsigned int cmd, void *uop, unsigned int count)
+{
+	if (cmd == GNTTABOP_map_grant_ref) {
+		unsigned int i;
+		for (i = 0; i < count; i++) {
+			gnttab_map_grant_ref_pre(
+				(struct gnttab_map_grant_ref*)uop + i);
+		}
+	}
+
+	return ____HYPERVISOR_grant_table_op(cmd, uop, count);
+}
+
+
+///////////////////////////////////////////////////////////////////////////
+// PageForeign(), SetPageForeign(), ClearPageForeign()
+
+struct address_space xen_ia64_foreign_dummy_mapping;
+
+///////////////////////////////////////////////////////////////////////////
+// foreign mapping
+#include <linux/efi.h>
+#include <asm/meminit.h> // for IA64_GRANULE_SIZE, GRANULEROUND{UP,DOWN}()
+
+static unsigned long privcmd_resource_min = 0;
+// Xen/ia64 currently can handle pseudo physical address bits up to
+// (PAGE_SHIFT * 3)
+static unsigned long privcmd_resource_max = GRANULEROUNDDOWN((1UL << (PAGE_SHIFT * 3)) - 1);
+static unsigned long privcmd_resource_align = IA64_GRANULE_SIZE;
+
+static unsigned long
+md_end_addr(const efi_memory_desc_t *md)
+{
+	return md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT);
+}
+
+#define XEN_IA64_PRIVCMD_LEAST_GAP_SIZE	(1024 * 1024 * 1024UL)
+static int
+xen_ia64_privcmd_check_size(unsigned long start, unsigned long end)
+{
+	return (start < end &&
+		(end - start) > XEN_IA64_PRIVCMD_LEAST_GAP_SIZE);
+}
+
+static int __init
+xen_ia64_privcmd_init(void)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	u64 efi_desc_size;
+	efi_memory_desc_t *md;
+	unsigned long tmp_min;
+	unsigned long tmp_max;
+	unsigned long gap_size;
+	unsigned long prev_end;
+
+	if (!is_running_on_xen())
+		return -1;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	// at first check the used highest address
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		// nothing
+	}
+	md = p - efi_desc_size;
+	privcmd_resource_min = GRANULEROUNDUP(md_end_addr(md));
+	if (xen_ia64_privcmd_check_size(privcmd_resource_min,
+					privcmd_resource_max)) {
+		goto out;
+	}
+
+	// the used highest address is too large. try to find the largest gap.
+	tmp_min = privcmd_resource_max;
+	tmp_max = 0;
+	gap_size = 0;
+	prev_end = 0;
+	for (p = efi_map_start;
+	     p < efi_map_end - efi_desc_size;
+	     p += efi_desc_size) {
+		unsigned long end;
+		efi_memory_desc_t* next;
+		unsigned long next_start;
+
+		md = p;
+		end = md_end_addr(md);
+		if (end > privcmd_resource_max) {
+			break;
+		}
+		if (end < prev_end) {
+			// work around. 
+			// Xen may pass incompletely sorted memory
+			// descriptors like
+			// [x, x + length]
+			// [x, x]
+			// this order should be reversed.
+			continue;
+		}
+		next = p + efi_desc_size;
+		next_start = next->phys_addr;
+		if (next_start > privcmd_resource_max) {
+			next_start = privcmd_resource_max;
+		}
+		if (end < next_start && gap_size < (next_start - end)) {
+			tmp_min = end;
+			tmp_max = next_start;
+			gap_size = tmp_max - tmp_min;
+		}
+		prev_end = end;
+	}
+
+	privcmd_resource_min = GRANULEROUNDUP(tmp_min);
+	if (xen_ia64_privcmd_check_size(privcmd_resource_min, tmp_max)) {
+		privcmd_resource_max = tmp_max;
+		goto out;
+	}
+
+	privcmd_resource_min = tmp_min;
+	privcmd_resource_max = tmp_max;
+	if (!xen_ia64_privcmd_check_size(privcmd_resource_min,
+					 privcmd_resource_max)) {
+		// Any large enough gap isn't found.
+		// go ahead anyway with the warning hoping that large region
+		// won't be requested.
+		printk(KERN_WARNING "xen privcmd: large enough region for privcmd mmap is not found.\n");
+	}
+
+out:
+	printk(KERN_INFO "xen privcmd uses pseudo physical addr range [0x%lx, 0x%lx] (%ldMB)\n",
+	       privcmd_resource_min, privcmd_resource_max, 
+	       (privcmd_resource_max - privcmd_resource_min) >> 20);
+	BUG_ON(privcmd_resource_min >= privcmd_resource_max);
+	return 0;
+}
+late_initcall(xen_ia64_privcmd_init);
+
+struct xen_ia64_privcmd_entry {
+	atomic_t	map_count;
+#define INVALID_GPFN	(~0UL)
+	unsigned long	gpfn;
+};
+
+struct xen_ia64_privcmd_range {
+	atomic_t			ref_count;
+	unsigned long			pgoff; // in PAGE_SIZE
+	struct resource*		res;
+
+	unsigned long			num_entries;
+	struct xen_ia64_privcmd_entry	entries[0];
+};
+
+struct xen_ia64_privcmd_vma {
+	struct xen_ia64_privcmd_range*	range;
+
+	unsigned long			num_entries;
+	struct xen_ia64_privcmd_entry*	entries;
+};
+
+static void
+xen_ia64_privcmd_init_entry(struct xen_ia64_privcmd_entry* entry)
+{
+	atomic_set(&entry->map_count, 0);
+	entry->gpfn = INVALID_GPFN;
+}
+
+static int
+xen_ia64_privcmd_entry_mmap(struct vm_area_struct* vma,
+			    unsigned long addr,
+			    struct xen_ia64_privcmd_range* privcmd_range,
+			    int i,
+			    unsigned long mfn,
+			    pgprot_t prot,
+			    domid_t domid)
+{
+	int error = 0;
+	struct xen_ia64_privcmd_entry* entry = &privcmd_range->entries[i];
+	unsigned long gpfn;
+	unsigned long flags;
+
+	BUG_ON((addr & ~PAGE_MASK) != 0);
+	BUG_ON(mfn == INVALID_MFN);
+
+	if (entry->gpfn != INVALID_GPFN) {
+		error = -EBUSY;
+		goto out;
+	}
+	gpfn = (privcmd_range->res->start >> PAGE_SHIFT) + i;
+
+	flags = ASSIGN_writable;
+	if (pgprot_val(prot) == PROT_READ) {
+		flags = ASSIGN_readonly;
+	}
+	error = HYPERVISOR_add_physmap(gpfn, mfn, flags, domid);
+	if (error != 0) {
+		goto out;
+	}
+
+	prot = vma->vm_page_prot;
+	error = remap_pfn_range(vma, addr, gpfn, 1 << PAGE_SHIFT, prot);
+	if (error != 0) {
+		error = HYPERVISOR_zap_physmap(gpfn, 0);
+		if (error) {
+			BUG();//XXX
+		}
+	} else {
+		atomic_inc(&entry->map_count);
+		entry->gpfn = gpfn;
+	}
+
+out:
+	return error;
+}
+
+static void
+xen_ia64_privcmd_entry_munmap(struct xen_ia64_privcmd_range* privcmd_range,
+			      int i)
+{
+	struct xen_ia64_privcmd_entry* entry = &privcmd_range->entries[i];
+	unsigned long gpfn = entry->gpfn;
+	//gpfn = (privcmd_range->res->start >> PAGE_SHIFT) +
+	//	(vma->vm_pgoff - privcmd_range->pgoff);
+	int error;
+
+	error = HYPERVISOR_zap_physmap(gpfn, 0);
+	if (error) {
+		BUG();//XXX
+	}
+	entry->gpfn = INVALID_GPFN;
+}
+
+static int
+xen_ia64_privcmd_entry_open(struct xen_ia64_privcmd_range* privcmd_range,
+			    int i)
+{
+	struct xen_ia64_privcmd_entry* entry = &privcmd_range->entries[i];
+	if (entry->gpfn != INVALID_GPFN) {
+		atomic_inc(&entry->map_count);
+	} else {
+		BUG_ON(atomic_read(&entry->map_count) != 0);
+	}
+}
+
+static int
+xen_ia64_privcmd_entry_close(struct xen_ia64_privcmd_range* privcmd_range,
+			     int i)
+{
+	struct xen_ia64_privcmd_entry* entry = &privcmd_range->entries[i];
+	if (entry->gpfn != INVALID_GPFN &&
+	    atomic_dec_and_test(&entry->map_count)) {
+		xen_ia64_privcmd_entry_munmap(privcmd_range, i);
+	}
+}
+
+static void xen_ia64_privcmd_vma_open(struct vm_area_struct* vma);
+static void xen_ia64_privcmd_vma_close(struct vm_area_struct* vma);
+
+struct vm_operations_struct xen_ia64_privcmd_vm_ops = {
+	.open = &xen_ia64_privcmd_vma_open,
+	.close = &xen_ia64_privcmd_vma_close,
+};
+
+static void
+__xen_ia64_privcmd_vma_open(struct vm_area_struct* vma,
+			    struct xen_ia64_privcmd_vma* privcmd_vma,
+			    struct xen_ia64_privcmd_range* privcmd_range)
+{
+	unsigned long entry_offset = vma->vm_pgoff - privcmd_range->pgoff;
+	unsigned long num_entries = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	unsigned long i;
+
+	BUG_ON(entry_offset < 0);
+	BUG_ON(entry_offset + num_entries > privcmd_range->num_entries);
+
+	privcmd_vma->range = privcmd_range;
+	privcmd_vma->num_entries = num_entries;
+	privcmd_vma->entries = &privcmd_range->entries[entry_offset];
+	vma->vm_private_data = privcmd_vma;
+	for (i = 0; i < privcmd_vma->num_entries; i++) {
+		xen_ia64_privcmd_entry_open(privcmd_range, entry_offset + i);
+	}
+
+	vma->vm_private_data = privcmd_vma;
+	vma->vm_ops = &xen_ia64_privcmd_vm_ops;
+}
+
+static void
+xen_ia64_privcmd_vma_open(struct vm_area_struct* vma)
+{
+	struct xen_ia64_privcmd_vma* privcmd_vma = (struct xen_ia64_privcmd_vma*)vma->vm_private_data;
+	struct xen_ia64_privcmd_range* privcmd_range = privcmd_vma->range;
+
+	atomic_inc(&privcmd_range->ref_count);
+	// vm_op->open() can't fail.
+	privcmd_vma = kmalloc(sizeof(*privcmd_vma), GFP_KERNEL | __GFP_NOFAIL);
+
+	__xen_ia64_privcmd_vma_open(vma, privcmd_vma, privcmd_range);
+}
+
+static void
+xen_ia64_privcmd_vma_close(struct vm_area_struct* vma)
+{
+	struct xen_ia64_privcmd_vma* privcmd_vma =
+		(struct xen_ia64_privcmd_vma*)vma->vm_private_data;
+	struct xen_ia64_privcmd_range* privcmd_range = privcmd_vma->range;
+	unsigned long entry_offset = vma->vm_pgoff - privcmd_range->pgoff;
+	unsigned long i;
+
+	for (i = 0; i < privcmd_vma->num_entries; i++) {
+		xen_ia64_privcmd_entry_close(privcmd_range, entry_offset + i);
+	}
+	vma->vm_private_data = NULL;
+	kfree(privcmd_vma);
+
+	if (atomic_dec_and_test(&privcmd_range->ref_count)) {
+#if 1
+		for (i = 0; i < privcmd_range->num_entries; i++) {
+			struct xen_ia64_privcmd_entry* entry =
+				&privcmd_range->entries[i];
+			BUG_ON(atomic_read(&entry->map_count) != 0);
+			BUG_ON(entry->gpfn != INVALID_GPFN);
+		}
+#endif
+		release_resource(privcmd_range->res);
+		kfree(privcmd_range->res);
+		vfree(privcmd_range);
+	}
+}
+
+int
+privcmd_mmap(struct file * file, struct vm_area_struct * vma)
+{
+	int error;
+	unsigned long size = vma->vm_end - vma->vm_start;
+	unsigned long num_entries = size >> PAGE_SHIFT;
+	struct xen_ia64_privcmd_range* privcmd_range = NULL;
+	struct xen_ia64_privcmd_vma* privcmd_vma = NULL;
+	struct resource* res = NULL;
+	unsigned long i;
+	BUG_ON(!is_running_on_xen());
+
+	BUG_ON(file->private_data != NULL);
+
+	error = -ENOMEM;
+	privcmd_range =
+		vmalloc(sizeof(*privcmd_range) +
+			sizeof(privcmd_range->entries[0]) * num_entries);
+	if (privcmd_range == NULL) {
+		goto out_enomem0;
+	}
+	privcmd_vma = kmalloc(sizeof(*privcmd_vma), GFP_KERNEL);
+	if (privcmd_vma == NULL) {
+		goto out_enomem1;
+	}
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (res == NULL) {
+		goto out_enomem1;
+	}
+	res->name = "Xen privcmd mmap";
+	error = allocate_resource(&iomem_resource, res, size,
+				  privcmd_resource_min, privcmd_resource_max,
+				  privcmd_resource_align, NULL, NULL);
+	if (error) {
+		goto out_enomem1;
+	}
+	privcmd_range->res = res;
+
+	/* DONTCOPY is essential for Xen as copy_page_range is broken. */
+	vma->vm_flags |= VM_RESERVED | VM_IO | VM_DONTCOPY | VM_PFNMAP;
+
+	atomic_set(&privcmd_range->ref_count, 1);
+	privcmd_range->pgoff = vma->vm_pgoff;
+	privcmd_range->num_entries = num_entries;
+	for (i = 0; i < privcmd_range->num_entries; i++) {
+		xen_ia64_privcmd_init_entry(&privcmd_range->entries[i]);
+	}
+
+	__xen_ia64_privcmd_vma_open(vma, privcmd_vma, privcmd_range);
+	return 0;
+
+out_enomem1:
+	kfree(res);
+	kfree(privcmd_vma);
+out_enomem0:
+	vfree(privcmd_range);
+	return error;
+}
+
+int
+direct_remap_pfn_range(struct vm_area_struct *vma,
+		       unsigned long address,	// process virtual address
+		       unsigned long mfn,	// mfn, mfn + 1, ... mfn + size/PAGE_SIZE
+		       unsigned long size,
+		       pgprot_t prot,
+		       domid_t  domid)		// target domain
+{
+	struct xen_ia64_privcmd_vma* privcmd_vma =
+		(struct xen_ia64_privcmd_vma*)vma->vm_private_data;
+	struct xen_ia64_privcmd_range* privcmd_range = privcmd_vma->range;
+	unsigned long entry_offset = vma->vm_pgoff - privcmd_range->pgoff;
+
+	unsigned long i;
+	unsigned long offset;
+	int error = 0;
+	BUG_ON(!is_running_on_xen());
+
+	i = (address - vma->vm_start) >> PAGE_SHIFT;
+	for (offset = 0; offset < size; offset += PAGE_SIZE) {
+		error = xen_ia64_privcmd_entry_mmap(vma, (address + offset) & PAGE_MASK, privcmd_range, entry_offset + i, mfn, prot, domid);
+		if (error != 0) {
+			break;
+		}
+
+		i++;
+		mfn++;
+        }
+
+	return error;
+}
+
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/xen/util.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/arch/ia64/xen/util.c	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,115 @@
+/******************************************************************************
+ * arch/ia64/xen/util.c
+ * This file is the ia64 counterpart of drivers/xen/util.c
+ *
+ * Copyright (c) 2006 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <asm/uaccess.h>
+#include <xen/driver_util.h>
+
+struct vm_struct *alloc_vm_area(unsigned long size)
+{
+	int order;
+	unsigned long virt;
+	unsigned long nr_pages;
+	struct vm_struct* area;
+	
+	order = get_order(size);
+	virt = __get_free_pages(GFP_KERNEL, order);
+	if (virt == 0) {
+		goto err0;
+	}
+	nr_pages = 1 << order;
+	scrub_pages(virt, nr_pages);
+	
+	area = kmalloc(sizeof(*area), GFP_KERNEL);
+	if (area == NULL) {
+		goto err1;
+	}
+	
+        area->flags = VM_IOREMAP;//XXX
+        area->addr = (void*)virt;
+        area->size = size;
+        area->pages = NULL; //XXX
+        area->nr_pages = nr_pages;
+        area->phys_addr = __pa(virt);
+
+	return area;
+
+err1:
+	free_pages(virt, order);
+err0:
+	return NULL;
+	
+}
+EXPORT_SYMBOL_GPL(alloc_vm_area);
+
+void free_vm_area(struct vm_struct *area)
+{
+	unsigned int order = get_order(area->size);
+	unsigned long i;
+
+	// This area is used for foreign page mappping.
+	// So underlying machine page may not be assigned.
+	for (i = 0; i < (1 << order); i++) {
+		unsigned long ret;
+		unsigned long gpfn = (area->phys_addr >> PAGE_SHIFT) + i;
+		struct xen_memory_reservation reservation = {
+			.nr_extents   = 1,
+			.address_bits = 0,
+			.extent_order = 0,
+			.domid        = DOMID_SELF
+		};
+		set_xen_guest_handle(reservation.extent_start, &gpfn);
+		ret = HYPERVISOR_memory_op(XENMEM_populate_physmap,
+					   &reservation);
+		BUG_ON(ret != 1);
+	}
+	free_pages((unsigned long)area->addr, order);
+	kfree(area);
+}
+EXPORT_SYMBOL_GPL(free_vm_area);
+
+void lock_vm_area(struct vm_struct *area)
+{
+	// nothing
+}
+EXPORT_SYMBOL_GPL(lock_vm_area);
+
+void unlock_vm_area(struct vm_struct *area)
+{
+	// nothing
+}
+EXPORT_SYMBOL_GPL(unlock_vm_area);
+
+/*
+ * Local variables:
+ *  c-file-style: "linux"
+ *  indent-tabs-mode: t
+ *  c-indent-level: 8
+ *  c-basic-offset: 8
+ *  tab-width: 8
+ * End:
+ */
diff -r 016512c08f6b -r 4489a633a5de arch/ia64/xen/xenhpski.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/arch/ia64/xen/xenhpski.c	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,19 @@
+
+extern unsigned long xen_get_cpuid(int);
+
+int
+running_on_sim(void)
+{
+	int i;
+	long cpuid[6];
+
+	for (i = 0; i < 5; ++i)
+		cpuid[i] = xen_get_cpuid(i);
+	if ((cpuid[0] & 0xff) != 'H') return 0;
+	if ((cpuid[3] & 0xff) != 0x4) return 0;
+	if (((cpuid[3] >> 8) & 0xff) != 0x0) return 0;
+	if (((cpuid[3] >> 16) & 0xff) != 0x0) return 0;
+	if (((cpuid[3] >> 24) & 0x7) != 0x7) return 0;
+	return 1;
+}
+

--=-LvePFxojTV3pKV77s9aG--

