From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Wed, 17 Mar 2021 21:14:24 +0000
Subject: Re: [PATCH 0/1] sched/topology: NUMA distance deduplication
Message-Id: <20210317211424.33090a37@sf>
List-Id: <linux-ia64.vger.kernel.org>
References: <255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de>
        <8735wtr2ro.mognet@arm.com>
        <cf4d7277-54a0-8bc7-60fb-9b2f6befb511@physik.fu-berlin.de>
        <87zgz1pmx4.mognet@arm.com>
In-Reply-To: <87zgz1pmx4.mognet@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <valentin.schneider@arm.com>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, debian-ia64 <debian-ia64@lists.debian.org>

On Wed, 17 Mar 2021 20:04:07 +0000
Valentin Schneider <valentin.schneider@arm.com> wrote:

> On 17/03/21 20:47, John Paul Adrian Glaubitz wrote:
> > Helo Valentin!
> >
> > On 3/17/21 8:36 PM, Valentin Schneider wrote:  
> >> I see ACPI in your boot logs, so I'm guessing you have a bogus SLIT table
> >> (the ACPI table with node distances). You should be able to double check
> >> this with something like:
> >>
> >> $ acpidump > acpi.dump
> >> $ acpixtract -a acpi.dump
> >> $ iasl -d *.dat
> >> $ cat slit.dsl  
> >
> > There does not seem to be a SLIT table in my firmware:
> >
> > root@glendronach:~# acpidump > acpi.dump
> > root@glendronach:~# acpixtract -a acpi.dump
> >
> > Intel ACPI Component Architecture
> > ACPI Binary Table Extraction Utility version 20200925
> > Copyright (c) 2000 - 2020 Intel Corporation
> >
> > acpixtract(31194): unaligned access to 0x60000fffff9b3925, ip=0x4000000000003e91
> >   SSDT -    3768 bytes written (0x00000EB8) - ssdt1.dat
> > acpixtract(31194): unaligned access to 0x60000fffff9b3925, ip=0x4000000000003e00
> > acpixtract(31194): unaligned access to 0x60000fffff9b3925, ip=0x4000000000003e91
> >   SPCR -      80 bytes written (0x00000050) - spcr.dat
> > acpixtract(31194): unaligned access to 0x60000fffff9b3925, ip=0x4000000000003e00
> > acpixtract(31194): unaligned access to 0x60000fffff9b3925, ip=0x4000000000003e91
> >   APIC -     200 bytes written (0x000000C8) - apic.dat
> >   SSDT -    1110 bytes written (0x00000456) - ssdt2.dat
> >   SSDT -     316 bytes written (0x0000013C) - ssdt3.dat
> >   SPMI -      80 bytes written (0x00000050) - spmi.dat
> >   DSDT -   58726 bytes written (0x0000E566) - dsdt.dat
> >   SSDT -     312 bytes written (0x00000138) - ssdt4.dat
> >   SSDT -    2150 bytes written (0x00000866) - ssdt5.dat
> >   SSDT -     316 bytes written (0x0000013C) - ssdt6.dat
> >   SSDT -    3768 bytes written (0x00000EB8) - ssdt7.dat
> >   FACP -     244 bytes written (0x000000F4) - facp.dat
> >   SSDT -    1203 bytes written (0x000004B3) - ssdt8.dat
> >   CPEP -      52 bytes written (0x00000034) - cpep.dat
> >   SSDT -     316 bytes written (0x0000013C) - ssdt9.dat
> >   DBGP -      52 bytes written (0x00000034) - dbgp.dat
> >   SSDT -    3768 bytes written (0x00000EB8) - ssdt10.dat
> >   FACS -      64 bytes written (0x00000040) - facs.dat
> > root@glendronach:~#
> >
> > root@glendronach:~# ls *.dsl *.dat
> > apic.dat  cpep.dsl  dsdt.dat  facp.dsl  spcr.dat  spmi.dsl    ssdt1.dat  ssdt2.dsl  ssdt4.dat  ssdt5.dsl  ssdt7.dat  ssdt8.dsl
> > apic.dsl  dbgp.dat  dsdt.dsl  facs.dat  spcr.dsl  ssdt10.dat  ssdt1.dsl  ssdt3.dat  ssdt4.dsl  ssdt6.dat  ssdt7.dsl  ssdt9.dat
> > cpep.dat  dbgp.dsl  facp.dat  facs.dsl  spmi.dat  ssdt10.dsl  ssdt2.dat  ssdt3.dsl  ssdt5.dat  ssdt6.dsl  ssdt8.dat  ssdt9.dsl
> > root@glendronach:~#
> >  
> 
> Huh, then this might be some initialization fail that leaves nr_node_ids to
> MAX_NUMNODES, which must be 256 in your case (NODES_SHIFT=8). Devicetree
> can provide node distances, but something tells me you're not using that :-)
> 
> >> a) Complain to your hardware vendor to have them fix the table and ship a
> >>    firmware fix  
> >
> > The hardware is probably too old for the vendor to care about fixing it.
> >  
> 
> Indeed, I only realized that after googling your machine
> 
> >> b) Fix the ACPI table yourself - I've been told it's doable for *some* of
> >>    them, but I've never done that myself
> >> c) Compile your kernel with CONFIG_NUMA=n, as AFAICT you only actually have
> >>    a single node
> >> d) Ignore the warning
> >>
> >>
> >> c) is clearly not ideal if you want to use a somewhat generic kernel image
> >> on a wide host of machines; d) is also a bit yucky...  
> >
> > Shouldn't the kernel be able to cope with quirky hardware? From what I remember in the past,
> > ACPI tables used to be broken quite a lot and the kernel contained workarounds for such cases,
> > didn't it?
> >  
> 
> Technically it *is* coping with it, it's just dumping the entire NUMA
> distance matrix in the process... Let me see if I can't figure out why your
> system doesn't end up with nr_node_ids=1.

I also poked at it a few days ago assuming it was an issue causing boot
failures (it was not, it's a harmless warning).

Looking at 'arch/ia64/**' NUMA presence is detected by SRAT ACPI
tables (and generic ACPI also wants SLIT, those probably exist on large
ia64 boxes?)

None of SRAT/SLIT are present on these small machines, thus I would
expect generic code to  erive single fake node. Boot log suggests we even
inferred 1 node system:

> [    0.040000] smp: Brought up 1 node, 4 CPUs

Or is it just an early bootstrap message assuming more are to come?

Could it be that we initialize too little of generic acpi boilerplace
when there is no SRAT? Somewhere around:

    https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/ia64/kernel/acpi.c#n446

arm64 and riscv calls `arch_numa_init()` and initializes numa node
data in numa_init().
While ia64 only calls acpi_numa_init() but not arch_acpi_numa_init()
(which would do numa_init() for us).

x86 seems to vaguely resemble generic code by duplicating numa_init().

(UNTESTED) Could it be that we need something like:

--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -571,7 +571,7 @@ setup_arch (char **cmdline_p)
        acpi_table_init();
        early_acpi_boot_init();
 #ifdef CONFIG_ACPI_NUMA
-       acpi_numa_init();
+       arch_numa_init();
        acpi_numa_fixup();
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
        prefill_possible_map();

-- 

  Sergei
