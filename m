From: Wupeng Ma <mawupeng1@huawei.com>
Date: Sat, 26 Mar 2022 06:46:23 +0000
Subject: [PATCH 0/9] introduce mirrored memory support for arm64
Message-Id: <20220326064632.131637-1-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zyccr.com, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

Commit b05b9f5f9dcf ("x86, mirror: x86 enabling - find mirrored memory ranges")
introduced mirrored memory support for x86. This support rely on UEFI to
report mirrored memory address ranges.  See UEFI 2.5 spec pages 157-158:

  http://www.uefi.org/sites/default/files/resources/UEFI%202_5.pdf

Arm64 can support this too. So mirrored memory support is added to support
arm64.

Patch #1-#2 introduce efi_fake_mem support for arm64.
Patch #3-#4 introduce mirrored memory support form arm64.
Patch #5-#7 fix some bugs for arm64 if memory reliable is enabled.
Patch #8 disable mirror feature if kernelcore is not specified.
Patch #9 remove some redundant code in ia64 efi_init.

Ma Wupeng (9):
  efi: Make efi_print_memmap() public
  arm64: efi: Add fake memory support
  efi: Make efi_find_mirror() public
  arm64/mirror: arm64 enabling - find mirrored memory ranges
  mm: Ratelimited mirrored memory related warning messages
  mm: Demote warning message in vmemmap_verify() to debug level
  mm: Calc the right pfn if page size is not 4K
  efi: Disable mirror feature if kernelcore is not specified
  ia64/efi: Code simplification in efi_init

 .../admin-guide/kernel-parameters.txt         |  4 +-
 arch/arm64/kernel/setup.c                     |  3 ++
 arch/ia64/kernel/efi.c                        | 37 +-----------------
 arch/x86/include/asm/efi.h                    |  5 ---
 arch/x86/platform/efi/efi.c                   | 39 -------------------
 drivers/firmware/efi/Kconfig                  |  2 +-
 drivers/firmware/efi/efi.c                    | 26 +++++++++++++
 drivers/firmware/efi/memmap.c                 | 16 ++++++++
 include/linux/efi.h                           |  4 ++
 include/linux/mm.h                            |  2 +
 mm/memblock.c                                 |  4 +-
 mm/page_alloc.c                               |  4 +-
 mm/sparse-vmemmap.c                           |  2 +-
 13 files changed, 60 insertions(+), 88 deletions(-)

-- 
2.18.0.huawei.25
