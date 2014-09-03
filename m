From: Laszlo Ersek <lersek@redhat.com>
Date: Wed, 03 Sep 2014 11:32:23 +0000
Subject: [PATCH v2 5/5] arm64: efi: format EFI memory type & attrs with efi_md_typeattr_format()
Message-Id: <1409743943-16934-6-git-send-email-lersek@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409743943-16934-1-git-send-email-lersek@redhat.com>
In-Reply-To: <1409743943-16934-1-git-send-email-lersek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@kernel.org, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, msalter@redhat.com, lersek@redhat.com

An example log excerpt demonstrating the change:

Before the patch:

> Processing EFI memory map:
>   0x000040000000-0x000040000fff [Loader Data]
>   0x000040001000-0x00004007ffff [Conventional Memory]
>   0x000040080000-0x00004072afff [Loader Data]
>   0x00004072b000-0x00005fdfffff [Conventional Memory]
>   0x00005fe00000-0x00005fe0ffff [Loader Data]
>   0x00005fe10000-0x0000964e8fff [Conventional Memory]
>   0x0000964e9000-0x0000964e9fff [Loader Data]
>   0x0000964ea000-0x000096c52fff [Loader Code]
>   0x000096c53000-0x00009709dfff [Boot Code]*
>   0x00009709e000-0x0000970b3fff [Runtime Code]*
>   0x0000970b4000-0x0000970f4fff [Runtime Data]*
>   0x0000970f5000-0x000097117fff [Runtime Code]*
>   0x000097118000-0x000097199fff [Runtime Data]*
>   0x00009719a000-0x0000971dffff [Runtime Code]*
>   0x0000971e0000-0x0000997f8fff [Conventional Memory]
>   0x0000997f9000-0x0000998f1fff [Boot Data]*
>   0x0000998f2000-0x0000999eafff [Conventional Memory]
>   0x0000999eb000-0x00009af09fff [Boot Data]*
>   0x00009af0a000-0x00009af21fff [Conventional Memory]
>   0x00009af22000-0x00009af46fff [Boot Data]*
>   0x00009af47000-0x00009af5bfff [Conventional Memory]
>   0x00009af5c000-0x00009afe1fff [Boot Data]*
>   0x00009afe2000-0x00009afe2fff [Conventional Memory]
>   0x00009afe3000-0x00009c01ffff [Boot Data]*
>   0x00009c020000-0x00009efbffff [Conventional Memory]
>   0x00009efc0000-0x00009f14efff [Boot Code]*
>   0x00009f14f000-0x00009f162fff [Runtime Code]*
>   0x00009f163000-0x00009f194fff [Runtime Data]*
>   0x00009f195000-0x00009f197fff [Boot Data]*
>   0x00009f198000-0x00009f198fff [Runtime Data]*
>   0x00009f199000-0x00009f1acfff [Conventional Memory]
>   0x00009f1ad000-0x00009f1affff [Boot Data]*
>   0x00009f1b0000-0x00009f1b0fff [Runtime Data]*
>   0x00009f1b1000-0x00009fffffff [Boot Data]*
>   0x000004000000-0x000007ffffff [Memory Mapped I/O]
>   0x000009010000-0x000009010fff [Memory Mapped I/O]

After the patch:

> Processing EFI memory map:
>   0x000040000000-0x000040000fff [Loader Data        |   |  |  |  |   |WB|WT|WC|UC]
>   0x000040001000-0x00004007ffff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x000040080000-0x00004072afff [Loader Data        |   |  |  |  |   |WB|WT|WC|UC]
>   0x00004072b000-0x00005fdfffff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x00005fe00000-0x00005fe0ffff [Loader Data        |   |  |  |  |   |WB|WT|WC|UC]
>   0x00005fe10000-0x0000964e8fff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x0000964e9000-0x0000964e9fff [Loader Data        |   |  |  |  |   |WB|WT|WC|UC]
>   0x0000964ea000-0x000096c52fff [Loader Code        |   |  |  |  |   |WB|WT|WC|UC]
>   0x000096c53000-0x00009709dfff [Boot Code          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009709e000-0x0000970b3fff [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x0000970b4000-0x0000970f4fff [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x0000970f5000-0x000097117fff [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x000097118000-0x000097199fff [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x00009719a000-0x0000971dffff [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x0000971e0000-0x0000997f8fff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x0000997f9000-0x0000998f1fff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x0000998f2000-0x0000999eafff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x0000999eb000-0x00009af09fff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009af0a000-0x00009af21fff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x00009af22000-0x00009af46fff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009af47000-0x00009af5bfff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x00009af5c000-0x00009afe1fff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009afe2000-0x00009afe2fff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x00009afe3000-0x00009c01ffff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009c020000-0x00009efbffff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x00009efc0000-0x00009f14efff [Boot Code          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009f14f000-0x00009f162fff [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x00009f163000-0x00009f194fff [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x00009f195000-0x00009f197fff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009f198000-0x00009f198fff [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x00009f199000-0x00009f1acfff [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC]
>   0x00009f1ad000-0x00009f1affff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x00009f1b0000-0x00009f1b0fff [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC]*
>   0x00009f1b1000-0x00009fffffff [Boot Data          |   |  |  |  |   |WB|WT|WC|UC]*
>   0x000004000000-0x000007ffffff [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC]
>   0x000009010000-0x000009010fff [Memory Mapped I/O  |RUN|  |  |  |   |  |  |  |UC]

The attribute bitmap is now displayed, in decoded form.

Signed-off-by: Laszlo Ersek <lersek@redhat.com>
---
 arch/arm64/kernel/efi.c | 26 ++++++--------------------
 1 file changed, 6 insertions(+), 20 deletions(-)

diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index 03aaa99..3b1f23c 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -119,23 +119,6 @@ static int __init uefi_init(void)
 	return retval;
 }
 
-static __initdata char memory_type_name[][32] = {
-	{"Reserved"},
-	{"Loader Code"},
-	{"Loader Data"},
-	{"Boot Code"},
-	{"Boot Data"},
-	{"Runtime Code"},
-	{"Runtime Data"},
-	{"Conventional Memory"},
-	{"Unusable Memory"},
-	{"ACPI Reclaim Memory"},
-	{"ACPI Memory NVS"},
-	{"Memory Mapped I/O"},
-	{"MMIO Port Space"},
-	{"PAL Code"},
-};
-
 /*
  * Return true for RAM regions we want to permanently reserve.
  */
@@ -166,10 +149,13 @@ static __init void reserve_regions(void)
 		paddr = md->phys_addr;
 		npages = md->num_pages;
 
-		if (uefi_debug)
-			pr_info("  0x%012llx-0x%012llx [%s]",
+		if (uefi_debug) {
+			char buf[64];
+
+			pr_info("  0x%012llx-0x%012llx %s",
 				paddr, paddr + (npages << EFI_PAGE_SHIFT) - 1,
-				memory_type_name[md->type]);
+				efi_md_typeattr_format(buf, sizeof(buf), md));
+		}
 
 		memrange_efi_to_native(&paddr, &npages);
 		size = npages << PAGE_SHIFT;
-- 
1.8.3.1

