From: Martin Hicks <mort@sgi.com>
Date: Wed, 07 Sep 2005 19:17:17 +0000
Subject: Re: efi_memmapwalk re-write (please test)
Message-Id: <20050907191717.GS13449@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
In-Reply-To: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, Sep 07, 2005 at 03:16:24PM -0400, Martin Hicks wrote:
> 
> Attached is a very small patch to find the uncached memory on SN2.
> 

and the patch this time...

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com


Index: linux-2.6.13/arch/ia64/kernel/efi.c
=================================--- linux-2.6.13.orig/arch/ia64/kernel/efi.c	2005-09-07 07:46:05.000000000 -0700
+++ linux-2.6.13/arch/ia64/kernel/efi.c	2005-09-07 07:47:41.000000000 -0700
@@ -831,7 +831,8 @@ efi_memmap_init(unsigned long *s, unsign
 	for (p = efi_map_start; p < efi_map_end; pmd = md, p += efi_desc_size) {
 		md = p;
 		if (!efi_wb(md)) {
-			if (efi_uc(md) && md->type = EFI_CONVENTIONAL_MEMORY) {
+			if (efi_uc(md) && (md->type = EFI_CONVENTIONAL_MEMORY ||
+				    	   md->type = EFI_BOOT_SERVICES_DATA)) {
 				k->attribute = EFI_MEMORY_UC;
 				k->start = md->phys_addr;
 				k->num_pages = md->num_pages;
