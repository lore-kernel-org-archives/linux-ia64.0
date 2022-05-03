From: Ard Biesheuvel <ardb@kernel.org>
Date: Tue, 03 May 2022 09:58:49 +0000
Subject: Re: [PATCH 0/2] Add support to relocate kernel image to mirrored region
Message-Id: <CAMj1kXHr2RdYSPor1st1ZnL=O42c8N6e=bNG+eFhatfefWLUrw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXGSStDgj9ABmUaTLnBmpQFksh3wx4tx=mJohum4GQe3Gg@mail.gmail.com>
 <20220419070150.254377-1-mawupeng1@huawei.com>
In-Reply-To: <20220419070150.254377-1-mawupeng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wupeng Ma <mawupeng1@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Mike Rapoport <rppt@kernel.org>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Joerg Roedel <jroedel@suse.de>, songmuchun@bytedance.com, macro@orcam.me.uk, Frederic Weisbecker <frederic@kernel.org>, W_Armin@gmx.de, John Garry <john.garry@huawei.com>, Sean Christopherson <seanjc@google.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Anshuman Khandual <anshuman.khandual@arm.com>, chenhuacai@kernel.org, David Hildenbrand <david@redhat.com>, gpiccoli@igalia.com, Mark Rutland <mark.rutland@arm.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 19 Apr 2022 at 08:43, Wupeng Ma <mawupeng1@huawei.com> wrote:
>
> From: Ma Wupeng <mawupeng1@huawei.com>
>
> Now system image will perfer to be located to mirrored regions both KASLR
> on and off.
>

Hello Ma Wupeng,

I wonder if we could simplify this as follows:
- ignore the non-KASLR case for now, and rely on the bootloader to
load the image into mirrored memory if it exists;
- simplify the KASLR case to the below.

I think this is reasonable, because it means we take mirrored memory
into account when we decide to move the image anyway, but expect the
boot chain to take care of this if there is no need to move the image.

-------------8<------------------
--- a/drivers/firmware/efi/libstub/randomalloc.c
+++ b/drivers/firmware/efi/libstub/randomalloc.c
@@ -56,6 +56,7 @@ efi_status_t efi_random_alloc(unsigned long size,
                              unsigned long random_seed)
 {
        unsigned long map_size, desc_size, total_slots = 0, target_slot;
+       unsigned long total_mirrored_slots = 0;
        unsigned long buff_size;
        efi_status_t status;
        efi_memory_desc_t *memory_map;
@@ -86,8 +87,14 @@ efi_status_t efi_random_alloc(unsigned long size,
                slots = get_entry_num_slots(md, size, ilog2(align));
                MD_NUM_SLOTS(md) = slots;
                total_slots += slots;
+               if (md->attribute & EFI_MEMORY_MORE_RELIABLE)
+                       total_mirrored_slots += slots;
        }

+       /* only consider mirrored slots for randomization if any exist */
+       if (total_mirrored_slots > 0)
+               total_slots = total_mirrored_slots;
+
        /* find a random number between 0 and total_slots */
        target_slot = (total_slots * (u64)(random_seed & U32_MAX)) >> 32;

@@ -107,6 +114,10 @@ efi_status_t efi_random_alloc(unsigned long size,
                efi_physical_addr_t target;
                unsigned long pages;

+               if (total_mirrored_slots > 0 &&
+                   !(md->attribute & EFI_MEMORY_MORE_RELIABLE))
+                       continue;
+
                if (target_slot >= MD_NUM_SLOTS(md)) {
                        target_slot -= MD_NUM_SLOTS(md);
                        continue;
