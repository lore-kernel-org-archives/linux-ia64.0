From: Ard Biesheuvel <ardb@kernel.org>
Date: Mon, 23 May 2022 14:41:58 +0000
Subject: Re: [PATCH 0/2] Add support to relocate kernel image to mirrored region
Message-Id: <CAMj1kXE_xc4FvdOLqfK+awqTqoGje=Gy7bmVUFTZY_hjw1K9=w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXGSStDgj9ABmUaTLnBmpQFksh3wx4tx=mJohum4GQe3Gg@mail.gmail.com>
 <20220419070150.254377-1-mawupeng1@huawei.com> <CAMj1kXHr2RdYSPor1st1ZnL=O42c8N6e=bNG+eFhatfefWLUrw@mail.gmail.com>
 <c65d22b4-f654-21aa-bd5f-d4f8b0939a25@huawei.com> <7058b8d8-c0cb-108e-0db9-2fdf5fb154cf@huawei.com>
 <CAMj1kXHnL12j6FPGtEeSQB2-kHzoVF+LJMUF9YBq43Yi1UntDg@mail.gmail.com> <7a1ce182-343a-75f9-5447-f7ca12cb0c36@huawei.com>
In-Reply-To: <7a1ce182-343a-75f9-5447-f7ca12cb0c36@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: mawupeng <mawupeng1@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Mike Rapoport <rppt@kernel.org>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Joerg Roedel <jroedel@suse.de>, songmuchun@bytedance.com, macro@orcam.me.uk, Frederic Weisbecker <frederic@kernel.org>, W_Armin@gmx.de, John Garry <john.garry@huawei.com>, Sean Christopherson <seanjc@google.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Anshuman Khandual <anshuman.khandual@arm.com>, chenhuacai@kernel.org, David Hildenbrand <david@redhat.com>, gpiccoli@igalia.com, Mark Rutland <mark.rutland@arm.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Mon, 23 May 2022 at 03:18, mawupeng <mawupeng1@huawei.com> wrote:
>
>
>
> 在 2022/5/20 14:52, Ard Biesheuvel 写道:
> > On Thu, 19 May 2022 at 13:09, mawupeng <mawupeng1@huawei.com> wrote:
> >>
> >>
> >>
> >> 在 2022/5/7 17:28, mawupeng 写道:
> >>>
> >>>
> >>> 在 2022/5/3 17:58, Ard Biesheuvel 写道:
> >>>> On Tue, 19 Apr 2022 at 08:43, Wupeng Ma <mawupeng1@huawei.com> wrote:
> >>>>>
> >>>>> From: Ma Wupeng <mawupeng1@huawei.com>
> >>>>>
> >>>>> Now system image will perfer to be located to mirrored regions both KASLR
> >>>>> on and off.
> >>>>>
> >>>>
> >>>> Hello Ma Wupeng,
> >>>>
> >>>> I wonder if we could simplify this as follows:
> >>>> - ignore the non-KASLR case for now, and rely on the bootloader  > load the image into mirrored memory if it exists;
> >>>
> >>> In grub, memory for static image is allocated via the following path:
> >>>
> >>> grub_cmd_linux
> >>>     kernel = grub_malloc(filelen)
> >>>     kernel_alloc_addr = grub_efi_allocate_any_pages (kernel_alloc_pages)
> >>>     grub_memcpy (kernel_addr, kernel, grub_min(filelen, kernel_size))
> >>>      grub_loader_set (grub_linux_boot, grub_linux_unload, 0)
> >>>
> >>> Can we get memory from mirrored region by the following steps:
> >>> 1. get memory map by calling grub_efi_get_memory_map()
> >>> 2. iter all memory map to find a suitable mirrored memory area
> >>> 3. locate kernel image to this area
> >>>
> >>> So, if kaslr is not enabled
> >>>    - grub will load kernel into mirrored region
> >>> else
> >>>    - arm64-stub.c will relocate kernel image to mirrored region
> >>>
> >>> Is this feasible?
> >>
> >> Is this a feasible proposal to relocate the static kernel image itself
> >> into more reliable memory?
> >>
> >
> > I'm not sure, it all depends on the firmware.
> >
> > When GRUB calls LoadImage(), the firmware will reallocate the image
> > and unpack it there. So it is really the firmware's job to ensure that
> > the image is loaded into a suitable location.
> >
> > I have some code here that implements a EFI based decompressor, and
> > which loads the kernel image into mirrored memory if it exists,
> > without the need to move it again. It could trivially be modified to
> > deal with non-randomized loads as well.
> >
> > But the bottom line is that UEFI should expose the ability to target
> > mirrored memory, hacking around it like this is not a sustainable
> > approach.
>
> Since firmware is responsible for put kernel static image into mirrored
> region and kernel is responsible for relocate this image into mirrored
> region if kaslr is enabled. There is no conflict between these two.
>
> Can we integrate the kernel part(introduce mirrored support to arm64) first?
>

Yes. If you drop the changes related to fake memmap and rebase, please
resend them after -rc1 is released.
