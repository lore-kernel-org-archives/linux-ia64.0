From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 28 Aug 2003 23:20:40 +0000
Subject: Re: [PATCH 2.4 and 2.6] trim.bottom trims the wrong entry
Message-Id: <marc-linux-ia64-106211448005770@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106208671402725@msgid-missing>
In-Reply-To: <marc-linux-ia64-106208671402725@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 28 August 2003 10:04 am, Luck, Tony wrote:
> ...
> The problem is that efi_memmap_walk() repeatedly trims the same
> entry, instead of trimming each of the entries in the granule.

I applied this patch for 2.4.  Thanks!

#### AUTHOR tony.luck@intel.com
#### COMMENT START
### Comments for ChangeSet
ia64: Trim granules correctly in efi_memmap_walk()

This was a fun one to track down.  I was trying to provide
a fake SRAT table so that I could start working on some more
ccNUMA issues on a non-NUMA tiger box, but my kernel kept dying
while running scripts out of /etc/init.d/*

I found I was getting an MCA while executing an lfetch.excl in
clear_page_tables(), the address that was being fetched was
0xe0000000000a00e8, which is non-cacheable VGA memory on Tiger.

Root cause was the "trim" code in efi_memmap_walk() had failed
to trim away all the blocks of memory in the bottom granule when
it had seen the memory hole there, so the kernel had managed to
allocate a page at 0x9c000 as a page table, and when the process
using it ended, the cleanup code prefetched off the end of the
page, and into the VGA memory, causing an MCA.

The problem is that efi_memmap_walk() repeatedly trims the same
entry, instead of trimming each of the entries in the granule.
### Comments for arch/ia64/kernel/efi.c
(efi_memmap_walk): Trim entries from the correct granule.
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1086  -> 1.1087 
#	arch/ia64/kernel/efi.c	1.13    -> 1.14   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/28	bjorn.helgaas@hp.com	1.1087
# tony's fix.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Thu Aug 28 18:53:48 2003
+++ b/arch/ia64/kernel/efi.c	Thu Aug 28 18:53:48 2003
@@ -324,7 +324,7 @@
 				check_md = q;
 
 				if (check_md->attribute & EFI_MEMORY_WB)
-					trim_bottom(md, granule_addr);
+					trim_bottom(check_md, granule_addr);
 
 				if (check_md->phys_addr < granule_addr)
 					continue;

