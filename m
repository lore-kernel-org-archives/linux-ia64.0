From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Fri, 18 Dec 2020 21:29:45 +0000
Subject: Re: [PATCH v2 05/15] ia64: convert to legacy_timer_tick
Message-Id: <59efce0e-a28d-9424-82ca-fb7f3a1b9c29@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
 <20201030151758.1241164-6-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-6-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Arnd Bergmann <arnd@kernel.org>, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Mike Rapoport <rppt@linux.ibm.com>, Anatoly Pugachev <matorola@gmail.com>

Hi Arnd!

On 10/30/20 4:17 PM, Arnd Bergmann wrote:
> ia64 is the only architecture that calls xtime_update() in a loop,
> once for each jiffie that has passed since the last event.
>=20
> Before commit 3171a0305d62 ("[PATCH] simplify update_times (avoid
> jiffies/jiffies_64 aliasing problem)") in 2006, it could not actually do
> this any differently, but now it seems simpler to just pass the number
> of jiffies that passed in the meantime.
>=20
> While this loses the ability process interrupts in the middle of
> the timer tick by calling local_irq_enable(), doing so is fairly
> peculiar anyway and it seems better to just do what everyone
> else does here.

This broke the hpsa block device driver on my HP RX2600.

I'm seeing this backtrace now:

[  905.883273] usb 1-2: SerialNumber: A60020000001                         =
                                                                           =
                    =20
[  905.918170]  sda: sda1 sda2 sda3                                        =
                                                                           =
                    =20
[  905.920107] sd 0:1:0:0: [sda] Attached SCSI disk                        =
                                                                           =
                    =20
[  905.944102] usb-storage 1-2:1.0: USB Mass Storage device detected       =
                                                                           =
                    =20
[  905.944102] scsi host1: usb-storage 1-2:1.0                             =
                                                                           =
                    =20
[  905.944102] usbcore: registered new interface driver usb-storage        =
                                                                           =
                    =20
[  905.944117] usbcore: registered new interface driver uas                =
                                                                           =
                    =20
[  905.948117] scsi 1:0:0:0: CD-ROM            TEAC     DV-W28EAW        H.=
0C PQ: 0 ANSI: 0                                                           =
                    =20
[  905.952013] usb 2-1: new full-speed USB device number 2 using ohci-pci  =
                                                                           =
                    =20
[  905.956102] sr 1:0:0:0: Power-on or device reset occurred               =
                                                                           =
                    =20
[  905.968107] sr 1:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer cd/rw xa/f=
orm2 cdda tray                                                             =
                    =20
[  905.968107] cdrom: Uniform CD-ROM driver Revision: 3.20                 =
                                                                           =
                    =20
[  906.028013] ioc0: LSISAS1068 B0: Capabilities=3D{Initiator}             =
                                                                           =
                      =20
[  906.028110] tg3 0000:01:02.0 eth0: Tigon3 [partno(BCM95700A6) rev 2100] =
(PCIX:66MHz:64-bit) MAC address 00:17:a4:99:2d:09                          =
                    =20
[  906.026167] usb 2-1: New USB device found, idVendor=03f0, idProduct=1126=
, bcdDevice=3D 0.01                                                        =
                      =20
[  906.028110] tg3 0000:01:02.0 eth0: attached PHY is 5704 (10/100/1000Base=
-T Ethernet) (WireSpeed[1], EEE[0])                                        =
                    =20
[  906.028110] tg3 0000:01:02.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF=
[0] TSOcap[1]                                                              =
                    =20
[  906.030214] usb 2-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumberc                                                                   =
                      =20
[  906.032240] tg3 0000:01:02.0 eth0: dma_rwctrl[769f0000] dma_mask[64-bit]=
                                                                           =
                    =20
[  906.036102] GSI 30 (level, low) -> CPU 2 (0x0200) vector 67             =
                                                                           =
                    =20
[  906.034186] usb 2-1: Product: Virtual Management Device                 =
                                                                           =
                    =20
[  906.038235] usb 2-1: Manufacturer: HP                                   =
                                                                           =
                    =20
[  906.040017] usb 2-1: SerialNumber: 0017a499dd1c                         =
                                                                           =
                    =20
[  906.056108] hid: raw HID events driver (C) Jiri Kosina                  =
                                                                           =
                    =20
[  906.080013] usbcore: registered new interface driver usbhid             =
                                                                           =
                    =20
[  906.080013] usbhid: USB HID core driver                                 =
                                                                           =
                    =20
[  906.080107] input: HP Virtual Management Device as /devices/pci0000:00/0=
000:00:02.0/usb2/2-1/2-1:1.0/0003:03F0:1126.0001/input/input2              =
                    =20
[  906.088110] hid-generic 0003:03F0:1126.0001: input,hidraw0: USB HID v1.1=
1 Keyboard [HP Virtual Management Device] on usb-0000:00:02.0-1/input0     =
                    =20
[  906.088110] input: HP Virtual Management Device as /devices/pci0000:00/0=
000:00:02.0/usb2/2-1/2-1:1.1/0003:03F0:1126.0002/input/input3              =
                    =20
[  906.092110] hid-generic 0003:03F0:1126.0002: input,hidraw1: USB HID v1.0=
1 Mouse [HP Virtual Management Device] on usb-0000:00:02.0-1/input1        =
                    =20
[  906.104104] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  906.108288] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  906.108288] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  906.152107] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  906.170926] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  906.170926] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  906.218925] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  906.222925] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  906.222925] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  906.266926] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  906.272016] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  906.272016] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  906.272107] scsi host2: ioc0: LSISAS1068 B0, FwRev=010f0000h, Ports=3D1,=
 MaxQQ1, IRQb                                                              =
                  =20
[  906.324110] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  906.330925] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  906.330925] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  906.378925] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  906.382926] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  906.382926] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  906.386926] tg3 0000:01:02.1 eth1: Tigon3 [partno(BCM95700A6) rev 2100] =
(PCIX:66MHz:64-bit) MAC address 00:17:a4:99:2d:08                          =
                    =20
[  906.386926] tg3 0000:01:02.1 eth1: attached PHY is 5704 (10/100/1000Base=
-T Ethernet) (WireSpeed[1], EEE[0])                                        =
                    =20
[  906.388016] tg3 0000:01:02.1 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF=
[0] TSOcap[1]                                                              =
                    =20
[  906.388016] tg3 0000:01:02.1 eth1: dma_rwctrl[769f0000] dma_mask[64-bit]=
                                                                           =
                    =20
[  906.396108] tg3 0000:01:02.1 enp1s2f1: renamed from eth1                =
                                                                           =
                    =20
[  906.408107] tg3 0000:01:02.0 enp1s2f0: renamed from eth0                =
                                                                           =
                    =20
Begin: Loading essential drivers ... done.                                 =
                                                                           =
                    =20
Begin: Running /scripts/init-premount ... done.                            =
                                                                           =
                    =20
Begin: Mounting root file system ... Begin: Running /scripts/local-top ... =
done.                                                                      =
                    =20
Begin: Running /scripts/local-premount ... done.                           =
                                                                           =
                    =20
Begin: Will now check root file system ... fsck from util-linux 2.36       =
                                                                           =
                    =20
[/sbin/fsck.ext4 (1) -- /dev/sda2] fsck.ext4 -a -C0 /dev/sda2              =
                                                                           =
                    =20
/dev/sda2: clean, 317994/2068416 files, 6480495/8257536 blocks             =
                                                                           =
                    =20
[  906.666923] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  906.670923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  906.670923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
done.                                                                      =
                                                                           =
                    =20
[  906.722166] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:         =
                                                                           =
                    =20
[  906.722166] rcu:     2-....: (3 ticks this GP) idle=FE6/1/0x400000000000=
0000 softirqi3/698 fqs=3D4                                                 =
                    =20
[  906.722166]  (detected by 0, ta15 jiffies, gF5, q=80)                   =
                                                                           =
                =20
[  906.722166] Task dump for CPU 2:                                        =
                                                                           =
                    =20
[  906.722166] task:modprobe        state:R  running task     stack:    0 p=
id:  162 ppid:   146 flags:0x00000002                                      =
                    =20
[  906.722166]                                                             =
                                                                           =
                    =20
[  906.722166] Call Trace:                                                 =
                                                                           =
                    =20
[  906.722166]  [<0000000000000fd6>] 0xfd6                                 =
                                                                           =
                    =20
[  906.722166]                                 sp=E000010046d27c70 bsp=E000=
010046d20e80                                                               =
                    =20
[  906.782168] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:         =
                                                                           =
                    =20
[  906.782168] rcu:     2-....: (18 ticks this GP) idle=FE6/1/0x40000000000=
00000 softirqi3/698 fqs=18                                                 =
                  =20
[  906.782168]  (detected by 0, t"157 jiffies, gF5, q=80)                  =
                                                                           =
                =20
[  906.782168] Task dump for CPU 2:                                        =
                                                                           =
                    =20
[  906.782168] task:modprobe        state:R  running task     stack:    0 p=
id:  162 ppid:   146 flags:0x00000002                                      =
                    =20
[  906.782168]                                                             =
                                                                           =
                    =20
[  906.782168] Call Trace:                                                 =
                                                                           =
                    =20
[  906.782168]  [<0000001d00000065>] 0x1d00000065                          =
                                                                           =
                    =20
[  906.782168]                                 sp=E000010046d27c70 bsp=E000=
010046d20d48                                                               =
                    =20
[  906.844107] EXT4-fs (sda2): mounted filesystem with ordered data mode. O=
pts: (null)                                                                =
                    =20
done.                                                                      =
                                                                           =
                    =20
Begin: Running /scripts/local-bottom ... done.                             =
                                                                           =
                    =20
Begin: Running /scripts/init-bottom ... done.                              =
                                                                           =
                    =20
[  906.978917] Not activating Mandatory Access Control as /sbin/tomoyo-init=
 does not exist.                                                           =
                    =20
[  907.726923] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  907.734923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  907.734923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  907.790923] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  907.802923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  907.802923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  907.860014] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  907.886923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  907.886923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  907.930923] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  907.942923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  907.942923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  907.976107] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  907.982923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  907.982923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  908.106923] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  908.110923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  908.110923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  908.256014] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  908.258922] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  908.258922] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  908.428014] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  908.434923] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  908.434923] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  908.710922] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  908.714922] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  908.714922] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  908.754922] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1    =
                      =20
[  908.758922] hpsa 0000:05:00.0: device is ready.                         =
                                                                           =
                    =20
[  908.758922] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1       =20
[  908.788106] systemd[1]: Inserted module 'autofs4'                       =
                                                                           =
                    =20
[  908.972107] systemd[1]: systemd 246.6-5 running in system mode. (+PAM +A=
UDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT =
+GNUTLS +ACL +XZ +LZ4 +ZSTD -SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCR=
E2 default-hierarchy=3Dhybrid)                                             =
                                           =20
[  908.976013] systemd[1]: Detected architecture ia64.                     =
                                                                           =
                    =20

Welcome to Debian GNU/Linux bullseye/sid!

[  909.020014] systemd[1]: Set hostname to <glendronach>.
[  909.178923] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1
[  909.182922] hpsa 0000:05:00.0: device is ready.
[  909.182922] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1
[  909.242922] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1
[  909.254922] hpsa 0000:05:00.0: device is ready.
[  909.254922] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1
[  909.322922] hpsa 0000:05:00.0: scsi 0:1:0:0: resetting logical  Direct-A=
ccess     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathCap- En- Exp=3D1
[  909.334922] hpsa 0000:05:00.0: device is ready.
[  909.334922] hpsa 0000:05:00.0: scsi 0:1:0:0: reset logical  completed su=
ccessfully Direct-Access     HP       LOGICAL VOLUME   RAID-0 SSDSmartPathC=
ap- En- Exp=3D1
[  909.360108] INFO: task systemd-sysv-ge:200 blocked for more than 127 sec=
onds.
[  909.360108]       Not tainted 5.10.0+ #130
[  909.360108] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[  909.360108] task:systemd-sysv-ge state:D stack:    0 pid:  200 ppid:   1=
89 flags:0x00000000
[  909.364108]=20
[  909.364108] Call Trace:
[  909.364423]  [<a00000010109b210>] __schedule+0x890/0x21e0
[  909.364423]                                 sp=E0000100487d7b70 bsp=E000=
0100487d1748
[  909.368423]  [<a00000010109cc00>] schedule+0xa0/0x240
[  909.368423]                                 sp=E0000100487d7b90 bsp=E000=
0100487d16e0
[  909.368558]  [<a00000010109ce70>] io_schedule+0x70/0xa0
[  909.368558]                                 sp=E0000100487d7b90 bsp=E000=
0100487d16c0
[  909.372290]  [<a00000010109e1c0>] bit_wait_io+0x20/0xe0
[  909.372290]                                 sp=E0000100487d7b90 bsp=E000=
0100487d1698
[  909.374168] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
[  909.376290]  [<a00000010109d860>] __wait_on_bit+0xc0/0x1c0
[  909.376290]                                 sp=E0000100487d7b90 bsp=E000=
0100487d1648
[  909.374168] rcu:     3-....: (2 ticks this GP) idle=19e/1/0x400000000000=
0002 softirq=1581/1581 fqs=3D2=20
[  909.374168]  (detected by 0, tV61 jiffies, g=1089, q=3D3)
[  909.376290]  [<a00000010109da80>] out_of_line_wait_on_bit+0x120/0x140
[  909.376290]                                 sp=E0000100487d7b90 bsp=E000=
0100487d1610
[  909.374168] Task dump for CPU 3:
[  909.374168] task:khungtaskd      state:R  running task

Adrian

--=20
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
