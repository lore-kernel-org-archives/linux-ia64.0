From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Wed, 21 May 2014 15:31:39 +0000
Subject: Re: [regression][bisected] zx1 AGP GART no more detected since merge of 'acpi-scan' branch
Message-Id: <CAA9xbM7CHcjV19MCNv8O_=Xnfk-RdB-PX39d6qeDFN2wYZtKzA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
In-Reply-To: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Again,

I'm now quite confident that the regression comes from commit
66345d5f79fcfa0214f5d98763643d4ee8e6965d as the description talks
about an ordering issue on hp rx2600 between the SBA I/O MMU driver
and the container scan handler.

First, I'm running on hp zx6000 that's a rx2600 with an AGP slot.
Then, defining DEBUG_SBA_INIT in sba_iommu.c clearly shows in dmesg
logs that, for working kernel 3.10.40, ioc_init (and thus
ioc_iova_init) is called once the ACPI/PCI resources (is this the
right terminology?) have been parsed, whereas for non-working kernel
3.11-rc1, ioc_init is called at the very beginning.

For working kernel 3.10.40, I get:
[    0.167176] ACPI: Using IOSAPIC for interrupt routing
[    1.655483] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-1f])
[    1.809485] acpi HWP0002:00: host bridge window [io  0x0000-0x03af]
[    1.809521] acpi HWP0002:00: host bridge window [io  0x03e0-0x1fff]
[    1.809555] acpi HWP0002:00: host bridge window [mem 0x80000000-0x8fffff=
ff]
[    1.809590] acpi HWP0002:00: host bridge window [mem
0x80004000000-0x80103fffffe]
[    1.809661] PCI host bridge to bus 0000:00
[    1.809693] pci_bus 0000:00: root bus resource [bus 00-1f]
[    1.809726] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[    1.809760] pci_bus 0000:00: root bus resource [io  0x03e0-0x1fff]
[    1.809794] pci_bus 0000:00: root bus resource [mem 0x80000000-0x8ffffff=
f]
[    1.809828] pci_bus 0000:00: root bus resource [mem
0x80004000000-0x80103fffffe]
[    1.810100] pci 0000:00:01.0: [1033:0035] type 00 class 0x0c0310
[    1.810503] pci 0000:00:01.0: reg 10: [mem 0x80023000-0x80023fff]
[    1.812250] pci 0000:00:01.0: supports D1 D2
[    1.812253] pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
[    1.812690] pci 0000:00:01.1: [1033:0035] type 00 class 0x0c0310
[    1.813097] pci 0000:00:01.1: reg 10: [mem 0x80022000-0x80022fff]
[    1.814796] pci 0000:00:01.1: supports D1 D2
[    1.814799] pci 0000:00:01.1: PME# supported from D0 D1 D2 D3hot
[    1.815255] pci 0000:00:01.2: [1033:00e0] type 00 class 0x0c0320
[    1.815655] pci 0000:00:01.2: reg 10: [mem 0x80021000-0x800210ff]
[    1.817370] pci 0000:00:01.2: supports D1 D2
[    1.817373] pci 0000:00:01.2: PME# supported from D0 D1 D2 D3hot
[    1.817957] pci 0000:00:02.0: [1095:0649] type 00 class 0x01018f
[    1.818340] pci 0000:00:02.0: reg 10: [io  0x0d58-0x0d5f]
[    1.818557] pci 0000:00:02.0: reg 14: [io  0x0d64-0x0d67]
[    1.818774] pci 0000:00:02.0: reg 18: [io  0x0d50-0x0d57]
[    1.819005] pci 0000:00:02.0: reg 1c: [io  0x0d60-0x0d63]
[    1.819221] pci 0000:00:02.0: reg 20: [io  0x0d40-0x0d4f]
[    1.820126] pci 0000:00:02.0: supports D1 D2
[    1.820495] pci 0000:00:03.0: [8086:1229] type 00 class 0x020000
[    1.820898] pci 0000:00:03.0: reg 10: [mem 0x80020000-0x80020fff]
[    1.821097] pci 0000:00:03.0: reg 14: [io  0x0d00-0x0d3f]
[    1.821314] pci 0000:00:03.0: reg 18: [mem 0x80000000-0x8001ffff]
[    1.822614] pci 0000:00:03.0: supports D1 D2
[    1.822617] pci 0000:00:03.0: PME# supported from D0 D1 D2 D3hot D3cold
[    1.823685] acpi HWP0002:00: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    1.823722] acpi HWP0002:00: Unable to request _OSC control (_OSC
support mask: 0x08)
[    1.905478] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 20-3f])
[    2.061482] acpi HWP0002:01: host bridge window [mem 0xff5e0000-0xff5e00=
07]
[    2.061518] acpi HWP0002:01: host bridge window [mem 0xff5e2000-0xff5e20=
07]
[    2.061555] acpi HWP0002:01: host bridge window [io  0x2000-0x2fff]
[    2.061589] acpi HWP0002:01: host bridge window [mem 0x90000000-0x97ffff=
ff]
[    2.061624] acpi HWP0002:01: host bridge window [mem
0x90004000000-0x90103fffffe]
[    2.061696] PCI host bridge to bus 0000:20
[    2.061727] pci_bus 0000:20: root bus resource [bus 20-3f]
[    2.061760] pci_bus 0000:20: root bus resource [io  0x2000-0x2fff]
[    2.061794] pci_bus 0000:20: root bus resource [mem 0x90000000-0x97fffff=
f]
[    2.061829] pci_bus 0000:20: root bus resource [mem
0x90004000000-0x90103fffffe]
[    2.062224] pci 0000:20:01.0: [1000:0030] type 00 class 0x010000
[    2.062769] pci 0000:20:01.0: reg 10: [io  0x2100-0x21ff]
[    2.063149] pci 0000:20:01.0: reg 14: [mem 0x90840000-0x9084ffff 64bit]
[    2.063550] pci 0000:20:01.0: reg 1c: [mem 0x90830000-0x9083ffff 64bit]
[    2.064077] pci 0000:20:01.0: reg 30: [mem 0x90400000-0x907fffff pref]
[    2.064731] pci 0000:20:01.0: supports D1 D2
[    2.065344] pci 0000:20:01.1: [1000:0030] type 00 class 0x010000
[    2.065889] pci 0000:20:01.1: reg 10: [io  0x2000-0x20ff]
[    2.066294] pci 0000:20:01.1: reg 14: [mem 0x90820000-0x9082ffff 64bit]
[    2.066694] pci 0000:20:01.1: reg 1c: [mem 0x90810000-0x9081ffff 64bit]
[    2.067185] pci 0000:20:01.1: reg 30: [mem 0x90000000-0x903fffff pref]
[    2.067839] pci 0000:20:01.1: supports D1 D2
[    2.068798] pci 0000:20:02.0: [14e4:1645] type 00 class 0x020000
[    2.069403] pci 0000:20:02.0: reg 10: [mem 0x90800000-0x9080ffff 64bit]
[    2.071438] pci 0000:20:02.0: PME# supported from D3hot D3cold
[    2.072877] acpi HWP0002:01: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    2.072913] acpi HWP0002:01: Unable to request _OSC control (_OSC
support mask: 0x08)
[    2.156480] ACPI: PCI Root Bridge [PCI2] (domain 0000 [bus 40-5f])
[    2.300482] acpi HWP0002:02: host bridge window [io  0x3000-0x5fff]
[    2.300517] acpi HWP0002:02: host bridge window [mem 0x98000000-0xafffff=
ff]
[    2.300553] acpi HWP0002:02: host bridge window [mem
0xa0004000000-0xa0103fffffe]
[    2.300642] PCI host bridge to bus 0000:40
[    2.300674] pci_bus 0000:40: root bus resource [bus 40-5f]
[    2.300707] pci_bus 0000:40: root bus resource [io  0x3000-0x5fff]
[    2.300740] pci_bus 0000:40: root bus resource [mem 0x98000000-0xaffffff=
f]
[    2.300775] pci_bus 0000:40: root bus resource [mem
0xa0004000000-0xa0103fffffe]
[    2.301138] pci 0000:40:01.0: [1319:0801] type 00 class 0x040100
[    2.301705] pci 0000:40:01.0: reg 10: [io  0x3000-0x307f]
[    2.304134] pci 0000:40:01.0: supports D2
[    2.336435] pci 0000:40:01.1: [1319:0802] type 00 class 0x098000
[    2.336959] pci 0000:40:01.1: reg 10: [io  0x3080-0x308f]
[    2.339393] pci 0000:40:01.1: supports D1
[    2.339396] pci 0000:40:01.1: PME# supported from D1 D3hot
[    2.373701] acpi HWP0002:02: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    2.373737] acpi HWP0002:02: Unable to request _OSC control (_OSC
support mask: 0x08)
[    2.509483] ACPI: PCI Root Bridge [PCI3] (domain 0000 [bus 60-7f])
[    2.645481] acpi HWP0002:03: host bridge window [io  0x6000-0x7fff]
[    2.645516] acpi HWP0002:03: host bridge window [mem 0xb0000000-0xc7ffff=
ff]
[    2.645551] acpi HWP0002:03: host bridge window [mem
0xb0004000000-0xb0103fffffe]
[    2.645641] PCI host bridge to bus 0000:60
[    2.645672] pci_bus 0000:60: root bus resource [bus 60-7f]
[    2.645705] pci_bus 0000:60: root bus resource [io  0x6000-0x7fff]
[    2.645739] pci_bus 0000:60: root bus resource [mem 0xb0000000-0xc7fffff=
f]
[    2.645773] pci_bus 0000:60: root bus resource [mem
0xb0004000000-0xb0103fffffe]
[    2.647348] acpi HWP0002:03: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    2.647383] acpi HWP0002:03: Unable to request _OSC control (_OSC
support mask: 0x08)
[    2.801485] ACPI: PCI Root Bridge [PCI4] (domain 0000 [bus 80-bf])
[    2.973489] acpi HWP0003:00: host bridge window [io  0x03b0-0x03df]
[    2.973525] acpi HWP0003:00: host bridge window [io  0x8000-0xbfff]
[    2.973560] acpi HWP0003:00: host bridge window [mem 0x000a0000-0x000fff=
ff]
[    2.973595] acpi HWP0003:00: host bridge window [mem 0xc8000000-0xdfffff=
ff]
[    2.973630] acpi HWP0003:00: host bridge window [mem
0xc0004000000-0xc0103fffffe]
[    2.973719] PCI host bridge to bus 0000:80
[    2.973751] pci_bus 0000:80: root bus resource [bus 80-bf]
[    2.973784] pci_bus 0000:80: root bus resource [io  0x03b0-0x03df]
[    2.973818] pci_bus 0000:80: root bus resource [io  0x8000-0xbfff]
[    2.973852] pci_bus 0000:80: root bus resource [mem 0x000a0000-0x000ffff=
f]
[    2.973886] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xdffffff=
f]
[    2.973921] pci_bus 0000:80: root bus resource [mem
0xc0004000000-0xc0103fffffe]
[    2.974453] pci 0000:80:00.0: [1002:4e47] type 00 class 0x030000
[    2.975282] pci 0000:80:00.0: reg 10: [mem 0xd0000000-0xd7ffffff pref]
[    2.975672] pci 0000:80:00.0: reg 14: [io  0x8000-0x80ff]
[    2.976060] pci 0000:80:00.0: reg 18: [mem 0xd8030000-0xd803ffff]
[    2.977613] pci 0000:80:00.0: reg 30: [mem 0xd8000000-0xd801ffff pref]
[    2.977784] pci 0000:80:00.0: Boot video device
[    2.978777] pci 0000:80:00.0: supports D1 D2
[    3.011504] pci 0000:80:00.1: [1002:4e67] type 00 class 0x038000
[    3.012172] pci 0000:80:00.1: reg 10: [mem 0xc8000000-0xcfffffff pref]
[    3.012562] pci 0000:80:00.1: reg 14: [mem 0xd8020000-0xd802ffff]
[    3.015281] pci 0000:80:00.1: supports D1 D2
[    3.050175] acpi HWP0003:00: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    3.050211] acpi HWP0003:00: Unable to request _OSC control (_OSC
support mask: 0x08)
[    3.185479] ACPI: PCI Root Bridge [PCI6] (domain 0000 [bus c0-df])
[    3.321485] acpi HWP0002:04: host bridge window [io  0xc000-0xdfff]
[    3.321520] acpi HWP0002:04: host bridge window [mem 0xe0000000-0xefffff=
ff]
[    3.321555] acpi HWP0002:04: host bridge window [mem
0xe0004000000-0xe0103fffffe]
[    3.321651] PCI host bridge to bus 0000:c0
[    3.321682] pci_bus 0000:c0: root bus resource [bus c0-df]
[    3.321715] pci_bus 0000:c0: root bus resource [io  0xc000-0xdfff]
[    3.321749] pci_bus 0000:c0: root bus resource [mem 0xe0000000-0xeffffff=
f]
[    3.321784] pci_bus 0000:c0: root bus resource [mem
0xe0004000000-0xe0103fffffe]
[    3.323828] acpi HWP0002:04: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    3.323864] acpi HWP0002:04: Unable to request _OSC control (_OSC
support mask: 0x08)
[    3.388232] ACPI: Enabled 1 GPEs in block 10 to 1F
[    3.388302] acpi root: \_SB_.SBA0.PCI0 notify handler is installed
[    3.388305] acpi root: \_SB_.SBA0.PCI1 notify handler is installed
[    3.388310] acpi root: \_SB_.SBA0.PCI2 notify handler is installed
[    3.388319] acpi root: \_SB_.SBA0.PCI3 notify handler is installed
[    3.388327] acpi root: \_SB_.SBA0.PCI4 notify handler is installed
[    3.388335] acpi root: \_SB_.SBA0.PCI6 notify handler is installed
[    3.388352] Found 6 acpi root devices
<snip>
[    3.730064] ioc_init: PAGE_SIZE 16K, iovp_size 16K
[    3.730098] ioc_iova_init() hpa c0000000fed01000 IOV base
0x40000000 mask 0xffffffffc0000000 (1024MB)
[    3.730255] ioc_iova_init() IOV page size 16K pdir e000004080300000
size 80000
[    3.732784] IOC: reserving 512Mb of IOVA space at 0x60000000 for agpgart
[    3.732818] ioc_resource_init() res_size 0x1000
[    3.732850] ioc_resource_init() res_map 1000 e000004080268000
[    3.733006] IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000

Whereas for non-working kernel 3.11-rc1, I get:
[    0.167172] ACPI: Using IOSAPIC for interrupt routing
[    1.912145] ioc_init: PAGE_SIZE 16K, iovp_size 16K
[    1.912207] ioc_iova_init() hpa c0000000fed01000 IOV base
0x40000000 mask 0xffffffffc0000000 (1024MB)
[    1.912470] ioc_iova_init() IOV page size 16K pdir e000004080280000
size 80000
[    1.912506] ioc_resource_init() res_size 0x2000
[    1.912541] ioc_resource_init() res_map 2000 e00000408021c000
[    1.912575] IOC: zx1 2.3 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000
[    1.997482] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-1f])
[    1.997521] acpi HWP0002:00: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    1.997556] acpi HWP0002:00: Unable to request _OSC control (_OSC
support mask: 0x08)
[    2.151479] acpi HWP0002:00: host bridge window [io  0x0000-0x03af]
[    2.151516] acpi HWP0002:00: host bridge window [io  0x03e0-0x1fff]
[    2.151550] acpi HWP0002:00: host bridge window [mem 0x80000000-0x8fffff=
ff]
[    2.151585] acpi HWP0002:00: host bridge window [mem
0x80004000000-0x80103fffffe]
[    2.151657] PCI host bridge to bus 0000:00
[    2.151689] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[    2.151723] pci_bus 0000:00: root bus resource [io  0x03e0-0x1fff]
[    2.151757] pci_bus 0000:00: root bus resource [mem 0x80000000-0x8ffffff=
f]
[    2.151792] pci_bus 0000:00: root bus resource [mem
0x80004000000-0x80103fffffe]
[    2.151828] pci_bus 0000:00: root bus resource [bus 00-1f]
[    2.152100] pci 0000:00:01.0: [1033:0035] type 00 class 0x0c0310
[    2.152505] pci 0000:00:01.0: reg 0x10: [mem 0x80023000-0x80023fff]
[    2.154250] pci 0000:00:01.0: supports D1 D2
[    2.154253] pci 0000:00:01.0: PME# supported from D0 D1 D2 D3hot
[    2.154698] pci 0000:00:01.1: [1033:0035] type 00 class 0x0c0310
[    2.155097] pci 0000:00:01.1: reg 0x10: [mem 0x80022000-0x80022fff]
[    2.156797] pci 0000:00:01.1: supports D1 D2
[    2.156800] pci 0000:00:01.1: PME# supported from D0 D1 D2 D3hot
[    2.157252] pci 0000:00:01.2: [1033:00e0] type 00 class 0x0c0320
[    2.157651] pci 0000:00:01.2: reg 0x10: [mem 0x80021000-0x800210ff]
[    2.159370] pci 0000:00:01.2: supports D1 D2
[    2.159374] pci 0000:00:01.2: PME# supported from D0 D1 D2 D3hot
[    2.159958] pci 0000:00:02.0: [1095:0649] type 00 class 0x01018f
[    2.160370] pci 0000:00:02.0: reg 0x10: [io  0x0d58-0x0d5f]
[    2.160588] pci 0000:00:02.0: reg 0x14: [io  0x0d64-0x0d67]
[    2.160805] pci 0000:00:02.0: reg 0x18: [io  0x0d50-0x0d57]
[    2.161005] pci 0000:00:02.0: reg 0x1c: [io  0x0d60-0x0d63]
[    2.161222] pci 0000:00:02.0: reg 0x20: [io  0x0d40-0x0d4f]
[    2.162126] pci 0000:00:02.0: supports D1 D2
[    2.162496] pci 0000:00:03.0: [8086:1229] type 00 class 0x020000
[    2.162899] pci 0000:00:03.0: reg 0x10: [mem 0x80020000-0x80020fff]
[    2.163127] pci 0000:00:03.0: reg 0x14: [io  0x0d00-0x0d3f]
[    2.163344] pci 0000:00:03.0: reg 0x18: [mem 0x80000000-0x8001ffff]
[    2.164614] pci 0000:00:03.0: supports D1 D2
[    2.164617] pci 0000:00:03.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.247481] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 20-3f])
[    2.247517] acpi HWP0002:01: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    2.247553] acpi HWP0002:01: Unable to request _OSC control (_OSC
support mask: 0x08)
[    2.403487] acpi HWP0002:01: host bridge window [mem 0xff5e0000-0xff5e00=
07]
[    2.403522] acpi HWP0002:01: host bridge window [mem 0xff5e2000-0xff5e20=
07]
[    2.403558] acpi HWP0002:01: host bridge window [io  0x2000-0x2fff]
[    2.403593] acpi HWP0002:01: host bridge window [mem 0x90000000-0x97ffff=
ff]
[    2.403628] acpi HWP0002:01: host bridge window [mem
0x90004000000-0x90103fffffe]
[    2.403699] PCI host bridge to bus 0000:20
[    2.403731] pci_bus 0000:20: root bus resource [io  0x2000-0x2fff]
[    2.403765] pci_bus 0000:20: root bus resource [mem 0x90000000-0x97fffff=
f]
[    2.403799] pci_bus 0000:20: root bus resource [mem
0x90004000000-0x90103fffffe]
[    2.403834] pci_bus 0000:20: root bus resource [bus 20-3f]
[    2.404224] pci 0000:20:01.0: [1000:0030] type 00 class 0x010000
[    2.404769] pci 0000:20:01.0: reg 0x10: [io  0x2100-0x21ff]
[    2.405186] pci 0000:20:01.0: reg 0x14: [mem 0x90840000-0x9084ffff 64bit]
[    2.405587] pci 0000:20:01.0: reg 0x1c: [mem 0x90830000-0x9083ffff 64bit]
[    2.406078] pci 0000:20:01.0: reg 0x30: [mem 0x90400000-0x907fffff pref]
[    2.406731] pci 0000:20:01.0: supports D1 D2
[    2.407351] pci 0000:20:01.1: [1000:0030] type 00 class 0x010000
[    2.407896] pci 0000:20:01.1: reg 0x10: [io  0x2000-0x20ff]
[    2.408294] pci 0000:20:01.1: reg 0x14: [mem 0x90820000-0x9082ffff 64bit]
[    2.408695] pci 0000:20:01.1: reg 0x1c: [mem 0x90810000-0x9081ffff 64bit]
[    2.409186] pci 0000:20:01.1: reg 0x30: [mem 0x90000000-0x903fffff pref]
[    2.409840] pci 0000:20:01.1: supports D1 D2
[    2.410799] pci 0000:20:02.0: [14e4:1645] type 00 class 0x020000
[    2.411438] pci 0000:20:02.0: reg 0x10: [mem 0x90800000-0x9080ffff 64bit]
[    2.413474] pci 0000:20:02.0: PME# supported from D3hot D3cold
[    2.498480] ACPI: PCI Root Bridge [PCI2] (domain 0000 [bus 40-5f])
[    2.498516] acpi HWP0002:02: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    2.498552] acpi HWP0002:02: Unable to request _OSC control (_OSC
support mask: 0x08)
[    2.642482] acpi HWP0002:02: host bridge window [io  0x3000-0x5fff]
[    2.642517] acpi HWP0002:02: host bridge window [mem 0x98000000-0xafffff=
ff]
[    2.642552] acpi HWP0002:02: host bridge window [mem
0xa0004000000-0xa0103fffffe]
[    2.675146] PCI host bridge to bus 0000:40
[    2.675178] pci_bus 0000:40: root bus resource [io  0x3000-0x5fff]
[    2.675212] pci_bus 0000:40: root bus resource [mem 0x98000000-0xaffffff=
f]
[    2.675247] pci_bus 0000:40: root bus resource [mem
0xa0004000000-0xa0103fffffe]
[    2.675282] pci_bus 0000:40: root bus resource [bus 40-5f]
[    2.675665] pci 0000:40:01.0: [1319:0801] type 00 class 0x040100
[    2.676223] pci 0000:40:01.0: reg 0x10: [io  0x3000-0x307f]
[    2.678655] pci 0000:40:01.0: supports D2
[    2.711436] pci 0000:40:01.1: [1319:0802] type 00 class 0x098000
[    2.711960] pci 0000:40:01.1: reg 0x10: [io  0x3080-0x308f]
[    2.714394] pci 0000:40:01.1: supports D1
[    2.714397] pci 0000:40:01.1: PME# supported from D1 D3hot
[    2.884480] ACPI: PCI Root Bridge [PCI3] (domain 0000 [bus 60-7f])
[    2.884517] acpi HWP0002:03: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    2.884553] acpi HWP0002:03: Unable to request _OSC control (_OSC
support mask: 0x08)
[    3.020484] acpi HWP0002:03: host bridge window [io  0x6000-0x7fff]
[    3.020519] acpi HWP0002:03: host bridge window [mem 0xb0000000-0xc7ffff=
ff]
[    3.020554] acpi HWP0002:03: host bridge window [mem
0xb0004000000-0xb0103fffffe]
[    3.053151] PCI host bridge to bus 0000:60
[    3.053183] pci_bus 0000:60: root bus resource [io  0x6000-0x7fff]
[    3.053217] pci_bus 0000:60: root bus resource [mem 0xb0000000-0xc7fffff=
f]
[    3.053252] pci_bus 0000:60: root bus resource [mem
0xb0004000000-0xb0103fffffe]
[    3.053287] pci_bus 0000:60: root bus resource [bus 60-7f]
[    3.208478] ACPI: PCI Root Bridge [PCI4] (domain 0000 [bus 80-bf])
[    3.208514] acpi HWP0003:00: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    3.208550] acpi HWP0003:00: Unable to request _OSC control (_OSC
support mask: 0x08)
[    3.380483] acpi HWP0003:00: host bridge window [io  0x03b0-0x03df]
[    3.380519] acpi HWP0003:00: host bridge window [io  0x8000-0xbfff]
[    3.380553] acpi HWP0003:00: host bridge window [mem 0x000a0000-0x000fff=
ff]
[    3.380588] acpi HWP0003:00: host bridge window [mem 0xc8000000-0xdfffff=
ff]
[    3.380624] acpi HWP0003:00: host bridge window [mem
0xc0004000000-0xc0103fffffe]
[    3.413142] PCI host bridge to bus 0000:80
[    3.413174] pci_bus 0000:80: root bus resource [io  0x03b0-0x03df]
[    3.413208] pci_bus 0000:80: root bus resource [io  0x8000-0xbfff]
[    3.413241] pci_bus 0000:80: root bus resource [mem 0x000a0000-0x000ffff=
f]
[    3.413276] pci_bus 0000:80: root bus resource [mem 0xc8000000-0xdffffff=
f]
[    3.413311] pci_bus 0000:80: root bus resource [mem
0xc0004000000-0xc0103fffffe]
[    3.413346] pci_bus 0000:80: root bus resource [bus 80-bf]
[    3.413880] pci 0000:80:00.0: [1002:4e47] type 00 class 0x030000
[    3.414669] pci 0000:80:00.0: reg 0x10: [mem 0xd0000000-0xd7ffffff pref]
[    3.415116] pci 0000:80:00.0: reg 0x14: [io  0x8000-0x80ff]
[    3.415507] pci 0000:80:00.0: reg 0x18: [mem 0xd8030000-0xd803ffff]
[    3.417061] pci 0000:80:00.0: reg 0x30: [mem 0xd8000000-0xd801ffff pref]
[    3.417232] pci 0000:80:00.0: Boot video device
[    3.418225] pci 0000:80:00.0: supports D1 D2
[    3.451505] pci 0000:80:00.1: [1002:4e67] type 00 class 0x038000
[    3.452172] pci 0000:80:00.1: reg 0x10: [mem 0xc8000000-0xcfffffff pref]
[    3.452563] pci 0000:80:00.1: reg 0x14: [mem 0xd8020000-0xd802ffff]
[    3.455281] pci 0000:80:00.1: supports D1 D2
[    3.625486] ACPI: PCI Root Bridge [PCI6] (domain 0000 [bus c0-df])
[    3.625522] acpi HWP0002:04: ACPI _OSC support notification failed,
disabling PCIe ASPM
[    3.625558] acpi HWP0002:04: Unable to request _OSC control (_OSC
support mask: 0x08)
[    3.761486] acpi HWP0002:04: host bridge window [io  0xc000-0xdfff]
[    3.761521] acpi HWP0002:04: host bridge window [mem 0xe0000000-0xefffff=
ff]
[    3.761556] acpi HWP0002:04: host bridge window [mem
0xe0004000000-0xe0103fffffe]
[    3.794165] PCI host bridge to bus 0000:c0
[    3.794198] pci_bus 0000:c0: root bus resource [io  0xc000-0xdfff]
[    3.794232] pci_bus 0000:c0: root bus resource [mem 0xe0000000-0xeffffff=
f]
[    3.794266] pci_bus 0000:c0: root bus resource [mem
0xe0004000000-0xe0103fffffe]
[    3.794302] pci_bus 0000:c0: root bus resource [bus c0-df]
[    3.869180] ACPI: Enabled 1 GPEs in block 10 to 1F
[    3.869249] ACPI: \_SB_.SBA0.PCI0: notify handler is installed
[    3.869253] ACPI: \_SB_.SBA0.PCI1: notify handler is installed
[    3.869258] ACPI: \_SB_.SBA0.PCI2: notify handler is installed
[    3.869267] ACPI: \_SB_.SBA0.PCI3: notify handler is installed
[    3.869276] ACPI: \_SB_.SBA0.PCI4: notify handler is installed
[    3.869286] ACPI: \_SB_.SBA0.PCI6: notify handler is installed
[    3.869302] Found 6 acpi root devices

Please notice how the call to ioc_init is reversed (w.r.t. ACPI/PCI
resource discovery and handler installation) between the two dmesg
excerpts.

Gang, I really need your help and expertise there, as this issue
completely breaks AGP, preventing me from contributing further to
GNOME stabilization effort on Gentoo/ia64.

Thanks,

     =C3=89meric


2014-05-21 15:23 GMT+02:00 =C3=89meric MASCHINO <emeric.maschino@gmail.com>:
> Hi,
>
> I've looked at this issue deeper: the problem seems to rely in the
> initialization of the PCI resources.
>
> Instrumenting the ioc_iova_init function in
> arch/ia64/hp/common/sba_iommu.c most notably gives for working <> 3.10.40=
 kernels:
> [    3.730289] for_each_pci_dev(0xe000004080245000)
> [    3.730442] for_each_pci_dev(0xe000004080245800)
> [    3.730594] for_each_pci_dev(0xe000004080246000)
> [    3.730745] for_each_pci_dev(0xe000004080246800)
> [    3.730897] for_each_pci_dev(0xe000004080247000)
> [    3.731034] for_each_pci_dev(0xe000004080247800)
> [    3.731281] for_each_pci_dev(0xe000004080248000)
> [    3.731528] for_each_pci_dev(0xe000004080248800)
> [    3.731918] for_each_pci_dev(0xe000004080249000)
> [    3.732133] for_each_pci_dev(0xe000004080249800)
> [    3.732336] for_each_pci_dev(0xe00000408024a000)
> [    3.732532] for_each_pci_dev(0xe00000408024a800)
>
> Whereas with kernel 3.11-rc1, the same function instrumentation
> outputs nothing, i.e. for_each_pci_dev(device) immediately returns
> NULL (see below). The agp_found variable is thus still 0 and the
> corresponding AGP GART initialization path is not taken:
>
>         /*
>         ** If an AGP device is present, only use half of the IOV space
>         ** for PCI DMA.  Unfortunately we can't know ahead of time
>         ** whether GART support will actually be used, for now we
>         ** can just key on an AGP device found in the system.
>         ** We program the next pdir index after we stop w/ a key for
>         ** the GART code to handshake on.
>         */
>         for_each_pci_dev(device)
>                 agp_found |=3D pci_find_capability(device, PCI_CAP_ID_AGP=
);
>
>         if (agp_found && reserve_sba_gart) {
>                 printk(KERN_INFO PFX "reserving %dMb of IOVA space at 0x%=
lx for$
>                       ioc->iov_size/2 >> 20, ioc->ibase + ioc->iov_size/2=
);
>                 ioc->pdir_size /=3D 2;
>                 ((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)] =3D =
ZX1_SBA_$
>         }
>
> Where should I look for now?
>
>      =C3=89meric
>
>
> 2014-05-15 2:32 GMT+02:00 =C3=89meric MASCHINO <emeric.maschino@gmail.com=
>:
>> Hi,
>>
>> Up to kernel 3.10.40, zx1 AGP GART was successfully detected:
>> [   15.896075] Linux agpgart interface v0.103
>> [   17.272674] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
>> [   17.272980]  (null): AGP aperture is 512M @ 0x60000000
>> [   17.273015] agpgart: Detected HP ZX1 HWP0003 AGP chipset (ioc=FEd0100=
0, lba=3Df
>> ed28000)
>> <snip>
>> [   29.602989] radeon 0000:80:00.0: putting AGP V2 device into 2x mode
>> [   29.603306] radeon 0000:80:00.0: GTT: 512M 0x60000000 - 0x7FFFFFFF
>> [   29.603399] [drm] Generation 1 PCI interface in multifunction mode
>>
>> Starting with kernel 3.11-rc1, zx1 AGP GART is no more detected and my
>> ATI FireGL X1 AGP graphics adapter is set to PCI mode:
>> [    5.442563] Linux agpgart interface v0.103
>> [    5.937458] agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
>> [    5.937491] agpgart: No reserved IO PDIR entry found; GART disabled
>> <snip>
>> [    6.028511] [drm:radeon_agp_init] *ERROR* Unable to acquire AGP: -19
>> [    6.028543] [drm] Forcing AGP to PCI mode
>> [    6.028631] [drm] Generation 1 PCI interface in multifunction mode
>>
>> Note: Nevermind the timing, timer frequency isn't the same between the
>> two runs (250 Hz vs 1000 Hz).
>>
>> I've managed to nearly bisect the regression. I say nearly, because
>> some commits made the kernel unbuildable and must be skipped.
>>
>> So, the offending candidates are:
>> - 66345d5f79fcfa0214f5d98763643d4ee8e6965d (ACPI / ia64 / sba_iommu:
>> Use ACPI scan handler for device discovery);
>> - 24071f472d813fccacc1ef7356b1f41422a1b968 (ACPI / scan: Do not bind
>> ACPI drivers to objects with scan handlers);
>> - d9e455f53f6fb93c764de2399c3894bbdfd2caa7 (ACPI / scan: Simplify ACPI
>> driver probing).
>> These were merged with 8e9914d5efe460600f5948da7ae4c1b6c038a4c0 (Merge
>> branch 'acpi-scan').
>>
>> I bet that the culprit is 66345d5f79fcfa0214f5d98763643d4ee8e6965d as
>> it is zx1 specific, but I can't verify for sure as reverting it makes
>> the kernel panics:
>> IOC IOMMU Driver: probe of HWP0001:00 failed with error -22
>> Kernel panic - not syncinc: Unable to find SBA IOMMU: Try a generic or
>> DIG kernel
>> (Yep, I'm running HP-zx1/sx1000, i.e. CONFIG_IA64_HP_ZX1=3Dy kernel).
>>
>> What's your opinion ia64 gurus? How to fix the breakage with the zx1
>> AGP GART detection?
>>
>> Thanks,
>>
>>      =C3=89meric
