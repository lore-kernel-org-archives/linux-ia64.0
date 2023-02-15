From: Ard Biesheuvel <ardb@kernel.org>
Date: Wed, 15 Feb 2023 11:22:12 +0000
Subject: Re: [RFC PATCH 2/5] kernel: Drop IA64 support from sig_fault handlers
Message-Id: <CAMj1kXGYcLLaJQfYjcjvAnFbb+MAWQF-2BzeUGJTqBu4V=ejNw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org> <20230215100008.2565237-3-ardb@kernel.org>
 <ea12dd12-db17-44a8-8c29-6b0a129f355d@app.fastmail.com> <62e7ab37-1148-4cf1-8d6a-3da440fa623f@app.fastmail.com>
In-Reply-To: <62e7ab37-1148-4cf1-8d6a-3da440fa623f@app.fastmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Wed, 15 Feb 2023 at 12:15, Arnd Bergmann <arnd@arndb.de> wrote:
>
> On Wed, Feb 15, 2023, at 11:19, Arnd Bergmann wrote:
> >
> > I can probably do the same recursive check for removed Kconfig
> > options that I used for finding dead code after the boardfile
> > removal.
>
> FWIW, here is the list from a bit of scripting.

Thanks

> Symbols that
> are only defined in arch/ia64 but are referenced elsewhere are:
>
> CONFIG_IA64
> CONFIG_IA64_PAGE_SIZE_64KB
> CONFIG_IA64_SGI_UV
> CONFIG_IA64_DEBUG_CMPXCHG
> CONFIG_MSPEC

These are all gone from the code after applying this series.

> Kconfig symbols that are only selected in arch/ia64 but
> defined elsewhere are
>
> CONFIG_ARCH_HAS_DMA_MARK_CLEAN
> CONFIG_ARCH_TASK_STRUCT_ALLOCATOR
> CONFIG_ARCH_TASK_STRUCT_ON_STACK
> CONFIG_ARCH_THREAD_STACK_ALLOCATOR
> CONFIG_GENERIC_IRQ_LEGACY
>

I can follow up with patches that remove all of those as well once we
progress on this series.

> plus a few that have only one or two other places selecting them:
>
> CONFIG_ARCH_CLOCKSOURCE_DATA (sparc64)
> CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC (x86)
> CONFIG_ATA_NONSTANDARD (powerpc-maple)
> CONFIG_FUNCTION_ALIGNMENT_32B (i386)
> CONFIG_HUGETLB_PAGE_SIZE_VARIABLE (powerpc64)
> CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT (x86, loongarch)
> CONFIG_ARCH_BINFMT_ELF_EXTRA_PHDRS (arm64, arch/um 32-bit)
> CONFIG_HAVE_FUNCTION_DESCRIPTORS (ppc64be, parisc64)
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK (parisc, x86)
> CONFIG_HAVE_VIRT_CPU_ACCOUNTING (powerpc, s390)
> CONFIG_SYSCTL_ARCH_UNALIGN_NO_WARN (arc, loongarch)
>
>       Arnd
