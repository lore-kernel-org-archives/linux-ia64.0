From: Wupeng Ma <mawupeng1@huawei.com>
Date: Tue, 19 Apr 2022 06:42:49 +0000
Subject: [PATCH 2/2] arm64/boot: Add support to relocate kernel image to mirrored region without kaslr
Message-Id: <20220419070150.254377-3-mawupeng1@huawei.com>
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

Add support to relocate kernel image to mirrord regions if KASLR doesn't
work.

If a suiable mirrored slot if found, call efi_random_alloc() with
random_seed be zero to relocate kernel code and data to the first slot
available.

Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
---
 drivers/firmware/efi/libstub/arm64-stub.c  | 10 ++++++++++
 drivers/firmware/efi/libstub/randomalloc.c |  1 +
 2 files changed, 11 insertions(+)

diff --git a/drivers/firmware/efi/libstub/arm64-stub.c b/drivers/firmware/efi/libstub/arm64-stub.c
index 39b774853b93..851a8948cafb 100644
--- a/drivers/firmware/efi/libstub/arm64-stub.c
+++ b/drivers/firmware/efi/libstub/arm64-stub.c
@@ -190,6 +190,16 @@ efi_status_t handle_kernel_image(unsigned long *image_addr,
 	}
 
 	if (status != EFI_SUCCESS) {
+		if (efi_mirror_found) {
+			status = efi_random_alloc(*reserve_size, min_kimg_align,
+					  reserve_addr, 0,
+					  efi_mirror_found);
+			if (status = EFI_SUCCESS)
+				goto out;
+
+			efi_err("Failed to relocate kernel to mirrored region\n");
+		}
+
 		if (!check_image_region((u64)_text, kernel_memsize)) {
 			efi_err("FIRMWARE BUG: Image BSS overlaps adjacent EFI memory region\n");
 		} else if (IS_ALIGNED((u64)_text, min_kimg_align)) {
diff --git a/drivers/firmware/efi/libstub/randomalloc.c b/drivers/firmware/efi/libstub/randomalloc.c
index dd81d6c3c406..d5f4249943a7 100644
--- a/drivers/firmware/efi/libstub/randomalloc.c
+++ b/drivers/firmware/efi/libstub/randomalloc.c
@@ -50,6 +50,7 @@ unsigned long get_entry_num_slots(efi_memory_desc_t *md,
  */
 #define MD_NUM_SLOTS(md)	((md)->virt_addr)
 
+/* random_seed = 0 means alloc mem from the first suitable slot */
 efi_status_t efi_random_alloc(unsigned long size,
 			      unsigned long align,
 			      unsigned long *addr,
-- 
2.25.1
