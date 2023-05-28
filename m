From: Song Liu <song@kernel.org>
Date: Sun, 28 May 2023 22:46:12 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <CAPhsuW5VdZiLwAax1Ax3OVD=Kp2y2i-U9Ap3LS3jY6jz59Nawg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On Sun, May 28, 2023 at 1:10 AM Frank Scheiner <frank.scheiner@web.de> wrote:
>
> Hi again,
>
> On 28.05.23 09:30, Frank Scheiner wrote:
> > [...]
> > Thanks, that patch (as -patch4 on top of v6.4-rc3) fixes the boot
> > regression for me on the rx2620:
> >
> > [...]
> >
> > Great! I'll give it a try on my rx2800-i2, too, but assume it wil work
> > there, too.
>
> Indeed, -patch4 also makes it work on the rx2800-i2:

Thanks for running the test!

I will send the official patch.

Thanks,
Song

>
> ```
> ELILO v3.16 for EFI/IA-64
> ..
> Uncompressing Linux... done
> Loading file AC10027B.initrd.img...done
> [    0.000000] Linux version
> 6.4.0-rc3-44c026a73be8038f03dbdeef028b642880cf1511-patch4 (root@x4270)
> (ia64-linux-gcc (GCC) 12.2.0, GNU ld (GNU Binutils) 2.39) #1 SMP Sun May
> 28 09:08:44 CEST 2023
> [    0.000000] efi: EFI v2.1 by HP
> [    0.000000] efi: SALsystab=0xdfdd63a18 ESI=0xdfdd63f18 ACPI
> 2.0=0x3d3c4014 HCDP=0xdffff8798 SMBIOS=0x3d368000
> [    0.000000] PCDP: v3 at 0xdffff8798
> [    0.000000] earlycon: uart8250 at I/O port 0x4000 (options '115200n8')
> [    0.000000] printk: bootconsole [uart8250] enabled
> [    0.000000] ACPI: Early table checksum verification disabled
> [    0.000000] ACPI: RSDP 0x000000003D3C4014 000024 (v02 HP    )
> [    0.000000] ACPI: XSDT 0x000000003D3C4580 000124 (v01 HP     RX2800-2
> 00000001      01000013)
> [...]
> [   36.649531] Run /init as init process
> Loading, please wait...
> Starting systemd-udevd version 252.6-1
> [   36.865635] pps_core: LinuxPPS API ver. 1 registered
> [   36.869321] pps_core: Software ver. 5.3.6 - Copyright 2005-2007
> Rodolfo Giometti <giometti@linux.it>
> [   36.885025] PTP clock support registered
> [   36.910852] ACPI: bus type USB registered
> [   36.918198] usbcore: registered new interface driver usbfs
> [   36.924762] usbcore: registered new interface driver hub
> [   36.922133] igb: Intel(R) Gigabit Ethernet Network Driver
> [   36.931386] usbcore: registered new device driver usb
> [   36.938149] igb: Copyright (c) 2007-2014 Intel Corporation.
> [...]
> [  OK  ] Finished apt-daily-upgrade… apt upgrade and clean activities.
>
> Debian GNU/Linux 12 rx2800-i2 -
>
> rx2800-i2 login:
> ```
>
> I'll try to test this on other machines (rx4640 w/Madison, rx2660
> w/Montecito/Montvale, rx6600 w/Montvale) as well, starting on Tuesday if
> possible.
>
> ****
>
> There is an issue - only for the rx2800-i2 - seemingly related to it's
> PCIe NIC(s) and MSIs, but this is already there in 6.3.x (see first part
> of [1]) and **not related to the problem of this thread (AFAICT)** and -
> more important - doesn't affect operation: The machine is working
> diskless using one of those interfaces so it can't be that bad. I'll
> look into bisecting that issue as well.
>
> [1]: https://lists.debian.org/debian-ia64/2023/05/msg00010.html
>
> Cheers,
> Frank
