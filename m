From: Ard Biesheuvel <ardb@kernel.org>
Date: Tue, 29 Mar 2022 08:26:02 +0000
Subject: Re: [PATCH 0/9] introduce mirrored memory support for arm64
Message-Id: <CAMj1kXEwzJE8V-tqJJwZ-RqHB3atKJvoRZ8C6_EVM7caNbttxw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326064632.131637-1-mawupeng1@huawei.com>
In-Reply-To: <20220326064632.131637-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wupeng Ma <mawupeng1@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, hpa@zyccr.com, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Mike Rapoport <rppt@kernel.org>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Joerg Roedel <jroedel@suse.de>, songmuchun@bytedance.com, macro@orcam.me.uk, Frederic Weisbecker <frederic@kernel.org>, W_Armin@gmx.de, John Garry <john.garry@huawei.com>, Sean Christopherson <seanjc@google.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Anshuman Khandual <anshuman.khandual@arm.com>, chenhuacai@kernel.org, David Hildenbrand <david@redhat.com>, gpiccoli@igalia.com, Mark Rutland <mark.rutland@arm.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 26 Mar 2022 at 07:27, Wupeng Ma <mawupeng1@huawei.com> wrote:
>
> From: Ma Wupeng <mawupeng1@huawei.com>
>
> Commit b05b9f5f9dcf ("x86, mirror: x86 enabling - find mirrored memory ranges")
> introduced mirrored memory support for x86. This support rely on UEFI to
> report mirrored memory address ranges.  See UEFI 2.5 spec pages 157-158:
>
>   http://www.uefi.org/sites/default/files/resources/UEFI%202_5.pdf
>
> Arm64 can support this too. So mirrored memory support is added to support
> arm64.
>

What is the point of this if the kernel itself is not loaded in
EFI_MORE_RELIABLE memory? On x86, this is handled by the decompressor,
but that does not exist on arm64.

The problem here is that UEFI defines this as a memory *attribute*
rather than a memory *type*, which means you cannot allocate
EFI_MORE_RELIABLE memory easily: you have to iterate over the memory
map and look for regions with the desired attribute, and allocate
those pages explicitly. I'd prefer to implement this in the
bootloader, and only add minimal logic to the stub to respect the
placement of the kernel by the loader if the loader signals it to do
so (there are other reasons for this - I will cc you on a patch
shortly that implements this)

This also means that the fake_mem stuff is not going to work: the
memory map observed by the stub comes straight from the firmware, and
if the stub needs to be involved in placing (or respecting the
placement by the loader of) the kernel image, it needs to observe
those EFI_MORE_RELIABLE regions too. If you don't have access to a
machine that actually exposes EFI_MORE_RELIABLE memory, I suggest you
prototype it in QEMU/edk2 instead.

In fact, we have been trying very hard not to touch the firmware
provided memory map at all on ARM, rather than use it as a scratchpad
for all kinds of annotations. This means, for instance, that kexec is
idempotent - the next kernel should not be affected by modifications
to the memory map applied by the previous kernel.

In summary, implementing kernelcore=mirror for arm64 is fine with me,
but there are some issues we need to address first.




> Patch #1-#2 introduce efi_fake_mem support for arm64.
> Patch #3-#4 introduce mirrored memory support form arm64.
> Patch #5-#7 fix some bugs for arm64 if memory reliable is enabled.
> Patch #8 disable mirror feature if kernelcore is not specified.
> Patch #9 remove some redundant code in ia64 efi_init.
>
> Ma Wupeng (9):
>   efi: Make efi_print_memmap() public
>   arm64: efi: Add fake memory support
>   efi: Make efi_find_mirror() public
>   arm64/mirror: arm64 enabling - find mirrored memory ranges
>   mm: Ratelimited mirrored memory related warning messages
>   mm: Demote warning message in vmemmap_verify() to debug level
>   mm: Calc the right pfn if page size is not 4K
>   efi: Disable mirror feature if kernelcore is not specified
>   ia64/efi: Code simplification in efi_init
>
>  .../admin-guide/kernel-parameters.txt         |  4 +-
>  arch/arm64/kernel/setup.c                     |  3 ++
>  arch/ia64/kernel/efi.c                        | 37 +-----------------
>  arch/x86/include/asm/efi.h                    |  5 ---
>  arch/x86/platform/efi/efi.c                   | 39 -------------------
>  drivers/firmware/efi/Kconfig                  |  2 +-
>  drivers/firmware/efi/efi.c                    | 26 +++++++++++++
>  drivers/firmware/efi/memmap.c                 | 16 ++++++++
>  include/linux/efi.h                           |  4 ++
>  include/linux/mm.h                            |  2 +
>  mm/memblock.c                                 |  4 +-
>  mm/page_alloc.c                               |  4 +-
>  mm/sparse-vmemmap.c                           |  2 +-
>  13 files changed, 60 insertions(+), 88 deletions(-)
>
> --
> 2.18.0.huawei.25
>
