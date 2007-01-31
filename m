From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Wed, 31 Jan 2007 03:49:52 +0000
Subject: Re: [Fastboot] [PATCH] kexec: Avoid migration of already disabled irqs (ia64)
Message-Id: <aec7e5c30701301949g35355525qe50f5cb50fbef9a2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45C005C1.5010606@sgi.com>
In-Reply-To: <45C005C1.5010606@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On 1/31/07, Jay Lan <jlan@sgi.com> wrote:
> Magnus Damm wrote:
> > kexec: Avoid migration of already disabled irqs (ia64)
> >
> > This patch fixes up ia64 kexec support for HP rx2620 hardware. It does =
this
> > by skipping migration of already disabled irqs. This is most likely a p=
roblem
> > on other ia64 platforms as well, but I've only tested this on one machi=
ne
> > so far.
>
> I have not seen this problem on SN systems.

Ok, thanks. Let me give you more details.

When I perform "kexec -e" the following output appears on my serial
console (with my patch applied).

ACPI: PCI interrupt for device 0000:20:02.1 disabled
GSI 30 (level, low) -> CPU 1 (0x0200) vector 53 unregistered
ACPI: PCI interrupt for device 0000:20:02.0 disabled
GSI 29 (level, low) -> CPU 0 (0x0000) vector 52 unregistered
Starting new kernel
CPU 1 is now offline
CPU 2 is now offline
CPU 3 is now offline
Linux version 2.6.20-rc6 (damm@localhost) (gcc version 3.4.5) #1 SMP
Tue Jan 30 16:59:54 JST 2007

Without the patch the kernel tries to migrate already disabled
interrupts which results in this:

ACPI: PCI interrupt for device 0000:20:02.1 disabled
GSI 30 (level, low) -> CPU 1 (0x0200) vector 53 unregistered
ACPI: PCI interrupt for device 0000:20:02.0 disabled
GSI 29 (level, low) -> CPU 0 (0x0000) vector 52 unregistered
Starting new kernel
BUG: at arch/ia64/kernel/irq.c:155 migrate_irqs()

Call Trace:
 [<a000000100012e10>] show_stack+0x50/0xa0
                                sp=E0000040fb7f7b20 bsp=E0000040fb7f0d60
 [<a000000100012e90>] dump_stack+0x30/0x60
                                sp=E0000040fb7f7cf0 bsp=E0000040fb7f0d48
 [<a000000100011610>] fixup_irqs+0x490/0x680
                                sp=E0000040fb7f7cf0 bsp=E0000040fb7f0d08
 [<a000000100055300>] __cpu_disable+0x5c0/0x660
                                sp=E0000040fb7f7d80 bsp=E0000040fb7f0cb8
 [<a0000001000d21c0>] take_cpu_down+0x20/0x80
                                sp=E0000040fb7f7dc0 bsp=E0000040fb7f0ca0
 [<a0000001000dcd90>] do_stop+0x250/0x360
                                sp=E0000040fb7f7dc0 bsp=E0000040fb7f0c60
 [<a0000001000bf9b0>] kthread+0x230/0x2a0
                                sp=E0000040fb7f7dd0 bsp=E0000040fb7f0c20
 [<a000000100015290>] kernel_thread_helper+0xd0/0x100
                                sp=E0000040fb7f7e30 bsp=E0000040fb7f0bf0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E0000040fb7f7e30 bsp=E0000040fb7f0bf0
irq 53, desc: a0000001007d1080, depth: 0, count: 3, unhandled: 0
->handle_irq():  0000000000000000, 0x0
->chip(): a000000100831fa8, no_irq_chip+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0x35 on CPU 1!
CPU 1 is now offline
...
(more or less same thing on CPU2 and CPU3 as well)

This is how my /proc/interrupts look:

/ # cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3
 28:          1          1          1          1          LSAPIC  cpe_poll
 29:          0          0          0          0          LSAPIC  cmc_poll
 31:          0          0          0          0          LSAPIC  cmc_hndlr
 48:          0          0          0          0  IO-SAPIC-level  acpi
 49:          0         52          0          0  IO-SAPIC-level  serial
 52:        104          0          0          0  IO-SAPIC-level  eth0
232:          0          0          0          0          LSAPIC  mca_rdzv
238:          0          0          0          0          LSAPIC  perfmon
239:       7027       6979       7055       6916          LSAPIC  timer
240:          0          0          0          0          LSAPIC  mca_wkup
253:        145        106        766        689          LSAPIC  resched
254:         21         50         51         34          LSAPIC  IPI
ERR:          0

Are IOSAPIC interrupts routed to multiples CPUs in your case?
Do you get any "ACPI: PCI interrupt for device nnn disabled" messages?

Thanks!

/ magnus
