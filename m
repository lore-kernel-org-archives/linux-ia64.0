From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 03 Nov 2006 00:10:23 +0000
Subject: alloc_bootmem can corrupt memory
Message-Id: <87mz798k5s.peterc%peterc@gelato.unsw.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




Hi,
	During bootup, the EFI memory map is scanned and converted to
an in-kernel representation.  The memory for that in-kernel
representation is allocated directly out of the EFI memory map using a
fairly arcane alogrithm.  But the allocation algorithm doesn't take
into account any reserved regions.  Which means that for some memory
layouts, it can allocate memory that overlaps an already reserved
region.

For example, assume an EFI memory map like this:

0-1MB WB EFI_BOOT_SERVICES_DATA
1-2MB WB EFI_PAL_CODE
2-1025MB WB EFI_CONVENTIONAL_MEMORY

and assume the kernel is loaded at 64M, and there is a 64M granule
size.

arch/ia64/kernel/efi.c:find_memmap_space() will find memory at the 64M
granule boundary.  This is already used by the kernel.  So the
rsvd_space[] array might look like:

rsvd[0] 10ac48->10acc0
rsvd[1] 10acc0->10ad10
rsvd[2] 10ad10->10ad58
rsvd[3] 4000000->4738dc8
rsvd[4] 4000000->4000030

The last entry is for the kernel copy of the EFI map.  It has already
corrupted the VHPT miss handler.  Then alloc_bootmem starts allocating
after the highest reserved space.

Maybe a patch something like this is needed (minus the debugging
output) (yes there are cleaner ways to do this, and I can do them if
the general approach is acceptable).

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index bb8770a..f8ae8d0 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -894,6 +895,16 @@ find_memmap_space (void)
 		as = max(contig_low, md->phys_addr);
 		ae = min(contig_high, efi_md_end(md));
 
+		{
+			int i;
+			for (i = 0; i < num_rsvd_regions; i++) {
+				if (rsvd_region[i].end < as)
+					continue;
+				if (rsvd_region[i].start <= as && rsvd_region[i].end >= as + space_needed)
+					as = rsvd_region[i].end;
+			}
+		}
+
 		/* keep within max_addr= command line arg */
 		ae = min(ae, max_addr);
 		if (ae <= as)
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index c4caa80..288f367 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -248,6 +248,7 @@ #ifdef CONFIG_BLK_DEV_INITRD
 		n++;
 	}
 #endif
+	num_rsvd_regions = n;
 
 	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
 	n++;
@@ -261,6 +262,14 @@ #endif
 	BUG_ON(IA64_MAX_RSVD_REGIONS + 1 < n);
 
 	sort_regions(rsvd_region, num_rsvd_regions);
+	{
+		int i;
+		for (i = 0; i < num_rsvd_regions; i++)
+			printk("rsvd[%d] %lx->%lx\n",
+				i,
+				rsvd_region[i].start,
+				rsvd_region[i].end);
+	}
 }
 
 /**
