From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 08 Aug 2005 13:51:12 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <yq0ek948rlb.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Tony> But it still doesn't really do what the comment claims it will
Tony> do.  The "attribute" field is a bitmask ... most of the memory
Tony> that was dropped because of holes or incompatible attributes
Tony> within the same granule will also have other allowable
Tony> attributes.  So final version of this should be checking
Tony> "md->attribute & EFI_MEMORY_UC" rather than "=".

Tony,

What about this then? I looked a bit further at treating the attribute
bit as a bitmask, however it doesn't really make sense as we can't
really use uncached memory which has the write protect bit set for
instance (I see those in the EFI mem map on the SN2). Worse is that I
have also seen regions marked both uncached and writeback which seems
pretty absurd, but to avoid getting trapped by these I think it's
safer to stick to using '='.

This patch is modelled on Alex's suggestion of using
is_available_memory().

Cheers,
Jes

Only grab uncached pages from the boot services data section to avoid
grabbing memory mapped IO regions by mistake. Regions which have other
attributes set besides the uncached bit are unsuitable as well
(eg. write protect etc).

Signed-off-by: Jes Sorensen <jes@trained-monkey.org>

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -409,6 +409,24 @@ efi_memmap_walk (efi_freemem_callback_t 
 	}
 }
 
+static inline int
+is_available_uc_memory (efi_memory_desc_t *md)
+{
+	if (!(md->attribute = EFI_MEMORY_UC))
+		return 0;
+
+	switch (md->type) {
+	case EFI_LOADER_CODE:
+	case EFI_LOADER_DATA:
+	case EFI_BOOT_SERVICES_CODE:
+	case EFI_BOOT_SERVICES_DATA:
+	case EFI_CONVENTIONAL_MEMORY:
+		return 1;
+	}
+
+	return 0;
+}
+
 /*
  * Walk the EFI memory map to pull out leftover pages in the lower
  * memory regions which do not end up in the regular memory map and
@@ -431,7 +449,7 @@ efi_memmap_walk_uc (efi_freemem_callback
 
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
-		if (md->attribute = EFI_MEMORY_UC) {
+		if (is_available_uc_memory(md)) {
 			start = PAGE_ALIGN(md->phys_addr);
 			end = PAGE_ALIGN((md->phys_addr+(md->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK);
 			if ((*callback)(start, end, NULL) < 0)
