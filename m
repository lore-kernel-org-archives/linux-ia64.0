From: Wupeng Ma <mawupeng1@huawei.com>
Date: Sat, 26 Mar 2022 06:46:25 +0000
Subject: [PATCH 2/9] arm64: efi: Add fake memory support
Message-Id: <20220326064632.131637-3-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326064632.131637-1-mawupeng1@huawei.com>
In-Reply-To: <20220326064632.131637-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zyccr.com, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

Fake memory map is used for faking memory's attribute values.
Commit 0f96a99dab36 ("efi: Add "efi_fake_mem" boot option") introduce the
efi_fake_mem function. Now it can support arm64 with this patch.
For example you can mark 0-6G memory as EFI_MEMORY_MORE_RELIABLE by adding
efi_fake_mem=6G@0:0x10000 in the bootarg. You find more info about
fake memmap in kernel-parameters.txt.

Variable memstart_addr is only confirmed after arm64_memblock_init(). So
efi_fake_memmap() is needed to add after arm64_memblock_init().

Otherwise:

efi_memmap_alloc
   memblock_phys_alloc
     kmemleak_alloc_phys
        kmemleak_alloc(__va(phys), size, min_count, gfp);

this __va() will convert phys to a fault va and lead to a kmemleak error.

Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 2 +-
 arch/arm64/kernel/setup.c                       | 2 ++
 drivers/firmware/efi/Kconfig                    | 2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index b7ccaa2ea867..e064839895ee 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1357,7 +1357,7 @@
 			you are really sure that your UEFI does sane gc and
 			fulfills the spec otherwise your board may brick.
 
-	efi_fake_mem=	nn[KMG]@ss[KMG]:aa[,nn[KMG]@ss[KMG]:aa,..] [EFI; X86]
+	efi_fake_mem=	nn[KMG]@ss[KMG]:aa[,nn[KMG]@ss[KMG]:aa,..] [EFI; X86; ARM64]
 			Add arbitrary attribute to specific memory range by
 			updating original EFI memory map.
 			Region of memory which aa attribute is added to is
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 3505789cf4bd..daade64889ff 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -344,6 +344,8 @@ void __init __no_sanitize_address setup_arch(char **cmdline_p)
 
 	arm64_memblock_init();
 
+	efi_fake_memmap();
+
 	paging_init();
 
 	acpi_table_upgrade();
diff --git a/drivers/firmware/efi/Kconfig b/drivers/firmware/efi/Kconfig
index 2c3dac5ecb36..3c91bbd4097a 100644
--- a/drivers/firmware/efi/Kconfig
+++ b/drivers/firmware/efi/Kconfig
@@ -50,7 +50,7 @@ config EFI_RUNTIME_MAP
 
 config EFI_FAKE_MEMMAP
 	bool "Enable EFI fake memory map"
-	depends on EFI && X86
+	depends on EFI && (X86 || ARM64)
 	default n
 	help
 	  Saying Y here will enable "efi_fake_mem" boot option.
-- 
2.18.0.huawei.25
