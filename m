From: Will Deacon <will.deacon@arm.com>
Date: Wed, 11 May 2016 10:40:32 +0000
Subject: Re: [PATCH v6 00/14] ACPI NUMA support for ARM64
Message-Id: <20160511104032.GA31374@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
 <CAJZ5v0iMDQ4pWip4vyCos0o+1DFDvXQf4XZQqC4SGjJsDO4Lnw@mail.gmail.com>
In-Reply-To: <CAJZ5v0iMDQ4pWip4vyCos0o+1DFDvXQf4XZQqC4SGjJsDO4Lnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: David Daney <ddaney.cavm@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "devel@acpica.org" <devel>

On Wed, May 11, 2016 at 02:43:11AM +0200, Rafael J. Wysocki wrote:
> On Wed, Apr 27, 2016 at 8:07 PM, David Daney <ddaney.cavm@gmail.com> wrote:
> > From: David Daney <david.daney@cavium.com>
> >
> > Based on git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git
> > for-next/core branch at commit 643d703d2d2d ("arm64: compat: Check for
> > AArch32 state")

[...]

> > David Daney (2):
> >   arm64, numa: Cleanup NUMA disabled messages.
> >   acpi, numa, srat: Improve SRAT error detection and add messages.
> >
> > Hanjun Guo (11):
> >   acpi, numa: Use pr_fmt() instead of printk
> >   acpi, numa: Replace ACPI_DEBUG_PRINT() with pr_debug()
> >   acpi, numa: remove duplicate NULL check
> >   acpi, numa: move acpi_numa_slit_init() to drivers/acpi/numa.c
> >   arm64, numa: rework numa_add_memblk()
> >   x86, acpi, numa: cleanup acpi_numa_processor_affinity_init()
> >   acpi, numa: move bad_srat() and srat_disabled() to
> >     drivers/acpi/numa.c
> >   acpi, numa: remove unneeded acpi_numa=1
> >   acpi, numa: Move acpi_numa_memory_affinity_init() to
> >     drivers/acpi/numa.c
> >   arm64, acpi, numa: NUMA support based on SRAT and SLIT
> >   acpi, numa: Enable ACPI based NUMA on ARM64
> >
> > Robert Richter (1):
> >   acpi, numa: Move acpi_numa_arch_fixup() to ia64 only
> 
> I need ACKs from the ARM64 maintainers on patches [6-7/13] and [13-14/14].

There's also a dependency on the arm64 for-next/core branch, so I've been
largely ignoring this as far as 4.6 is concerned and was planning to take
a proper look for 4.7 once the upcoming merge window is out of the way.

Will
