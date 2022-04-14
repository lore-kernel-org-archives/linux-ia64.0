From: Wupeng Ma <mawupeng1@huawei.com>
Date: Thu, 14 Apr 2022 09:54:18 +0000
Subject: [PATCH v2 4/9] arm64/mirror: arm64 enabling - find mirrored memory ranges
Message-Id: <20220414101314.1250667-5-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220414101314.1250667-1-mawupeng1@huawei.com>
In-Reply-To: <20220414101314.1250667-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zyccr.com, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

Commit b05b9f5f9dcf ("x86, mirror: x86 enabling - find mirrored memory ranges")
introduced mirrored memory support for x86 and this could be used on arm64.

So efi_find_mirror() is added in efi_init() so on EFI enabled systems scan
the memory map and tell memblock about any mirrored ranges.

Signed-off-by: Ma Wupeng <mawupeng1@huawei.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 2 +-
 arch/arm64/kernel/setup.c                       | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index ea47c0ba7593..1d87dc4e3cef 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2270,7 +2270,7 @@
 
 	keepinitrd	[HW,ARM]
 
-	kernelcore=	[KNL,X86,IA-64,PPC]
+	kernelcore=	[KNL,X86,IA-64,PPC,ARM64]
 			Format: nn[KMGTPE] | nn% | "mirror"
 			This parameter specifies the amount of memory usable by
 			the kernel for non-movable allocations.  The requested
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index daade64889ff..3957290d9ade 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -345,6 +345,7 @@ void __init __no_sanitize_address setup_arch(char **cmdline_p)
 	arm64_memblock_init();
 
 	efi_fake_memmap();
+	efi_find_mirror();
 
 	paging_init();
 
-- 
2.18.0.huawei.25
