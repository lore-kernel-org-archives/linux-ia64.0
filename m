From: Laszlo Ersek <lersek@redhat.com>
Date: Mon, 01 Sep 2014 00:53:35 +0000
Subject: [PATCH 0/5] beautify EFI memmap logs
Message-Id: <1409532820-5027-1-git-send-email-lersek@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, msalter@redhat.com, lersek@redhat.com

It's a pain to analyze EFI memmap logs while debugging, especially to
verify the memory types (an enum) and the memory attributes (a bitmap).
This series renders those columns human-readable, and unifies their
formatting between x86, ia64 and arm64.

Example output with the patchset on arm64 (in a qemu-system-aarch64
guest, booted with Ard's v5 series from edk2-devel ("QEMU_EFI.fd")):

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

Output on x86 (OVMF guest):

> [    0.000000] efi: mem00: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000000000-0x000000000009f000) (0MB)
> [    0.000000] efi: mem01: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x000000000009f000-0x00000000000a0000) (0MB)
> [    0.000000] efi: mem02: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000100000-0x0000000000400000) (3MB)
> [    0.000000] efi: mem03: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000400000-0x0000000000800000) (4MB)
> [    0.000000] efi: mem04: [ACPI Memory NVS    |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000800000-0x0000000000808000) (0MB)
> [    0.000000] efi: mem05: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000808000-0x0000000000810000) (0MB)
> [    0.000000] efi: mem06: [ACPI Memory NVS    |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000810000-0x0000000000900000) (0MB)
> [    0.000000] efi: mem07: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000900000-0x0000000001100000) (8MB)
> [    0.000000] efi: mem08: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000001100000-0x0000000001400000) (3MB)
> [    0.000000] efi: mem09: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000001400000-0x0000000002613000) (18MB)
> [    0.000000] efi: mem10: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000002613000-0x0000000004000000) (25MB)
> [    0.000000] efi: mem11: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000004000000-0x0000000004020000) (0MB)
> [    0.000000] efi: mem12: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000004020000-0x00000000068ea000) (40MB)
> [    0.000000] efi: mem13: [Loader Data        |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000068ea000-0x00000000068f0000) (0MB)
> [    0.000000] efi: mem14: [Boot Code          |   |  |  |  |   |WB|WT|WC|UC] range=[0x00000000068f0000-0x0000000006c7b000) (3MB)
> [    0.000000] efi: mem15: [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000006c7b000-0x0000000006c7d000) (0MB)
> [    0.000000] efi: mem16: [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000006c7d000-0x0000000006c85000) (0MB)
> [    0.000000] efi: mem17: [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000006c85000-0x0000000006c87000) (0MB)
> [    0.000000] efi: mem18: [Boot Code          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000006c87000-0x0000000006ca3000) (0MB)
> [    0.000000] efi: mem19: [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000006ca3000-0x0000000006ca6000) (0MB)
> [    0.000000] efi: mem20: [ACPI Memory NVS    |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000006ca6000-0x0000000006cc6000) (0MB)
> [    0.000000] efi: mem21: [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000006cc6000-0x0000000006d95000) (0MB)
> [    0.000000] efi: mem22: [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000006d95000-0x0000000006e22000) (0MB)
> [    0.000000] efi: mem23: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000006e22000-0x0000000007165000) (3MB)
> [    0.000000] efi: mem24: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007165000-0x0000000007d22000) (11MB)
> [    0.000000] efi: mem25: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007d22000-0x0000000007d25000) (0MB)
> [    0.000000] efi: mem26: [Boot Code          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007d25000-0x0000000007ea2000) (1MB)
> [    0.000000] efi: mem27: [Runtime Code       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000007ea2000-0x0000000007ed2000) (0MB)
> [    0.000000] efi: mem28: [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000007ed2000-0x0000000007ef6000) (0MB)
> [    0.000000] efi: mem29: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007ef6000-0x0000000007f00000) (0MB)
> [    0.000000] efi: mem30: [ACPI Reclaim Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007f00000-0x0000000007f02000) (0MB)
> [    0.000000] efi: mem31: [ACPI Memory NVS    |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007f02000-0x0000000007f06000) (0MB)
> [    0.000000] efi: mem32: [Boot Data          |   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007f06000-0x0000000007fd0000) (0MB)
> [    0.000000] efi: mem33: [Runtime Data       |RUN|  |  |  |   |WB|WT|WC|UC] range=[0x0000000007fd0000-0x0000000007ff0000) (0MB)
> [    0.000000] efi: mem34: [Conventional Memory|   |  |  |  |   |WB|WT|WC|UC] range=[0x0000000007ff0000-0x0000000008000000) (0MB)

I can't test the series on ia64.

Thanks,
Laszlo

Laszlo Ersek (5):
  efi: add macro for EFI_MEMORY_UCE memory attribute
  efi: introduce efi_md_typeattr_format()
  x86: efi: format EFI memory type & attrs with efi_md_typeattr_format()
  ia64: efi: format EFI memory type & attrs with
    efi_md_typeattr_format()
  arm64: efi: format EFI memory type & attrs with
    efi_md_typeattr_format()

 include/linux/efi.h         |  8 +++++++
 arch/arm64/kernel/efi.c     | 26 +++++----------------
 arch/ia64/kernel/efi.c      |  6 +++--
 arch/x86/platform/efi/efi.c |  7 ++++--
 drivers/firmware/efi/efi.c  | 57 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 80 insertions(+), 24 deletions(-)

-- 
1.8.3.1

