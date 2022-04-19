From: Wupeng Ma <mawupeng1@huawei.com>
Date: Tue, 19 Apr 2022 06:42:51 +0000
Subject: [PATCH 1/2] arm64/boot/KASLR: Add support to relocate kernel image to mirrored region
Message-Id: <20220419070150.254377-2-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXGSStDgj9ABmUaTLnBmpQFksh3wx4tx=mJohum4GQe3Gg@mail.gmail.com>
 <20220419070150.254377-1-mawupeng1@huawei.com>
In-Reply-To: <20220419070150.254377-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

Add support to relocate kernel image to mirrored regions if KASLR is
enabled.

If a suiable mirrored slot if found, iterate EFI memory map and pick the
mirrored region to process for adding candidate of randomization slot. If
no suitable mirrored region found, alloc memory from non-mirrored regions.

Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
---
 drivers/firmware/efi/libstub/arm64-stub.c  | 52 +++++++++++++++++++++-
 drivers/firmware/efi/libstub/efistub.h     |  7 ++-
 drivers/firmware/efi/libstub/randomalloc.c | 13 +++++-
 3 files changed, 68 insertions(+), 4 deletions(-)

diff --git a/drivers/firmware/efi/libstub/arm64-stub.c b/drivers/firmware/efi/libstub/arm64-stub.c
index 9cc556013d08..39b774853b93 100644
--- a/drivers/firmware/efi/libstub/arm64-stub.c
+++ b/drivers/firmware/efi/libstub/arm64-stub.c
@@ -79,6 +79,51 @@ static bool check_image_region(u64 base, u64 size)
 	return ret;
 }
 
+/* check if system has suitable for kernel to relocate */
+static bool check_mirror_suitable(unsigned long size,
+				   unsigned long align)
+{
+	unsigned long map_size, desc_size;
+	unsigned long buff_size;
+	efi_status_t status;
+	efi_memory_desc_t *memory_map;
+	int map_offset;
+	struct efi_boot_memmap map;
+	bool found = false;
+
+	map.map = &memory_map;
+	map.map_size = &map_size;
+	map.desc_size = &desc_size;
+	map.desc_ver = NULL;
+	map.key_ptr = NULL;
+	map.buff_size = &buff_size;
+
+	status = efi_get_memory_map(&map);
+	if (status != EFI_SUCCESS)
+		return false;
+
+	if (align < EFI_ALLOC_ALIGN)
+		align = EFI_ALLOC_ALIGN;
+
+	size = round_up(size, EFI_ALLOC_ALIGN);
+
+	for (map_offset = 0; map_offset < map_size; map_offset += desc_size) {
+		efi_memory_desc_t *md = (void *)memory_map + map_offset;
+		unsigned long slots;
+
+		/* system has suiable mirrored area */
+		slots = get_entry_num_slots(md, size, ilog2(align));
+		if (slots > 0 && md->attribute & EFI_MEMORY_MORE_RELIABLE) {
+			found = true;
+			break;
+		}
+	}
+
+	efi_bs_call(free_pool, memory_map);
+
+	return found;
+}
+
 efi_status_t handle_kernel_image(unsigned long *image_addr,
 				 unsigned long *image_size,
 				 unsigned long *reserve_addr,
@@ -88,6 +133,7 @@ efi_status_t handle_kernel_image(unsigned long *image_addr,
 	efi_status_t status;
 	unsigned long kernel_size, kernel_memsize = 0;
 	u32 phys_seed = 0;
+	bool efi_mirror_found;
 
 	/*
 	 * Although relocatable kernels can fix up the misalignment with
@@ -127,13 +173,16 @@ efi_status_t handle_kernel_image(unsigned long *image_addr,
 	kernel_memsize = kernel_size + (_end - _edata);
 	*reserve_size = kernel_memsize;
 
+	efi_mirror_found = check_mirror_suitable(*reserve_size, min_kimg_align);
+
 	if (IS_ENABLED(CONFIG_RANDOMIZE_BASE) && phys_seed != 0) {
 		/*
 		 * If KASLR is enabled, and we have some randomness available,
 		 * locate the kernel at a randomized offset in physical memory.
 		 */
 		status = efi_random_alloc(*reserve_size, min_kimg_align,
-					  reserve_addr, phys_seed);
+					  reserve_addr, phys_seed,
+					  efi_mirror_found);
 		if (status != EFI_SUCCESS)
 			efi_warn("efi_random_alloc() failed: 0x%lx\n", status);
 	} else {
@@ -163,6 +212,7 @@ efi_status_t handle_kernel_image(unsigned long *image_addr,
 		}
 	}
 
+out:
 	*image_addr = *reserve_addr;
 	memcpy((void *)*image_addr, _text, kernel_size);
 
diff --git a/drivers/firmware/efi/libstub/efistub.h b/drivers/firmware/efi/libstub/efistub.h
index edb77b0621ea..0cf2e25cb7d0 100644
--- a/drivers/firmware/efi/libstub/efistub.h
+++ b/drivers/firmware/efi/libstub/efistub.h
@@ -790,7 +790,8 @@ void efi_get_virtmap(efi_memory_desc_t *memory_map, unsigned long map_size,
 efi_status_t efi_get_random_bytes(unsigned long size, u8 *out);
 
 efi_status_t efi_random_alloc(unsigned long size, unsigned long align,
-			      unsigned long *addr, unsigned long random_seed);
+			      unsigned long *addr, unsigned long random_seed,
+			      bool efi_has_mirror);
 
 efi_status_t check_platform_features(void);
 
@@ -875,6 +876,10 @@ void efi_handle_post_ebs_state(void);
 
 enum efi_secureboot_mode efi_get_secureboot(void);
 
+extern unsigned long get_entry_num_slots(efi_memory_desc_t *md,
+					 unsigned long size,
+					 unsigned long align_shift);
+
 #ifdef CONFIG_RESET_ATTACK_MITIGATION
 void efi_enable_reset_attack_mitigation(void);
 #else
diff --git a/drivers/firmware/efi/libstub/randomalloc.c b/drivers/firmware/efi/libstub/randomalloc.c
index 724155b9e10d..dd81d6c3c406 100644
--- a/drivers/firmware/efi/libstub/randomalloc.c
+++ b/drivers/firmware/efi/libstub/randomalloc.c
@@ -14,7 +14,7 @@
  * addresses it covers that are suitably aligned and supply enough room
  * for the allocation.
  */
-static unsigned long get_entry_num_slots(efi_memory_desc_t *md,
+unsigned long get_entry_num_slots(efi_memory_desc_t *md,
 					 unsigned long size,
 					 unsigned long align_shift)
 {
@@ -53,7 +53,8 @@ static unsigned long get_entry_num_slots(efi_memory_desc_t *md,
 efi_status_t efi_random_alloc(unsigned long size,
 			      unsigned long align,
 			      unsigned long *addr,
-			      unsigned long random_seed)
+			      unsigned long random_seed,
+			      bool efi_mirror_found)
 {
 	unsigned long map_size, desc_size, total_slots = 0, target_slot;
 	unsigned long buff_size;
@@ -83,6 +84,10 @@ efi_status_t efi_random_alloc(unsigned long size,
 		efi_memory_desc_t *md = (void *)memory_map + map_offset;
 		unsigned long slots;
 
+		if (efi_mirror_found &&
+		    !(md->attribute & EFI_MEMORY_MORE_RELIABLE))
+			continue;
+
 		slots = get_entry_num_slots(md, size, ilog2(align));
 		MD_NUM_SLOTS(md) = slots;
 		total_slots += slots;
@@ -112,6 +117,10 @@ efi_status_t efi_random_alloc(unsigned long size,
 			continue;
 		}
 
+		if (efi_mirror_found &&
+		    !(md->attribute & EFI_MEMORY_MORE_RELIABLE))
+			continue;
+
 		target = round_up(md->phys_addr, align) + target_slot * align;
 		pages = size / EFI_PAGE_SIZE;
 
-- 
2.25.1
