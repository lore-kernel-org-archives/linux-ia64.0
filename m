From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 22 Oct 2003 00:59:58 +0000
Subject: make X server on zx2000 (and probably others) work again
Message-Id: <marc-linux-ia64-106678442302747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In recent 2.5/6 kernels, the X server on my zx2000/Radeon workstation
would cause a crash.  Turns out this is due to a long-standing bug in
efi.c: the range checking in efi_mem_type() and efi_mem_attributes()
could cause an underflow if the size of a memory descriptor is zero
(as happens sometimes due to memory trimming).  In my case, granule
zero had a zero size and that in turn caused all /dev/mem mappings to
occur with WRITE-BACK mapping, which doesn't make the X server happy
(instant MCA on a zx2000, for example).

Note that this bug existed for a long time, so it's possible that
there may have been other subtle memory-attribute related problems in
the past.  This bug just became more noticable recently, since the
/dev/mem driver now completely ignores the O_SYNC flag and relies
totally on the value returned by efi_mem_attributes().

	--david

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1354  -> 1.1355 
#	arch/ia64/kernel/efi.c	1.25    -> 1.26   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/21	davidm@tiger.hpl.hp.com	1.1355
# ia64: Fix efi_mem_type() and efi_mem_attributes() to avoid potential
# 	underflows.  In my case, the underflows occurred with the
# 	first memory descriptor which got trimmed down to a size of 0.
# 	Due to the underflow, this descriptor ended up covering the entire
# 	address-range which in turn caused Bad Things to happen with the
# 	X server.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Tue Oct 21 17:53:28 2003
+++ b/arch/ia64/kernel/efi.c	Tue Oct 21 17:53:28 2003
@@ -685,8 +685,7 @@
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if ((md->phys_addr <= phys_addr) && (phys_addr <-		    (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1)))
+		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
 			 return md->type;
 	}
 	return 0;
@@ -706,8 +705,7 @@
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if ((md->phys_addr <= phys_addr) && (phys_addr <-		    (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1)))
+		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
 			return md->attribute;
 	}
 	return 0;
