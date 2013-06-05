From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 05 Jun 2013 06:01:49 +0000
Subject: [PATCH -v4 0/8] Add hostbridge resource release to support root bus hotplug in IA64
Message-Id: <1370412117-12860-1-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>

v3->v4: fix memory allocation problem and use dev_err instead of pr_err follow Bjorn's suggestion.
        Also add some SGI folks cc for the first two SN related patches.
v2->v3: remove "PCI/X86: fix always use info->res[0] to store _CRS resource when pci=nocrs set" 
		from this patchset, and update some changes about remove pci_window from pci_controller in IA64.
v1->v2: update the patchset description in this cover letter.

Hi Bjorn,
   I update this patchset description, and add some MMIO and dmesg info in order to describe
this problem more clearly. I hope it can make you review this patch easier.

Part1: clean up pci_window related code in IA64:SN, arch/ia64/sn/kernel/io_init.c
  PCI/IA64: SN: remove sn_pci_window_fixup()
  PCI/IA64: SN: use normal resource instead of pci_window

Part2: embeded pci hostbridge resource into pci_root_info and rework related code in arch/ia64/pci/pci.c
  PCI/IA64: embed pci hostbridge resources into pci_root_info
  PCI/IA64: Allocate pci_root_info instead of using stack

Part3: add hostbridge resource release to support root bus hotpug in IA64
  PCI/IA64: fix memleak for create pci root bus fail
  PCI/IA64: add host bridge resource release for _CRS path
  PCI/IA64: introduce probe_pci_root_info() to manage  _CRS resource

The main idea about this patchset based Bjorn's suggestion at http://marc.info/?l=linux-pci&m4506155529536&w=2

Before applied this patchset, there is a problem when we do root bus hotplug in IA64. Because
we do not release MMIO and ioport resource occupied by root bus.

1. Before hot remove pci root bus

-+-[0000:40]-+-00.0-[0000:41]--
 |           +-01.0-[0000:42]--+-00.0  Intel Corporation 82576 Gigabit Network Connection
 |           |                 \-00.1  Intel Corporation 82576 Gigabit Network Connection
 |           +-03.0-[0000:43]----00.0  LSI Logic / Symbios Logic SAS1064ET PCI-Express Fusion-MPT SAS
 |           +-04.0-[0000:44]--
 |           +-05.0-[0000:45]--
 |           +-07.0-[0000:46]--+-00.0  Intel Corporation 82576 Gigabit Network Connection
 |           |                 \-00.1  Intel Corporation 82576 Gigabit Network Connection
 |           +-0d.0  Intel Corporation Device 343a
 |           +-0d.1  Intel Corporation Device 343b
 |           +-0d.7  Intel Corporation Device 341b
 [....snip.....]
 |           +-16.3  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 |           \-16.7  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 \-[0000:00]-+-00.0  Intel Corporation 5520/5500/X58 I/O Hub to ESI Port
             +-01.0-[0000:01]--+-00.0  Intel Corporation 82576 Gigabit Network Connection
             |                 \-00.1  Intel Corporation 82576 Gigabit Network Connection
             +-03.0-[0000:02]----00.0  LSI Logic / Symbios Logic SAS1064ET PCI-Express Fusion-MPT SAS
             +-04.0-[0000:03]--
             +-05.0-[0000:04]--
             +-07.0-[0000:05]--+-00.0  nVidia Corporation GT218 [GeForce G210]
             |                 \-00.1  nVidia Corporation High Definition Audio Controller
             +-0d.0  Intel Corporation Device 343a
 [....snip.....]
             +-0d.1  Intel Corporation Device 343b

#cat /proc/iomem
[....snip....]
3fbf3000-3fffffff : reserved
50000000-7fffffff : PCI Bus 0000:00
  50000000-630fffff : PCI Bus 0000:05
    50000000-5fffffff : 0000:05:00.0
    60000000-61ffffff : 0000:05:00.0
    62000000-62ffffff : 0000:05:00.0
    63000000-63003fff : 0000:05:00.1
      63000000-63003fff : ICH HD audio
  64000000-680fffff : PCI Bus 0000:0a
    64000000-67ffffff : 0000:0a:00.0
    68000000-6803ffff : 0000:0a:00.0
[....snip....]
  68314000-68317fff : 0000:00:16.5
  68318000-6831bfff : 0000:00:16.6
  6831c000-6831ffff : 0000:00:16.7
  68320000-68320fff : 0000:00:13.0
  68321000-683213ff : 0000:00:1d.7
    68321000-683213ff : ehci_hcd
  68321400-683217ff : 0000:00:1a.7
    68321400-683217ff : ehci_hcd
  68321800-683218ff : 0000:00:1f.3
80000000-9fffffff : PCI Bus 0000:40
  80000000-800fffff : PCI Bus 0000:46
    80000000-8001ffff : 0000:46:00.1
      80000000-8001ffff : igb
    80020000-8003ffff : 0000:46:00.1
      80020000-8003ffff : igb
    80040000-8005ffff : 0000:46:00.0
      80040000-8005ffff : igb
    80060000-8007ffff : 0000:46:00.0
      80060000-8007ffff : igb
    80080000-80083fff : 0000:46:00.1
      80080000-80083fff : igb
    80084000-80087fff : 0000:46:00.0
      80084000-80087fff : igb
  80100000-801fffff : PCI Bus 0000:43
    80100000-8010ffff : 0000:43:00.0
      80100000-8010ffff : mpt
    80110000-80113fff : 0000:43:00.0
      80110000-80113fff : mpt
  80200000-802fffff : PCI Bus 0000:42
    80200000-8021ffff : 0000:42:00.1
      80200000-8021ffff : igb
    80220000-8023ffff : 0000:42:00.1
      80220000-8023ffff : igb
    80240000-8025ffff : 0000:42:00.0
      80240000-8025ffff : igb
    80260000-8027ffff : 0000:42:00.0
      80260000-8027ffff : igb
    80280000-80283fff : 0000:42:00.1
      80280000-80283fff : igb
    80284000-80287fff : 0000:42:00.0
      80284000-80287fff : igb
  80300000-80303fff : 0000:40:16.0
  80304000-80307fff : 0000:40:16.1
  80308000-8030bfff : 0000:40:16.2
  8030c000-8030ffff : 0000:40:16.3
  80310000-80313fff : 0000:40:16.4
  80314000-80317fff : 0000:40:16.5
  80318000-8031bfff : 0000:40:16.6
  8031c000-8031ffff : 0000:40:16.7
  80320000-80320fff : 0000:40:13.0
fea00000-fea0001f : pnp 00:06
[....snip......]
20fc000000-20ffffffff : reserved
1fffffc000000-1fffffc33dcf7 : PCI Bus 0000:00 I/O Ports 00000000-00000cf7
1fffffc400000-1fffffe3fffff : PCI Bus 0000:00 I/O Ports 00001000-00008fff
1fffffe400000-1fffffffffffe : PCI Bus 0000:40 I/O Ports 00009000-0000fffe

2. After hot remove pci root bus 0000:40
#cat /proc/iomem
[....snip.....]
50000000-7fffffff : PCI Bus 0000:00
  50000000-630fffff : PCI Bus 0000:05
    50000000-5fffffff : 0000:05:00.0
    60000000-61ffffff : 0000:05:00.0
    62000000-62ffffff : 0000:05:00.0
    63000000-63003fff : 0000:05:00.1
      63000000-63003fff : ICH HD audio
  64000000-680fffff : PCI Bus 0000:0a
    64000000-67ffffff : 0000:0a:00.0
    68000000-6803ffff : 0000:0a:00.0
  68100000-681fffff : PCI Bus 0000:02
    68100000-6810ffff : 0000:02:00.0
      68100000-6810ffff : mpt
    68110000-68113fff : 0000:02:00.0
      68110000-68113fff : mpt
  68200000-682fffff : PCI Bus 0000:01
    68200000-6821ffff : 0000:01:00.1
      68200000-6821ffff : igb
    68220000-6823ffff : 0000:01:00.1
      68220000-6823ffff : igb
    68240000-6825ffff : 0000:01:00.0
      68240000-6825ffff : igb
    68260000-6827ffff : 0000:01:00.0
      68260000-6827ffff : igb
    68280000-68283fff : 0000:01:00.1
      68280000-68283fff : igb
    68284000-68287fff : 0000:01:00.0
      68284000-68287fff : igb
  68300000-68303fff : 0000:00:16.0
  68304000-68307fff : 0000:00:16.1
  68308000-6830bfff : 0000:00:16.2
  6830c000-6830ffff : 0000:00:16.3
  68310000-68313fff : 0000:00:16.4
  68314000-68317fff : 0000:00:16.5
  68318000-6831bfff : 0000:00:16.6
  6831c000-6831ffff : 0000:00:16.7
  68320000-68320fff : 0000:00:13.0
  68321000-683213ff : 0000:00:1d.7
    68321000-683213ff : ehci_hcd
  68321400-683217ff : 0000:00:1a.7
    68321400-683217ff : ehci_hcd
  68321800-683218ff : 0000:00:1f.3
80000000-9fffffff : PCI Bus 0000:40
  80000000-9fffffff : PCI Bus 0000:40 (<-----------------pci root bus 0000:40 resource is not released)
fea00000-fea0001f : pnp 00:06
fed1b000-fed1bfff : pnp 00:06
fed1c000-fed8bffe : pnp 00:06
  fed1f410-fed1f414 : iTCO_wdt
fee00000-feefffff : pnp 00:06
ff000000-ffffffff : pnp 00:06
[.....snip....]
20fa516000-20fbffffff : System RAM
20fc000000-20ffffffff : reserved
1fffffc000000-1fffffc33dcf7 : PCI Bus 0000:00 I/O Ports 00000000-00000cf7
1fffffc400000-1fffffe3fffff : PCI Bus 0000:00 I/O Ports 00001000-00008fff
1fffffe400000-1fffffffffffe : PCI Bus 0000:40 I/O Ports 00009000-0000fffe
  1fffffe400000-1fffffffffffe : PCI Bus 0000:40 I/O Ports 00009000-0000fffe (<--------------io port map resource is not released)

3. hot add pci root bus 0000:40
linux-ha2:~ # echo "\_SB_.NOD1.PCI1 1" > /sys/kernel/debug/acpi/sci_notify
linux-ha2:~ # dmesg
ACPI: ACPI device name is <\_SB_.NOD1.PCI1>, event code is <1>
ACPI: Notify event is queued
ACPI: \_SB_.NOD1.PCI1: Device check notify on _handle_hotplug_event_root
ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 40-7f])
acpi PNP0A08:02: Requesting ACPI _OSC control (0x1d)
acpi PNP0A08:02: ACPI _OSC control (0x1d) granted
acpi PNP0A08:02: host bridge window [io  0x9000-0xfffe]
acpi PNP0A08:02: host bridge window [mem 0x80000000-0x9fffffff]
PCI host bridge to bus 0000:40
pci_bus 0000:40: root bus resource [bus 40-7f]
[......snip.......]
pc 0000:40:16.5: [8086:342a] type 00 class 0x088000
pci 0000:40:16.5: reg 10: [mem 0x80314000-0x80317fff 64bit]
pci 0000:40:16.6: [8086:342b] type 00 class 0x088000
pci 0000:40:16.6: reg 10: [mem 0x80318000-0x8031bfff 64bit]
pci 0000:40:16.7: [8086:342c] type 00 class 0x088000
pci 0000:40:16.7: reg 10: [mem 0x8031c000-0x8031ffff 64bit]  (------------------------------conflict resource found bellow---------)
pci 0000:40:13.0: address space collision: [mem 0x80320000-0x80320fff] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]  
pci 0000:40:16.0: address space collision: [mem 0x80300000-0x80303fff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:16.1: address space collision: [mem 0x80304000-0x80307fff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:16.2: address space collision: [mem 0x80308000-0x8030bfff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:16.3: address space collision: [mem 0x8030c000-0x8030ffff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:16.4: address space collision: [mem 0x80310000-0x80313fff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:16.5: address space collision: [mem 0x80314000-0x80317fff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:16.6: address space collision: [mem 0x80318000-0x8031bfff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:16.7: address space collision: [mem 0x8031c000-0x8031ffff 64bit] conflicts with PCI Bus 0000:40 [mem 0x80000000-0x9fffffff]
pci 0000:40:00.0: PCI bridge to [bus 41]
pci 0000:42:00.0: [8086:10c9] type 00 class 0x020000
pci 0000:40:07.0: res[8]=[mem 0x00100000-0x001fffff] get_res_add_size add_size 200000
[......snip.......]
pci 0000:40:07.0: res[9]=[mem 0x00100000-0x001fffff pref] get_res_add_size add_size 200000
pci 0000:40:03.0: BAR 9: can't assign mem pref (size 0x400000)
pci 0000:40:01.0: BAR 8: can't assign mem (size 0x100000)
pci 0000:40:01.0: BAR 9: can't assign mem pref (size 0x100000)
pci 0000:40:03.0: BAR 8: can't assign mem (size 0x300000)
pci 0000:40:04.0: BAR 8: can't assign mem (size 0x200000)
pci 0000:40:04.0: BAR 9: can't assign mem pref (size 0x200000)
pci 0000:40:05.0: BAR 8: can't assign mem (size 0x200000)
pci 0000:40:05.0: BAR 9: can't assign mem pref (size 0x200000)
pci 0000:40:07.0: BAR 8: can't assign mem (size 0x300000)
pci 0000:40:07.0: BAR 9: can't assign mem pref (size 0x300000)
pci 0000:40:16.0: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.1: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.2: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.3: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.4: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.5: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.6: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.7: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:01.0: BAR 7: can't assign io (size 0x1000)
pci 0000:40:03.0: BAR 7: can't assign io (size 0x2000)
pci 0000:40:04.0: BAR 7: can't assign io (size 0x1000)
pci 0000:40:05.0: BAR 7: can't assign io (size 0x1000)
pci 0000:40:07.0: BAR 7: can't assign io (size 0x2000)
pci 0000:40:03.0: BAR 9: can't assign mem pref (size 0x200000)
pci 0000:40:01.0: BAR 8: can't assign mem (size 0x100000)
pci 0000:40:01.0: BAR 9: can't assign mem pref (size 0x100000)
pci 0000:40:03.0: BAR 8: can't assign mem (size 0x100000)
pci 0000:40:07.0: BAR 8: can't assign mem (size 0x100000)
pci 0000:40:07.0: BAR 9: can't assign mem pref (size 0x100000)
pci 0000:40:16.0: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.1: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.2: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.3: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.4: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.5: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.6: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:16.7: BAR 0: can't assign mem (size 0x4000)
pci 0000:40:01.0: BAR 7: can't assign io (size 0x1000)
pci 0000:40:03.0: BAR 7: can't assign io (size 0x2000)
pci 0000:40:04.0: BAR 7: can't assign io (size 0x1000)
pci 0000:40:05.0: BAR 7: can't assign io (size 0x1000)
pci 0000:40:07.0: BAR 7: can't assign io (size 0x2000)
pci 0000:40:05.0: BAR 8: can't assign mem (size 0x200000)
pci 0000:40:05.0: BAR 9: can't assign mem pref (size 0x200000)
pci 0000:40:04.0: BAR 8: can't assign mem (size 0x200000)
pci 0000:40:04.0: BAR 9: can't assign mem pref (size 0x200000)
pci 0000:40:00.0: PCI bridge to [bus 41]
pci 0000:42:00.0: BAR 6: can't assign mem pref (size 0x20000)
pci 0000:42:00.1: BAR 6: can't assign mem pref (size 0x20000)
pci 0000:40:01.0: PCI bridge to [bus 42]
pci 0000:43:00.0: BAR 6: can't assign mem pref (size 0x200000)
pci 0000:40:03.0: PCI bridge to [bus 43]
pci 0000:40:04.0: PCI bridge to [bus 44]
pci 0000:40:05.0: PCI bridge to [bus 45]
pci 0000:46:00.0: BAR 6: can't assign mem pref (size 0x20000)
pci 0000:46:00.1: BAR 6: can't assign mem pref (size 0x20000)
pci 0000:40:07.0: PCI bridge to [bus 46]


Jiang Liu (1):
  PCI/IA64: fix memleak for create pci root bus fail

Yijing Wang (7):
  PCI/IA64: SN: remove sn_pci_window_fixup()
  PCI/IA64: SN: use normal resource instead of pci_window
  PCI/IA64: embed pci hostbridge resources into pci_root_info
  PCI/IA64: Allocate pci_root_info instead of using stack
  PCI/IA64: add host bridge resource release for _CRS path
  PCI/IA64: introduce probe_pci_root_info() to manage  _CRS resource
  PCI: Replace printks with appropriate pr_*()

 arch/ia64/include/asm/pci.h   |   10 +-
 arch/ia64/pci/pci.c           |  236 ++++++++++++++++++++++++++++-------------
 arch/ia64/sn/kernel/io_init.c |  109 +++++--------------
 3 files changed, 192 insertions(+), 163 deletions(-)


