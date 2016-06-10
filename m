From: Robert Richter <robert.richter@cavium.com>
Date: Fri, 10 Jun 2016 10:26:15 +0000
Subject: Re: [PATCH v7 00/15] ACPI NUMA support for ARM64
Message-Id: <20160610102615.GI1535@rric.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
 <6187968.ZZVJRAFzpv@vostro.rjw.lan>
 <20160610102005.GH1535@rric.localdomain>
In-Reply-To: <20160610102005.GH1535@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, David Daney <david.daney@cavium.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Lv Zheng <lv.zheng@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Frank Rowand <frowand.list@gmail.com>, x86@kernel.org, Robert Moore <robert.moore@intel.com>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Grant Likely <grant.likely@linaro.org>, Len Brown <lenb@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Marc Zyngier <Marc.Zyngier@arm.com>, Rob Herring <robh+dt@kernel.org>, David Daney <ddaney.cavm@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, devel@acpica.org, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Hanjun Guo <hanjun.guo@linaro.org>

On 10.06.16 12:20:05, Robert Richter wrote:
> On 04.06.16 00:07:04, Rafael J. Wysocki wrote:
> > On Tuesday, May 24, 2016 03:35:30 PM David Daney wrote:
> > > From: David Daney <david.daney@cavium.com>
> > > 
> > > Rebased to Linus' master branch at commit 1d6da87a3241 ("Merge branch
> > > 'drm-next' of git://people.freedesktop.org/~airlied/linux")
> > > 
> > > ACPI 5.1 already introduced NUMA support for ARM64, which can get the
> > > NUMA domain information from SRAT and SLIT table, so parse those two
> > > tables to get mappings from cpu/mem to numa node configuration and
> > > system locality.
> > > 
> > > v7 updates:
> > > 
> > >  - Rebased to resolve one merge conflict.
> > > 
> > >  - New patch 13/15 to enable use of existing MADT parsing code instead
> > >    of adding an additional implementation of the parser.
> > > 
> > >  - Added some Acked-by headers to patches in arm64 arch directories.
> > > 
> > > v6 updates:
> > > 
> > >  - Changed message printed in 13/14 to omit meaningless "cpu"
> > >    number. (noted by Dennis Chen and Hanjun Guo)
> > > 
> > >  - New patch 7/14 to print different messages for NUMA disabled case.
> > >    (noted by Dennis Chen)
> > > 
> > >  - Squashed two patches into 14/14.
> > > 
> > >  - Added Reviewed-by to 4/14
> > > 
> > > v5 updates:
> > > 
> > >  - Fixed ia64 build failure by gating some unused functions with #if
> > >    CONFIG_{X86,ARM64}.
> > > 
> > >  - Fixed section mismatch errors for X86 case.
> > > 
> > >  - Removed unneeded #include from some files.
> > > 
> > >  - Tested to build cleanly on ARM64, X86_64, IA64
> > > 
> > > v4 updates:
> > > 
> > >  - Updated from Hanjun Guo's v3 patches.
> > > 
> > >  - Rebased on top of v16 of device-tree NUMA patches.
> > > 
> > >  - Reordered some of the changes so that we don't introduce code and
> > >    then change it several times in the patch set.  New code is
> > >    introduced in its final form.  Code reused from x86 is first moved
> > >    with no change, and then a separate patch to make any needed
> > >    changes.
> > > 
> > >  - code that is used only by ia64, moved to architecture specific
> > >    files.
> > > 
> > > v3 updates:
> > >  - Deep investigation about the ACPI_DEBUG_PRINT() and remvoe
> > >    that for acpi/numa.c (patch 2/12)
> > > 
> > >  - Remove the duplicate NULL check for table print (patch 3/12)
> > > 
> > >  - Introduce CONFIG_ACPI_HAS_NUMA_ARCH_FIXUP to remove duplicate
> > >    dummy function for acpi_numa_arch_fixup()
> > > 
> > >  - Solve the problem that the mapping from logical cpu to numa node
> > >    is wrong which spotted out by Lorenzo
> > > 
> > >  - cleanups for x86 and move acpi_numa_slit_init() and some other
> > >    functions to common place, then reduce the duplicate of x86
> > >    and arm64 (patch 7-12/12).
> > > 
> > >  - rebased on top of 4.4 and Ganapat's v9 patch set.
> > > 
> > > David Daney (4):
> > >   arm64, numa: Cleanup NUMA disabled messages.
> > >   acpi, numa: move bad_srat() and srat_disabled() to
> > >     drivers/acpi/numa.c
> > >   acpi, numa, srat: Improve SRAT error detection and add messages.
> > >   ACPI / processor: Add acpi_map_madt_entry().
> > > 
> > > Hanjun Guo (10):
> > >   acpi, numa: Use pr_fmt() instead of printk
> > >   acpi, numa: Replace ACPI_DEBUG_PRINT() with pr_debug()
> > >   acpi, numa: remove duplicate NULL check
> > >   acpi, numa: move acpi_numa_slit_init() to drivers/acpi/numa.c
> > >   arm64, numa: rework numa_add_memblk()
> > >   x86, acpi, numa: cleanup acpi_numa_processor_affinity_init()
> > >   acpi, numa: remove unneeded acpi_numa=1
> > >   acpi, numa: Move acpi_numa_memory_affinity_init() to
> > >     drivers/acpi/numa.c
> > >   arm64, acpi, numa: NUMA support based on SRAT and SLIT
> > >   acpi, numa: Enable ACPI based NUMA on ARM64
> > > 
> > > Robert Richter (1):
> > >   acpi, numa: Move acpi_numa_arch_fixup() to ia64 only
> > > 
> > >  arch/arm64/include/asm/acpi.h |   8 ++
> > >  arch/arm64/include/asm/numa.h |   2 +
> > >  arch/arm64/kernel/Makefile    |   1 +
> > >  arch/arm64/kernel/acpi_numa.c | 112 +++++++++++++++++++++
> > >  arch/arm64/kernel/smp.c       |   2 +
> > >  arch/arm64/mm/numa.c          |  28 ++++--
> > >  arch/ia64/include/asm/acpi.h  |   3 +
> > >  arch/ia64/kernel/acpi.c       |   2 +-
> > >  arch/ia64/kernel/setup.c      |   1 +
> > >  arch/x86/include/asm/acpi.h   |   1 -
> > >  arch/x86/mm/numa.c            |   2 +-
> > >  arch/x86/mm/srat.c            | 116 +---------------------
> > >  drivers/acpi/Kconfig          |   4 +-
> > >  drivers/acpi/numa.c           | 226 ++++++++++++++++++++++++++++++++----------
> > >  drivers/acpi/processor_core.c |  26 ++++-
> > >  drivers/of/of_numa.c          |   4 +-
> > >  include/acpi/acpi_numa.h      |   4 +
> > >  include/acpi/processor.h      |   1 +
> > >  include/linux/acpi.h          |  18 +++-
> > >  19 files changed, 369 insertions(+), 192 deletions(-)
> > >  create mode 100644 arch/arm64/kernel/acpi_numa.c
> > 
> > All [1-15/15] queued up for 4.8, thanks!
> 
> Rafael,
> 
> I noticed patch #15 missing in your today's tree, I only found:
> 
>  d8b47fca8c23 arm64, ACPI, NUMA: NUMA support based on SRAT and SLIT
> 
> Is this intended? It still cleanly applies.

Ah, just seen Matthias' comment, I guess we need to resend a fixed
version.

-Robert
