From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 22 Jul 2015 23:56:41 +0000
Subject: Re: [arch] WARNING: CPU: 0 PID: 0 at kernel/memremap.c:31 memremap()
Message-Id: <CAPcyv4hL79y7Viyb7DySFLaO4odiHDhU_Qt1uOFXZkE6r-h8Vg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <55b02823.YCZlvehUZTMuyZIC%fengguang.wu@intel.com>
In-Reply-To: <55b02823.YCZlvehUZTMuyZIC%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: kernel test robot <fengguang.wu@intel.com>
Cc: LKP <lkp@01.org>, iommu@lists.linux-foundation.org, tlinux-users@tce.toshiba-dme.co.jp, Linux ACPI <linux-acpi@vger.kernel.org>, linux-xtensa@linux-xtensa.org, linux-efi@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, xen-devel@lists.xenproject.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

[ note: this patch is in a dev branch for test coverage, safe to
disregard for now ]

On Wed, Jul 22, 2015 at 4:32 PM, kernel test robot
<fengguang.wu@intel.com> wrote:
> Greetings,
>
> 0day kernel testing robot got the below dmesg and the first bad commit is
>
> git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git pmem-api
>
> commit 163f9409a57082aed03fbeeb321fbf18bdaf5f42
> Author:     Dan Williams <dan.j.williams@intel.com>
> AuthorDate: Wed Jul 22 18:09:01 2015 -0400
> Commit:     Dan Williams <dan.j.williams@intel.com>
> CommitDate: Wed Jul 22 18:09:01 2015 -0400
>
>     arch: introduce memremap(), replace ioremap_cache()
>
>     Existing users of ioremap_cache() are mapping memory that is known in
>     advance to not have i/o side effects.  These users are forced to cast
>     away the __iomem annotation, or otherwise neglect to fix the sparse
>     errors thrown when dereferencing pointers to this memory.  Provide
>     memremap() as a non __iomem annotated ioremap_*() in the case when
>     ioremap is otherwise a pointer to memory.
>
>     The ARCH_HAS_MEMREMAP kconfig symbol is introduced for archs to assert
>     that it is safe to recast / reuse the return value from ioremap as a
>     normal pointer to memory.  In other words, archs that mandate specific
>     accessors for __iomem are not memremap() capable and drivers that car=
e,
>     like pmem, can add a dependency to disable themselves on these archs.
>
>     Note, that memremap is a break from the ioremap implementation pattern
>     of adding a new memremap_<type>() for each mapping type.  Instead,
>     the implementation defines flags that are passed to the central
>     memremap() implementation.
>
>     Outside of ioremap() and ioremap_nocache(), the expectation is that m=
ost
>     calls to ioremap_<type>() are seeking memory-like semantics (e.g.
>     speculative reads, and prefetching permitted).  These callsites can be
>     moved to memremap() over time.
>
>     Cc: Arnd Bergmann <arnd@arndb.de>
>     Acked-by: Andy Shevchenko <andy.shevchenko@gmail.com>
>     Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> +------------------------------------------------+------------+----------=
--+------------+
> |                                                | dc5d38e432 | 163f9409a=
5 | 5dfe2d5864 |
> +------------------------------------------------+------------+----------=
--+------------+
> | boot_successes                                 | 63         | 0        =
  | 0          |
> | boot_failures                                  | 0          | 26       =
  | 19         |
> | WARNING:at_kernel/memremap.c:#memremap()       | 0          | 26       =
  | 19         |
> | backtrace:acpi_load_tables                     | 0          | 26       =
  | 19         |
> | backtrace:acpi_early_init                      | 0          | 26       =
  | 19         |
> | IP-Config:Auto-configuration_of_network_failed | 0          | 0        =
  | 2          |
> +------------------------------------------------+------------+----------=
--+------------+
>
> [    0.227312] ACPI: Core revision 20150619
> [    0.227690] memremap: acpi_os_map_iomem
> [    0.228021] ------------[ cut here ]------------
> [    0.228406] WARNING: CPU: 0 PID: 0 at kernel/memremap.c:31 memremap+0x=
73/0x159()
> [    0.229202] memremap attempted on unknown/mixed range 0x000000000ffe00=
00 size: 4096
> [    0.229829] Modules linked in:
> [    0.230106] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.2.0-rc3-00007-=
g163f940 #1
> [    0.230718]  00000000 00000000 c175bf04 c1489068 c175bf30 c175bf20 c10=
3a1ae 0000001f
> [    0.231456]  c10f6407 00001000 00000001 00000001 c175bf38 c103a1f0 000=
00009 c175bf30
> [    0.232242]  c16b3ecb c175bf4c c175bf68 c10f6407 c16b3f04 0000001f c16=
b3ecb c175bf54
> [    0.232985] Call Trace:
> [    0.233196]  [<c1489068>] dump_stack+0x48/0x60
> [    0.233570]  [<c103a1ae>] warn_slowpath_common+0x89/0xa0
> [    0.234016]  [<c10f6407>] ? memremap+0x73/0x159
> [    0.234396]  [<c103a1f0>] warn_slowpath_fmt+0x2b/0x2f
> [    0.234816]  [<c10f6407>] memremap+0x73/0x159
> [    0.235190]  [<c1486181>] acpi_os_map_iomem+0x10b/0x15f
> [    0.235660]  [<c14861e2>] acpi_os_map_memory+0xd/0xf
> [    0.236089]  [<c1293d5c>] acpi_tb_acquire_table+0x35/0x5a
> [    0.236538]  [<c1293e41>] acpi_tb_validate_table+0x22/0x37
> [    0.237001]  [<c1841255>] acpi_load_tables+0x38/0x146
> [    0.237424]  [<c184080e>] acpi_early_init+0x64/0xd4
> [    0.237830]  [<c1817b14>] start_kernel+0x3e1/0x447
> [    0.238232]  [<c18172bb>] i386_start_kernel+0x85/0x89
> [    0.238734] ---[ end trace cb88537fdc8fa200 ]---
> [    0.239133] ACPI Exception: AE_NO_ACPI_TABLES, While loading namespace=
 from ACPI tables (20150619/tbxfload-80)
>
> git bisect start 5dfe2d5864e91244e7befaa2317519ea15dc9c89 52721d9d3334c1c=
b1f76219a161084094ec634dc --
> git bisect good cfc652fabeee43adf800889a5a4a935a9af090a7  # 07:04     20+=
      0  arch, drivers: don't include <asm/io.h> directly, use <linux/io.h>=
 instead
> git bisect good dc5d38e432ff171125f746d80a037692feb16fc9  # 07:11     22+=
      0  intel_iommu: fix leaked ioremap mapping
> git bisect  bad 163f9409a57082aed03fbeeb321fbf18bdaf5f42  # 07:17      0-=
     22  arch: introduce memremap(), replace ioremap_cache()
> # first bad commit: [163f9409a57082aed03fbeeb321fbf18bdaf5f42] arch: intr=
oduce memremap(), replace ioremap_cache()
> git bisect good dc5d38e432ff171125f746d80a037692feb16fc9  # 07:19     63+=
      0  intel_iommu: fix leaked ioremap mapping
> # extra tests with DEBUG_INFO
> git bisect  bad 163f9409a57082aed03fbeeb321fbf18bdaf5f42  # 07:24      0-=
     29  arch: introduce memremap(), replace ioremap_cache()
> # extra tests on HEAD of nvdimm/pmem-api
> git bisect  bad 5dfe2d5864e91244e7befaa2317519ea15dc9c89  # 07:24      0-=
     19  pmem: convert to generic memremap
> # extra tests on tree/branch nvdimm/pmem-api
> git bisect  bad 5dfe2d5864e91244e7befaa2317519ea15dc9c89  # 07:24      0-=
     19  pmem: convert to generic memremap
> # extra tests on tree/branch linus/master
> git bisect good 5a5ca73ac0a73c876b62858f0753a25ee430e370  # 07:26     66+=
      2  Merge tag 'arm64-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/arm64/linux
> # extra tests on tree/branch linux-next/master
> git bisect good 72a68fd733c8b6cd2e0ebc0586a9103067cd4ed7  # 07:29     65+=
      0  Add linux-next specific files for 20150722
>
>
> This script may reproduce the error.
>
> -------------------------------------------------------------------------=
---
> #!/bin/bash
>
> kernel=3D$1
> initrd=3Dyocto-minimal-i386.cgz
>
> wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/m=
aster/initrd/$initrd
>
> kvm=3D(
>         qemu-system-x86_64
>         -enable-kvm
>         -cpu Haswell,+smep,+smap
>         -kernel $kernel
>         -initrd $initrd
>         -m 256
>         -smp 1
>         -device e1000,netdev=3Dnet0
>         -netdev user,id=3Dnet0
>         -boot order=3Dnc
>         -no-reboot
>         -watchdog i6300esb
>         -rtc base=3Dlocaltime
>         -serial stdio
>         -display none
>         -monitor null
> )
>
> append=3D(
>         hung_task_panic=3D1
>         earlyprintk=3DttyS0,115200
>         systemd.log_level=3Derr
>         debug
>         apic=DEbug
>         sysrq_always_enabled
>         rcupdate.rcu_cpu_stall_timeout=100
>         panic=3D-1
>         softlockup_panic=3D1
>         nmi_watchdog=3Dpanic
>         oops=3Dpanic
>         load_ramdisk=3D2
>         prompt_ramdisk=3D0
>         console=3DttyS0,115200
>         console=3Dtty0
>         vga=3Dnormal
>         root=3D/dev/ram0
>         rw
>         drbd.minor_count=3D8
> )
>
> "${kvm[@]}" --append "${append[*]}"
> -------------------------------------------------------------------------=
---
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter
> https://lists.01.org/pipermail/lkp                          Intel Corpora=
tion
