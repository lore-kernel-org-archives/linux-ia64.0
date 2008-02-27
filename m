From: Russ Anderson <rja@sgi.com>
Date: Wed, 27 Feb 2008 01:05:01 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080227010500.GC23088@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 26, 2008 at 05:34:19PM -0700, Alex Chiang wrote:
> * Russ Anderson <rja@sgi.com>:
> > 
> > That causes ia64_sal_physical_id_info() to fail on my Altix.  :-(
> 
> Did it work before?

Yes.
 
> > ------------------------------------------------------------------
> > Shell> fs1:efi\suse\elilo net0:rja/vmlinux.rja.2624 root=/dev/sda8 console=ttySG0 kdb=on
> > ELILO
> > Uncompressing Linux... done
> > Initializing cgroup subsys cpuset
> > Linux version 2.6.24 (rja@attica) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #39 SMP Tue Feb 26 18:08:59 CST 2008
> > EFI v1.10 by INTEL: SALsystab=0x6002c25290 ACPI 2.0=0x6002c25b10
> > console [sn_sal0] enabled
> > ACPI: RSDP 6002C25B10, 0024 (r2    SGI)
> > ACPI: XSDT 6002C29270, 0044 (r1    SGI  XSDTSN2    10001           5C)
> > ACPI: APIC 6002C25BB0, 00D4 (r1    SGI  APICSN2    10001            1)
> > ACPI: SRAT 6002C25CA0, 0200 (r1    SGI  SRATSN2    10001            1)
> > ACPI: SLIT 6002C25EB0, 0050 (r1    SGI  SLITSN2    10001            1)
> > ACPI: FACP 6002C25F20, 00F4 (r3    SGI  FACPSN2    30001            1)
> > ACPI: DSDT 6002C28D90, 0024 (r2    SGI  DSDTSN2    20001          4C4)
> > ACPI: FACS 6002C25380, 0040
> > Number of logical nodes in system = 6
> > Number of memory chunks in system = 6
> > SAL 2.9: SGI SN2 version 1.30
> 
> I wouldn't expect SAL 2.9 to implement a call defined in SAL 3.2,
> unless I'm seriously misunderstanding something?

I will ask one of our SAL developers where the 2.9 comes from.
The 1.30 number is our SAL (prom) version.  It started at 1.00 with
SGI Altix 4700.
 
> > SAL Platform features: ITC_Drift
> > SAL: AP wakeup using external interrupt vector 0x12
> > ia64_sal_pltid failed with -1
> 
> Annoying noise, I agree with you.

More than annoying.  An indication of a problem.

> > ACPI: Local APIC address c0000000fee00000
> > register_intr: No IOSAPIC for GSI 52
> > 14 CPUs available, 14 CPUs total
> 
> More annoying noise; I thought about removing or changing that
> printk the first time around to something like KERN_INFO since
> failure of that particular SAL call doesn't really affect any
> functionality.
> 
> Opinions?
> 
> > Brought up 14 CPUs
> > Total of 14 processors activated (44793.85 BogoMIPS).
> > ------------------------------------------------------------------------------
> > 
> > 
> > saturn1-10:~ # cat /proc/cpuinfo
> > processor  : 0
> > vendor     : GenuineIntel
> > arch       : IA-64
> > family     : 32
> > model      : 1
> > model name : Dual-Core Intel(R) Itanium(R) Processor 9150M
> 
> This looks like a Montvale? That means we *should* be getting
> meaningful "physical id" information from /proc/cpuinfo. :(

Correct.  

> What values were you getting before my workaround above?

See below.

> And again, the more interesting question is, why is your SAL
> reporting a revision of 2.9?

I'll find out.  

> Thanks.
> 
> /ac
> 
> > revision   : 0
> > archrev    : 0
> > features   : branchlong, 16-byte atomic ops
> > cpu number : 0
> > cpu regs   : 4
> > cpu MHz    : 1669.503
> > itc MHz    : 416.875000
> > BogoMIPS   : 3325.95
> > siblings   : 1
-----------------------------------------------------------

Without the change:

saturn1-10:~ # cat /proc/cpuinfo
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) Processor 9150M
revision   : 0
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1669.000503
itc MHz    : 416.875000
BogoMIPS   : 3325.95
siblings   : 2
physical id: 0
core id    : 0
thread id  : 0

processor  : 1
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) Processor 9150M
revision   : 0
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1669.000503
itc MHz    : 416.875000
BogoMIPS   : 3325.95
siblings   : 2
physical id: 0
core id    : 1
thread id  : 0



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
