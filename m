From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Jun 2013 02:56:21 +0000
Subject: Re: [PATCH -v5 0/8] Add hostbridge resource release to support root bus hotplug in IA64
Message-Id: <51BE7AD5.5010300@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370504093-14908-1-git-send-email-wangyijing@huawei.com> <20130615002224.GA21643@google.com>
In-Reply-To: <20130615002224.GA21643@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, Tony Luck <tony.luck@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com

On 2013/6/15 8:22, Bjorn Helgaas wrote:
> On Thu, Jun 06, 2013 at 03:34:45PM +0800, Yijing Wang wrote:
>> ...
>> Jiang Liu (1):
>>   PCI/IA64: fix memleak for create pci root bus fail
>>
>> Yijing Wang (7):
>>   PCI/IA64: SN: remove sn_pci_window_fixup()
>>   PCI/IA64: SN: use normal resource instead of pci_window
>>   PCI/IA64: embed pci hostbridge resources into pci_root_info
>>   PCI/IA64: Allocate pci_root_info instead of using stack
>>   PCI/IA64: add host bridge resource release for _CRS path
>>   PCI/IA64: introduce probe_pci_root_info() to manage  _CRS resource
>>   PCI: Replace printks with appropriate pr_*()
>>
>>  arch/ia64/include/asm/pci.h   |   10 +-
>>  arch/ia64/pci/pci.c           |  236 ++++++++++++++++++++++++++++-------------
>>  arch/ia64/sn/kernel/io_init.c |  109 +++++--------------
>>  3 files changed, 192 insertions(+), 163 deletions(-)
> 
> Tony, what do you think about this?  It only touches ia64, and I
> have no way to build or test it.  So maybe you should handle this?
> 
> I haven't reviewed it, but I think it's the right general direction,
> at least.
> 
Bjorn, thanks for your comments!

Hi Tony, this series mainly to make pci root bus hotplug happy in IA64.
I cannot test the first two patch(SGI related) in my IA64 machine.
But the rest patches has been tested in my ia64 machine, and result is ok.

The following message is extracted from ia64 machine applied with this series patch.
Here, we can hotplug pci root bus by sci_notify interface happy.

linux-ha2:~ # lspci -tv
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
 |           +-0d.2  Intel Corporation Device 343c
 |           +-0d.3  Intel Corporation Device 343d
 |           +-0d.4  Intel Corporation 5520/5500/X58 Physical Layer Port 0
 |           +-0d.5  Intel Corporation 5520/5500 Physical Layer Port 1
 |           +-0d.6  Intel Corporation Device 341a
 |           +-0d.7  Intel Corporation Device 341b
 |           +-0e.0  Intel Corporation Device 341c
 |           +-0e.1  Intel Corporation Device 341d
 |           +-0e.2  Intel Corporation Device 341e
 |           +-0e.3  Intel Corporation Device 341f
 |           +-0e.4  Intel Corporation Device 3439
 |           +-0f.0  Intel Corporation Device 3424
 |           +-10.0  Intel Corporation 5520/5500/X58 Physical and Link Layer Registers Port 0
 |           +-10.1  Intel Corporation 5520/5500/X58 Routing and Protocol Layer Registers Port 0
 |           +-11.0  Intel Corporation 5520/5500 Physical and Link Layer Registers Port 1
 |           +-11.1  Intel Corporation 5520/5500 Routing & Protocol Layer Register Port 1
 |           +-13.0  Intel Corporation 5520/5500/X58 I/O Hub I/OxAPIC Interrupt Controller
 |           +-14.0  Intel Corporation 5520/5500/X58 I/O Hub System Management Registers
 |           +-14.1  Intel Corporation 5520/5500/X58 I/O Hub GPIO and Scratch Pad Registers
 |           +-14.2  Intel Corporation 5520/5500/X58 I/O Hub Control Status and RAS Registers
 |           +-14.3  Intel Corporation 5520/5500/X58 I/O Hub Throttle Registers
 |           +-15.0  Intel Corporation 5520/5500/X58 Trusted Execution Technology Registers
 |           +-16.0  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 |           +-16.1  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 |           +-16.2  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 |           +-16.3  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 |           +-16.4  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 |           +-16.5  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
 |           +-16.6  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
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
             +-0d.1  Intel Corporation Device 343b
             +-0d.2  Intel Corporation Device 343c
             +-0d.3  Intel Corporation Device 343d
             +-0d.4  Intel Corporation 5520/5500/X58 Physical Layer Port 0
             +-0d.5  Intel Corporation 5520/5500 Physical Layer Port 1
             +-0d.6  Intel Corporation Device 341a
             +-0d.7  Intel Corporation Device 341b
             +-0e.0  Intel Corporation Device 341c
             +-0e.1  Intel Corporation Device 341d
             +-0e.2  Intel Corporation Device 341e
             +-0e.3  Intel Corporation Device 341f
             +-0e.4  Intel Corporation Device 3439
             +-0f.0  Intel Corporation Device 3424
             +-10.0  Intel Corporation 5520/5500/X58 Physical and Link Layer Registers Port 0
             +-10.1  Intel Corporation 5520/5500/X58 Routing and Protocol Layer Registers Port 0
             +-11.0  Intel Corporation 5520/5500 Physical and Link Layer Registers Port 1
[......snip......]
             +-1a.1  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #5
             +-1a.2  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #6
             +-1a.7  Intel Corporation 82801JI (ICH10 Family) USB2 EHCI Controller #2
             +-1c.0-[0000:06]--
             +-1c.1-[0000:07]--
             +-1c.2-[0000:08]--
             +-1c.3-[0000:09]--
             +-1c.4-[0000:0a]----00.0  XGI Technology Inc. (eXtreme Graphics Innovation) Z11/Z11M
             +-1c.5-[0000:0b]--
             +-1d.0  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #1
             +-1d.1  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #2
             +-1d.2  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #3
             +-1d.7  Intel Corporation 82801JI (ICH10 Family) USB2 EHCI Controller #1
             +-1e.0-[0000:0c]--
             +-1f.0  Intel Corporation 82801JIB (ICH10) LPC Interface Controller
             +-1f.2  Intel Corporation 82801JI (ICH10 Family) 4 port SATA IDE Controller #1
             +-1f.3  Intel Corporation 82801JI (ICH10 Family) SMBus Controller
             \-1f.5  Intel Corporation 82801JI (ICH10 Family) 2 port SATA IDE Controller #2
linux-ha2:~ # cat /proc/iomem
00000000-00000fff : System RAM
[.....snip......]
3fbcf000-3fbf2fff : System RAM
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
  80600000-806fffff : PCI Bus 0000:42
    80600000-8061ffff : 0000:42:00.0
    80620000-8063ffff : 0000:42:00.1
  80700000-809fffff : PCI Bus 0000:46
    80700000-8071ffff : 0000:46:00.0
    80720000-8073ffff : 0000:46:00.1
  80a00000-80bfffff : PCI Bus 0000:45
  80c00000-80dfffff : PCI Bus 0000:45
  80e00000-80ffffff : PCI Bus 0000:44
  81000000-811fffff : PCI Bus 0000:44
  81200000-815fffff : PCI Bus 0000:43
    81200000-813fffff : 0000:43:00.0
fea00000-fea0001f : pnp 00:06
fed1b000-fed1bfff : pnp 00:06
fed1c000-fed8bffe : pnp 00:06
  fed1f410-fed1f414 : iTCO_wdt
fee00000-feefffff : pnp 00:06
ff000000-ffffffff : pnp 00:06
100000000-1fffffffff : System RAM
2040000000-20f96dffff : System RAM
20f96e0000-20fa365fff : System RAM
20fa366000-20fa3cbfff : reserved
[......snip......]
20fa512000-20fbffffff : System RAM
20fc000000-20ffffffff : reserved
1fffffc000000-1fffffc33dcf7 : PCI Bus 0000:00 I/O Ports 00000000-00000cf7
1fffffc400000-1fffffe3fffff : PCI Bus 0000:00 I/O Ports 00001000-00008fff
1fffffe400000-1fffffffffffe : PCI Bus 0000:40 I/O Ports 00009000-0000fffe
linux-ha2:~ # echo "\_SB_.NOD1.PCI1 3" > /sys/kernel/debug/acpi/sci_notify           <------------------hot remove pci root bus 0000:40
linux-ha2:~ # lspci -tv
-[0000:00]-+-00.0  Intel Corporation 5520/5500/X58 I/O Hub to ESI Port
           +-01.0-[0000:01]--+-00.0  Intel Corporation 82576 Gigabit Network Connection
           |                 \-00.1  Intel Corporation 82576 Gigabit Network Connection
           +-03.0-[0000:02]----00.0  LSI Logic / Symbios Logic SAS1064ET PCI-Express Fusion-MPT SAS
           +-04.0-[0000:03]--
           +-05.0-[0000:04]--
           +-07.0-[0000:05]--+-00.0  nVidia Corporation GT218 [GeForce G210]
           |                 \-00.1  nVidia Corporation High Definition Audio Controller
           +-0d.0  Intel Corporation Device 343a
           +-0d.1  Intel Corporation Device 343b
           +-0d.2  Intel Corporation Device 343c
           +-0d.3  Intel Corporation Device 343d
           +-0d.4  Intel Corporation 5520/5500/X58 Physical Layer Port 0
           +-0d.5  Intel Corporation 5520/5500 Physical Layer Port 1
           +-0d.6  Intel Corporation Device 341a
           +-0d.7  Intel Corporation Device 341b
           +-0e.0  Intel Corporation Device 341c
           +-0e.1  Intel Corporation Device 341d
           +-0e.2  Intel Corporation Device 341e
           +-0e.3  Intel Corporation Device 341f
           +-0e.4  Intel Corporation Device 3439
           +-0f.0  Intel Corporation Device 3424
           +-10.0  Intel Corporation 5520/5500/X58 Physical and Link Layer Registers Port 0
           +-10.1  Intel Corporation 5520/5500/X58 Routing and Protocol Layer Registers Port 0
           +-11.0  Intel Corporation 5520/5500 Physical and Link Layer Registers Port 1
           +-11.1  Intel Corporation 5520/5500 Routing & Protocol Layer Register Port 1
           +-13.0  Intel Corporation 5520/5500/X58 I/O Hub I/OxAPIC Interrupt Controller
           +-14.0  Intel Corporation 5520/5500/X58 I/O Hub System Management Registers
           +-14.1  Intel Corporation 5520/5500/X58 I/O Hub GPIO and Scratch Pad Registers
           +-14.2  Intel Corporation 5520/5500/X58 I/O Hub Control Status and RAS Registers
           +-14.3  Intel Corporation 5520/5500/X58 I/O Hub Throttle Registers
           +-15.0  Intel Corporation 5520/5500/X58 Trusted Execution Technology Registers
           +-16.0  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-16.1  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-16.2  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-16.3  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-16.4  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-16.5  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-16.6  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-16.7  Intel Corporation 5520/5500/X58 Chipset QuickData Technology Device
           +-1a.0  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #4
           +-1a.1  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #5
           +-1a.2  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #6
           +-1a.7  Intel Corporation 82801JI (ICH10 Family) USB2 EHCI Controller #2
           +-1c.0-[0000:06]--
           +-1c.1-[0000:07]--
           +-1c.2-[0000:08]--
           +-1c.3-[0000:09]--
           +-1c.4-[0000:0a]----00.0  XGI Technology Inc. (eXtreme Graphics Innovation) Z11/Z11M
           +-1c.5-[0000:0b]--
           +-1d.0  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #1
           +-1d.1  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #2
           +-1d.2  Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #3
           +-1d.7  Intel Corporation 82801JI (ICH10 Family) USB2 EHCI Controller #1
           +-1e.0-[0000:0c]--
           +-1f.0  Intel Corporation 82801JIB (ICH10) LPC Interface Controller
           +-1f.2  Intel Corporation 82801JI (ICH10 Family) 4 port SATA IDE Controller #1
           +-1f.3  Intel Corporation 82801JI (ICH10 Family) SMBus Controller
           \-1f.5  Intel Corporation 82801JI (ICH10 Family) 2 port SATA IDE Controller #2
linux-ha2:~ # cat /proc/iomem
00000000-00000fff : System RAM
00001000-0005ffff : System RAM
00060000-00087fff : System RAM
00088000-00096fff : System RAM
00097000-00097fff : System RAM
00098000-0009ffff : System RAM
000c0000-000fffff : reserved
[.....snip.......]
3f2db000-3fadafff : reserved
3fadb000-3fae4fff : System RAM
3fae5000-3fbcefff : reserved
3fbcf000-3fbf2fff : System RAM
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
fea00000-fea0001f : pnp 00:06
fed1b000-fed1bfff : pnp 00:06
fed1c000-fed8bffe : pnp 00:06
  fed1f410-fed1f414 : iTCO_wdt
fee00000-feefffff : pnp 00:06
ff000000-ffffffff : pnp 00:06
100000000-1fffffffff : System RAM
2040000000-20f96dffff : System RAM
20f96e0000-20fa365fff : System RAM
[....snip......]
20fa510000-20fa511fff : System RAM
20fa512000-20fbffffff : System RAM
20fc000000-20ffffffff : reserved
1fffffc000000-1fffffc33dcf7 : PCI Bus 0000:00 I/O Ports 00000000-00000cf7
1fffffc400000-1fffffe3fffff : PCI Bus 0000:00 I/O Ports 00001000-00008fff
> 
> 
> 


-- 
Thanks!
Yijing

