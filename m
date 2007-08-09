From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Aug 2007 18:04:32 +0000
Subject: RE: need NOTES in vmlinux.lds.S
Message-Id: <617E1C2C70743745A92448908E030B2A022138B5@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
In-Reply-To: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> Sure, that sounds reasonable.  Updated patch attached.
>=20
> I tried this patch with Linus' 2.6.23-rc2 tree and the resulting
> kernel boots fine, though there are some scary-looking error messages:

These come from some debug code added by Thomas ... adding him to
this thread so he can see the trace that his code generated ...

WARNING: at /data/sc/linux-2.6/kernel/irq/resend.c:70 check_irq_resend()

Call Trace:
 [<a0000001000132e0>] show_stack+0x80/0xa0
                                sp=E00000407ff97bc0 bsp=E00000407ff90f58
 [<a000000100013330>] dump_stack+0x30/0x60
                                sp=E00000407ff97d90 bsp=E00000407ff90f40
 [<a0000001000db860>] check_irq_resend+0x1e0/0x200
                                sp=E00000407ff97d90 bsp=E00000407ff90ef8
 [<a0000001000dadd0>] enable_irq+0x210/0x240
                                sp=E00000407ff97d90 bsp=E00000407ff90ec8
 [<a0000001004f9aa0>] probe_hwif+0x440/0x1800
                                sp=E00000407ff97d90 bsp=E00000407ff90db0
 [<a0000001004fc7d0>] probe_hwif_init_with_fixup+0x30/0x180
                                sp=E00000407ff97d90 bsp=E00000407ff90d80
 [<a0000001005037c0>] ide_setup_pci_device+0x160/0x1c0
                                sp=E00000407ff97d90 bsp=E00000407ff90d40
 [<a0000001004e2670>] init_setup_cmd64x+0x30/0x60
                                sp=E00000407ff97da0 bsp=E00000407ff90d18
 [<a0000001004e25c0>] cmd64x_init_one+0x140/0x160
                                sp=E00000407ff97da0 bsp=E00000407ff90cf0
 [<a000000100933a10>] ide_scan_pcidev+0xf0/0x180
                                sp=E00000407ff97e00 bsp=E00000407ff90cb8
 [<a000000100933b20>] ide_scan_pcibus+0x80/0x2e0
                                sp=E00000407ff97e00 bsp=E00000407ff90c80
 [<a0000001009338c0>] ide_init+0xc0/0x120
                                sp=E00000407ff97e00 bsp=E00000407ff90c60
 [<a0000001009003c0>] kernel_init+0x1a0/0x6a0
                                sp=E00000407ff97e00 bsp=E00000407ff90c00
 [<a0000001000113b0>] kernel_thread_helper+0xd0/0x100
                                sp=E00000407ff97e30 bsp=E00000407ff90bd0
 [<a000000100008dc0>] start_kernel_thread+0x20/0x40
                                sp=E00000407ff97e30 bsp=E00000407ff90bd0
