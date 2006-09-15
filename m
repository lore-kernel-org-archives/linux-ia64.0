From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Fri, 15 Sep 2006 05:15:45 +0000
Subject: Re: BUG: warning at
Message-Id: <1158297344.20092.574.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 2006-09-14 at 20:24, Andreas Schwab wrote:
> Has anyone else seen this?  When shutting down 2.6.18-rc6-git3 on an Intel
> Tiger I'm always getting this BUG:
>=20
> ACPI: PCI interrupt for device 0000:01:00.0 disabled
> GSI 18 (level, low) -> CPU 5 (0xc318) vector 53 unregistered
> interrupt handlers still exist onIRQ 53
> BUG: warning at arch/ia64/kernel/iosapic.c:917/iosapic_unregister_intr()
>=20
> Call Trace:
>  [<a000000100014400>] show_stack+0x40/0xa0
>                                 sp=E0000003ff897b40 bsp=E0000003ff891360
>  [<a000000100014490>] dump_stack+0x30/0x60
>                                 sp=E0000003ff897d10 bsp=E0000003ff891348
>  [<a00000010004fac0>] iosapic_unregister_intr+0x700/0x760
>                                 sp=E0000003ff897d10 bsp=E0000003ff8912f8
>  [<a00000010000bc00>] acpi_unregister_gsi+0x20/0x40
>                                 sp=E0000003ff897d10 bsp=E0000003ff8912d8
>  [<a000000100356380>] acpi_pci_irq_disable+0x140/0x160
>                                 sp=E0000003ff897d10 bsp=E0000003ff8912a8
>  [<a00000010041d160>] pcibios_disable_device+0x20/0x40
>                                 sp=E0000003ff897d20 bsp=E0000003ff891288
>  [<a0000001002ca3f0>] pci_disable_device+0x170/0x1a0
>                                 sp=E0000003ff897d20 bsp=E0000003ff891250
>  [<a0000002046bf610>] e1000_suspend+0x870/0x8e0 [e1000]
>                                 sp=E0000003ff897d30 bsp=E0000003ff8911e8
>  [<a0000002046bf6b0>] e1000_shutdown+0x30/0x60 [e1000]
>                                 sp=E0000003ff897d30 bsp=E0000003ff8911c8
>  [<a0000001002cd8c0>] pci_device_shutdown+0x80/0xc0
>                                 sp=E0000003ff897d30 bsp=E0000003ff8911a8
>  [<a0000001003c8780>] device_shutdown+0x100/0x1c0
>                                 sp=E0000003ff897d30 bsp=E0000003ff891188
>  [<a0000001000aea40>] kernel_shutdown_prepare+0x60/0x80
>                                 sp=E0000003ff897d30 bsp=E0000003ff891168
>  [<a0000001000aea80>] kernel_power_off+0x20/0x80
>                                 sp=E0000003ff897d30 bsp=E0000003ff891150
>  [<a0000001000aef90>] sys_reboot+0x2d0/0x480
>                                 sp=E0000003ff897d30 bsp=E0000003ff8910d8
>  [<a00000010000c8c0>] ia64_ret_from_syscall+0x0/0x20
>                                 sp=E0000003ff897e30 bsp=E0000003ff8910d8
>  [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=E0000003ff898000 bsp=E0000003ff8910d8
The new e1000_suspend doesn't call e1000_free_irq to free the irq. I don't
know why e1000 developers move it to e1000_close.
