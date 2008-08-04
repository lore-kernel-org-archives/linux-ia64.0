From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Mon, 04 Aug 2008 19:46:46 +0000
Subject: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080804194646.GA17390@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Bisection on an x455 (2-node IA64) showed that commit
27ec4407790d075c325e1f4da0a19c56953cce23 (sched: make cpu_clock()
globally synchronous) broke booting. I see the uncompressing initramfs
message and then nothing on the console. I wait about 5 minutes (which
is way longer than it takes for the first console messages to get
printed normally). The commit immediately before it works fine.

The commit no longer cleanly reverts, but I tried to manually put things
back to the way they were before in cpu_clock(). The resulting kernel
boots fine. I could figure out a clean way to leave cpu_clock() in
sched_clock.c because of all the rq dependencies from sched.c. The
attempt I tested is below [1]. This patch is *NOT* for inclusion, just
to demonstrate what I tested.

I'm happy to test any better patches.

Bootlog is also below [2].

Sorry for the long time between the commit and this report. I was
looking through some automated results and noticed this box
spontaneously stopped generating results a while ago and had some free
time to investigate.

Not sure if the unaligned messages in the booting log are indicative of
a problem in my patch or if they were introduced at some point after the
bad commit and current -git...

[1]

diff --git a/kernel/sched.c b/kernel/sched.c
index 21f7da9..0ae90d6 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -9136,3 +9136,22 @@ struct cgroup_subsys cpuacct_subsys = {
 	.subsys_id = cpuacct_subsys_id,
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
+
+unsigned long long cpu_clock(int cpu)
+{
+	unsigned long long now;
+	unsigned long flags;
+	struct rq *rq;
+
+	if (unlikely(!scheduler_running))
+		return 0;
+
+	local_irq_save(flags);
+	rq = cpu_rq(cpu);
+	update_rq_clock(rq);
+	now = rq->clock;
+	local_irq_restore(flags);
+
+	return now;
+}
+EXPORT_SYMBOL_GPL(cpu_clock);
diff --git a/kernel/sched_clock.c b/kernel/sched_clock.c
index 22ed55d..0bce56b 100644
--- a/kernel/sched_clock.c
+++ b/kernel/sched_clock.c
@@ -320,26 +320,3 @@ void sched_clock_idle_wakeup_event(u64 delta_ns)
 EXPORT_SYMBOL_GPL(sched_clock_idle_wakeup_event);
 
 #endif
-
-/*
- * Scheduler clock - returns current time in nanosec units.
- * This is default implementation.
- * Architectures and sub-architectures can override this.
- */
-unsigned long long __attribute__((weak)) sched_clock(void)
-{
-	return (unsigned long long)jiffies * (NSEC_PER_SEC / HZ);
-}
-
-unsigned long long cpu_clock(int cpu)
-{
-	unsigned long long clock;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	clock = sched_clock_cpu(cpu);
-	local_irq_restore(flags);
-
-	return clock;
-}
-EXPORT_SYMBOL_GPL(cpu_clock);

[2]

[    0.000000] Linux version 2.6.27-rc1-00000-g54e558c (root@elm3a170.beaverton.ibm.com) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #32 SMP Mon Aug 4 12:23:11 PDT 2008
[    0.000000] EFI v1.10 by INTEL: SALsystab=0x1eec2000 ACPI 2.0=0xf1100 SMBIOS=0xf1000
[    0.000000] booting generic kernel on platform dig
[    0.000000] ACPI: RSDP 000F1100, 0024 (r2 IBM   )
[    0.000000] ACPI: XSDT 1EF00050, 0064 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: APIC 1EF000C0, 02A8 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: SRAT 1EF00370, 0240 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: OEM0 1EF005B0, 00A0 (r1 IBM    RIOTABLE        3 IBM         1)
[    0.000000] ACPI: FACP 1EF006E0, 00F4 (r3 IBM    SERMOW          3 IBM         1)
[    0.000000] ACPI: DSDT 1EF00850, 8E0E (r32 IBM    SERMOWC0      100 INTL  2002041)
[    0.000000] ACPI: FACS 1EF1FD80, 0040
[    0.000000] ACPI: DBGP 1EF007E0, 0034 (r1 IBM    SERMOW          1 IBM         1)
[    0.000000] ACPI: IPPT 1EF00820, 0028 (r1 IBM    SERMOW          3 IBM         1)
[    0.000000] ACPI: SSDT 1EF09660, 66B9 (r32 IBM    SERMOWC1      100 INTL  2002041)
[    0.000000] ACPI: SSDT 1EF0FD20, 10038 (r32 IBM    SERMOWVR        1 MSFT  100000E)
[    0.000000] Number of logical nodes in system = 2
[    0.000000] Number of memory chunks in system = 10
[    0.000000] Initial ramdisk at: 0xe00000001acf7000 (2679092 bytes)
[    0.000000] SAL 3.0:  IBM                              x455 (8688-xxx)                 version 3.0
[    0.000000] SAL Platform features: None
[    0.000000] SAL: AP wakeup using external interrupt vector 0xff
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] ia64_native_iosapic_pcat_compat_init: Disabling PC-AT compatible 8259 interrupts
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] ACPI: [APIC:0x07] ignored 8 entries of 16 found
[    0.000000] PLATFORM int INIT (0x2): GSI 44 (edge, low) -> CPU 0 (0x0000) vector 48
[    0.000000] PLATFORM int PMI (0x1): GSI 46 (edge, low) -> CPU 0 (0x0000) vector 3
[    0.000000] PLATFORM int INIT (0x2): GSI 91 (edge, low) -> CPU 0 (0x0000) vector 49
[    0.000000] PLATFORM int INIT (0x2): GSI 92 (edge, low) -> CPU 0 (0x0000) vector 50
[    0.000000] PLATFORM int INIT (0x2): GSI 93 (edge, low) -> CPU 0 (0x0000) vector 51
[    0.000000] PLATFORM int INIT (0x2): GSI 94 (edge, low) -> CPU 0 (0x0000) vector 52
[    0.000000] PLATFORM int INIT (0x2): GSI 95 (edge, low) -> CPU 0 (0x0000) vector 53
[    0.000000] PLATFORM int INIT (0x2): GSI 96 (edge, low) -> CPU 0 (0x0000) vector 54
[    0.000000] PLATFORM int INIT (0x2): GSI 97 (edge, low) -> CPU 0 (0x0000) vector 55
[    0.000000] PLATFORM int INIT (0x2): GSI 98 (edge, low) -> CPU 0 (0x0000) vector 56
[    0.000000] Reassigning vector 3 to 57
[    0.000000] PLATFORM int PMI (0x1): GSI 136 (edge, low) -> CPU 8 (0x1000) vector 3
[    0.000000] PLATFORM int INIT (0x2): GSI 146 (edge, low) -> CPU 8 (0x1000) vector 58
[    0.000000] Reassigning vector 3 to 59
[    0.000000] PLATFORM int PMI (0x1): GSI 148 (edge, low) -> CPU 8 (0x1000) vector 3
[    0.000000] PLATFORM int INIT (0x2): GSI 193 (edge, low) -> CPU 8 (0x1000) vector 60
[    0.000000] PLATFORM int INIT (0x2): GSI 194 (edge, low) -> CPU 8 (0x1000) vector 61
[    0.000000] PLATFORM int INIT (0x2): GSI 195 (edge, low) -> CPU 8 (0x1000) vector 62
[    0.000000] PLATFORM int INIT (0x2): GSI 196 (edge, low) -> CPU 8 (0x1000) vector 63
[    0.000000] PLATFORM int INIT (0x2): GSI 197 (edge, low) -> CPU 8 (0x1000) vector 64
[    0.000000] PLATFORM int INIT (0x2): GSI 198 (edge, low) -> CPU 8 (0x1000) vector 65
[    0.000000] PLATFORM int INIT (0x2): GSI 199 (edge, low) -> CPU 8 (0x1000) vector 66
[    0.000000] PLATFORM int INIT (0x2): GSI 200 (edge, low) -> CPU 8 (0x1000) vector 67
[    0.000000] PLATFORM int CPEI (0x3): GSI 19 (edge, low) -> CPU 0 (0x0000) vector 30
[    0.000000] register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level
[    0.000000] register_intr: changing vector 37 from IO-SAPIC-edge to IO-SAPIC-level
[    0.000000] 8 CPUs available, 8 CPUs total
[    0.000000] MCA related initialization done
[    0.000000] Virtual mem_map starts at 0xa0007fffef280000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000400 -> 0x00040000
[    0.000000]   Normal   0x00040000 -> 0x004d0000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0: 0x00000400 -> 0x00006f84
[    0.000000]     0: 0x00006fa0 -> 0x00006fd7
[    0.000000]     0: 0x00007000 -> 0x00007800
[    0.000000]     0: 0x00008000 -> 0x00020000
[    0.000000]     0: 0x00040000 -> 0x001a0000
[    0.000000]     1: 0x00400000 -> 0x004d0000
[    0.000000] On node 0 totalpages: 1569723
[    0.000000] free_area_init_node: node 0, pgdat e000000001140000, node_mem_map a0007fffef280000
[    0.000000]   DMA zone: 127038 pages, LIFO batch:7
[    0.000000]   Normal zone: 1436864 pages, LIFO batch:7
[    0.000000] On node 1 totalpages: 851968
[    0.000000] free_area_init_node: node 1, pgdat e000001000050080, node_mem_map a0007ffffd280000
[    0.000000]   Normal zone: 849056 pages, LIFO batch:7
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 2412958
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-2.6.27-rc1-00000-g54e558c root=/dev/sda2 console=tty0 console=ttyS0,115200n8 ro
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] CPU 0: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    0.916781] Console: colour VGA+ 80x25
[    0.916786] console [tty0] enabled
[    0.982859] Placing software IO TLB between 0x4dec000 - 0x8dec000
[    2.315446] Memory: 38529616k/38730112k available (7947k code, 217440k reserved, 4455k data, 1728k init)
[    2.315994] SLUB: Genslabs, HWalign8, Order=0-3, MinObjects=0, CPUs=8, Nodes24
[    2.316275] Calibrating delay loop... 2392.06 BogoMIPS (lpjG84128)
[    2.421057] Dentry cache hash table entries: 8388608 (order: 12, 67108864 bytes)
[    2.614396] Inode-cache hash table entries: 4194304 (order: 11, 33554432 bytes)
[    2.712379] Mount-cache hash table entries: 1024
[    2.713458] ACPI: Core revision 20080609
[    2.719540] Boot processor id 0x0/0x0
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] CPU 1: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] CPU 2: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] CPU 3: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] CPU 4: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] CPU 5: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] CPU 6: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    0.000000] TR register number exceeds IA64_TR_ALLOC_MAX!IA64_TR_ALLOC_MAX should be extended
[    0.000000] CPU 7: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
[    2.735262] Brought up 8 CPUs
[    2.735378] Total of 8 processors activated (19136.51 BogoMIPS).
[    2.742351] net_namespace: 552 bytes
[    2.742483] DMI 2.3 present.
[    2.742978] NET: Registered protocol family 16
[    2.743958] ACPI: bus type pci registered
[    2.751597] ACPI: EC: Look up EC in DSDT
[    3.883081] ACPI: Interpreter enabled
[    3.883197] ACPI: (supports S0 S5)
[    3.883350] ACPI: Using IOSAPIC for interrupt routing
[    3.894060] ACPI: PCI Root Bridge [P000] (0000:00)
[    3.897610] pci 0000:00:03.0: Boot video device
[    3.897632] pci 0000:00:03.0: supports D1
[    3.897634] pci 0000:00:03.0: supports D2
[    3.899067] pci 0000:00:05.4: quirk: region 0440-044f claimed by vt82c686 SMB
[    3.899366] ACPI: PCI Interrupt Routing Table [\_SB_.P000._PRT]
[    3.900622] ACPI: PCI Root Bridge [P001] (0000:01)
[    3.903448] pci 0000:01:03.0: supports D1
[    3.903450] pci 0000:01:03.0: supports D2
[    3.903743] pci 0000:01:03.1: supports D1
[    3.903745] pci 0000:01:03.1: supports D2
[    3.904070] pci 0000:01:04.0: PME# supported from D3hot D3cold
[    3.904207] pci 0000:01:04.0: PME# disabled
[    3.904623] pci 0000:01:04.1: PME# supported from D3hot D3cold
[    3.904758] pci 0000:01:04.1: PME# disabled
[    3.905020] ACPI: PCI Interrupt Routing Table [\_SB_.P001._PRT]
[    3.905851] ACPI: PCI Root Bridge [P002] (0000:02)
[    3.909213] ACPI: PCI Interrupt Routing Table [\_SB_.P002._PRT]
[    3.909547] ACPI: PCI Root Bridge [P010] (0000:05)
[    3.912906] ACPI: PCI Interrupt Routing Table [\_SB_.P010._PRT]
[    3.913165] ACPI: PCI Root Bridge [P011] (0000:07)
[    3.916491] ACPI: PCI Interrupt Routing Table [\_SB_.P011._PRT]
[    3.916772] ACPI: PCI Root Bridge [P012] (0000:09)
[    3.920126] ACPI: PCI Interrupt Routing Table [\_SB_.P012._PRT]
[    3.920461] ACPI: PCI Root Bridge [P100] (0000:40)
[    3.924993] pci 0000:40:05.4: quirk: region 8440-844f claimed by vt82c686 SMB
[    3.925301] ACPI: PCI Interrupt Routing Table [\_SB_.P100._PRT]
[    3.926194] ACPI: PCI Root Bridge [P101] (0000:41)
[    3.929062] pci 0000:41:03.0: supports D1
[    3.929064] pci 0000:41:03.0: supports D2
[    3.929381] pci 0000:41:03.1: supports D1
[    3.929383] pci 0000:41:03.1: supports D2
[    3.929736] pci 0000:41:04.0: PME# supported from D3hot D3cold
[    3.929871] pci 0000:41:04.0: PME# disabled
[    3.930314] pci 0000:41:04.1: PME# supported from D3hot D3cold
[    3.930450] pci 0000:41:04.1: PME# disabled
[    3.930734] ACPI: PCI Interrupt Routing Table [\_SB_.P101._PRT]
[    3.931598] ACPI: PCI Root Bridge [P102] (0000:42)
[    3.935010] ACPI: PCI Interrupt Routing Table [\_SB_.P102._PRT]
[    3.935350] ACPI: PCI Root Bridge [P110] (0000:45)
[    3.938726] ACPI: PCI Interrupt Routing Table [\_SB_.P110._PRT]
[    3.938991] ACPI: PCI Root Bridge [P111] (0000:47)
[    3.942372] ACPI: PCI Interrupt Routing Table [\_SB_.P111._PRT]
[    3.942771] ACPI: PCI Root Bridge [P112] (0000:49)
[    3.946152] ACPI: PCI Interrupt Routing Table [\_SB_.P112._PRT]
[    3.946648] ACPI: PCI Interrupt Link [IDI0] (IRQs *14)
[    3.946915] ACPI: PCI Interrupt Link [IDI1] (IRQs *116)
[    3.947605] Linux Plug and Play Support v0.97 (c) Adam Belay
[    3.947851] pnp: PnP ACPI init
[    3.947974] ACPI: bus type pnp registered
[    3.967144] pnp: PnP ACPI: found 17 devices
[    3.967263] ACPI: ACPI bus type pnp unregistered
[    3.968234] SCSI subsystem initialized
[    3.968836] usbcore: registered new interface driver usbfs
[    3.969193] usbcore: registered new interface driver hub
[    3.969509] usbcore: registered new device driver usb
[    4.014652] system 00:00: iomem range 0x80000000-0x82400000 could not be reserved
[    4.014875] system 00:00: iomem range 0xfeb00000-0xfebfffff has been reserved
[    4.015010] system 00:00: iomem range 0xfec00000-0xfeffffff has been reserved
[    4.015144] system 00:00: iomem range 0xfff00000-0xffffffff has been reserved
[    4.015283] system 00:02: ioport range 0x440-0x44f has been reserved
[    4.015415] system 00:02: ioport range 0x4c0-0x4c0 has been reserved
[    4.015546] system 00:02: ioport range 0x4d0-0x4d1 has been reserved
[    4.015677] system 00:02: ioport range 0xed8-0xedf has been reserved
[    4.015807] system 00:02: ioport range 0xee0-0xeef has been reserved
[    4.015937] system 00:02: ioport range 0xef0-0xef3 has been reserved
[    4.016069] system 00:02: ioport range 0xef4-0xef7 has been reserved
[    4.016199] system 00:02: ioport range 0xef8-0xef9 has been reserved
[    4.016329] system 00:02: ioport range 0xefa-0xefb has been reserved
[    4.016460] system 00:02: ioport range 0xf00-0xf7f has been reserved
[    4.016591] system 00:02: ioport range 0xf80-0xfff has been reserved
[    4.016727] system 00:0a: iomem range 0xa0000000-0xbfffffff could not be reserved
[    4.018608] NET: Registered protocol family 2
[    4.071526] IP route cache hash table entries: 2097152 (order: 10, 16777216 bytes)
[    4.090698] TCP established hash table entries: 524288 (order: 9, 8388608 bytes)
[    4.115269] TCP bind hash table entries: 65536 (order: 6, 1048576 bytes)
[    4.121945] TCP: Hash tables configured (established 524288 bind 65536)
[    4.122079] TCP reno registered
[    4.134968] NET: Registered protocol family 1
[    4.135300] checking if image is initramfs... it is
[    4.390235] Freeing initrd memory: 2608kB freed
[    4.390449] perfmon: version 2.0 IRQ 238
[    4.390583] perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
[    1.663920] perfmon: added sampling format default_format
[    1.664158] perfmon_default_smpl: default_format v2.0 registered
[    1.664364] Summit chipset: Starting Cyclone Counter.
[    1.695170] HugeTLB registered 256 MB page size, pre-allocated 0 pages
[    1.707682] msgmni has been set to 32768
[    1.708732] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
[    1.709083] io scheduler noop registered
[    1.709271] io scheduler anticipatory registered
[    1.709463] io scheduler deadline registered
[    1.710075] io scheduler cfq registered (default)
[    1.711064] input: Power Button (FF) as /class/input/input0
[    1.711265] ACPI: Power Button (FF) [PWRF]
[    1.712948] processor ACPI0007:00: registered as cooling_device0
[    1.713361] processor ACPI0007:01: registered as cooling_device1
[    1.713776] processor ACPI0007:02: registered as cooling_device2
[    1.714191] processor ACPI0007:03: registered as cooling_device3
[    1.714609] processor ACPI0007:04: registered as cooling_device4
[    1.715014] processor ACPI0007:05: registered as cooling_device5
[    1.715422] processor ACPI0007:06: registered as cooling_device6
[    1.715837] processor ACPI0007:07: registered as cooling_device7
[    1.837601] mspec 4.0 initialized devices:  Cached, Uncached
[    1.837805] EFI Time Services Driver v0.4
[    1.838143] Serial: 8250/16550 driver6 ports, IRQ sharing enabled
[    1.840435] 00:04: ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
[    1.840674] console [ttyS0] enabled
[    2.903626] brd: module loaded
[    2.909807] loop: module loaded
[    2.913656] tg3.c:v3.93 (May 22, 2008)
[    2.917837] GSI 42 (level, low) -> CPU 0 (0x0000) vector 68
[    2.923617] tg3 0000:01:04.0: PCI INT A -> GSI 42 (level, low) -> IRQ 68
[    3.103515] eth0: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:1f:80:b0
[    3.115546] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    3.123374] eth0: dma_rwctrl[769f0000] dma_mask[64-bit]
[    3.128835] tg3 0000:01:04.1: PCI INT B -> GSI 11 (level, low) -> IRQ 37
[    3.408699] eth1: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:9f:80:b0
[    3.420734] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    3.428559] eth1: dma_rwctrl[769f0000] dma_mask[64-bit]
[    3.434062] GSI 144 (level, low) -> CPU 1 (0x0200) vector 69
[    3.439932] tg3 0000:41:04.0: PCI INT A -> GSI 144 (level, low) -> IRQ 69
[    3.626559] eth2: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:1f:80:e2
[    3.638588] eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    3.646417] eth2: dma_rwctrl[769f0000] dma_mask[64-bit]
[    3.651888] GSI 113 (level, low) -> CPU 2 (0x0400) vector 70
[    3.657748] tg3 0000:41:04.1: PCI INT B -> GSI 113 (level, low) -> IRQ 70
[    3.931050] eth3: Tigon3 [partno(BCM95704A6) rev 2002 PHY(5704)] (PCIX:66MHz:64-bit) 10/100/1000Base-T Ethernet 00:02:55:9f:80:e2
[    3.943084] eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[    3.950911] eth3: dma_rwctrl[769f0000] dma_mask[64-bit]
[    3.957515] console [netcon0] enabled
[    3.961368] netconsole: network logging started
[    3.966093] Uniform Multi-Platform E-IDE driver
[    3.971226] via82cxxx 0000:00:05.1: VIA vt82c686b (rev 40) IDE UDMA100
[    3.977977] via82cxxx 0000:00:05.1: IDE controller (0x1106:0x0571 rev 0x06)
[    3.985200] via82cxxx 0000:00:05.1: IDE port disabled
[    3.990486] via82cxxx 0000:00:05.1: not 100% native mode: will probe irqs later
[    3.998166]     ide0: BM-DMA at 0x0700-0x0707
[    4.002731] Probing IDE interface ide0...
[    4.547929] hda: HL-DT-STDVD-ROM GDR8081N, ATAPI CD/DVD-ROM drive
[    5.227765] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    5.238143] hda: UDMA/33 mode selected
[    5.242882] ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
[    5.248266] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    5.258374] ide_generic: I/O resource 0x1F0-0x1F7 not free.
[    5.264150] ide_generic: I/O resource 0x170-0x177 not free.
[    5.270129] kernel unaligned access to 0xe00000064496c596, ip=0xa000000100516ba1
[    5.277892] kernel unaligned access to 0xe00000064496c59e, ip=0xa000000100516ba1
[    8.023290] hda: ATAPI 24X DVD-ROM drive, 512kB Cache
[    8.028654] Uniform CD-ROM driver Revision: 3.20
[    8.033587] kernel unaligned access to 0xe0000006449500d6, ip=0xa000000100516ba1
[    8.041224] kernel unaligned access to 0xe0000006449500de, ip=0xa000000100516ba1
[    8.049593] kernel unaligned access to 0xe0000013044e693e, ip=0xa000000100516ba1
[    8.067523] Driver 'sd' needs updating - please use bus_type methods
[    8.074279] Fusion MPT base driver 3.04.07
[    8.078494] Copyright (c) 1999-2008 LSI Corporation
[    8.083525] Fusion MPT SPI Host driver 3.04.07
[    8.088367] GSI 40 (level, low) -> CPU 3 (0x0600) vector 71
[    8.094074] mptspi 0000:01:03.0: PCI INT A -> GSI 40 (level, low) -> IRQ 71
[    8.101405] mptbase: ioc0: Initiating bringup
[    8.578645] ioc0: LSI53C1030 C0: Capabilities={Initiator}
[    9.260079] scsi0 : ioc0: LSI53C1030 C0, FwRev032821h, Ports=1, MaxQ"2, IRQq
[   10.695651] scsi 0:0:0:0: Direct-Access     IBM-ESXS DTN018C1UCDY10F  S25J PQ: 0 ANSI: 3
[   10.703975]  target0:0:0: Beginning Domain Validation
[   10.721731]  target0:0:0: Ending Domain Validation
[   10.726716]  target0:0:0: FAST-80 WIDE SCSI 160.0 MB/s DT (12.5 ns, offset 127)
[   10.735381] sd 0:0:0:0: [sda] 35548320 512-byte hardware sectors (18201 MB)
[   10.743282] sd 0:0:0:0: [sda] Write Protect is off
[   10.748208] sd 0:0:0:0: [sda] Mode Sense: cb 00 00 08
[   10.749171] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   10.759214] sd 0:0:0:0: [sda] 35548320 512-byte hardware sectors (18201 MB)
[   10.767096] sd 0:0:0:0: [sda] Write Protect is off
[   10.772017] sd 0:0:0:0: [sda] Mode Sense: cb 00 00 08
[   10.772933] sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[   10.782297]  sda: sda1 sda2 sda3
[   10.820188] sd 0:0:0:0: [sda] Attached SCSI disk
[   10.825877] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   12.332784] scsi 0:0:8:0: Processor         IBM      25P3495a S320  1 1    PQ: 0 ANSI: 2
[   12.341105]  target0:0:8: Beginning Domain Validation
[   12.346894]  target0:0:8: Ending Domain Validation
[   12.351878]  target0:0:8: asynchronous
[   12.356358] scsi 0:0:8:0: Attached scsi generic sg1 type 3
[   14.113394] GSI 41 (level, low) -> CPU 4 (0x1000) vector 72
[   14.119099] mptspi 0000:01:03.1: PCI INT B -> GSI 41 (level, low) -> IRQ 72
[   14.126338] mptbase: ioc1: Initiating bringup
[   14.610641] ioc1: LSI53C1030 C0: Capabilities={Initiator}
[   15.300046] scsi1 : ioc1: LSI53C1030 C0, FwRev032821h, Ports=1, MaxQ"2, IRQr
[   20.486287] GSI 142 (level, low) -> CPU 5 (0x1200) vector 73
[   20.492076] mptspi 0000:41:03.0: PCI INT A -> GSI 142 (level, low) -> IRQ 73
[   20.499406] mptbase: ioc2: Initiating bringup
[   20.982640] ioc2: LSI53C1030 C0: Capabilities={Initiator}
[   21.664094] scsi2 : ioc2: LSI53C1030 C0, FwRev032821h, Ports=1, MaxQ"2, IRQs
[   24.849456] scsi 2:0:8:0: Processor         IBM      25P3495a S320  1 1    PQ: 0 ANSI: 2
[   24.857779]  target2:0:8: Beginning Domain Validation
[   24.863613]  target2:0:8: Ending Domain Validation
[   24.868597]  target2:0:8: asynchronous
[   24.873084] scsi 2:0:8:0: Attached scsi generic sg2 type 3
[   26.630140] GSI 143 (level, low) -> CPU 6 (0x1400) vector 74
[   26.635933] mptspi 0000:41:03.1: PCI INT B -> GSI 143 (level, low) -> IRQ 74
[   26.643259] mptbase: ioc3: Initiating bringup
[   27.126640] ioc3: LSI53C1030 C0: Capabilities={Initiator}
[   27.816094] scsi3 : ioc3: LSI53C1030 C0, FwRev032821h, Ports=1, MaxQ"2, IRQt
[   33.002419] USB Universal Host Controller Interface driver v3.0
[   33.008519] uhci_hcd 0000:00:05.2: enabling device (0000 -> 0001)
[   33.014759] GSI 18 (level, low) -> CPU 7 (0x1600) vector 75
[   33.020461] uhci_hcd 0000:00:05.2: PCI INT D -> GSI 18 (level, low) -> IRQ 75
[   33.027752] uhci_hcd 0000:00:05.2: UHCI Host Controller
[   33.033276] uhci_hcd 0000:00:05.2: new USB bus registered, assigned bus number 1
[   33.040943] uhci_hcd 0000:00:05.2: irq 75, io base 0x00000800
[   33.047108] usb usb1: configuration #1 chosen from 1 choice
[   33.052963] hub 1-0:1.0: USB hub found
[   33.056858] hub 1-0:1.0: 2 ports detected
[   33.267228] uhci_hcd 0000:00:05.3: enabling device (0000 -> 0001)
[   33.273462] uhci_hcd 0000:00:05.3: PCI INT D -> GSI 18 (level, low) -> IRQ 75
[   33.280742] uhci_hcd 0000:00:05.3: UHCI Host Controller
[   33.286211] uhci_hcd 0000:00:05.3: new USB bus registered, assigned bus number 2
[   33.293863] uhci_hcd 0000:00:05.3: irq 75, io base 0x00000820
[   33.299989] usb usb2: configuration #1 chosen from 1 choice
[   33.305835] hub 2-0:1.0: USB hub found
[   33.309720] hub 2-0:1.0: 2 ports detected
[   30.652682] usb 1-1: new full speed USB device using uhci_hcd and address 2
[   33.519137] uhci_hcd 0000:40:05.2: enabling device (0000 -> 0001)
[   33.525384] GSI 120 (level, low) -> CPU 0 (0x0000) vector 76
[   33.531177] uhci_hcd 0000:40:05.2: PCI INT D -> GSI 120 (level, low) -> IRQ 76
[   33.538630] uhci_hcd 0000:40:05.2: UHCI Host Controller
[   33.544124] uhci_hcd 0000:40:05.2: new USB bus registered, assigned bus number 3
[   33.551801] uhci_hcd 0000:40:05.2: irq 76, io base 0x00008840
[   33.557963] usb usb3: configuration #1 chosen from 1 choice
[   33.563813] hub 3-0:1.0: USB hub found
[   33.567711] hub 3-0:1.0: 2 ports detected
[   33.590058] usb 1-1: configuration #1 chosen from 1 choice
[   33.601022] hub 1-1:1.0: USB hub found
[   33.605890] hub 1-1:1.0: 3 ports detected
[   33.779111] uhci_hcd 0000:40:05.3: enabling device (0000 -> 0001)
[   33.785351] uhci_hcd 0000:40:05.3: PCI INT D -> GSI 120 (level, low) -> IRQ 76
[   33.792810] uhci_hcd 0000:40:05.3: UHCI Host Controller
[   33.798286] uhci_hcd 0000:40:05.3: new USB bus registered, assigned bus number 4
[   33.805992] uhci_hcd 0000:40:05.3: irq 76, io base 0x00008860
[   33.812142] usb usb4: configuration #1 chosen from 1 choice
[   33.817988] hub 4-0:1.0: USB hub found
[   33.821882] hub 4-0:1.0: 2 ports detected
[   33.907891] usb 1-1.1: new full speed USB device using uhci_hcd and address 3
[   34.031218] Initializing USB Mass Storage driver...
[   34.053054] usb 1-1.1: configuration #1 chosen from 1 choice
[   34.139884] usb 1-1.3: new low speed USB device using uhci_hcd and address 4
[   34.275069] usb 1-1.3: configuration #1 chosen from 1 choice
[   34.286032] usbcore: registered new interface driver usb-storage
[   34.292486] USB Mass Storage support registered.
[   34.298076] mice: PS/2 mouse device common for all mice
[   34.323261] i2c /dev entries driver
[   34.327154] vt596_smbus 0000:00:05.4: SMBUS: Error: Host SMBus controller not enabled! - upgrade BIOS or use force=1
[   34.337951] vt596_smbus 0000:40:05.4: SMBUS: Error: Host SMBus controller not enabled! - upgrade BIOS or use force=1
[   34.348968] EFI Variables Facility v0.08 2004-May-17
[   34.357268] usbcore: registered new interface driver hiddev
[   34.366342] input: Silitek IBM USB HUB KEYBOARD as /class/input/input1
[   34.406791] input: USB HID v1.10 Keyboard [Silitek IBM USB HUB KEYBOARD] on usb-0000:00:05.2-1.1
[   34.431153] input: Logitech as /class/input/input2
[   34.470786] input: USB HID v1.00 Mouse [Logitech] on usb-0000:00:05.2-1.3
[   34.477920] usbcore: registered new interface driver usbhid
[   34.483631] usbhid: v2.6:USB HID core driver
[   34.488038] perfmon: added sampling format oprofile_format
[   34.493653] oprofile: using perfmon.
[   34.497978] TCP cubic registered
[   34.501334] NET: Registered protocol family 17
[   34.507165] RPC: Registered udp transport module.
[   34.512005] RPC: Registered tcp transport module.
[   34.517682] Freeing unused kernel memory: 1728kB freed
[   31.961131] kernel unaligned access to 0xe0000013047340d6, ip=0xa000000100516ba1
[   31.968891] kernel unaligned access to 0xe0000013047340da, ip=0xa000000100516ba1
[   31.976638] kernel unaligned access to 0xe0000013047340de, ip=0xa000000100516ba1
[   34.718216] kernel unaligned access to 0xe0000013044e693e, ip=0xa000000100516ba1
[   34.725860] kernel unaligned access to 0xe0000013044e6942, ip=0xa000000100516ba1
[   35.450479] kjournald starting.  Commit interval 5 seconds
[   35.456155] EXT3-fs: mounted filesystem with ordered data mode.
[   37.633344] EXT3 FS on sda2, internal journal
[   43.521068] tg3: eth0: Link is up at 1000 Mbps, full duplex.
[   43.526890] tg3: eth0: Flow control is off for TX and off for RX.

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
